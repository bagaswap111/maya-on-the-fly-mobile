import 'dart:io';
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../settings/data/database/app_database.dart';
import 'export_isolate.dart';

const _uuid = Uuid();

/// Callback type for export progress/status updates
typedef ExportCallback = void Function(double progress, String status);

class ExportResult {
  final bool success;
  final String filePath;
  final String format;
  final int fileSize;
  final String? error;

  ExportResult({
    required this.success,
    required this.filePath,
    required this.format,
    required this.fileSize,
    this.error,
  });
}

class ExportService {
  Isolate? _exportIsolate;
  SendPort? _isolateSendPort;
  bool _isolateReady = false;

  /// Initialize the export isolate (lazy initialization on first use)
  Future<void> _ensureIsolate() async {
    if (_isolateReady) return;

    final receivePort = ReceivePort();
    _exportIsolate = await Isolate.spawn(exportIsolateMain, receivePort.sendPort);

    // Wait for the first message (the SendPort from the isolate)
    _isolateSendPort = await receivePort.first as SendPort?;
    _isolateReady = true;
  }

  /// Export document, optionally running in a background isolate
  Future<ExportResult> exportDocument({
    required String documentId,
    required String content,
    required String title,
    required String format,
    bool useIsolate = true,
    ExportCallback? onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) await exportDir.create(recursive: true);

    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final filename = '${safeTitle}_${_uuid.v4().substring(0, 8)}';
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    onProgress?.call(0.1, 'Preparing export...');

    // Try isolate export for compatible formats
    if (useIsolate && ['txt', 'html', 'json', 'csv'].contains(format)) {
      try {
        await _ensureIsolate();
        onProgress?.call(0.2, 'Starting background export...');
        return await _exportViaIsolate(
          content: content,
          title: title,
          format: format,
          documentId: documentId,
          exportDir: exportDir.path,
          timestamp: timestamp,
          onProgress: onProgress,
        );
      } catch (e) {
        // Fall back to main thread if isolate fails
        onProgress?.call(0.3, 'Isolate unavailable, exporting on main thread...');
      }
    }

    // Main-thread export (PDF/DOCX always use main thread for now)
    onProgress?.call(0.4, 'Exporting on main thread...');
    ExportResult result;

    switch (format) {
      case 'txt':
        result = await _exportTxt(content, exportDir.path, filename, documentId);
        break;
      case 'html':
        result = await _exportHtml(content, title, exportDir.path, filename, documentId);
        break;
      case 'pdf':
        result = await _exportPdf(content, title, exportDir.path, filename, documentId);
        break;
      case 'docx':
        result = await _exportDocx(content, title, exportDir.path, filename, documentId);
        break;
      default:
        return ExportResult(success: false, filePath: '', format: format, fileSize: 0, error: 'Unsupported format: $format');
    }

    onProgress?.call(0.9, 'Saving record...');

    if (result.success) {
      await AppDatabase.instance.db.insert('export_records', {
        'id': _uuid.v4(),
        'document_id': documentId,
        'format': format,
        'destination': result.filePath,
        'file_size': result.fileSize,
        'created_at': timestamp,
      });
    }

    onProgress?.call(1.0, 'Export complete');
    return result;
  }

  Future<ExportResult> _exportViaIsolate({
    required String content,
    required String title,
    required String format,
    required String documentId,
    required String exportDir,
    required int timestamp,
    ExportCallback? onProgress,
  }) async {
    final receivePort = ReceivePort();
    final request = ExportIsolateRequest(
      sendPortId: documentId,
      content: content,
      title: title,
      format: format,
      outputDir: exportDir,
    );

    _isolateSendPort?.send(request.toJson());

    onProgress?.call(0.6, 'Background export running...');

    // Wait for the result
    final resultData = await receivePort.first as Map<String, dynamic>;
    final result = ExportIsolateResult.fromJson(resultData);

    onProgress?.call(0.9, 'Saving record...');

    if (result.success) {
      await AppDatabase.instance.db.insert('export_records', {
        'id': _uuid.v4(),
        'document_id': documentId,
        'format': format,
        'destination': result.filePath,
        'file_size': result.fileSize,
        'created_at': timestamp,
      });
    }

    onProgress?.call(1.0, 'Export complete');
    return ExportResult(
      success: result.success,
      filePath: result.filePath,
      format: result.format,
      fileSize: result.fileSize,
      error: result.error,
    );
  }

  Future<ExportResult> _exportTxt(String content, String dir, String filename, String docId) async {
    final path = '$dir/$filename.txt';
    await File(path).writeAsString(content);
    final file = File(path);
    final size = await file.length();
    return ExportResult(success: true, filePath: path, format: 'txt', fileSize: size);
  }

  Future<ExportResult> _exportHtml(String content, String title, String dir, String filename, String docId) async {
    final html = '''
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>$title</title>
<style>
  body { font-family: system-ui, sans-serif; max-width: 800px; margin: 0 auto; padding: 2rem; line-height: 1.6; }
  pre { background: #f4f4f4; padding: 1rem; overflow-x: auto; border-radius: 4px; }
  code { background: #f4f4f4; padding: 0.2em 0.4em; border-radius: 3px; }
  img { max-width: 100%; }
  blockquote { border-left: 3px solid #ccc; margin-left: 0; padding-left: 1rem; color: #666; }
</style>
</head>
<body>
  <h1>$title</h1>
  <div>${_markdownToHtml(content)}</div>
</body>
</html>''';
    final path = '$dir/$filename.html';
    await File(path).writeAsString(html);
    final file = File(path);
    final size = await file.length();
    return ExportResult(success: true, filePath: path, format: 'html', fileSize: size);
  }

  Future<ExportResult> _exportPdf(String content, String title, String dir, String filename, String docId) async {
    final path = '$dir/$filename.pdf';
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title, style: const pw.TextStyle(fontSize: 24))),
          pw.Paragraph(text: content),
        ],
      ),
    );
    final bytes = await pdf.save();
    await File(path).writeAsBytes(bytes);
    return ExportResult(success: true, filePath: path, format: 'pdf', fileSize: bytes.length);
  }

  Future<ExportResult> _exportDocx(String content, String title, String dir, String filename, String docId) async {
    final path = '$dir/$filename.docx';
    final html = '<html><body><h1>$title</h1>${_markdownToHtml(content)}</body></html>';
    await File(path).writeAsString(html);
    final file = File(path);
    final size = await file.length();
    return ExportResult(success: true, filePath: path, format: 'docx', fileSize: size);
  }

  String _markdownToHtml(String md) {
    final buffer = StringBuffer();
    final lines = md.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('### ')) {
        buffer.writeln('<h3>${line.substring(4)}</h3>');
      } else if (line.startsWith('## ')) {
        buffer.writeln('<h2>${line.substring(3)}</h2>');
      } else if (line.startsWith('# ')) {
        buffer.writeln('<h1>${line.substring(2)}</h1>');
      } else if (line.startsWith('- ')) {
        buffer.writeln('<li>${line.substring(2)}</li>');
      } else if (line.startsWith('> ')) {
        buffer.writeln('<blockquote>${line.substring(2)}</blockquote>');
      } else if (line.startsWith('```')) {
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        buffer.writeln('<pre><code>${codeLines.join('\n').replaceAll('<', '<').replaceAll('>', '>')}</code></pre>');
      } else if (line.startsWith('|')) {
        buffer.writeln('<p>$line</p>');
      } else if (line.trim().isEmpty) {
        buffer.writeln('<br>');
      } else {
        var processed = line;
        processed = processed.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => '<strong>${m[1]}</strong>');
        processed = processed.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => '<em>${m[1]}</em>');
        processed = processed.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => '<code>${m[1]}</code>');
        processed = processed.replaceAllMapped(RegExp(r'\[(.+?)\]\((.+?)\)'), (m) => '<a href="${m[2]}">${m[1]}</a>');
        buffer.writeln('<p>$processed</p>');
      }
    }
    return buffer.toString();
  }

  /// Dispose the export isolate
  void dispose() {
    _exportIsolate?.kill();
    _exportIsolate = null;
    _isolateReady = false;
  }
}

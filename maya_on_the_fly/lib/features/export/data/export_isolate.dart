import 'dart:io';
import 'dart:isolate';
import 'dart:convert';

/// Message sent to the export isolate
class ExportIsolateRequest {
  final String sendPortId;
  final String content;
  final String title;
  final String format;
  final String outputDir;

  ExportIsolateRequest({
    required this.sendPortId,
    required this.content,
    required this.title,
    required this.format,
    required this.outputDir,
  });

  Map<String, dynamic> toJson() => {
    'sendPortId': sendPortId,
    'content': content,
    'title': title,
    'format': format,
    'outputDir': outputDir,
  };

  factory ExportIsolateRequest.fromJson(Map<String, dynamic> json) => ExportIsolateRequest(
    sendPortId: json['sendPortId'] as String,
    content: json['content'] as String,
    title: json['title'] as String,
    format: json['format'] as String,
    outputDir: json['outputDir'] as String,
  );
}

/// Result sent back from the export isolate
class ExportIsolateResult {
  final bool success;
  final String filePath;
  final String format;
  final int fileSize;
  final String? error;

  ExportIsolateResult({
    required this.success,
    required this.filePath,
    required this.format,
    required this.fileSize,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'filePath': filePath,
    'format': format,
    'fileSize': fileSize,
    'error': error,
  };

  factory ExportIsolateResult.fromJson(Map<String, dynamic> json) => ExportIsolateResult(
    success: json['success'] as bool,
    filePath: json['filePath'] as String,
    format: json['format'] as String,
    fileSize: json['fileSize'] as int,
    error: json['error'] as String?,
  );
}

/// Entry point for the export isolate
void exportIsolateMain(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message is Map<String, dynamic>) {
      final request = ExportIsolateRequest.fromJson(message);
      try {
        final result = await _performExport(request);
        sendPort.send(result.toJson());
      } catch (e) {
        sendPort.send(ExportIsolateResult(
          success: false,
          filePath: '',
          format: request.format,
          fileSize: 0,
          error: e.toString(),
        ).toJson());
      }
    }
  });
}

Future<ExportIsolateResult> _performExport(ExportIsolateRequest request) async {
  final safeTitle = request.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final filename = '${safeTitle}_$timestamp';

  switch (request.format) {
    case 'txt':
      return _exportTxt(request.content, request.outputDir, filename);
    case 'html':
      return _exportHtml(request.content, request.title, request.outputDir, filename);
    case 'json':
      return _exportJson(request.content, request.outputDir, filename);
    case 'csv':
      return _exportCsv(request.content, request.outputDir, filename);
    default:
      return ExportIsolateResult(
        success: false,
        filePath: '',
        format: request.format,
        fileSize: 0,
        error: 'Unsupported format in isolate: ${request.format}',
      );
  }
}

Future<ExportIsolateResult> _exportTxt(String content, String dir, String filename) async {
  final path = '$dir/$filename.txt';
  await File(path).writeAsString(content);
  final file = File(path);
  final size = await file.length();
  return ExportIsolateResult(success: true, filePath: path, format: 'txt', fileSize: size);
}

Future<ExportIsolateResult> _exportHtml(String content, String title, String dir, String filename) async {
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
  return ExportIsolateResult(success: true, filePath: path, format: 'html', fileSize: size);
}

Future<ExportIsolateResult> _exportJson(String content, String dir, String filename) async {
  final path = '$dir/$filename.json';
  // Try to parse as JSON, otherwise wrap as text
  String jsonContent;
  try {
    final parsed = jsonDecode(content);
    jsonContent = const JsonEncoder.withIndent('  ').convert(parsed);
  } catch (_) {
    jsonContent = jsonEncode({'content': content, 'exported_at': DateTime.now().toIso8601String()});
  }
  await File(path).writeAsString(jsonContent);
  final file = File(path);
  final size = await file.length();
  return ExportIsolateResult(success: true, filePath: path, format: 'json', fileSize: size);
}

Future<ExportIsolateResult> _exportCsv(String content, String dir, String filename) async {
  final path = '$dir/$filename.csv';
  final lines = content.split('\n');
  final csvLines = lines.map((line) {
    final cells = line.split(',');
    return cells.map((c) => '"${c.trim().replaceAll('"', '""')}"').join(',');
  }).join('\n');
  await File(path).writeAsString(csvLines);
  final file = File(path);
  final size = await file.length();
  return ExportIsolateResult(success: true, filePath: path, format: 'csv', fileSize: size);
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
      buffer.writeln('<pre><code>${codeLines.join('\n').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</code></pre>');
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
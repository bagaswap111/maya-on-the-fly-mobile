import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens.dart';
import '../../documents/data/document_service.dart';
import '../data/export_service.dart';

class ExportPage extends StatefulWidget {
  final String? docId;
  const ExportPage({super.key, this.docId});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final DocumentService _docService = DocumentService();
  final ExportService _exportService = ExportService();
  List<Map<String, dynamic>> _documents = [];
  Map<String, dynamic>? _selectedDoc;
  bool _loading = true;
  bool _exporting = false;
  ExportResult? _lastResult;

  static const _formats = [
    {'id': 'txt', 'name': 'Plain Text', 'icon': Icons.text_snippet, 'ext': '.txt'},
    {'id': 'html', 'name': 'HTML', 'icon': Icons.code, 'ext': '.html'},
    {'id': 'pdf', 'name': 'PDF', 'icon': Icons.picture_as_pdf, 'ext': '.pdf'},
    {'id': 'docx', 'name': 'DOCX (HTML)', 'icon': Icons.description, 'ext': '.docx'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final docs = await _docService.getDocuments();
    if (mounted) {
      setState(() {
        _documents = docs;
        if (widget.docId != null) {
          _selectedDoc = docs.cast<Map<String, dynamic>?>().firstWhere(
            (d) => d?['id'] == widget.docId, orElse: () => null);
        }
        _loading = false;
      });
    }
  }

  Future<void> _export(String format) async {
    if (_selectedDoc == null) return;
    setState(() => _exporting = true);

    final doc = _selectedDoc!;
    String content = doc['content'] as String? ?? '';
    if (content.isEmpty) {
      final full = await _docService.getDocument(doc['id'] as String);
      content = full?['content'] as String? ?? '';
    }

    final result = await _exportService.exportDocument(
      documentId: doc['id'] as String,
      content: content,
      title: doc['title'] as String? ?? 'Untitled',
      format: format,
    );

    if (mounted) {
      setState(() {
        _lastResult = result;
        _exporting = false;
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported as ${format.toUpperCase()}'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => Share.shareXFiles([XFile(result.filePath)]),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${result.error}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        children: [
          Text('Select Document', style: theme.textTheme.titleMedium),
          const SizedBox(height: DesignTokens.spaceSm),
          DropdownButtonFormField<String>(
            value: _selectedDoc?['id'] as String?,
            items: _documents.map((d) => DropdownMenuItem(
              value: d['id'] as String,
              child: Text(d['title'] as String? ?? 'Untitled'),
            )).toList(),
            onChanged: (id) {
              setState(() => _selectedDoc = _documents.firstWhere((d) => d['id'] == id));
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Choose a document...',
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          if (_selectedDoc != null) ...[
            Text('Export Format', style: theme.textTheme.titleMedium),
            const SizedBox(height: DesignTokens.spaceSm),
            ..._formats.map((f) => Card(
              child: ListTile(
                leading: Icon(f['icon'] as IconData, color: theme.colorScheme.primary),
                title: Text(f['name'] as String),
                subtitle: Text(f['ext'] as String),
                trailing: _exporting ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ) : const Icon(Icons.file_download_outlined),
                onTap: _exporting ? null : () => _export(f['id'] as String),
              ),
            )),
          ],
          if (_lastResult != null) ...[
            const SizedBox(height: DesignTokens.spaceLg),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last Export', style: theme.textTheme.titleSmall),
                    const SizedBox(height: DesignTokens.spaceXxs),
                    Text('Format: ${_lastResult!.format.toUpperCase()}', style: theme.textTheme.bodySmall),
                    Text('Size: ${_formatSize(_lastResult!.fileSize)}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../utils/error_handler.dart';
import '../../documents/data/document_service.dart';

class EditorPage extends StatefulWidget {
  final String? docId;
  final bool isNew;
  final bool isPreview;

  const EditorPage({
    super.key,
    this.docId,
    this.isNew = false,
    this.isPreview = false,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final DocumentService _docService = DocumentService();
  late TextEditingController _controller;
  String _title = 'Untitled';
  bool _previewMode = false;
  bool _isDirty = false;
  bool _loading = true;
  String? _docId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _previewMode = widget.isPreview;
    _docId = widget.docId;
    if (widget.isNew) {
      _createNew();
    } else if (widget.docId != null) {
      _loadDocument(widget.docId!);
    } else {
      _loading = false;
    }
    _controller.addListener(() {
      if (!_isDirty) setState(() => _isDirty = true);
    });
  }

  Future<void> _createNew() async {
    final id = await _docService.createDocument();
    if (mounted) setState(() { _docId = id; _loading = false; });
  }

  Future<void> _loadDocument(String id) async {
    final doc = await _docService.getDocument(id);
    if (mounted && doc != null) {
      setState(() {
        _docId = id;
        _title = doc['title'] as String? ?? 'Untitled';
        _controller.text = doc['content'] as String? ?? '';
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_docId == null) return;
    await _docService.saveDocument(_docId!, _controller.text);
    setState(() => _isDirty = false);
    if (mounted) {
      ErrorHandler.showSuccess(context, 'Saved');
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('Do you want to save before leaving?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Discard')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save & leave')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
        ],
      ),
    );
    if (result == true) await _save();
    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title, style: theme.textTheme.titleMedium),
          actions: [
            IconButton(
              icon: Icon(_previewMode ? Icons.edit : Icons.visibility),
              onPressed: () => setState(() => _previewMode = !_previewMode),
              tooltip: _previewMode ? 'Edit' : 'Preview',
            ),
            if (_isDirty)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _save,
                tooltip: 'Save',
              ),
          ],
        ),
        body: Column(
          children: [
            if (_isDirty)
              Container(
                width: double.infinity,
                color: theme.colorScheme.tertiaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text('Unsaved changes', style: theme.textTheme.bodySmall),
              ),
            Expanded(
              child: _previewMode
                ? Markdown(
                    data: _controller.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Start writing...',
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Text(
                    '${_controller.text.isEmpty ? 0 : _controller.text.trim().split(RegExp(r'\s+')).length} words',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text('${_controller.text.length} chars', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

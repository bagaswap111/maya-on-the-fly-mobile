import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:maya_on_the_fly/features/settings/data/database/app_database.dart';
import 'tool.dart';

const _uuid = Uuid();

class CreateDocumentTool extends Tool {
  @override final String id = 'document_create';
  @override final String name = 'Create Document';
  @override final String description = 'Create a new document with title and optional content';
  @override final String category = 'document';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'title', type: 'string', description: 'Document title', required: true),
    const ToolParameter(name: 'content', type: 'string', description: 'Initial content (Markdown)'),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final title = args['title'] as String? ?? 'Untitled';
      final content = args['content'] as String? ?? '';
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = _uuid.v4();
      final filePath = 'documents/$id.md';

      await AppDatabase.instance.db.insert('documents', {
        'id': id,
        'title': title,
        'content': content,
        'file_path': filePath,
        'created_at': now,
        'updated_at': now,
        'last_opened_at': now,
        'is_pinned': 0,
        'word_count': content.isEmpty ? 0 : content.split(RegExp(r'\s+')).length,
        'content_preview': content.length > 200 ? content.substring(0, 200) : content,
      });

      return jsonEncode({
        'success': true,
        'title': title,
        'id': id,
        'content_preview': content.length > 100 ? '${content.substring(0, 100)}...' : content,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class AppendToDocumentTool extends Tool {
  @override final String id = 'document_append';
  @override final String name = 'Append to Document';
  @override final String description = 'Append content to an existing document';
  @override final String category = 'document';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'document_id', type: 'string', description: 'Document ID', required: true),
    const ToolParameter(name: 'content', type: 'string', description: 'Content to append', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final docId = args['document_id'] as String;
      final content = args['content'] as String;
      final rows = await AppDatabase.instance.db.query('documents',
        where: 'id = ?', whereArgs: [docId]);
      if (rows.isEmpty) {
        return jsonEncode({'success': false, 'error': 'Document not found: $docId'});
      }
      final existing = rows.first['content'] as String? ?? '';
      final updated = existing + '\n' + content;
      final now = DateTime.now().millisecondsSinceEpoch;
      await AppDatabase.instance.db.update('documents', {
        'content': updated,
        'updated_at': now,
        'word_count': updated.split(RegExp(r'\s+')).length,
        'content_preview': updated.length > 200 ? updated.substring(0, 200) : updated,
      }, where: 'id = ?', whereArgs: [docId]);
      return jsonEncode({'success': true, 'appended': content.length, 'total_length': updated.length});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class UpdateDocumentTool extends Tool {
  @override final String id = 'document_update';
  @override final String name = 'Update Document';
  @override final String description = 'Replace full content of a document';
  @override final String category = 'document';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'document_id', type: 'string', description: 'Document ID', required: true),
    const ToolParameter(name: 'content', type: 'string', description: 'New content', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final docId = args['document_id'] as String;
      final content = args['content'] as String;
      final rows = await AppDatabase.instance.db.query('documents',
        where: 'id = ?', whereArgs: [docId]);
      if (rows.isEmpty) {
        return jsonEncode({'success': false, 'error': 'Document not found: $docId'});
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await AppDatabase.instance.db.update('documents', {
        'content': content,
        'updated_at': now,
        'word_count': content.split(RegExp(r'\s+')).length,
        'content_preview': content.length > 200 ? content.substring(0, 200) : content,
      }, where: 'id = ?', whereArgs: [docId]);
      return jsonEncode({'success': true, 'updated': content.length});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class GetDocumentTool extends Tool {
  @override final String id = 'document_get';
  @override final String name = 'Get Document';
  @override final String description = 'Retrieve document content by ID';
  @override final String category = 'document';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'document_id', type: 'string', description: 'Document ID', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final docId = args['document_id'] as String;
      final rows = await AppDatabase.instance.db.query('documents',
        where: 'id = ?', whereArgs: [docId]);
      if (rows.isEmpty) {
        return jsonEncode({'success': false, 'error': 'Document not found: $docId'});
      }
      return jsonEncode({'success': true, 'document': rows.first});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class ListDocumentsTool extends Tool {
  @override final String id = 'document_list';
  @override final String name = 'List Documents';
  @override final String description = 'List all documents with metadata';
  @override final String category = 'document';

  @override
  List<ToolParameter> get parameters => [];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final rows = await AppDatabase.instance.db.query('documents',
        columns: ['id', 'title', 'updated_at', 'word_count', 'is_pinned', 'content_preview'],
        orderBy: 'updated_at DESC');
      return jsonEncode({'success': true, 'documents': rows});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class DeleteDocumentTool extends Tool {
  @override final String id = 'document_delete';
  @override final String name = 'Delete Document';
  @override final String description = 'Delete a document by ID';
  @override final String category = 'document';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'document_id', type: 'string', description: 'Document ID', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final docId = args['document_id'] as String;
      final deleted = await AppDatabase.instance.db.delete('documents',
        where: 'id = ?', whereArgs: [docId]);
      return jsonEncode({'success': true, 'deleted': docId, 'rows_affected': deleted});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class SearchDocumentsTool extends Tool {
  @override final String id = 'document_search';
  @override final String name = 'Search Documents';
  @override final String description = 'Full-text search across all documents';
  @override final String category = 'document';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'query', type: 'string', description: 'Search query', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final query = args['query'] as String;
      final searchTerm = '%$query%';
      final rows = await AppDatabase.instance.db.query('documents',
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: [searchTerm, searchTerm],
        orderBy: 'updated_at DESC',
        limit: 50);
      return jsonEncode({'success': true, 'query': query, 'results': rows});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class RenameDocumentTool extends Tool {
  @override final String id = 'document_rename';
  @override final String name = 'Rename Document';
  @override final String description = 'Rename a document';
  @override final String category = 'document';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'document_id', type: 'string', description: 'Document ID', required: true),
    const ToolParameter(name: 'title', type: 'string', description: 'New title', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final docId = args['document_id'] as String;
      final title = args['title'] as String;
      final now = DateTime.now().millisecondsSinceEpoch;
      final updated = await AppDatabase.instance.db.update('documents',
        {'title': title, 'updated_at': now},
        where: 'id = ?', whereArgs: [docId]);
      if (updated == 0) {
        return jsonEncode({'success': false, 'error': 'Document not found: $docId'});
      }
      return jsonEncode({'success': true, 'renamed': docId, 'title': title});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}
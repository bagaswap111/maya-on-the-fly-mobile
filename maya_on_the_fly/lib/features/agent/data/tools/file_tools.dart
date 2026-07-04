import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'tool.dart';

class ReadFileTool extends Tool {
  @override final String id = 'file_read';
  @override final String name = 'Read File';
  @override final String description = 'Read contents of a file';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'path', type: 'string', description: 'File path', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;
      final file = File(path);
      if (!await file.exists()) {
        return jsonEncode({'success': false, 'error': 'File not found: $path'});
      }
      final content = await file.readAsString();
      final stat = await file.stat();
      return jsonEncode({
        'success': true,
        'path': path,
        'content': content,
        'size': stat.size,
        'modified': stat.modified.toIso8601String(),
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class WriteFileTool extends Tool {
  @override final String id = 'file_write';
  @override final String name = 'Write File';
  @override final String description = 'Write content to a file';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'path', type: 'string', description: 'File path', required: true),
    const ToolParameter(name: 'content', type: 'string', description: 'File content', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;
      final content = args['content'] as String;
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsString(content);
      final size = await file.length();
      return jsonEncode({'success': true, 'path': path, 'written': size});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class DeleteFileTool extends Tool {
  @override final String id = 'file_delete';
  @override final String name = 'Delete File';
  @override final String description = 'Delete a file';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'path', type: 'string', description: 'File path', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;
      final file = File(path);
      if (!await file.exists()) {
        return jsonEncode({'success': false, 'error': 'File not found: $path'});
      }
      await file.delete();
      return jsonEncode({'success': true, 'deleted': path});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class ListFilesTool extends Tool {
  @override final String id = 'file_list';
  @override final String name = 'List Files';
  @override final String description = 'List files in a directory';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'directory', type: 'string', description: 'Directory path'),
    const ToolParameter(name: 'pattern', type: 'string', description: 'Glob pattern (e.g. *.dart)'),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final dirPath = args['directory'] as String? ?? '.';
      final pattern = args['pattern'] as String?;
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        return jsonEncode({'success': false, 'error': 'Directory not found: $dirPath'});
      }
      final entities = await dir.list().toList();
      final files = <Map<String, dynamic>>[];
      for (final entity in entities) {
        final stat = await entity.stat();
        final name = p.basename(entity.path);
        if (pattern != null && !name.contains(pattern.replaceAll('*', ''))) continue;
        files.add({
          'name': name,
          'path': entity.path,
          'type': entity is File ? 'file' : 'directory',
          'size': stat.size,
          'modified': stat.modified.toIso8601String(),
        });
      }
      return jsonEncode({'success': true, 'directory': dirPath, 'files': files});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class CreateDirectoryTool extends Tool {
  @override final String id = 'file_mkdir';
  @override final String name = 'Create Directory';
  @override final String description = 'Create a directory (and parents if needed)';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'path', type: 'string', description: 'Directory path', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;
      final dir = Directory(path);
      await dir.create(recursive: true);
      return jsonEncode({'success': true, 'created': path});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class MoveFileTool extends Tool {
  @override final String id = 'file_move';
  @override final String name = 'Move File';
  @override final String description = 'Move or rename a file';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'source', type: 'string', description: 'Source path', required: true),
    const ToolParameter(name: 'destination', type: 'string', description: 'Destination path', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final source = args['source'] as String;
      final destination = args['destination'] as String;
      final file = File(source);
      if (!await file.exists()) {
        return jsonEncode({'success': false, 'error': 'Source not found: $source'});
      }
      await File(destination).parent.create(recursive: true);
      await file.rename(destination);
      return jsonEncode({'success': true, 'from': source, 'to': destination});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class CopyFileTool extends Tool {
  @override final String id = 'file_copy';
  @override final String name = 'Copy File';
  @override final String description = 'Copy a file to a new location';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'source', type: 'string', description: 'Source path', required: true),
    const ToolParameter(name: 'destination', type: 'string', description: 'Destination path', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final source = args['source'] as String;
      final destination = args['destination'] as String;
      final file = File(source);
      if (!await file.exists()) {
        return jsonEncode({'success': false, 'error': 'Source not found: $source'});
      }
      await File(destination).parent.create(recursive: true);
      await file.copy(destination);
      return jsonEncode({'success': true, 'from': source, 'to': destination});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class GetFileInfoTool extends Tool {
  @override final String id = 'file_info';
  @override final String name = 'Get File Info';
  @override final String description = 'Get metadata (size, modified date, type) for a file';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'path', type: 'string', description: 'File path', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;
      final file = File(path);
      if (!await file.exists()) {
        return jsonEncode({'success': false, 'error': 'File not found: $path', 'exists': false});
      }
      final stat = await file.stat();
      return jsonEncode({
        'success': true,
        'path': path,
        'exists': true,
        'size': stat.size,
        'modified': stat.modified.toIso8601String(),
        'accessed': stat.accessed.toIso8601String(),
        'type': stat.type == FileSystemEntityType.file ? 'file' : 'directory',
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class SearchFilesTool extends Tool {
  @override final String id = 'file_search';
  @override final String name = 'Search Files';
  @override final String description = 'Search for files by name or content pattern';
  @override final String category = 'file';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'pattern', type: 'string', description: 'Search pattern (glob or regex)', required: true),
    const ToolParameter(name: 'directory', type: 'string', description: 'Directory to search in'),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final pattern = args['pattern'] as String;
      final dirPath = args['directory'] as String? ?? '.';
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        return jsonEncode({'success': false, 'error': 'Directory not found: $dirPath'});
      }
      final matches = <Map<String, dynamic>>[];
      final regex = RegExp(pattern, caseSensitive: false);
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final name = p.basename(entity.path);
          if (regex.hasMatch(name)) {
            final stat = await entity.stat();
            matches.add({
              'path': entity.path,
              'name': name,
              'size': stat.size,
              'modified': stat.modified.toIso8601String(),
            });
          }
        }
      }
      return jsonEncode({'success': true, 'pattern': pattern, 'matches': matches});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}
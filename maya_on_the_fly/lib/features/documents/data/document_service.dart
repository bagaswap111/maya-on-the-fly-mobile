import 'package:uuid/uuid.dart';
import '../../settings/data/database/daos/document_dao.dart';

const _uuid = Uuid();

class DocumentService {
  final DocumentDao _dao = DocumentDao();

  Future<List<Map<String, dynamic>>> getDocuments() async => _dao.getAll();

  Future<Map<String, dynamic>?> getDocument(String id) async => _dao.getById(id);

  Future<String> createDocument({String? title}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _dao.insert({
      'id': id,
      'title': title ?? 'Untitled',
      'content': '',
      'file_path': 'documents/$id.md',
      'created_at': now,
      'updated_at': now,
      'last_opened_at': now,
      'is_pinned': 0,
      'word_count': 0,
      'content_preview': '',
    });
    return id;
  }

  Future<void> saveDocument(String id, String content) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final wordCount = content.trim().isEmpty ? 0 : content.trim().split(RegExp(r'\s+')).length;
    final preview = content.length > 200 ? content.substring(0, 200) : content;
    await _dao.update(id, {
      'content': content,
      'updated_at': now,
      'word_count': wordCount,
      'content_preview': preview,
    });
  }

  Future<void> deleteDocument(String id) async {
    await _dao.delete(id);
  }

  Future<void> pinDocument(String id, bool pinned) async {
    await _dao.update(id, {'is_pinned': pinned ? 1 : 0});
  }
}

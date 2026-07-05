import 'package:uuid/uuid.dart';
import '../../settings/data/database/daos/chat_dao.dart';
import '../../settings/data/database/daos/usage_dao.dart';

const _uuid = Uuid();

class ChatService {
  final ChatDao _chatDao = ChatDao();
  final UsageDao _usageDao = UsageDao();

  Future<List<Map<String, dynamic>>> getSessions() async => _chatDao.getSessions();

  Future<Map<String, dynamic>?> getSession(String id) async {
    final results = await _chatDao.getSession(id);
    return results;
  }

  Future<List<Map<String, dynamic>>> getMessages(String sessionId) async => _chatDao.getMessages(sessionId);

  Future<String> createSession({String? title, String? agentId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _chatDao.insertSession({
      'id': id,
      'title': title ?? 'New Chat',
      'agent_id': agentId ?? 'auto',
      'token_count': 0,
      'created_at': now,
      'updated_at': now,
    });
    return id;
  }

  Future<void> addMessage({
    required String sessionId,
    required String role,
    required String content,
    String? toolCalls,
    String? toolResults,
    int? tokenCount,
  }) async {
    await _chatDao.insertMessage({
      'id': _uuid.v4(),
      'session_id': sessionId,
      'role': role,
      'content': content,
      'tool_calls': toolCalls,
      'tool_results': toolResults,
      'token_count': tokenCount,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> recordUsage(Map<String, dynamic> record) async {
    await _usageDao.insertRecord(record);
  }

  Future<void> deleteSession(String id) async {
    await _chatDao.deleteSession(id);
  }
}

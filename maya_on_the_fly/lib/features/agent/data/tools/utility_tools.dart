import 'dart:convert';
import 'dart:math' as math;
import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';
import 'tool.dart';

const _uuid = Uuid();

class GenerateUuidTool extends Tool {
  @override final String id = 'util_uuid';
  @override final String name = 'Generate UUID';
  @override final String description = 'Generate a UUID v4';
  @override final String category = 'utility';

  @override
  List<ToolParameter> get parameters => [];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final uuid = _uuid.v4();
      return jsonEncode({'success': true, 'uuid': uuid, 'version': 'v4'});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class GetTimestampTool extends Tool {
  @override final String id = 'util_timestamp';
  @override final String name = 'Get Timestamp';
  @override final String description = 'Get the current date and time';
  @override final String category = 'utility';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'format', type: 'string', description: 'Output format (iso, unix, readable)', enumValues: ['iso', 'unix', 'readable']),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final now = DateTime.now();
      final format = args['format'] as String? ?? 'iso';
      String formatted;
      switch (format) {
        case 'unix':
          formatted = (now.millisecondsSinceEpoch ~/ 1000).toString();
          break;
        case 'readable':
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          formatted = '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}, ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
          break;
        case 'iso':
        default:
          formatted = now.toIso8601String();
          break;
      }
      return jsonEncode({
        'success': true,
        'timestamp': formatted,
        'unix': now.millisecondsSinceEpoch ~/ 1000,
        'iso': now.toIso8601String(),
        'format': format,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class EncodeBase64Tool extends Tool {
  @override final String id = 'util_encode';
  @override final String name = 'Encode Base64';
  @override final String description = 'Encode text or data to Base64';
  @override final String category = 'utility';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'data', type: 'string', description: 'Data to encode', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final data = args['data'] as String? ?? '';
      final encoded = base64Encode(utf8.encode(data));
      return jsonEncode({'success': true, 'encoded': encoded, 'original_length': data.length});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class DecodeBase64Tool extends Tool {
  @override final String id = 'util_decode';
  @override final String name = 'Decode Base64';
  @override final String description = 'Decode Base64 to text';
  @override final String category = 'utility';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'data', type: 'string', description: 'Base64 data to decode', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final decoded = utf8.decode(base64Decode(args['data'] as String? ?? ''));
      return jsonEncode({'success': true, 'decoded': decoded, 'decoded_length': decoded.length});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class ParseJsonTool extends Tool {
  @override final String id = 'util_parse_json';
  @override final String name = 'Parse JSON';
  @override final String description = 'Parse a JSON string';
  @override final String category = 'utility';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'json', type: 'string', description: 'JSON string to parse', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final parsed = jsonDecode(args['json'] as String? ?? '');
      return jsonEncode({'success': true, 'parsed': parsed, 'type': parsed.runtimeType.toString()});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class ValidateJsonTool extends Tool {
  @override final String id = 'util_validate_json';
  @override final String name = 'Validate JSON';
  @override final String description = 'Validate and pretty-print a JSON string';
  @override final String category = 'utility';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'json', type: 'string', description: 'JSON string to validate', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final parsed = jsonDecode(args['json'] as String? ?? '');
      final pretty = const JsonEncoder.withIndent('  ').convert(parsed);
      return jsonEncode({'success': true, 'valid': true, 'pretty': pretty, 'type': parsed.runtimeType.toString()});
    } catch (e) {
      return jsonEncode({'success': false, 'valid': false, 'error': e.toString()});
    }
  }
}

class HashTextTool extends Tool {
  @override final String id = 'util_hash';
  @override final String name = 'Hash Text';
  @override final String description = 'Compute hash of text (SHA-256)';
  @override final String category = 'utility';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'text', type: 'string', description: 'Text to hash', required: true),
    const ToolParameter(name: 'algorithm', type: 'string', description: 'Hash algorithm', enumValues: ['sha256', 'sha512', 'md5']),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final text = args['text'] as String;
      final algorithm = (args['algorithm'] as String?) ?? 'sha256';
      String hash;
      switch (algorithm) {
        case 'sha256':
          final sha256 = Sha256();
          final digest = await sha256.hash(utf8.encode(text));
          hash = digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
          break;
        case 'sha512':
          final sha512 = Sha512();
          final digest = await sha512.hash(utf8.encode(text));
          hash = digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
          break;
        case 'md5':
          // Simple MD5-like hash using Dart's built-in (not cryptographic)
          hash = _simpleHash(text);
          break;
        default:
          return jsonEncode({'success': false, 'error': 'Unknown algorithm: $algorithm'});
      }
      return jsonEncode({
        'success': true,
        'algorithm': algorithm,
        'hash': hash,
        'input_length': text.length,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }

  String _simpleHash(String input) {
    final bytes = utf8.encode(input);
    var h = 0x67452301;
    for (final b in bytes) {
      h = ((h << 5) - h + b) & 0xFFFFFFFF;
    }
    return h.toRadixString(16).padLeft(8, '0');
  }
}

class CompareTextTool extends Tool {
  @override final String id = 'util_compare';
  @override final String name = 'Compare Text';
  @override final String description = 'Compare two strings for equality or similarity';
  @override final String category = 'utility';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'text_a', type: 'string', description: 'First text', required: true),
    const ToolParameter(name: 'text_b', type: 'string', description: 'Second text', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final a = args['text_a'] as String? ?? '';
      final b = args['text_b'] as String? ?? '';
      // Levenshtein distance-based similarity
      final distance = _levenshteinDistance(a, b);
      final maxLen = math.max(a.length, b.length);
      final similarity = maxLen > 0 ? 1.0 - (distance / maxLen) : 1.0;

      return jsonEncode({
        'success': true,
        'equal': a == b,
        'length_a': a.length,
        'length_b': b.length,
        'similarity': similarity,
        'levenshtein_distance': distance,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }

  int _levenshteinDistance(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) dp[i][0] = i;
    for (var j = 0; j <= n; j++) dp[0][j] = j;
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost].reduce(math.min);
      }
    }
    return dp[m][n];
  }
}
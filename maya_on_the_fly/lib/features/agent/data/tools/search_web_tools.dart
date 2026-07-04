import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tool.dart';

class SearchWebTool extends Tool {
  @override final String id = 'search_web';
  @override final String name = 'Search Web';
  @override final String description = 'Search the internet for information (uses DuckDuckGo instant answer API)';
  @override final String category = 'search';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'query', type: 'string', description: 'Search query', required: true),
    const ToolParameter(name: 'max_results', type: 'number', description: 'Maximum results'),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final query = args['query'] as String;
      final maxResults = args['max_results'] as int? ?? 5;
      final encoded = Uri.encodeComponent(query);

      // Use DuckDuckGo Instant Answer API (no API key required)
      final uri = Uri.parse('https://api.duckduckgo.com/?q=$encoded&format=json&no_html=1&skip_disambig=1');
      final response = await http.get(uri, headers: {'User-Agent': 'MayaOnTheFly/1.0'});

      if (response.statusCode != 200) {
        return jsonEncode({'success': false, 'error': 'Search API returned status ${response.statusCode}'});
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = <Map<String, dynamic>>[];

      // Abstract text
      if (data['AbstractText'] != null && (data['AbstractText'] as String).isNotEmpty) {
        results.add({
          'title': data['AbstractSource'] ?? 'Abstract',
          'url': data['AbstractURL'] ?? '',
          'snippet': data['AbstractText'],
          'type': 'abstract',
        });
      }

      // Related topics
      final related = data['RelatedTopics'] as List? ?? [];
      for (final topic in related) {
        if (results.length >= maxResults) break;
        if (topic is Map<String, dynamic>) {
          results.add({
            'title': topic['Text']?.toString().split(' - ').first ?? 'Result',
            'url': topic['FirstURL'] ?? '',
            'snippet': topic['Text'] ?? '',
            'type': 'related',
          });
        }
      }

      return jsonEncode({'success': true, 'query': query, 'results': results, 'result_count': results.length});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class FetchUrlTool extends Tool {
  @override final String id = 'web_fetch';
  @override final String name = 'Fetch URL';
  @override final String description = 'Fetch content from a URL';
  @override final String category = 'web';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'url', type: 'string', description: 'URL to fetch', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final url = args['url'] as String;
      final uri = Uri.parse(url);
      final response = await http.get(uri, headers: {'User-Agent': 'MayaOnTheFly/1.0'});

      if (response.statusCode != 200) {
        return jsonEncode({'success': false, 'error': 'HTTP ${response.statusCode} fetching $url'});
      }

      final contentType = response.headers['content-type'] ?? 'text/plain';
      final body = response.body;
      final truncated = body.length > 10000 ? '${body.substring(0, 10000)}\n\n... [truncated, full content is ${body.length} characters]' : body;

      return jsonEncode({
        'success': true,
        'url': url,
        'content': truncated,
        'content_type': contentType,
        'status_code': response.statusCode,
        'full_length': body.length,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class FetchApiTool extends Tool {
  @override final String id = 'web_api';
  @override final String name = 'Call API';
  @override final String description = 'Make an HTTP API call';
  @override final String category = 'web';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'url', type: 'string', description: 'API endpoint URL', required: true),
    const ToolParameter(name: 'method', type: 'string', description: 'HTTP method', enumValues: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']),
    const ToolParameter(name: 'headers', type: 'object', description: 'Request headers as JSON'),
    const ToolParameter(name: 'body', type: 'object', description: 'Request body as JSON'),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final url = args['url'] as String;
      final method = (args['method'] as String? ?? 'GET').toUpperCase();
      final headers = Map<String, String>.from(args['headers'] as Map? ?? {});
      headers['User-Agent'] = 'MayaOnTheFly/1.0';

      http.Response response;
      final uri = Uri.parse(url);

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: args['body'] != null ? jsonEncode(args['body']) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: args['body'] != null ? jsonEncode(args['body']) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: args['body'] != null ? jsonEncode(args['body']) : null);
          break;
        default:
          return jsonEncode({'success': false, 'error': 'Unsupported method: $method'});
      }

      final responseBody = response.body;
      final truncated = responseBody.length > 10000
          ? '${responseBody.substring(0, 10000)}\n\n... [truncated, full response is ${responseBody.length} characters]'
          : responseBody;

      // Try to parse as JSON for structured response
      dynamic parsedBody;
      try {
        parsedBody = jsonDecode(responseBody);
      } catch (_) {
        parsedBody = truncated;
      }

      return jsonEncode({
        'success': true,
        'url': url,
        'status': response.statusCode,
        'headers': response.headers,
        'response': parsedBody,
        'response_preview': truncated,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}
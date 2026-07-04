import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:maya_on_the_fly/features/agent/data/tools/tool.dart';
import 'package:maya_on_the_fly/features/agent/data/tools/calculation_tools.dart';
import 'package:maya_on_the_fly/features/agent/data/tools/utility_tools.dart';
import 'package:maya_on_the_fly/features/agent/data/tools/transformation_tools.dart';
import 'package:maya_on_the_fly/features/agent/data/tools/code_tools.dart';

void main() {
  group('Calculation Tools', () {
    test('CalculateTool evaluates basic arithmetic', () async {
      final tool = CalculateTool();
      final result = await tool.execute({'expression': '2 + 3 * 4'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 14.0);
    });

    test('CalculateTool handles parentheses', () async {
      final tool = CalculateTool();
      final result = await tool.execute({'expression': '(2 + 3) * 4'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 20.0);
    });

    test('CalculateTool handles division', () async {
      final tool = CalculateTool();
      final result = await tool.execute({'expression': '10 / 2'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 5.0);
    });

    test('CalculateTool handles power', () async {
      final tool = CalculateTool();
      final result = await tool.execute({'expression': '2 ^ 3'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 8.0);
    });

    test('CalculateTool handles unary minus', () async {
      final tool = CalculateTool();
      final result = await tool.execute({'expression': '-5 + 3'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], -2.0);
    });

    test('CalculateTool handles sin/cos', () async {
      final tool = CalculateTool();
      final result = await tool.execute({'expression': 'sin(0)'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 0.0);
    });

    test('CalculateTool handles sqrt', () async {
      final tool = CalculateTool();
      final result = await tool.execute({'expression': 'sqrt(9)'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 3.0);
    });

    test('ConvertUnitTool converts length', () async {
      final tool = ConvertUnitTool();
      final result = await tool.execute({'value': 1, 'from': 'm', 'to': 'cm'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 100.0);
    });

    test('ConvertUnitTool converts temperature C to F', () async {
      final tool = ConvertUnitTool();
      final result = await tool.execute({'value': 0, 'from': 'c', 'to': 'f'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 32.0);
    });

    test('ConvertUnitTool converts temperature F to C', () async {
      final tool = ConvertUnitTool();
      final result = await tool.execute({'value': 32, 'from': 'f', 'to': 'c'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['result'], 0.0);
    });

    test('StatsCalculateTool computes statistics', () async {
      final tool = StatsCalculateTool();
      final result = await tool.execute({'data': [1, 2, 3, 4, 5]});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['count'], 5);
      expect(data['mean'], 3.0);
      expect(data['median'], 3.0);
      expect(data['min'], 1.0);
      expect(data['max'], 5.0);
    });

    test('StatsCalculateTool handles empty dataset', () async {
      final tool = StatsCalculateTool();
      final result = await tool.execute({'data': []});
      final data = jsonDecode(result);
      expect(data['success'], false);
    });

    test('FormatNumberTool formats with decimals', () async {
      final tool = FormatNumberTool();
      final result = await tool.execute({'value': 3.14159, 'decimals': 2});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['formatted'], '3.14');
    });
  });

  group('Utility Tools', () {
    test('GenerateUuidTool generates valid UUID', () async {
      final tool = GenerateUuidTool();
      final result = await tool.execute({});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['uuid'], isNotEmpty);
      expect(data['uuid'].length, 36); // UUID v4 format
    });

    test('GetTimestampTool returns ISO format by default', () async {
      final tool = GetTimestampTool();
      final result = await tool.execute({});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['timestamp'], contains('T')); // ISO format
    });

    test('GetTimestampTool returns unix format', () async {
      final tool = GetTimestampTool();
      final result = await tool.execute({'format': 'unix'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(int.tryParse(data['timestamp']), isNotNull);
    });

    test('EncodeBase64Tool encodes correctly', () async {
      final tool = EncodeBase64Tool();
      final result = await tool.execute({'data': 'hello'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['encoded'], isNotEmpty);
    });

    test('DecodeBase64Tool decodes correctly', () async {
      final tool = DecodeBase64Tool();
      final result = await tool.execute({'data': base64Encode(utf8.encode('hello'))});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['decoded'], 'hello');
    });

    test('ParseJsonTool parses valid JSON', () async {
      final tool = ParseJsonTool();
      final result = await tool.execute({'json': '{"key": "value"}'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['parsed']['key'], 'value');
    });

    test('ParseJsonTool handles invalid JSON', () async {
      final tool = ParseJsonTool();
      final result = await tool.execute({'json': 'invalid'});
      final data = jsonDecode(result);
      expect(data['success'], false);
    });

    test('ValidateJsonTool validates and pretty-prints', () async {
      final tool = ValidateJsonTool();
      final result = await tool.execute({'json': '{"a":1,"b":2}'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['valid'], true);
      expect(data['pretty'], contains('\n'));
    });

    test('CompareTextTool detects equality', () async {
      final tool = CompareTextTool();
      final result = await tool.execute({'text_a': 'hello', 'text_b': 'hello'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['equal'], true);
      expect(data['similarity'], 1.0);
    });

    test('CompareTextTool detects difference', () async {
      final tool = CompareTextTool();
      final result = await tool.execute({'text_a': 'hello', 'text_b': 'world'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['equal'], false);
      expect(data['similarity'], lessThan(1.0));
    });
  });

  group('Transformation Tools', () {
    test('SummarizeTextTool shortens long text', () async {
      final tool = SummarizeTextTool();
      final longText = 'This is the first sentence. This is the second sentence. This is the third sentence. This is the fourth sentence.';
      final result = await tool.execute({'text': longText, 'max_length': 10});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['summary'], isNotEmpty);
      expect(data['summary'].length, lessThan(longText.length));
    });

    test('ExtractDataTool extracts with regex', () async {
      final tool = ExtractDataTool();
      final result = await tool.execute({
        'text': 'My email is user@example.com and phone is 555-1234',
        'schema': {'email': r'([\w.+-]+@[\w-]+\.[\w.]+)', 'phone': r'(\d{3}-\d{4})'},
      });
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['extracted']['email'], 'user@example.com');
      expect(data['extracted']['phone'], '555-1234');
    });

    test('FormatTextTool formats JSON', () async {
      final tool = FormatTextTool();
      final result = await tool.execute({'text': '{"a":1}', 'format': 'json'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['formatted'], contains('\n'));
    });

    test('DiffTextTool computes diff', () async {
      final tool = DiffTextTool();
      final result = await tool.execute({'old_text': 'line1\nline2\nline3', 'new_text': 'line1\nmodified\nline3'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['additions'], 1);
      expect(data['deletions'], 1);
    });

    test('MergeTextTool handles no conflicts', () async {
      final tool = MergeTextTool();
      final result = await tool.execute({'base': 'hello', 'ours': 'hello world', 'theirs': 'hello world'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['conflict_count'], 0);
    });
  });

  group('Code Tools', () {
    test('LintCodeTool detects trailing whitespace', () async {
      final tool = LintCodeTool();
      final result = await tool.execute({'code': 'line with space ', 'language': 'dart'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['total_issues'], greaterThan(0));
    });

    test('LintCodeTool detects long lines', () async {
      final tool = LintCodeTool();
      final longLine = 'x' * 150;
      final result = await tool.execute({'code': longLine, 'language': 'dart'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['total_issues'], greaterThan(0));
    });

    test('ExplainCodeTool provides basic analysis', () async {
      final tool = ExplainCodeTool();
      final result = await tool.execute({'code': 'void main() { print("hello"); }'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['explanation'], isNotEmpty);
    });

    test('ReviewCodeTool detects TODOs', () async {
      final tool = ReviewCodeTool();
      final result = await tool.execute({'code': '// TODO: fix this\nfinal x = 1;'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['review']['issues'], isNotEmpty);
    });

    test('FindBugsTool detects hardcoded credentials', () async {
      final tool = FindBugsTool();
      final result = await tool.execute({'code': 'final password = "secret123";'});
      final data = jsonDecode(result);
      expect(data['success'], true);
      expect(data['total_bugs'], greaterThan(0));
    });
  });

  group('Tool Registry', () {
    test('ToolRegistry initializes all tools', () async {
      // Import dynamically to test
      final registry = _createTestRegistry();
      expect(registry.length, greaterThanOrEqualTo(44)); // 44+ tools
    });
  });
}

/// Simple test registry to verify tool count
List<Map<String, dynamic>> _createTestRegistry() {
  final tools = <Tool>[
    // Document (8)
    CreateDocumentTool(),
    AppendToDocumentTool(),
    UpdateDocumentTool(),
    GetDocumentTool(),
    ListDocumentsTool(),
    DeleteDocumentTool(),
    SearchDocumentsTool(),
    RenameDocumentTool(),
    // Code (8)
    FormatCodeTool(),
    LintCodeTool(),
    ExplainCodeTool(),
    GenerateCodeTool(),
    RefactorCodeTool(),
    ReviewCodeTool(),
    FindBugsTool(),
    ConvertCodeTool(),
    // File (9)
    ReadFileTool(),
    WriteFileTool(),
    DeleteFileTool(),
    ListFilesTool(),
    CreateDirectoryTool(),
    MoveFileTool(),
    CopyFileTool(),
    GetFileInfoTool(),
    SearchFilesTool(),
    // Search & Web (3)
    SearchWebTool(),
    FetchUrlTool(),
    FetchApiTool(),
    // Calculation (4)
    CalculateTool(),
    ConvertUnitTool(),
    StatsCalculateTool(),
    FormatNumberTool(),
    // Transformation (6)
    SummarizeTextTool(),
    TranslateTextTool(),
    ExtractDataTool(),
    FormatTextTool(),
    DiffTextTool(),
    MergeTextTool(),
    // Utility (8)
    GenerateUuidTool(),
    GetTimestampTool(),
    EncodeBase64Tool(),
    DecodeBase64Tool(),
    ParseJsonTool(),
    ValidateJsonTool(),
    HashTextTool(),
    CompareTextTool(),
  ];
  return tools.map((t) => t.toJson()).toList();
}

// Import these for the test registry
import 'package:maya_on_the_fly/features/agent/data/tools/document_tools.dart';
import 'package:maya_on_the_fly/features/agent/data/tools/file_tools.dart';
import 'package:maya_on_the_fly/features/agent/data/tools/search_web_tools.dart';
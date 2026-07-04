import 'tool.dart';
import 'document_tools.dart';
import 'code_tools.dart';
import 'file_tools.dart';
import 'search_web_tools.dart';
import 'calculation_tools.dart';
import 'transformation_tools.dart';
import 'utility_tools.dart';

class ToolRegistry {
  ToolRegistry._();
  static final ToolRegistry _instance = ToolRegistry._();
  static ToolRegistry get instance => _instance;

  final Map<String, Tool> _tools = {};

  ToolRegistry init() {
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
      // File (8)
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
      // Utility (7)
      GenerateUuidTool(),
      GetTimestampTool(),
      EncodeBase64Tool(),
      DecodeBase64Tool(),
      ParseJsonTool(),
      ValidateJsonTool(),
      HashTextTool(),
      CompareTextTool(),
    ];
    _tools.clear();
    for (final t in tools) {
      _tools[t.id] = t;
    }
    return this;
  }

  Tool? get(String id) => _tools[id];
  List<Tool> getAll() => _tools.values.toList();
  List<Tool> getByCategory(String category) => _tools.values.where((t) => t.category == category).toList();
  Map<String, List<Tool>> get groupedByCategory {
    final result = <String, List<Tool>>{};
    for (final t in _tools.values) {
      result.putIfAbsent(t.category, () => []).add(t);
    }
    return result;
  }

  List<Map<String, dynamic>> toJsonList() => _tools.values.map((t) => t.toJson()).toList();
}

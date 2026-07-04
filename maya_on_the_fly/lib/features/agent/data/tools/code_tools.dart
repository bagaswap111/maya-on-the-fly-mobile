import 'dart:convert';
import 'tool.dart';

class FormatCodeTool extends Tool {
  @override final String id = 'code_format';
  @override final String name = 'Format Code';
  @override final String description = 'Format source code with automatic indentation and style fixes';
  @override final String category = 'code';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'code', type: 'string', description: 'Source code', required: true),
    const ToolParameter(name: 'language', type: 'string', description: 'Programming language', enumValues: ['dart', 'python', 'javascript', 'typescript', 'java', 'go', 'rust', 'cpp', 'csharp', 'swift', 'kotlin'], required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final code = args['code'] as String;
      final language = args['language'] as String;
      // Basic formatting: normalize line endings, trim trailing whitespace
      final lines = code.split('\n');
      final formatted = lines.map((line) => line.trimRight()).join('\n');
      // Estimate original/formatted char count
      return jsonEncode({
        'success': true,
        'formatted': formatted,
        'language': language,
        'original_length': code.length,
        'formatted_length': formatted.length,
        'changes': formatted != code ? 'Trailing whitespace trimmed' : 'No changes needed',
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class LintCodeTool extends Tool {
  @override final String id = 'code_lint';
  @override final String name = 'Lint Code';
  @override final String description = 'Analyze code for errors, warnings, and style issues';
  @override final String category = 'code';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'code', type: 'string', description: 'Source code', required: true),
    const ToolParameter(name: 'language', type: 'string', description: 'Programming language', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final code = args['code'] as String;
      final lines = code.split('\n');
      final issues = <Map<String, dynamic>>[];
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Check for trailing whitespace
        if (line.isNotEmpty && line.endsWith(' ')) {
          issues.add({'line': i + 1, 'column': line.length, 'severity': 'warning', 'message': 'Trailing whitespace', 'code': 'W001'});
        }
        // Check for long lines
        if (line.length > 120) {
          issues.add({'line': i + 1, 'column': 120, 'severity': 'warning', 'message': 'Line exceeds 120 characters', 'code': 'W002'});
        }
        // Check for tabs
        if (line.contains('\t')) {
          issues.add({'line': i + 1, 'column': 1, 'severity': 'info', 'message': 'Uses tabs instead of spaces', 'code': 'I001'});
        }
        // Check for missing newline at EOF
        if (i == lines.length - 1 && line.isNotEmpty) {
          issues.add({'line': i + 1, 'column': line.length, 'severity': 'info', 'message': 'No newline at end of file', 'code': 'I002'});
        }
      }
      return jsonEncode({
        'success': true,
        'issues': issues,
        'severity': issues.where((i) => i['severity'] == 'error').isEmpty ? 'clean' : 'issues_found',
        'total_issues': issues.length,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class ExplainCodeTool extends Tool {
  @override final String id = 'code_explain';
  @override final String name = 'Explain Code';
  @override final String description = 'Explain what a piece of code does in plain language';
  @override final String category = 'code';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'code', type: 'string', description: 'Source code to explain', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final code = args['code'] as String;
      final lines = code.split('\n');
      final lineCount = lines.length;
      final charCount = code.length;
      // Extract simple structural hints
      final hasFunctions = code.contains(RegExp(r'(function|def|void|int|String|Future)\s+\w+\s*\('));
      final hasClasses = code.contains(RegExp(r'(class|interface|mixin|enum)\s+\w+'));
      final hasImports = code.contains(RegExp(r'(import|include|require|using)\s'));
      final hasLoops = code.contains(RegExp(r'(for|while|do)\s*\('));
      final hasConditionals = code.contains(RegExp(r'(if|switch|case|else)\s'));

      final parts = <String>[];
      parts.add('This code contains $lineCount lines and $charCount characters.');
      if (hasImports) parts.add('It imports external dependencies.');
      if (hasClasses) parts.add('It defines classes or interfaces.');
      if (hasFunctions) parts.add('It contains function/method definitions.');
      if (hasLoops) parts.add('It uses loops for iteration.');
      if (hasConditionals) parts.add('It has conditional logic (if/else).');

      return jsonEncode({
        'success': true,
        'explanation': parts.join(' '),
        'line_count': lineCount,
        'char_count': charCount,
        'has_functions': hasFunctions,
        'has_classes': hasClasses,
        'has_imports': hasImports,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class GenerateCodeTool extends Tool {
  @override final String id = 'code_generate';
  @override final String name = 'Generate Code';
  @override final String description = 'Generate source code from a description';
  @override final String category = 'code';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'description', type: 'string', description: 'What the code should do', required: true),
    const ToolParameter(name: 'language', type: 'string', description: 'Target language', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final description = args['description'] as String;
      final language = args['language'] as String;
      // Generate a skeleton based on the description
      final comment = _languageComment(language);
      return jsonEncode({
        'success': true,
        'code': '$comment Generated code for: $description\n$comment Language: $language\n$comment This is a skeleton — full generation requires LLM integration.\n',
        'language': language,
        'description': description,
        'note': 'Full code generation requires LLM model integration for best results.',
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }

  String _languageComment(String lang) {
    switch (lang) {
      case 'python': return '#';
      case 'javascript':
      case 'typescript':
      case 'java':
      case 'go':
      case 'rust':
      case 'cpp':
      case 'csharp':
      case 'swift':
      case 'kotlin':
      case 'dart': return '//';
      default: return '#';
    }
  }
}

class RefactorCodeTool extends Tool {
  @override final String id = 'code_refactor';
  @override final String name = 'Refactor Code';
  @override final String description = 'Suggest and apply code refactorings';
  @override final String category = 'code';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'code', type: 'string', description: 'Source code', required: true),
    const ToolParameter(name: 'goal', type: 'string', description: 'Refactoring goal (e.g. extract method, rename)', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final code = args['code'] as String;
      final goal = args['goal'] as String;
      final lines = code.split('\n');
      final suggestions = <String>[];
      if (goal.contains('extract') || goal.contains('method') || goal.contains('function')) {
        suggestions.add('Consider extracting repeated code blocks (${_findDuplicates(code)} potential duplicates found)');
        suggestions.add('Look for code blocks >10 lines that could be extracted');
      }
      if (goal.contains('rename')) {
        suggestions.add('Check for unclear variable names (single-letter, abbreviations)');
        suggestions.add('Use consistent naming conventions (camelCase, snake_case)');
      }
      if (lines.length > 100) suggestions.add('Consider splitting into smaller files/modules');
      if (suggestions.isEmpty) suggestions.add('Code appears clean based on basic analysis. LLM-based refactoring would provide deeper insights.');

      return jsonEncode({
        'success': true,
        'code': code,
        'goal': goal,
        'changes': suggestions,
        'suggestion_count': suggestions.length,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }

  int _findDuplicates(String code) {
    final lines = code.split('\n');
    var count = 0;
    final seen = <String>{};
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.length > 20 && seen.contains(trimmed)) count++;
      seen.add(trimmed);
    }
    return count;
  }
}

class ReviewCodeTool extends Tool {
  @override final String id = 'code_review';
  @override final String name = 'Review Code';
  @override final String description = 'Perform a code review with suggestions';
  @override final String category = 'code';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'code', type: 'string', description: 'Source code to review', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final code = args['code'] as String;
      final lines = code.split('\n');
      final issues = <Map<String, dynamic>>[];
      var summary = '';

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('TODO')) {
          issues.add({'line': i + 1, 'type': 'info', 'message': 'Contains TODO comment', 'severity': 'info'});
        }
        if (line.contains('FIXME')) {
          issues.add({'line': i + 1, 'type': 'warning', 'message': 'Contains FIXME — unresolved issue', 'severity': 'warning'});
        }
        if (line.contains('print(') || line.contains('console.log')) {
          issues.add({'line': i + 1, 'type': 'warning', 'message': 'Contains debug print statement', 'severity': 'warning'});
        }
        if (line.contains('password') || line.contains('secret') || line.contains('api_key')) {
          issues.add({'line': i + 1, 'type': 'security', 'message': 'Potential hardcoded credential', 'severity': 'error'});
        }
      }

      if (issues.isEmpty) {
        summary = 'No issues found in basic scan.';
      } else {
        final errors = issues.where((i) => i['severity'] == 'error').length;
        final warnings = issues.where((i) => i['severity'] == 'warning').length;
        summary = 'Found $errors errors, $warnings warnings, and ${issues.length - errors - warnings} info items.';
      }

      return jsonEncode({
        'success': true,
        'review': {
          'summary': summary,
          'issues': issues,
          'suggestions': [
            'Consider adding error handling for edge cases',
            'Add documentation for public APIs',
            'Use descriptive variable names',
          ],
        },
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class FindBugsTool extends Tool {
  @override final String id = 'code_find_bugs';
  @override final String name = 'Find Bugs';
  @override final String description = 'Identify potential bugs and vulnerabilities in code';
  @override final String category = 'code';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'code', type: 'string', description: 'Source code to analyze', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final code = args['code'] as String;
      if (code.isEmpty) {
        return jsonEncode({'success': true, 'bugs': [], 'total_bugs': 0});
      }
      final lines = code.split('\n');
      final bugs = <Map<String, dynamic>>[];

      // Regex for hardcoded credentials
      final credentialRegex = RegExp('(password|secret|token|apikey)\\s*[:=]\\s*["\']', caseSensitive: false);

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Null safety check
        if (line.contains('.') && line.contains('null')) {
          bugs.add({'line': i + 1, 'type': 'null_safety', 'message': 'Potential null dereference', 'severity': 'high'});
        }
        // Infinite loops
        if (line.contains('while(true)') || line.contains('while (true)') || line.contains('for(;;)')) {
          bugs.add({'line': i + 1, 'type': 'infinite_loop', 'message': 'Potential infinite loop without break condition', 'severity': 'high'});
        }
        // Hardcoded credentials
        if (credentialRegex.hasMatch(line)) {
          bugs.add({'line': i + 1, 'type': 'security', 'message': 'Hardcoded credential detected', 'severity': 'critical'});
        }
        // Unsafe eval
        if (line.contains('eval(') || line.contains('Function(')) {
          bugs.add({'line': i + 1, 'type': 'security', 'message': 'Use of eval() — code injection risk', 'severity': 'critical'});
        }
      }

      return jsonEncode({
        'success': true,
        'bugs': bugs,
        'total_bugs': bugs.length,
        'critical_count': bugs.where((b) => b['severity'] == 'critical').length,
        'high_count': bugs.where((b) => b['severity'] == 'high').length,
        'medium_count': bugs.where((b) => b['severity'] == 'medium').length,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class ConvertCodeTool extends Tool {
  @override final String id = 'code_convert';
  @override final String name = 'Convert Code';
  @override final String description = 'Convert code from one language to another';
  @override final String category = 'code';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'code', type: 'string', description: 'Source code', required: true),
    const ToolParameter(name: 'from_language', type: 'string', description: 'Source language', required: true),
    const ToolParameter(name: 'to_language', type: 'string', description: 'Target language', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final code = args['code'] as String;
      final fromLang = args['from_language'] as String;
      final toLang = args['to_language'] as String;

      // Provide a wrapper comment showing the conversion intent
      final result = StringBuffer();
      result.writeln('// Converted from $fromLang to $toLang');
      result.writeln('// Full conversion requires LLM integration for accurate results.');
      result.writeln('// Below is the original code for reference:');
      result.writeln(code);

      return jsonEncode({
        'success': true,
        'converted': result.toString(),
        'from_language': fromLang,
        'to_language': toLang,
        'note': 'Full language conversion requires LLM model integration for best results.',
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}
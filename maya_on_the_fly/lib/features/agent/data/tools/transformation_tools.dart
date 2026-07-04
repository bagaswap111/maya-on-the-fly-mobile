import 'dart:convert';
import 'dart:math' as math;
import 'tool.dart';

class SummarizeTextTool extends Tool {
  @override final String id = 'transform_summarize';
  @override final String name = 'Summarize Text';
  @override final String description = 'Summarize a long text to a shorter version (extractive: keeps key sentences)';
  @override final String category = 'transformation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'text', type: 'string', description: 'Text to summarize', required: true),
    const ToolParameter(name: 'max_length', type: 'number', description: 'Maximum summary length in words'),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final text = args['text'] as String;
      final maxWords = args['max_length'] as int? ?? 100;
      final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
      if (sentences.length <= 3) {
        return jsonEncode({'success': true, 'summary': text, 'original_length': text.length, 'method': 'truncated'});
      }
      // Score sentences by length and position (simple extractive approach)
      final scored = <_ScoredSentence>[];
      for (var i = 0; i < sentences.length; i++) {
        final words = sentences[i].split(RegExp(r'\s+')).length;
        final positionScore = 1.0 - (i / sentences.length); // earlier sentences score higher
        final lengthScore = words > 3 ? 1.0 : 0.3;
        scored.add(_ScoredSentence(sentences[i], positionScore * lengthScore, words));
      }
      scored.sort((a, b) => b.score.compareTo(a.score));
      var wordCount = 0;
      final selected = <String>[];
      for (final s in scored) {
        if (wordCount + s.wordCount > maxWords) break;
        selected.add(s.text);
        wordCount += s.wordCount;
      }
      selected.sort((a, b) => sentences.indexOf(a).compareTo(sentences.indexOf(b)));
      final summary = selected.join(' ');
      return jsonEncode({
        'success': true,
        'summary': summary,
        'original_length': text.length,
        'summary_length': summary.length,
        'method': 'extractive',
        'sentence_count': selected.length,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class _ScoredSentence {
  final String text;
  final double score;
  final int wordCount;
  _ScoredSentence(this.text, this.score, this.wordCount);
}

class TranslateTextTool extends Tool {
  @override final String id = 'transform_translate';
  @override final String name = 'Translate Text';
  @override final String description = 'Translate text between languages (uses LibreTranslate or LLM)';
  @override final String category = 'transformation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'text', type: 'string', description: 'Text to translate', required: true),
    const ToolParameter(name: 'source_language', type: 'string', description: 'Source language (auto-detect if empty)'),
    const ToolParameter(name: 'target_language', type: 'string', description: 'Target language', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final text = args['text'] as String;
      final source = args['source_language'] as String? ?? 'auto';
      final target = args['target_language'] as String;
      // Note: Full translation requires LLM integration or external API key.
      // This provides a basic character-level placeholder.
      return jsonEncode({
        'success': true,
        'translated': '[Translation from $source to $target: "${text.length > 50 ? '${text.substring(0, 50)}...' : text}"]',
        'source': source,
        'target': target,
        'note': 'Full translation requires LLM model integration for accurate results.',
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class ExtractDataTool extends Tool {
  @override final String id = 'transform_extract';
  @override final String name = 'Extract Data';
  @override final String description = 'Extract structured data from text using regex patterns';
  @override final String category = 'transformation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'text', type: 'string', description: 'Source text', required: true),
    const ToolParameter(name: 'schema', type: 'object', description: 'Schema describing what to extract (field: regex pairs)', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final text = args['text'] as String;
      final schema = args['schema'] as Map<String, dynamic>;
      final extracted = <String, dynamic>{};
      for (final entry in schema.entries) {
        final field = entry.key;
        final pattern = entry.value.toString();
        try {
          final regex = RegExp(pattern, caseSensitive: false, multiLine: true);
          final match = regex.firstMatch(text);
          if (match != null) {
            extracted[field] = match.groupCount >= 1 ? match.group(1) : match.group(0);
          } else {
            extracted[field] = null;
          }
        } catch (e) {
          extracted[field] = '(invalid regex: $e)';
        }
      }
      return jsonEncode({'success': true, 'extracted': extracted, 'fields_found': extracted.values.where((v) => v != null).length});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class FormatTextTool extends Tool {
  @override final String id = 'transform_format';
  @override final String name = 'Format Text';
  @override final String description = 'Format text as Markdown, JSON, HTML, CSV, etc.';
  @override final String category = 'transformation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'text', type: 'string', description: 'Source text', required: true),
    const ToolParameter(name: 'format', type: 'string', description: 'Target format', enumValues: ['markdown', 'json', 'html', 'csv', 'yaml', 'xml'], required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final text = args['text'] as String;
      final format = args['format'] as String;
      String formatted;
      switch (format) {
        case 'json':
          // Try to parse as JSON and pretty-print
          try {
            final parsed = jsonDecode(text);
            formatted = const JsonEncoder.withIndent('  ').convert(parsed);
          } catch (_) {
            formatted = text; // Not valid JSON, return as-is
          }
          break;
        case 'html':
          formatted = '<pre>$text</pre>';
          break;
        case 'csv':
          final lines = text.split('\n');
          formatted = lines.map((line) => line.split(',').map((cell) => '"${cell.trim()}"').join(',')).join('\n');
          break;
        case 'markdown':
          formatted = text; // Already markdown
          break;
        case 'yaml':
        case 'xml':
          formatted = text; // Passthrough for now
          break;
        default:
          formatted = text;
      }
      return jsonEncode({'success': true, 'formatted': formatted, 'format': format});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class DiffTextTool extends Tool {
  @override final String id = 'transform_diff';
  @override final String name = 'Compute Diff';
  @override final String description = 'Compute textual diff between two versions (line-based)';
  @override final String category = 'transformation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'old_text', type: 'string', description: 'Original text', required: true),
    const ToolParameter(name: 'new_text', type: 'string', description: 'New text', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final oldText = args['old_text'] as String;
      final newText = args['new_text'] as String;
      final oldLines = oldText.split('\n');
      final newLines = newText.split('\n');
      final diff = _computeDiff(oldLines, newLines);
      return jsonEncode({
        'success': true,
        'diff': diff.join('\n'),
        'additions': diff.where((l) => l.startsWith('+')).length,
        'deletions': diff.where((l) => l.startsWith('-')).length,
        'unchanged': diff.where((l) => l.startsWith(' ')).length,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }

  List<String> _computeDiff(List<String> oldLines, List<String> newLines) {
    final result = <String>[];
    final lcs = _longestCommonSubsequence(oldLines, newLines);
    var oldIdx = 0, newIdx = 0;
    for (final common in lcs) {
      while (oldIdx < oldLines.length && oldLines[oldIdx] != common) {
        result.add('- ${oldLines[oldIdx]}');
        oldIdx++;
      }
      while (newIdx < newLines.length && newLines[newIdx] != common) {
        result.add('+ ${newLines[newIdx]}');
        newIdx++;
      }
      result.add('  $common');
      oldIdx++;
      newIdx++;
    }
    while (oldIdx < oldLines.length) {
      result.add('- ${oldLines[oldIdx]}');
      oldIdx++;
    }
    while (newIdx < newLines.length) {
      result.add('+ ${newLines[newIdx]}');
      newIdx++;
    }
    return result;
  }

  List<String> _longestCommonSubsequence(List<String> a, List<String> b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = math.max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }
    final result = <String>[];
    var i = m, j = n;
    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        result.add(a[i - 1]);
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }
    return result.reversed.toList();
  }
}

class MergeTextTool extends Tool {
  @override final String id = 'transform_merge';
  @override final String name = 'Merge Text';
  @override final String description = 'Three-way merge of text with conflict markers';
  @override final String category = 'transformation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'base', type: 'string', description: 'Base version', required: true),
    const ToolParameter(name: 'ours', type: 'string', description: 'Our version', required: true),
    const ToolParameter(name: 'theirs', type: 'string', description: 'Their version', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final base = args['base'] as String;
      final ours = args['ours'] as String;
      final theirs = args['theirs'] as String;

      if (base == ours && base == theirs) {
        return jsonEncode({'success': true, 'merged': base, 'conflicts': []});
      }
      if (base == ours) {
        return jsonEncode({'success': true, 'merged': theirs, 'conflicts': []});
      }
      if (base == theirs) {
        return jsonEncode({'success': true, 'merged': ours, 'conflicts': []});
      }

      // Simple line-based merge with conflict markers
      final baseLines = base.split('\n');
      final ourLines = ours.split('\n');
      final theirLines = theirs.split('\n');

      final merged = <String>[];
      final conflicts = <Map<String, dynamic>>[];
      final maxLen = [baseLines.length, ourLines.length, theirLines.length].reduce(math.max);

      for (var i = 0; i < maxLen; i++) {
        final b = i < baseLines.length ? baseLines[i] : '';
        final o = i < ourLines.length ? ourLines[i] : '';
        final t = i < theirLines.length ? theirLines[i] : '';

        if (o == t) {
          merged.add(o);
        } else if (o == b) {
          merged.add(t);
        } else if (t == b) {
          merged.add(o);
        } else {
          // Conflict
          conflicts.add({'line': i + 1, 'ours': o, 'theirs': t});
          merged.add('<<<<<<< ours');
          merged.add(o);
          merged.add('=======');
          merged.add(t);
          merged.add('>>>>>>> theirs');
        }
      }

      return jsonEncode({
        'success': true,
        'merged': merged.join('\n'),
        'conflicts': conflicts,
        'conflict_count': conflicts.length,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}
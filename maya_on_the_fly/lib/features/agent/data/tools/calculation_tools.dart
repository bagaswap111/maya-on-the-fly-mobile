import 'dart:convert';
import 'dart:math' as math;
import 'tool.dart';

class CalculateTool extends Tool {
  @override final String id = 'calc_evaluate';
  @override final String name = 'Evaluate Expression';
  @override final String description = 'Evaluate a mathematical expression';
  @override final String category = 'calculation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'expression', type: 'string', description: 'Mathematical expression', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final expression = args['expression'] as String;
      final result = _evaluate(expression);
      return jsonEncode({'success': true, 'expression': expression, 'result': result});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }

  double _evaluate(String expr) {
    // Simple safe expression evaluator using Dart's math
    final sanitized = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', math.pi.toString())
        .replaceAll('pi', math.pi.toString())
        .replaceAll('e', math.e.toString())
        .replaceAll(' ', '');
    // Use a simple recursive descent parser for basic arithmetic
    return _parseExpression(sanitized);
  }

  int _pos = 0;
  String _input = '';

  double _parseExpression(String input) {
    _pos = 0;
    _input = input;
    final result = _parseAddSub();
    if (_pos < _input.length) {
      throw FormatException('Unexpected character: ${_input[_pos]}');
    }
    return result;
  }

  double _parseAddSub() {
    var left = _parseMulDiv();
    while (_pos < _input.length) {
      final c = _input[_pos];
      if (c == '+') { _pos++; left += _parseMulDiv(); }
      else if (c == '-') { _pos++; left -= _parseMulDiv(); }
      else break;
    }
    return left;
  }

  double _parseMulDiv() {
    var left = _parsePower();
    while (_pos < _input.length) {
      final c = _input[_pos];
      if (c == '*') { _pos++; left *= _parsePower(); }
      else if (c == '/') {
        _pos++;
        final right = _parsePower();
        if (right == 0) throw ArgumentError('Division by zero');
        left /= right;
      }
      else break;
    }
    return left;
  }

  double _parsePower() {
    var left = _parseUnary();
    if (_pos < _input.length && _input[_pos] == '^') {
      _pos++;
      final right = _parseUnary();
      left = math.pow(left, right).toDouble();
    }
    return left;
  }

  double _parseUnary() {
    if (_pos < _input.length && _input[_pos] == '-') {
      _pos++;
      return -_parsePrimary();
    }
    if (_pos < _input.length && _input[_pos] == '+') {
      _pos++;
      return _parsePrimary();
    }
    return _parsePrimary();
  }

  double _parsePrimary() {
    if (_pos >= _input.length) throw FormatException('Unexpected end of expression');

    final c = _input[_pos];
    if (c == '(') {
      _pos++;
      final val = _parseAddSub();
      if (_pos >= _input.length || _input[_pos] != ')') {
        throw FormatException('Missing closing parenthesis');
      }
      _pos++;
      return val;
    }

    if (c == 's' && _input.startsWith('sin(', _pos)) {
      _pos += 4;
      final val = _parseAddSub();
      if (_pos < _input.length && _input[_pos] == ')') _pos++;
      return math.sin(val);
    }
    if (c == 'c' && _input.startsWith('cos(', _pos)) {
      _pos += 4;
      final val = _parseAddSub();
      if (_pos < _input.length && _input[_pos] == ')') _pos++;
      return math.cos(val);
    }
    if (c == 't' && _input.startsWith('tan(', _pos)) {
      _pos += 4;
      final val = _parseAddSub();
      if (_pos < _input.length && _input[_pos] == ')') _pos++;
      return math.tan(val);
    }
    if (c == 's' && _input.startsWith('sqrt(', _pos)) {
      _pos += 5;
      final val = _parseAddSub();
      if (_pos < _input.length && _input[_pos] == ')') _pos++;
      return math.sqrt(val);
    }
    if (c == 'l' && _input.startsWith('log(', _pos)) {
      _pos += 4;
      final val = _parseAddSub();
      if (_pos < _input.length && _input[_pos] == ')') _pos++;
      return math.log(val);
    }
    if (c == 'a' && _input.startsWith('abs(', _pos)) {
      _pos += 4;
      final val = _parseAddSub();
      if (_pos < _input.length && _input[_pos] == ')') _pos++;
      return val.abs();
    }

    // Parse number
    final start = _pos;
    while (_pos < _input.length && (_isDigit(_input[_pos]) || _input[_pos] == '.')) {
      _pos++;
    }
    if (_pos == start) throw FormatException('Expected number at position $_pos');
    return double.parse(_input.substring(start, _pos));
  }

  bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }
}

class ConvertUnitTool extends Tool {
  @override final String id = 'calc_convert';
  @override final String name = 'Convert Units';
  @override final String description = 'Convert between units of measurement';
  @override final String category = 'calculation';

  static const _conversions = {
    // Length
    'm': 1.0, 'meter': 1.0, 'meters': 1.0,
    'km': 1000.0, 'kilometer': 1000.0, 'kilometers': 1000.0,
    'cm': 0.01, 'centimeter': 0.01, 'centimeters': 0.01,
    'mm': 0.001, 'millimeter': 0.001, 'millimeters': 0.001,
    'in': 0.0254, 'inch': 0.0254, 'inches': 0.0254,
    'ft': 0.3048, 'foot': 0.3048, 'feet': 0.3048,
    'yd': 0.9144, 'yard': 0.9144, 'yards': 0.9144,
    'mi': 1609.344, 'mile': 1609.344, 'miles': 1609.344,
    // Mass
    'kg': 1.0, 'kilogram': 1.0, 'kilograms': 1.0,
    'g': 0.001, 'gram': 0.001, 'grams': 0.001,
    'mg': 0.000001, 'milligram': 0.000001, 'milligrams': 0.000001,
    'lb': 0.453592, 'pound': 0.453592, 'pounds': 0.453592,
    'oz': 0.0283495, 'ounce': 0.0283495, 'ounces': 0.0283495,
    // Temperature (special handling)
    'c': double.nan, 'celsius': double.nan,
    'f': double.nan, 'fahrenheit': double.nan,
    'k': double.nan, 'kelvin': double.nan,
    // Volume
    'l': 1.0, 'liter': 1.0, 'liters': 1.0,
    'ml': 0.001, 'milliliter': 0.001, 'milliliters': 0.001,
    'gal': 3.78541, 'gallon': 3.78541, 'gallons': 3.78541,
    'qt': 0.946353, 'quart': 0.946353, 'quarts': 0.946353,
    'cup': 0.236588, 'cups': 0.236588,
    'fl_oz': 0.0295735, 'fluid_ounce': 0.0295735, 'fluid_ounces': 0.0295735,
  };

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'value', type: 'number', description: 'Value to convert', required: true),
    const ToolParameter(name: 'from', type: 'string', description: 'Source unit', required: true),
    const ToolParameter(name: 'to', type: 'string', description: 'Target unit', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final value = (args['value'] as num).toDouble();
      final from = (args['from'] as String).toLowerCase();
      final to = (args['to'] as String).toLowerCase();

      // Temperature conversion
      if ((from == 'c' || from == 'celsius') && (to == 'f' || to == 'fahrenheit')) {
        return jsonEncode({'success': true, 'result': value * 9 / 5 + 32, 'unit': to});
      }
      if ((from == 'f' || from == 'fahrenheit') && (to == 'c' || to == 'celsius')) {
        return jsonEncode({'success': true, 'result': (value - 32) * 5 / 9, 'unit': to});
      }
      if ((from == 'c' || from == 'celsius') && (to == 'k' || to == 'kelvin')) {
        return jsonEncode({'success': true, 'result': value + 273.15, 'unit': to});
      }
      if ((from == 'k' || from == 'kelvin') && (to == 'c' || to == 'celsius')) {
        return jsonEncode({'success': true, 'result': value - 273.15, 'unit': to});
      }

      final fromFactor = _conversions[from];
      final toFactor = _conversions[to];
      if (fromFactor == null) return jsonEncode({'success': false, 'error': 'Unknown unit: $from'});
      if (toFactor == null) return jsonEncode({'success': false, 'error': 'Unknown unit: $to'});

      final result = value * fromFactor / toFactor;
      return jsonEncode({'success': true, 'result': result, 'unit': to});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class StatsCalculateTool extends Tool {
  @override final String id = 'calc_stats';
  @override final String name = 'Calculate Statistics';
  @override final String description = 'Calculate descriptive statistics for a dataset';
  @override final String category = 'calculation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'data', type: 'array', description: 'Array of numbers', required: true),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final data = (args['data'] as List).map((e) => (e as num).toDouble()).toList();
      if (data.isEmpty) {
        return jsonEncode({'success': false, 'error': 'Empty dataset'});
      }
      data.sort();
      final n = data.length;
      final mean = data.reduce((a, b) => a + b) / n;
      final variance = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / n;
      final stdDev = math.sqrt(variance);
      final median = n.isOdd ? data[n ~/ 2] : (data[n ~/ 2 - 1] + data[n ~/ 2]) / 2;
      final sum = data.reduce((a, b) => a + b);

      return jsonEncode({
        'success': true,
        'count': n,
        'sum': sum,
        'mean': mean,
        'median': median,
        'min': data.first,
        'max': data.last,
        'std_dev': stdDev,
        'variance': variance,
        'range': data.last - data.first,
      });
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}

class FormatNumberTool extends Tool {
  @override final String id = 'calc_format';
  @override final String name = 'Format Number';
  @override final String description = 'Format a number with locale-aware formatting';
  @override final String category = 'calculation';

  @override
  List<ToolParameter> get parameters => [
    const ToolParameter(name: 'value', type: 'number', description: 'Number to format', required: true),
    const ToolParameter(name: 'decimals', type: 'number', description: 'Decimal places'),
    const ToolParameter(name: 'locale', type: 'string', description: 'Locale (e.g. en-US)'),
  ];

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    try {
      final value = (args['value'] as num).toDouble();
      final decimals = args['decimals'] as int? ?? 2;
      final formatted = value.toStringAsFixed(decimals);
      return jsonEncode({'success': true, 'formatted': formatted, 'value': value});
    } catch (e) {
      return jsonEncode({'success': false, 'error': e.toString()});
    }
  }
}
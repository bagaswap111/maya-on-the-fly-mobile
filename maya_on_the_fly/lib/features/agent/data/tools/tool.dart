class ToolParameter {
  final String name;
  final String type;
  final String description;
  final bool required;
  final List<String>? enumValues;

  const ToolParameter({
    required this.name,
    required this.type,
    required this.description,
    this.required = false,
    this.enumValues,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'description': description,
    'required': required,
    if (enumValues != null) 'enum': enumValues,
  };
}

abstract class Tool {
  String get id;
  String get name;
  String get description;
  String get category;
  List<ToolParameter> get parameters;

  Future<String> execute(Map<String, dynamic> args);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'parameters': parameters.map((p) => p.toJson()).toList(),
  };
}

abstract class Agent {
  String get id;
  String get name;
  String get description;
  String get icon;
  List<String> get toolIds;
  String get systemPrompt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'tools': toolIds,
  };
}

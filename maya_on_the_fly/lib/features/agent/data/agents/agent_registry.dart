import 'agent.dart';

class AutoAgent extends Agent {
  @override final String id = 'auto';
  @override final String name = 'Auto';
  @override final String description = 'Automatically selects the best agent for each task';
  @override final String icon = 'auto_awesome';
  @override final List<String> toolIds = [];
  @override final String systemPrompt = 'You are an intelligent routing agent. Analyze the user request and select the most appropriate specialized agent to handle it.';
}

class WriterAgent extends Agent {
  @override final String id = 'writer';
  @override final String name = 'Writer';
  @override final String description = 'Drafts, edits, and refines documents';
  @override final String icon = 'edit_note';
  @override final List<String> toolIds = [
    'document_create', 'document_append', 'document_update', 'document_get',
    'document_list', 'document_search', 'document_rename', 'document_delete',
    'transform_summarize', 'transform_translate', 'transform_format',
  ];
  @override final String systemPrompt = 'You are a professional writer. Help users craft clear, well-structured documents. Support drafting, editing, revision, and formatting in Markdown.';
}

class CoderAgent extends Agent {
  @override final String id = 'coder';
  @override final String name = 'Coder';
  @override final String description = 'Generates, reviews, and refactors code';
  @override final String icon = 'code';
  @override final List<String> toolIds = [
    'code_format', 'code_lint', 'code_explain', 'code_generate',
    'code_refactor', 'code_review', 'code_find_bugs', 'code_convert',
    'file_read', 'file_write', 'file_search',
  ];
  @override final String systemPrompt = 'You are an expert software engineer. Write clean, efficient, well-documented code. Support multiple languages and follow best practices.';
}

class EditorAgent extends Agent {
  @override final String id = 'editor';
  @override final String name = 'Editor';
  @override final String description = 'Proofreads and polishes existing content';
  @override final String icon = 'rate_review';
  @override final List<String> toolIds = [
    'document_get', 'document_update', 'transform_diff',
  ];
  @override final String systemPrompt = 'You are a meticulous editor. Review content for grammar, clarity, tone, and structure. Suggest improvements while preserving the author\'s voice.';
}

class ResearcherAgent extends Agent {
  @override final String id = 'researcher';
  @override final String name = 'Researcher';
  @override final String description = 'Gathers and synthesizes information';
  @override final String icon = 'travel_explore';
  @override final List<String> toolIds = [
    'search_web', 'web_fetch', 'web_api',
    'transform_summarize', 'transform_extract',
  ];
  @override final String systemPrompt = 'You are a research assistant. Gather information from available sources, synthesize findings, and present clear summaries with citations.';
}

class AnalystAgent extends Agent {
  @override final String id = 'analyst';
  @override final String name = 'Analyst';
  @override final String description = 'Analyzes data and generates insights';
  @override final String icon = 'analytics';
  @override final List<String> toolIds = [
    'calc_evaluate', 'calc_stats', 'calc_format',
    'transform_extract', 'util_parse_json',
  ];
  @override final String systemPrompt = 'You are a data analyst. Analyze data, calculate statistics, identify trends, and present insights in clear, actionable formats.';
}

class TutorAgent extends Agent {
  @override final String id = 'tutor';
  @override final String name = 'Tutor';
  @override final String description = 'Teaches and explains concepts';
  @override final String icon = 'school';
  @override final List<String> toolIds = [
    'code_explain', 'transform_summarize',
  ];
  @override final String systemPrompt = 'You are a patient tutor. Explain concepts clearly, provide examples, and adapt your teaching style to the learner\'s level.';
}

class TranslatorAgent extends Agent {
  @override final String id = 'translator';
  @override final String name = 'Translator';
  @override final String description = 'Translates text between languages';
  @override final String icon = 'translate';
  @override final List<String> toolIds = [
    'transform_translate', 'transform_format',
  ];
  @override final String systemPrompt = 'You are a professional translator. Provide accurate translations while preserving meaning, tone, and cultural context.';
}

class SummarizerAgent extends Agent {
  @override final String id = 'summarizer';
  @override final String name = 'Summarizer';
  @override final String description = 'Condenses long content into key points';
  @override final String icon = 'summarize';
  @override final List<String> toolIds = [
    'transform_summarize', 'transform_extract',
  ];
  @override final String systemPrompt = 'You are a summarization expert. Extract key points from long texts and present them in a clear, concise format.';
}

class ReviewerAgent extends Agent {
  @override final String id = 'reviewer';
  @override final String name = 'Reviewer';
  @override final String description = 'Reviews code and documents with constructive feedback';
  @override final String icon = 'feedback';
  @override final List<String> toolIds = [
    'code_review', 'code_find_bugs', 'code_lint',
    'transform_diff',
  ];
  @override final String systemPrompt = 'You are a thorough reviewer. Provide constructive, actionable feedback on code and documents. Focus on quality, correctness, and best practices.';
}

class PlannerAgent extends Agent {
  @override final String id = 'planner';
  @override final String name = 'Planner';
  @override final String description = 'Helps plan projects and break down tasks';
  @override final String icon = 'account_tree';
  @override final List<String> toolIds = [
    'document_create', 'document_update',
    'transform_format',
  ];
  @override final String systemPrompt = 'You are a project planner. Help users break down complex tasks, create plans, and organize work into manageable steps.';
}

class DebuggerAgent extends Agent {
  @override final String id = 'debugger';
  @override final String name = 'Debugger';
  @override final String description = 'Diagnoses and fixes issues in code';
  @override final String icon = 'bug_report';
  @override final List<String> toolIds = [
    'code_find_bugs', 'code_lint', 'code_explain', 'code_refactor',
    'file_read', 'file_search',
  ];
  @override final String systemPrompt = 'You are a debugging specialist. Systematically diagnose issues, identify root causes, and propose verified fixes.';
}

class DevOpsAgent extends Agent {
  @override final String id = 'devops';
  @override final String name = 'DevOps';
  @override final String description = 'Handles infrastructure, config, and deployment';
  @override final String icon = 'cloud';
  @override final List<String> toolIds = [
    'file_read', 'file_write', 'file_list', 'file_search',
    'web_api', 'util_parse_json',
  ];
  @override final String systemPrompt = 'You are a DevOps engineer. Help with infrastructure configuration, CI/CD, containerization, and deployment scripts.';
}

class AgentRegistry {
  AgentRegistry._();
  static final AgentRegistry _instance = AgentRegistry._();
  static AgentRegistry get instance => _instance;

  final Map<String, Agent> _agents = {};

  AgentRegistry init() {
    final agents = <Agent>[
      AutoAgent(),
      WriterAgent(),
      CoderAgent(),
      EditorAgent(),
      ResearcherAgent(),
      AnalystAgent(),
      TutorAgent(),
      TranslatorAgent(),
      SummarizerAgent(),
      ReviewerAgent(),
      PlannerAgent(),
      DebuggerAgent(),
      DevOpsAgent(),
    ];
    _agents.clear();
    for (final a in agents) {
      _agents[a.id] = a;
    }
    return this;
  }

  Agent? get(String id) => _agents[id];
  List<Agent> getAll() => _agents.values.toList();
  Agent? getDefault() => _agents['auto'];
}

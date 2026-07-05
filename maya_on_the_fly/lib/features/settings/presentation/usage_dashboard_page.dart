import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../data/database/daos/usage_dao.dart';

class UsageDashboardPage extends StatefulWidget {
  const UsageDashboardPage({super.key});

  @override
  State<UsageDashboardPage> createState() => _UsageDashboardPageState();
}

class _UsageDashboardPageState extends State<UsageDashboardPage> {
  final UsageDao _dao = UsageDao();
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await _dao.getRecords();
    if (mounted) setState(() { _records = records; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final totalInput = _records.fold<int>(0, (s, r) => s + (r['input_tokens'] as int? ?? 0));
    final totalOutput = _records.fold<int>(0, (s, r) => s + (r['output_tokens'] as int? ?? 0));
    final totalCost = _records.fold<double>(0.0, (s, r) => s + (r['cost'] as num? ?? 0).toDouble());

    return Scaffold(
      appBar: AppBar(title: const Text('Usage Dashboard')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Input Tokens', value: totalInput.toString(), icon: Icons.input, color: theme.colorScheme.primary)),
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(child: _StatCard(title: 'Output Tokens', value: totalOutput.toString(), icon: Icons.output, color: theme.colorScheme.tertiary)),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Total Tokens', value: (totalInput + totalOutput).toString(), icon: Icons.token, color: theme.colorScheme.secondary)),
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(child: _StatCard(title: 'Est. Cost', value: '\$${totalCost.toStringAsFixed(4)}', icon: Icons.attach_money, color: Colors.amber.shade700)),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            Text('Recent Usage', style: theme.textTheme.titleMedium),
            const SizedBox(height: DesignTokens.spaceSm),
            if (_records.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLg),
                  child: Text('No usage records yet. Start chatting to see usage.', style: theme.textTheme.bodyMedium?.copyWith(color: DesignTokens.muted)),
                ),
              )
            else
              ..._records.take(20).map((r) => ListTile(
                dense: true,
                leading: Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
                title: Text('${r['model_id'] ?? 'unknown'} - ${r['task_type'] ?? 'chat'}', style: theme.textTheme.bodySmall),
                subtitle: Text('${r['input_tokens'] ?? 0} in / ${r['output_tokens'] ?? 0} out', style: theme.textTheme.bodySmall),
                trailing: Text('\$${(r['cost'] as num?)?.toStringAsFixed(4) ?? '0'}', style: theme.textTheme.bodySmall),
              )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: DesignTokens.spaceXs),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: theme.textTheme.bodySmall?.copyWith(color: DesignTokens.muted)),
          ],
        ),
      ),
    );
  }
}

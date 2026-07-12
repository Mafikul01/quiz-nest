import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/quiz_history_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../core/theme/app_theme.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  String _filterType = 'All';
  String _sortOrder = 'Newest';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Quiz History', showBackButton: false),
      body: Column(
        children: [
          _buildFilters(colorScheme),
          Expanded(
            child: StreamBuilder<List<QuizHistoryModel>>(
              stream: auth.dbService.getQuizHistoryStream(auth.user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading history: ${snapshot.error}'));
                }

                var history = snapshot.data ?? [];
                
                // Apply Search
                if (_searchQuery.isNotEmpty) {
                  history = history.where((h) => 
                    h.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    h.category.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                // Apply Type Filter
                if (_filterType != 'All') {
                  history = history.where((h) => h.quizType == _filterType).toList();
                }

                // Apply Sorting
                if (_sortOrder == 'Oldest') {
                  history.sort((a, b) => a.date.compareTo(b.date));
                } else {
                  history.sort((a, b) => b.date.compareTo(a.date));
                }

                if (history.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: history.length,
                  itemBuilder: (context, index) => _buildHistoryCard(history[index], colorScheme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search quizzes...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDropdown('Type', _filterType, ['All', 'API', 'AI'], (val) {
                setState(() => _filterType = val!);
              }),
              const SizedBox(width: 12),
              _buildDropdown('Sort', _sortOrder, ['Newest', 'Oldest'], (val) {
                setState(() => _sortOrder = val!);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(QuizHistoryModel history, ColorScheme colorScheme) {
    final isAI = history.quizType == 'AI';
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(history.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _showSummary(history),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: isAI ? AppTheme.primaryGradient : null,
            color: isAI ? null : AppTheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isAI ? Icons.auto_awesome_rounded : Icons.quiz_rounded,
            color: isAI ? Colors.white : AppTheme.secondary,
          ),
        ),
        title: Text(
          history.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateStr, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (history.percentage >= 60 ? Colors.green : Colors.orange).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${history.percentage.toInt()}%',
            style: TextStyle(
              color: history.percentage >= 60 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showSummary(QuizHistoryModel history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text(history.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(history.quizType == 'AI' ? 'AI Generated Quiz' : 'Category Quiz', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 40),
            _buildSummaryRow('Score', '${history.score} / ${history.totalQuestions}'),
            _buildSummaryRow('Correct Answers', '${history.correctAnswers}'),
            _buildSummaryRow('Wrong Answers', '${history.wrongAnswers}'),
            _buildSummaryRow('Duration', history.duration),
            _buildSummaryRow('Accuracy', '${history.percentage.toInt()}%'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          const Text('No history found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Complete a quiz to see it here.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

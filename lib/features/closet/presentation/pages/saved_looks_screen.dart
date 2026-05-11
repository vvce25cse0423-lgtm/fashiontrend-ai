import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../themes/app_theme.dart';
import '../../../../shared/widgets/app_snackbar.dart';

/// Screen showing user's saved outfit looks
class SavedLooksScreen extends StatefulWidget {
  const SavedLooksScreen({super.key});

  @override
  State<SavedLooksScreen> createState() => _SavedLooksScreenState();
}

class _SavedLooksScreenState extends State<SavedLooksScreen> {
  final List<_SavedLook> _looks = [
    _SavedLook(
      name: 'Urban Minimalist',
      occasion: 'Casual Outing',
      score: 94,
      emoji: '🤍',
      date: '2 days ago',
      items: ['White Linen Shirt', 'Beige Chinos', 'White Sneakers'],
    ),
    _SavedLook(
      name: 'Date Night',
      occasion: 'Date Night',
      score: 92,
      emoji: '🌹',
      date: '5 days ago',
      items: ['Black Slim Jeans', 'Wine Turtleneck', 'Chelsea Boots'],
    ),
    _SavedLook(
      name: 'Business Casual',
      occasion: 'Work',
      score: 96,
      emoji: '💼',
      date: '1 week ago',
      items: ['Navy Blazer', 'White OCBD', 'Grey Trousers'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saved Looks',
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text('${_looks.length} looks saved',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list),
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.2, duration: 400.ms),

              const SizedBox(height: 16),

              // Looks list
              Expanded(
                child: _looks.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _looks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          return _buildLookCard(context, _looks[i], i);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLookCard(BuildContext context, _SavedLook look, int index) {
    return Dismissible(
      key: Key(look.name),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
      ),
      onDismissed: (_) {
        setState(() => _looks.removeAt(index));
        AppSnackbar.info(context, 'Look removed');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Column(
          children: [
            // Top section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.surfaceBg, AppTheme.cardBg],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // Emoji
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(look.emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(look.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(look.occasion,
                                  style: const TextStyle(
                                      color: AppTheme.accentPurple, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Text(look.date,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Score badge
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('${look.score}',
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
                        const Text('pts', style: TextStyle(color: Colors.black, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Items
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  ...look.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right, color: AppTheme.primaryGold, size: 18),
                          const SizedBox(width: 6),
                          Text(item, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textPrimary,
                            side: const BorderSide(color: AppTheme.borderGlass),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.share_outlined, size: 16),
                          label: const Text('Share', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.download_outlined, size: 16),
                          label: const Text('Download', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.3, delay: (index * 100).ms, duration: 400.ms),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_outline, size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text('No saved looks yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Save outfits from recommendations', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SavedLook {
  final String name;
  final String occasion;
  final int score;
  final String emoji;
  final String date;
  final List<String> items;

  const _SavedLook({
    required this.name,
    required this.occasion,
    required this.score,
    required this.emoji,
    required this.date,
    required this.items,
  });
}

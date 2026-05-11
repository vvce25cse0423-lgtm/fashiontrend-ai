import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../themes/app_theme.dart';
import '../../../../services/ai_service.dart';
import '../../../../services/profile_service.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../core/constants/app_constants.dart';

class AccessoriesScreen extends ConsumerStatefulWidget {
  const AccessoriesScreen({super.key});
  @override
  ConsumerState<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends ConsumerState<AccessoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _gender = 'Male';
  String _occasion = 'Daily Wear';
  String _budget = '₹2,000–₹5,000';
  String _season = 'Summer (Mar-Jun)';

  String _shoesResult = '';
  String _watchResult = '';
  String _perfumeResult = '';
  bool _shoesLoading = false;
  bool _watchLoading = false;
  bool _perfumeLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _loadProfile() async {
    final p = await ref.read(userProfileProvider.future);
    if (p != null && mounted) {
      setState(() {
        _gender = p.gender ?? 'Male';
        _budget = p.budgetRange ?? '₹2,000–₹5,000';
      });
    }
  }

  Future<void> _getShoes() async {
    setState(() { _shoesLoading = true; _shoesResult = ''; });
    try {
      final r = await aiService.getShoeRecommendation(
        gender: _gender, occasion: _occasion,
        outfitStyle: 'Casual', budget: _budget,
      );
      if (mounted) setState(() => _shoesResult = r);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Could not load. Check internet.');
    } finally {
      if (mounted) setState(() => _shoesLoading = false);
    }
  }

  Future<void> _getWatch() async {
    setState(() { _watchLoading = true; _watchResult = ''; });
    try {
      final r = await aiService.getWatchRecommendation(
        gender: _gender, occasion: _occasion, budget: _budget,
      );
      if (mounted) setState(() => _watchResult = r);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Could not load. Check internet.');
    } finally {
      if (mounted) setState(() => _watchLoading = false);
    }
  }

  Future<void> _getPerfume() async {
    setState(() { _perfumeLoading = true; _perfumeResult = ''; });
    try {
      final r = await aiService.getPerfumeRecommendation(
        gender: _gender, occasion: _occasion, season: _season,
      );
      if (mounted) setState(() => _perfumeResult = r);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Could not load. Check internet.');
    } finally {
      if (mounted) setState(() => _perfumeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
                    Text('Accessories & Grooming', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(child: _dropdownSmall('Occasion', _occasion, AppConstants.occasions, (v) => setState(() => _occasion = v!))),
                    const SizedBox(width: 8),
                    Expanded(child: _dropdownSmall('Season', _season, AppConstants.seasons, (v) => setState(() => _season = v!))),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderGlass),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(10)),
                    labelColor: Colors.black,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [Tab(text: '👟 Shoes'), Tab(text: '⌚ Watch'), Tab(text: '🌸 Perfume')],
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTab(Icons.hiking, 'Shoes', _shoesResult, _shoesLoading, _getShoes, AppTheme.goldGradient),
                    _buildTab(Icons.watch, 'Watch', _watchResult, _watchLoading, _getWatch, AppTheme.purpleGradient),
                    _buildTab(Icons.water_drop, 'Perfume', _perfumeResult, _perfumeLoading, _getPerfume,
                        const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFFF6B6B)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, String result, bool loading, VoidCallback onTap, LinearGradient gradient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GradientButton(
            onPressed: loading ? null : onTap,
            isLoading: loading,
            text: '✨ GET $label RECOMMENDATIONS',
            gradient: gradient,
            textColor: label == 'Shoes' ? Colors.black : Colors.white,
          ),

          const SizedBox(height: 20),

          if (loading)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderGlass)),
              child: Column(
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(gradient.colors.first), strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text('Finding best $label for you...', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          else if (result.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gradient.colors.first.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Best $label for $_occasion', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(result, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7)),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, duration: 400.ms)
          else
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderGlass)),
              child: Column(
                children: [
                  Icon(icon, size: 60, color: gradient.colors.first.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text('Tap the button above', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text('AI will recommend the best $label for your occasion and budget', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _dropdownSmall(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderGlass)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          dropdownColor: AppTheme.cardBg,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textPrimary),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

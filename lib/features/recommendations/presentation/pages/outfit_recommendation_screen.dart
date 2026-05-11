import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/ai_service.dart';
import '../../../../services/profile_service.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/recommendation_model.dart';

class OutfitRecommendationScreen extends ConsumerStatefulWidget {
  const OutfitRecommendationScreen({super.key});

  @override
  ConsumerState<OutfitRecommendationScreen> createState() =>
      _OutfitRecommendationScreenState();
}

class _OutfitRecommendationScreenState
    extends ConsumerState<OutfitRecommendationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // User selected filters
  String _occasion = 'Daily Wear';
  String _season = 'Summer (Mar-Jun)';

  // AI response
  String _aiOutfit = '';
  bool _isLoading = false;
  bool _hasGenerated = false;

  // User profile values (loaded from Supabase)
  String _gender = 'Male';
  String _skinTone = 'Wheatish';
  String _bodyType = 'Average';
  String _budget = '₹2,000–₹5,000';
  String _style = 'Casual';
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final profile = await ref.read(userProfileProvider.future);
    if (profile != null && mounted) {
      setState(() {
        _gender = profile.gender ?? 'Male';
        _skinTone = profile.skinTone ?? 'Wheatish';
        _bodyType = profile.bodyType ?? 'Average';
        _budget = profile.budgetRange ?? '₹2,000–₹5,000';
        _style = profile.fashionStyle ?? 'Casual';
      });
    }
  }

  Future<void> _generateOutfit() async {
    setState(() { _isLoading = true; _hasGenerated = true; _aiOutfit = ''; });
    try {
      final result = await aiService.getOutfitRecommendation(
        gender: _gender,
        skinTone: _skinTone,
        bodyType: _bodyType,
        occasion: _occasion,
        season: _season,
        budget: _budget,
        style: _style,
        language: _language,
      );
      if (mounted) setState(() => _aiOutfit = result);
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Could not get recommendation. Check internet.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
                    Expanded(child: Text('AI Outfit Recommendations', style: Theme.of(context).textTheme.titleLarge)),
                  ],
                ),
              ),

              // Profile summary chip
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppTheme.primaryGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$_gender · $_skinTone skin · $_bodyType · $_style',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tabs
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
                    tabs: const [Tab(text: '✨ For Me'), Tab(text: '🔥 Trending'), Tab(text: '🌟 Celebrity')],
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildForMeTab(),
                    _buildTrendingTab(),
                    _buildCelebrityTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForMeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter row
          Row(
            children: [
              Expanded(child: _dropdown('Occasion', _occasion, AppConstants.occasions, (v) => setState(() => _occasion = v!))),
              const SizedBox(width: 12),
              Expanded(child: _dropdown('Season', _season, AppConstants.seasons, (v) => setState(() => _season = v!))),
            ],
          ),

          const SizedBox(height: 16),

          // Generate button
          GradientButton(
            onPressed: _isLoading ? null : _generateOutfit,
            isLoading: _isLoading,
            text: '✨ GET MY OUTFIT',
            gradient: AppTheme.goldGradient,
            textColor: Colors.black,
          ),

          const SizedBox(height: 20),

          // AI Response
          if (!_hasGenerated) ...[
            _buildEmptyPrompt(),
          ] else if (_isLoading) ...[
            _buildLoadingCard(),
          ] else if (_aiOutfit.isNotEmpty) ...[
            _buildAiResultCard(_aiOutfit),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyPrompt() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGlass),
      ),
      child: Column(
        children: [
          const Icon(Icons.checkroom, size: 60, color: AppTheme.primaryGold),
          const SizedBox(height: 12),
          Text('Ready for your personalized outfit!',
              style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Select your occasion and season above, then tap "Get My Outfit" for AI recommendations made just for you.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 3),
          const SizedBox(height: 16),
          Text('AI is creating your outfit...', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Personalizing for $_skinTone skin, $_bodyType body, $_occasion',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildAiResultCard(String text) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: AppTheme.primaryGold.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text('AI Outfit For You', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Text('$_occasion · $_season', style: const TextStyle(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),
          // AI text content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7)),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generateOutfit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.borderGlass),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Regenerate'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => AppSnackbar.success(context, 'Look saved! ✅'),
                    icon: const Icon(Icons.favorite_outline, size: 16),
                    label: const Text('Save Look'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, duration: 400.ms).fade(duration: 400.ms);
  }

  Widget _buildTrendingTab() {
    final trends = [
      _TrendItem('Y2K Revival 🌈', 'Low waist jeans + crop tops + platform shoes. Trending on Instagram reels.', 'College/Party'),
      _TrendItem('Clean Girl Look ✨', 'Minimal makeup, slicked hair, white tee, beige trousers. Simple and elegant.', 'Daily Wear'),
      _TrendItem('Indian Streetwear 🔥', 'Oversized kurta + joggers + sneakers. Desi swag with modern touch.', 'Casual'),
      _TrendItem('Office Chic 💼', 'Solid color salwar suit or slim trousers + blazer. Professional but stylish.', 'Work'),
      _TrendItem('Festival Ready 🪔', 'Mirror work lehenga or cotton anarkali. Traditional with modern cuts.', 'Festive'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: trends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trends[i].name, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(trends[i].occasion, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(trends[i].desc, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ).animate().slideX(begin: 0.3, delay: (i * 80).ms, duration: 400.ms),
    );
  }

  Widget _buildCelebrityTab() {
    final celebs = [
      _CelebItem('Virat Kohli Style 🏏', 'Athleisure + smart casual. Slim fit tees, chinos, clean sneakers.', 'Athletic/Smart'),
      _CelebItem('Ranveer Singh 🎨', 'Bold prints, oversized jackets, experimental fashion. For the daring!', 'Streetwear/Bold'),
      _CelebItem('Deepika Padukone 👑', 'Elegant sarees + modern gowns. Classic beauty with a modern twist.', 'Formal/Traditional'),
      _CelebItem('Alia Bhatt 🌸', 'Flowy dresses, cotton kurtis, casual chic. Relatable everyday fashion.', 'Casual/Chic'),
      _CelebItem('AP Dhillon 🎵', 'Indo-Western fusion. Shackets, white tees, kurtas with modern cuts.', 'Indo-Western'),
      _CelebItem('Samantha Ruth ✨', 'Bold colors, designer sarees, fitness looks. South Indian elegance.', 'Traditional/Bold'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: celebs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.cardBg, AppTheme.surfaceBg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(celebs[i].name, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(celebs[i].desc, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(celebs[i].styleType, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _style = celebs[i].styleType.split('/').first.trim();
                  _tabController.index = 0;
                });
                AppSnackbar.info(context, 'Style set! Now tap "Get My Outfit" 👆');
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
              child: const Text('Try'),
            ),
          ],
        ),
      ).animate().slideX(begin: 0.3, delay: (i * 80).ms, duration: 400.ms),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGlass),
      ),
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

class _TrendItem { final String name, desc, occasion; const _TrendItem(this.name, this.desc, this.occasion); }
class _CelebItem { final String name, desc, styleType; const _CelebItem(this.name, this.desc, this.styleType); }

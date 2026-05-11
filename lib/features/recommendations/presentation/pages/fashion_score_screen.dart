import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../services/ai_service.dart';
import '../../../../services/analysis_store.dart';
import '../../../../services/profile_service.dart';
import '../../../../shared/widgets/gradient_button.dart';

class FashionScoreScreen extends ConsumerStatefulWidget {
  const FashionScoreScreen({super.key});
  @override
  ConsumerState<FashionScoreScreen> createState() => _FashionScoreScreenState();
}

class _FashionScoreScreenState extends ConsumerState<FashionScoreScreen> {
  Map<String, int> _scores = {};
  PhotoAnalysisResult? _lastAnalysis;
  bool _isLoading = true;
  String _improvementTips = '';
  bool _loadingTips = false;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    setState(() => _isLoading = true);
    try {
      // Load last photo analysis from Supabase/cache
      final analysis = await AnalysisStore.load();
      final profile = await ref.read(userProfileProvider.future);
      final stats = await ref.read(profileStatsProvider.future);

      final scores = await aiService.getFashionScore(
        gender: profile?.gender ?? 'Male',
        skinTone: profile?.skinTone ?? 'Wheatish',
        bodyType: profile?.bodyType ?? 'Average',
        style: profile?.fashionStyle ?? 'Casual',
        closetItems: stats['closetItems'] ?? 0,
        savedLooks: stats['savedLooks'] ?? 0,
        lastAnalysis: analysis,
      );

      if (mounted) {
        setState(() {
          _scores = scores;
          _lastAnalysis = analysis;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _scores = {'outfitMatch': 65, 'colorHarmony': 68, 'trendiness': 70, 'grooming': 67, 'accessories': 65, 'overall': 67};
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTips() async {
    if (_lastAnalysis == null) return;
    setState(() => _loadingTips = true);
    try {
      final tips = await aiService.getImprovementTips(
        gender: _lastAnalysis!.gender,
        skinTone: _lastAnalysis!.skinTone,
        bodyType: _lastAnalysis!.bodyType,
        currentStyle: _lastAnalysis!.currentStyle,
        outfitScore: _lastAnalysis!.outfitScore,
        colorScore: _lastAnalysis!.colorHarmonyScore,
        groomingScore: _lastAnalysis!.groomingScore,
        improvements: _lastAnalysis!.improvements,
      );
      if (mounted) setState(() => _improvementTips = tips);
    } catch (_) {
      if (mounted) {
        setState(() => _improvementTips = _lastAnalysis!.improvements
            .asMap()
            .entries
            .map((e) => '${e.key + 1}. ${e.value}')
            .join('\n\n'));
      }
    } finally {
      if (mounted) setState(() => _loadingTips = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overall = _scores['overall'] ?? 0;

    final categories = [
      ('👕 Outfit Match', _scores['outfitMatch'] ?? 0, AppTheme.goldGradient),
      ('🎨 Colour Harmony', _scores['colorHarmony'] ?? 0, AppTheme.purpleGradient),
      ('🔥 Trendiness', _scores['trendiness'] ?? 0, const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFFF6B6B)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      ('💈 Grooming', _scores['grooming'] ?? 0, const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      ('⌚ Accessories', _scores['accessories'] ?? 0, const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
              : CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                        child: Row(
                          children: [
                            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
                            Text('Fashion Score', style: Theme.of(context).textTheme.titleLarge),
                            if (_lastAnalysis != null && _lastAnalysis!.aiPowered) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.successGreen.withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.camera_alt, size: 12, color: AppTheme.successGreen),
                                    SizedBox(width: 4),
                                    Text('From Photo', style: TextStyle(color: AppTheme.successGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // No photo analysed yet — prompt
                            if (_lastAnalysis == null) _buildNoPhotoPrompt(context),

                            // Score circle
                            _buildScoreCircle(context, overall),
                            const SizedBox(height: 20),

                            // Source info
                            _buildSourceInfo(context),
                            const SizedBox(height: 24),

                            // Score bars
                            Text('Score Breakdown', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            ...categories.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _scoreBar(context, e.value.$1, e.value.$2, e.value.$3, e.key),
                            )),

                            const SizedBox(height: 20),

                            // Improvement tips section
                            _buildTipsSection(context),

                            const SizedBox(height: 20),

                            // Action buttons
                            GradientButton(
                              onPressed: () => context.push(AppRoutes.uploadPhoto),
                              text: '📸 ANALYSE NEW PHOTO',
                              gradient: AppTheme.goldGradient,
                              textColor: Colors.black,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _loadScore,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textPrimary,
                                side: const BorderSide(color: AppTheme.borderGlass),
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('🔄 Refresh Score'),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNoPhotoPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1200), Color(0xFF2A2000)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt, color: AppTheme.primaryGold, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload a photo for real score!',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primaryGold)),
                const SizedBox(height: 4),
                Text('Your score is estimated from profile. Upload a selfie to get an accurate AI score based on your actual look.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.uploadPhoto),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            child: const Text('Upload', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 400.ms);
  }

  Widget _buildScoreCircle(BuildContext context, int overall) {
    final scoreColor = overall >= 80
        ? AppTheme.successGreen
        : overall >= 65
            ? AppTheme.primaryGold
            : AppTheme.errorRed;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1200), Color(0xFF2A2000)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160, height: 160,
                child: CircularProgressIndicator(
                  value: overall / 100,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.borderGlass,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text('$overall',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: scoreColor, fontWeight: FontWeight.w700)),
                  Text('/100', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ],
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(_getLabel(overall),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                foreground: Paint()
                  ..shader = AppTheme.goldGradient
                      .createShader(const Rect.fromLTWH(0, 0, 200, 30)),
              )),
          const SizedBox(height: 8),
          Text(_getMessage(overall),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 500.ms);
  }

  Widget _buildSourceInfo(BuildContext context) {
    if (_lastAnalysis == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Score estimated from your profile. Upload a selfie to get an accurate score.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _lastAnalysis!.aiPowered
                  ? 'Score from your last photo analysis ✅ (${_lastAnalysis!.currentStyle} · ${_lastAnalysis!.skinTone} skin)'
                  : 'Score estimated from profile. Add API key for real photo scoring.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _lastAnalysis!.aiPowered
                        ? AppTheme.successGreen
                        : AppTheme.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0E0A1E), Color(0xFF1A0E2E)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AppTheme.accentPurple, size: 18),
                const SizedBox(width: 8),
                Text('How to Improve Your Score',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.accentPurple)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show analysis-based tips if available
                if (_lastAnalysis != null && _lastAnalysis!.improvements.isNotEmpty) ...[
                  Text('Based on your last photo scan:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  ..._lastAnalysis!.improvements.take(3).map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppTheme.accentPurple),
                          child: const Center(
                              child: Icon(Icons.arrow_upward, size: 12, color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(tip,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // Detailed AI tips button
                  if (_improvementTips.isEmpty && !_loadingTips)
                    GradientButton(
                      onPressed: _loadTips,
                      text: '✨ GET DETAILED AI TIPS',
                      gradient: AppTheme.purpleGradient,
                      textColor: Colors.white,
                      height: 48,
                    )
                  else if (_loadingTips)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(color: AppTheme.accentPurple, strokeWidth: 2),
                    ))
                  else ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('Detailed Tips:', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.accentPurple)),
                    const SizedBox(height: 8),
                    Text(_improvementTips,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7)),
                  ],
                ] else ...[
                  // Generic tips when no photo analysed
                  ..._genericTips().map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppTheme.accentPurple),
                          child: const Center(
                              child: Icon(Icons.arrow_upward, size: 12, color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(tip,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt, color: AppTheme.primaryGold, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Upload your photo for personalised improvement tips!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 300.ms, duration: 400.ms);
  }

  Widget _scoreBar(BuildContext context, String name, int score, LinearGradient g, int index) {
    return Container(
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
              Text(name, style: Theme.of(context).textTheme.titleSmall),
              Text('$score/100',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: AppTheme.primaryGold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppTheme.borderGlass,
              valueColor: AlwaysStoppedAnimation(g.colors.first),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getBarTip(name, score),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.3, delay: (index * 80).ms, duration: 400.ms);
  }

  String _getBarTip(String name, int score) {
    if (score >= 85) return '✅ Excellent — keep it up!';
    if (score >= 70) return '👍 Good — small improvements can push this to 85+';
    if (name.contains('Outfit')) return '💡 Tip: Mix and match from your closet more often';
    if (name.contains('Colour')) return '💡 Tip: Add your skin tone in profile for better suggestions';
    if (name.contains('Trend')) return '💡 Tip: Check the Trending tab for latest Indian styles';
    if (name.contains('Groom')) return '💡 Tip: Upload a photo for accurate grooming score';
    if (name.contains('Access')) return '💡 Tip: Add accessories to your virtual closet';
    return '💡 Tip: Upload a photo for accurate score';
  }

  List<String> _genericTips() => [
        'Complete your profile — add gender, skin tone, and body type for personalised advice',
        'Upload a selfie in the Analyse section for an accurate score based on your real look',
        'Add clothes to your Virtual Closet so AI can create outfit combinations for you',
        'Save outfits you like — each saved look improves your style score',
        'Check the Trending section daily and try at least one new style per week',
      ];

  String _getLabel(int s) {
    if (s >= 90) return '🌟 Fashion Icon';
    if (s >= 80) return '🔥 Style Star';
    if (s >= 70) return '👍 Trendy Person';
    if (s >= 60) return '🌱 Style Explorer';
    return '📖 Learning Style';
  }

  String _getMessage(int s) {
    if (s >= 80) return 'Excellent style! Upload a new photo to keep tracking your progress.';
    if (s >= 70) return 'Good going! Follow the improvement tips below to score higher.';
    return 'Great start! Upload your photo and complete your profile to improve fast.';
  }
}

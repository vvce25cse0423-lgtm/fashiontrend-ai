import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../services/ai_service.dart';
import '../../../../services/analysis_store.dart';
import '../../../../shared/widgets/gradient_button.dart';

class AiAnalysisScreen extends ConsumerStatefulWidget {
  final String? imagePath;
  const AiAnalysisScreen({super.key, this.imagePath});

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen> {
  // States: analyzing → scored → tips
  bool _isAnalyzing = true;
  bool _hasError = false;
  int _step = 0;
  PhotoAnalysisResult? _result;
  String _improvementTips = '';
  bool _loadingTips = false;

  final _steps = [
    '🔍 Detecting face shape...',
    '🎨 Analysing skin tone...',
    '👤 Reading body proportions...',
    '👕 Checking outfit colours...',
    '⭐ Calculating style score...',
  ];

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    if (widget.imagePath == null) {
      setState(() { _isAnalyzing = false; _hasError = true; });
      return;
    }

    // Animate steps while AI processes
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() => _step = i);
      await Future.delayed(const Duration(milliseconds: 700));
    }

    // Call real AI vision analysis
    try {
      final result = await aiService.analysePhoto(widget.imagePath!);
      if (!mounted) return;

      // Save result to Supabase + local cache
      await AnalysisStore.save(result);

      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      if (mounted) setState(() { _isAnalyzing = false; _hasError = true; });
    }
  }

  Future<void> _loadTips() async {
    if (_result == null) return;
    setState(() => _loadingTips = true);
    try {
      final tips = await aiService.getImprovementTips(
        gender: _result!.gender,
        skinTone: _result!.skinTone,
        bodyType: _result!.bodyType,
        currentStyle: _result!.currentStyle,
        outfitScore: _result!.outfitScore,
        colorScore: _result!.colorHarmonyScore,
        groomingScore: _result!.groomingScore,
        improvements: _result!.improvements,
      );
      if (mounted) setState(() => _improvementTips = tips);
    } catch (_) {
      if (mounted) setState(() => _improvementTips = _result!.improvements.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n\n'));
    } finally {
      if (mounted) setState(() => _loadingTips = false);
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
                    IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios)),
                    Text('AI Style Analysis', style: Theme.of(context).textTheme.titleLarge),
                    if (_result != null && _result!.aiPowered) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.successGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.successGreen.withOpacity(0.4))),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.auto_awesome, size: 12, color: AppTheme.successGreen), SizedBox(width: 4), Text('AI Powered', style: TextStyle(color: AppTheme.successGreen, fontSize: 11, fontWeight: FontWeight.w600))],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _isAnalyzing
                    ? _buildAnalysing(context)
                    : _hasError
                        ? _buildError(context)
                        : _buildResults(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysing(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Photo with scanning overlay
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 230, height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryGold, width: 2),
                ),
                child: widget.imagePath != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(File(widget.imagePath!), fit: BoxFit.cover))
                    : const Icon(Icons.person, size: 100, color: Colors.white24),
              ),
              // Scan line
              Container(
                width: 230, height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppTheme.primaryGold.withOpacity(0.2), Colors.transparent],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1400.ms, color: AppTheme.primaryGold.withOpacity(0.4)),
              // AI grid overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(painter: _GridPainter()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Step indicators
          ...List.generate(_steps.length, (i) {
            final done = i < _step;
            final current = i == _step;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppTheme.successGreen : current ? AppTheme.primaryGold : AppTheme.borderGlass,
                    ),
                    child: Icon(done ? Icons.check : (current ? Icons.radio_button_checked : Icons.circle_outlined), size: 13, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(_steps[i], style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: done || current ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontWeight: current ? FontWeight.w600 : FontWeight.normal,
                  )),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.primaryGold), strokeWidth: 3),
          const SizedBox(height: 12),
          Text('AI is reading your photo...', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 60),
            const SizedBox(height: 16),
            Text('Analysis Failed', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Could not analyse photo. Please try again with a clear, well-lit photo.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            GradientButton(onPressed: () => context.pop(), text: 'TRY AGAIN', gradient: AppTheme.goldGradient, textColor: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final r = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Score hero card
          _buildScoreHero(context, r),
          const SizedBox(height: 20),

          // Score breakdown bars
          _buildScoreBars(context, r),
          const SizedBox(height: 20),

          // What the AI detected
          _buildDetectedCard(context, r),
          const SizedBox(height: 20),

          // What you're doing well
          _buildPositivesCard(context, r),
          const SizedBox(height: 20),

          // Improvement tips
          _buildImprovementsCard(context, r),
          const SizedBox(height: 20),

          // Recommended colours
          _buildColoursCard(context, r),
          const SizedBox(height: 28),

          // Action buttons
          GradientButton(
            onPressed: () => context.push(AppRoutes.outfitRecommendation),
            text: '✨ GET OUTFIT RECOMMENDATIONS',
            gradient: AppTheme.goldGradient,
            textColor: Colors.black,
          ),
          const SizedBox(height: 12),
          GradientButton(
            onPressed: () => context.push(AppRoutes.fashionScore),
            text: '📊 VIEW FULL FASHION SCORE',
            gradient: AppTheme.purpleGradient,
            textColor: Colors.white,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: const BorderSide(color: AppTheme.borderGlass),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Analyse Another Photo'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildScoreHero(BuildContext context, PhotoAnalysisResult r) {
    final scoreColor = r.overallScore >= 80 ? AppTheme.successGreen : r.overallScore >= 65 ? AppTheme.primaryGold : AppTheme.errorRed;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1200), Color(0xFF2A2000)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text('Your Style Score', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryGold, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Photo thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.imagePath != null
                    ? Image.file(File(widget.imagePath!), width: 90, height: 110, fit: BoxFit.cover)
                    : Container(width: 90, height: 110, color: AppTheme.cardBg, child: const Icon(Icons.person, color: Colors.white24)),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  // Score circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110, height: 110,
                        child: CircularProgressIndicator(
                          value: r.overallScore / 100,
                          strokeWidth: 10,
                          backgroundColor: AppTheme.borderGlass,
                          valueColor: AlwaysStoppedAnimation(scoreColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        children: [
                          Text('${r.overallScore}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: scoreColor, fontWeight: FontWeight.w700)),
                          Text('/100', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 10),
                  Text(_getScoreLabel(r.overallScore), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primaryGold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.surfaceBg, borderRadius: BorderRadius.circular(12)),
            child: Text(
              r.aiPowered ? '✅ Analysed by real AI vision model' : '⚠️ Add OpenRouter API key for real AI analysis',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: r.aiPowered ? AppTheme.successGreen : AppTheme.primaryGold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 500.ms);
  }

  Widget _buildScoreBars(BuildContext context, PhotoAnalysisResult r) {
    final bars = [
      ('👕 Outfit Match', r.outfitScore, AppTheme.goldGradient),
      ('🎨 Colour Harmony', r.colorHarmonyScore, AppTheme.purpleGradient),
      ('💈 Grooming', r.groomingScore, const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    ];

    return Container(
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderGlass)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(children: [const Icon(Icons.bar_chart, color: AppTheme.primaryGold, size: 18), const SizedBox(width: 8), Text('Score Breakdown', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primaryGold))]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: bars.asMap().entries.map((entry) {
                final bar = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(bar.$1, style: Theme.of(context).textTheme.bodyMedium),
                          Text('${bar.$2}/100', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryGold, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: bar.$2 / 100,
                          backgroundColor: AppTheme.borderGlass,
                          valueColor: AlwaysStoppedAnimation(bar.$3.colors.first),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, delay: 100.ms, duration: 400.ms);
  }

  Widget _buildDetectedCard(BuildContext context, PhotoAnalysisResult r) {
    final items = [
      (Icons.face, 'Face Shape', r.faceShape),
      (Icons.palette, 'Skin Tone', r.skinTone),
      (Icons.fitness_center, 'Body Type', r.bodyType),
      (Icons.content_cut, 'Hair Style', r.hairStyle),
      (Icons.style, 'Current Style', r.currentStyle),
      (Icons.color_lens, 'Outfit Colours', r.currentOutfitColors.join(', ')),
    ];

    return Container(
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderGlass)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: AppTheme.purpleGradient, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(children: [const Icon(Icons.search, color: Colors.white, size: 18), const SizedBox(width: 8), const Text('What AI Detected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
          ),
          ...items.map((item) => ListTile(
            dense: true,
            leading: Icon(item.$1, color: AppTheme.primaryGold, size: 20),
            title: Text(item.$2, style: Theme.of(context).textTheme.bodySmall),
            trailing: Text(item.$3, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          )),
        ],
      ),
    ).animate().slideY(begin: 0.2, delay: 150.ms, duration: 400.ms);
  }

  Widget _buildPositivesCard(BuildContext context, PhotoAnalysisResult r) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.successGreen.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(children: [const Icon(Icons.thumb_up, color: AppTheme.successGreen, size: 18), const SizedBox(width: 8), Text('What You Are Doing Well ✅', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.successGreen))]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: r.positives.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(p, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, delay: 200.ms, duration: 400.ms);
  }

  Widget _buildImprovementsCard(BuildContext context, PhotoAnalysisResult r) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(children: [Icon(Icons.lightbulb, color: Colors.black, size: 18), SizedBox(width: 8), Text('Tips to Improve Your Style', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))]),
          ),

          if (_improvementTips.isEmpty && !_loadingTips)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...r.improvements.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryGold),
                          child: Center(child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  GradientButton(
                    onPressed: _loadingTips ? null : _loadTips,
                    isLoading: _loadingTips,
                    text: '✨ GET DETAILED AI TIPS',
                    gradient: AppTheme.goldGradient,
                    textColor: Colors.black,
                    height: 48,
                  ),
                ],
              ),
            )
          else if (_loadingTips)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 3)),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_improvementTips, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7)),
            ),
        ],
      ),
    ).animate().slideY(begin: 0.2, delay: 250.ms, duration: 400.ms);
  }

  Widget _buildColoursCard(BuildContext context, PhotoAnalysisResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: AppTheme.primaryGold, size: 18),
              const SizedBox(width: 8),
              Text('Colours That Suit You', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primaryGold)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Based on your ${r.skinTone} skin tone:', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: r.recommendedColors.map((color) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
              ),
              child: Text(color, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.surfaceBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.primaryGold, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('Recommended style for you: ${r.recommendedStyle}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, delay: 300.ms, duration: 400.ms);
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return '🌟 Fashion Icon';
    if (score >= 80) return '🔥 Style Star';
    if (score >= 70) return '👍 Trendy Person';
    if (score >= 60) return '🌱 Style Explorer';
    return '📖 Learning Style';
  }
}

// Grid overlay painter for scanning effect
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A843).withOpacity(0.15)
      ..strokeWidth = 0.5;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

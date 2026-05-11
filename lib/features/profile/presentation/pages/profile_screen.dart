import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../services/profile_service.dart';
import '../../../../services/analysis_store.dart';
import '../../../../services/ai_service.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/user_profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _user = Supabase.instance.client.auth.currentUser;
  bool _isSaving = false;

  // Editable fields — loaded from Supabase
  String _name = '';
  String _gender = 'Male';
  String _bodyType = 'Average';
  String _skinTone = 'Wheatish';
  String _fashionStyle = 'Casual';
  String _budget = '₹2,000–₹5,000';
  String _selectedLanguage = 'en';
  bool _profileLoaded = false;
  PhotoAnalysisResult? _lastAnalysis;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    try {
      final service = ref.read(profileServiceProvider);
      final profile = await service.getProfile(_user!.id);
      if (profile != null && mounted) {
        setState(() {
          _name = profile.name;
          _gender = profile.gender ?? 'Male';
          _bodyType = profile.bodyType ?? 'Average';
          _skinTone = profile.skinTone ?? 'Wheatish';
          _fashionStyle = profile.fashionStyle ?? 'Casual';
          _budget = profile.budgetRange ?? '₹2,000–₹5,000';
          _profileLoaded = true;
        });
      } else {
        if (mounted) {
          setState(() {
            _name = _user?.userMetadata?['name'] as String? ?? '';
            _profileLoaded = true;
          });
        }
      }
    // Load last analysis for real score
    final analysis = await AnalysisStore.load();
    if (mounted && analysis != null) setState(() => _lastAnalysis = analysis);
    } catch (_) {
      if (mounted) setState(() => _profileLoaded = true);
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    setState(() => _isSaving = true);
    try {
      final service = ref.read(profileServiceProvider);
      await service.updateProfile(UserProfile(
        id: _user!.id,
        name: _name,
        email: _user?.email ?? '',
        gender: _gender,
        bodyType: _bodyType,
        skinTone: _skinTone,
        fashionStyle: _fashionStyle,
        budgetRange: _budget,
        createdAt: DateTime.now(),
      ));
      // Invalidate cached profile so other screens refresh
      ref.invalidate(userProfileProvider);
      if (mounted) AppSnackbar.success(context, '✅ Profile saved successfully!');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Could not save profile. Try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get _displayName =>
      _name.isNotEmpty
          ? _name
          : (_user?.userMetadata?['name'] as String? ??
              _user?.email?.split('@').first ??
              'User');

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: stats.when(
                  data: (s) => _buildStats(context, s),
                  loading: () => _buildStatsLoading(context),
                  error: (_, __) => _buildStats(context, {}),
                ),
              ),
              SliverToBoxAdapter(child: _buildPreferences(context)),
              SliverToBoxAdapter(child: _buildLanguageSection(context)),
              SliverToBoxAdapter(child: _buildAccountSection(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          // Avatar circle with first letter
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.goldGradient,
              boxShadow: [BoxShadow(color: AppTheme.primaryGold.withOpacity(0.4), blurRadius: 20)],
            ),
            child: Center(
              child: Text(
                _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 40),
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 14),

          // Editable name
          GestureDetector(
            onTap: () => _showEditNameDialog(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_displayName, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(width: 6),
                const Icon(Icons.edit, size: 16, color: AppTheme.primaryGold),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Text(_user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20)),
            child: Text(
              _getStyleBadge(),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getStyleBadge() {
    if (_fashionStyle == 'Traditional' || _fashionStyle == 'Indo-Western') return '🪔 Cultural Fashionista';
    if (_fashionStyle == 'Streetwear') return '🔥 Street Style Star';
    if (_fashionStyle == 'Formal') return '💼 Power Dresser';
    if (_fashionStyle == 'Festive') return '✨ Festival Queen/King';
    return '👗 Style Enthusiast';
  }

  Widget _buildStats(BuildContext context, Map<String, int> stats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          _statCard(context, '${stats['savedLooks'] ?? 0}', 'Looks\nSaved'),
          const SizedBox(width: 12),
          _statCard(context, '${stats['closetItems'] ?? 0}', 'Closet\nItems'),
          const SizedBox(width: 12),
          _statCard(context, '${stats['analyses'] ?? 0}', 'AI\nScans'),
          const SizedBox(width: 12),
          _statCard(context, _getScoreDisplay(), 'Style\nScore'),
        ],
      ).animate().slideY(begin: 0.3, delay: 200.ms, duration: 400.ms),
    );
  }

  String _getScoreDisplay() {
    // Use real photo analysis score if available
    if (_lastAnalysis != null) return '${_lastAnalysis!.overallScore}';
    // Fallback: score from profile completeness
    int score = 50;
    if (_name.isNotEmpty) score += 10;
    if (_gender != 'Male') score += 5;
    if (_skinTone != 'Wheatish') score += 5;
    if (_bodyType != 'Average') score += 5;
    if (_fashionStyle != 'Casual') score += 10;
    if (_budget != '₹2,000–₹5,000') score += 5;
    return '${score.clamp(50, 95)}';
  }

  Widget _buildStatsLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: List.generate(4, (_) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            height: 72,
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
          ),
        )),
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryGold)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences(BuildContext context) {
    if (!_profileLoaded) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Style Profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('This helps AI give you personal recommendations', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),

          GlassCard(
            child: Column(
              children: [
                _prefRow(context, '👤 Gender', _gender, AppConstants.genders, (v) => setState(() => _gender = v!)),
                const Divider(height: 24),
                _prefRow(context, '👗 Style', _fashionStyle, AppConstants.styleCategories, (v) => setState(() => _fashionStyle = v!)),
                const Divider(height: 24),
                _prefRow(context, '🎨 Skin Tone', _skinTone, AppConstants.skinTones, (v) => setState(() => _skinTone = v!)),
                const Divider(height: 24),
                _prefRow(context, '💪 Body Type', _bodyType, AppConstants.bodyTypes, (v) => setState(() => _bodyType = v!)),
                const Divider(height: 24),
                _prefRow(context, '💰 Budget', _budget, AppConstants.budgetRanges, (v) => setState(() => _budget = v!)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          GradientButton(
            onPressed: _isSaving ? null : _saveProfile,
            isLoading: _isSaving,
            text: 'SAVE MY PROFILE',
            gradient: AppTheme.goldGradient,
            textColor: Colors.black,
          ),

          const SizedBox(height: 8),
          Text(
            'After saving, your outfit recommendations will be personalized just for you!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().slideY(begin: 0.3, delay: 300.ms, duration: 400.ms),
    );
  }

  Widget _prefRow(BuildContext context, String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: options.contains(value) ? value : options.first,
            dropdownColor: AppTheme.cardBg,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryGold),
            icon: const Icon(Icons.expand_more, color: AppTheme.primaryGold, size: 18),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Language / भाषा', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your preferred language for AI responses:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.supportedLanguages.entries.map((entry) {
                    final isSelected = _selectedLanguage == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppTheme.goldGradient : null,
                          color: isSelected ? null : AppTheme.surfaceBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? Colors.transparent : AppTheme.borderGlass),
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI stylist will reply in your chosen language 🎉',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold),
                ),
              ],
            ),
          ),
        ],
      ).animate().slideY(begin: 0.3, delay: 350.ms, duration: 400.ms),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                _menuTile(context, Icons.settings_outlined, 'Settings', onTap: () => context.push(AppRoutes.settings)),
                const Divider(height: 1),
                _menuTile(context, Icons.help_outline, 'Help & Support'),
                const Divider(height: 1),
                _menuTile(
                  context, Icons.logout, 'Sign Out',
                  color: AppTheme.errorRed,
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 400.ms),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String label, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppTheme.textSecondary, size: 22),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  void _showEditNameDialog() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(hintText: 'Enter your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _name = ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

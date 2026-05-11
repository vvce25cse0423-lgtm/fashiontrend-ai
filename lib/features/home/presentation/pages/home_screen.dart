import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../services/profile_service.dart';
import '../../../../services/weather_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _user = Supabase.instance.client.auth.currentUser;
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    if (hour < 12) _greeting = 'Good Morning';
    else if (hour < 17) _greeting = 'Good Afternoon';
    else _greeting = 'Good Evening';
  }

  String get _userName =>
      _user?.userMetadata?['name'] as String? ??
      _user?.email?.split('@').first ??
      'Friend';

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.primaryGold,
            backgroundColor: AppTheme.cardBg,
            onRefresh: () async {
              ref.invalidate(userProfileProvider);
              ref.invalidate(weatherProvider);
              ref.invalidate(profileStatsProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, profileAsync)),
                SliverToBoxAdapter(child: _buildWeatherCard(context, weatherAsync)),
                SliverToBoxAdapter(child: _buildProfileAlert(context, profileAsync)),
                SliverToBoxAdapter(child: _buildQuickActions(context)),
                SliverToBoxAdapter(child: _buildTodaysLook(context, profileAsync)),
                SliverToBoxAdapter(child: _buildCategories(context)),
                SliverToBoxAdapter(child: _buildTrendingSection(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue profileAsync) {
    final name = profileAsync.whenData((p) => p?.name ?? _userName).value ?? _userName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryGold)),
              Text(name.isNotEmpty ? name : _userName, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ).animate().slideX(begin: -0.3, duration: 500.ms),

          Row(
            children: [
              IconButton(onPressed: () {}, icon: Stack(children: [
                const Icon(Icons.notifications_outlined, size: 26),
                Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryGold))),
              ])),
              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.goldGradient,
                    boxShadow: [BoxShadow(color: AppTheme.primaryGold.withOpacity(0.3), blurRadius: 10)],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fade(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, AsyncValue<WeatherData> weatherAsync) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: weatherAsync.when(
        loading: () => Container(
          height: 80, decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGlass)),
          child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (weather) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0E1A30), Color(0xFF0A1020)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGlass),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryGold, size: 16),
                  const SizedBox(width: 4),
                  Text(weather.city, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold)),
                  const Spacer(),
                  Text(weather.temperatureDisplay, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  Text(weather.condition, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(weather.fashionTip, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.3, delay: 100.ms, duration: 400.ms),
    );
  }

  Widget _buildProfileAlert(BuildContext context, AsyncValue profileAsync) {
    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        final isIncomplete = profile == null ||
            profile.gender == null ||
            profile.skinTone == null ||
            profile.bodyType == null;

        if (!isIncomplete) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A1200), Color(0xFF2A2000)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: AppTheme.primaryGold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Complete Your Profile!', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primaryGold)),
                        Text('Add your gender, skin tone & body type for personalized recommendations', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryGold),
                ],
              ),
            ),
          ).animate().slideY(begin: 0.3, delay: 150.ms, duration: 400.ms),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _Action(Icons.camera_alt, 'Analyse\nLook', AppTheme.goldGradient, () => context.push(AppRoutes.uploadPhoto)),
      _Action(Icons.checkroom, 'Outfit\nIdeas', AppTheme.purpleGradient, () => context.push(AppRoutes.outfitRecommendation)),
      _Action(Icons.star, 'Fashion\nScore', const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFFF6B6B)], begin: Alignment.topLeft, end: Alignment.bottomRight), () => context.push(AppRoutes.fashionScore)),
      _Action(Icons.shopping_bag, 'Shoes &\nMore', const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight), () => context.push(AppRoutes.accessories)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            children: actions.map((a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: a.onTap,
                  child: Container(
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: a.gradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: a.gradient.colors.first.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(a.icon, color: Colors.white, size: 26),
                        const SizedBox(height: 6),
                        Text(a.label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3)),
                      ],
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ).animate().slideY(begin: 0.3, delay: 200.ms, duration: 500.ms),
    );
  }

  Widget _buildTodaysLook(BuildContext context, AsyncValue profileAsync) {
    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        final gender = profile?.gender ?? 'Male';
        final style = profile?.fashionStyle ?? 'Casual';
        final skinTone = profile?.skinTone ?? 'Wheatish';

        // Personalised look based on profile
        final looks = _getPersonalisedLook(gender, style, skinTone);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Look", style: Theme.of(context).textTheme.titleLarge),
                  TextButton(onPressed: () => context.push(AppRoutes.outfitRecommendation), child: const Text('See More')),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(colors: [Color(0xFF0E0A1E), Color(0xFF1A1A3E)]),
                  border: Border.all(color: AppTheme.borderGlass),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                          gradient: LinearGradient(colors: [AppTheme.accentPurple.withOpacity(0.3), AppTheme.accentPink.withOpacity(0.1)]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(looks['emoji']!, style: const TextStyle(fontSize: 50)),
                            const SizedBox(height: 8),
                            Text('$gender Look', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.primaryGold.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                              child: Text('$style · $skinTone skin', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 9, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 10),
                            Text(looks['name']!, style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 8),
                            Text(looks['items']!, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.8)),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.outfitRecommendation),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(10)),
                                child: const Text('Get AI Outfit', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().slideY(begin: 0.3, delay: 300.ms, duration: 500.ms),
        );
      },
    );
  }

  Map<String, String> _getPersonalisedLook(String gender, String style, String skinTone) {
    if (gender == 'Female') {
      if (style == 'Traditional' || style == 'Festive') {
        return {'emoji': '🪔', 'name': 'Festive Kurta Set', 'items': '• Embroidered kurta\n• Palazzo pants\n• Kolhapuri chappals'};
      }
      if (style == 'Formal') {
        return {'emoji': '💼', 'name': 'Office Power Look', 'items': '• Solid colour blazer\n• Formal trousers\n• Block heels'};
      }
      return {'emoji': '🌸', 'name': 'Casual Chic', 'items': '• Flowy kurti\n• Jeggings\n• White sneakers'};
    }
    if (style == 'Formal') {
      return {'emoji': '💼', 'name': 'Smart Office Look', 'items': '• White formal shirt\n• Dark trousers\n• Derby shoes'};
    }
    if (style == 'Traditional') {
      return {'emoji': '🪔', 'name': 'Traditional Look', 'items': '• Cotton kurta\n• Straight pants\n• Kolhapuri chappals'};
    }
    if (style == 'Streetwear') {
      return {'emoji': '🔥', 'name': 'Street Style', 'items': '• Oversized tee\n• Baggy cargo pants\n• Chunky sneakers'};
    }
    return {'emoji': '👕', 'name': 'Everyday Casual', 'items': '• Cotton polo shirt\n• Slim chinos\n• White sneakers'};
  }

  Widget _buildCategories(BuildContext context) {
    final cats = [
      ('Outfits', Icons.checkroom, AppTheme.goldGradient, AppRoutes.outfitRecommendation),
      ('Shoes', Icons.hiking, AppTheme.purpleGradient, AppRoutes.accessories),
      ('Watches', Icons.watch, const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight), AppRoutes.accessories),
      ('Perfume', Icons.water_drop, const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFFF6B6B)], begin: Alignment.topLeft, end: Alignment.bottomRight), AppRoutes.accessories),
      ('Analyse', Icons.camera_alt, const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight), AppRoutes.uploadPhoto),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(right: 20), child: Text('Style Categories', style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 14),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => context.push(cats[i].$4),
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(gradient: cats[i].$3, borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cats[i].$2, color: Colors.white, size: 28),
                      const SizedBox(height: 6),
                      Text(cats[i].$1, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ).animate().slideX(begin: 0.3, delay: 400.ms, duration: 500.ms),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    // Indian fashion trends
    final trends = [
      ('Korean Minimal', 'Soft tones, clean cuts', '🇰🇷'),
      ('Desi Streetwear', 'Oversized kurta + joggers', '🔥'),
      ('Old Money India', 'Timeless silk & linen', '💎'),
      ('Y2K Desi Twist', 'Low waist + crop top', '✨'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(right: 20), child: Text('Trending in India', style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: trends.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => context.push(AppRoutes.outfitRecommendation),
                child: Container(
                  width: 155,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.borderGlass)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trends[i].$3, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(trends[i].$1, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(trends[i].$2, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ).animate().slideX(begin: 0.3, delay: 500.ms, duration: 500.ms),
    );
  }
}

class _Action { final IconData icon; final String label; final LinearGradient gradient; final VoidCallback onTap; const _Action(this.icon, this.label, this.gradient, this.onTap); }

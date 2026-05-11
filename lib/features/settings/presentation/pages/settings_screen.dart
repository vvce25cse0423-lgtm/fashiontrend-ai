import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../themes/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyLookReminder = true;
  bool _weatherUpdates = true;
  bool _trendAlerts = false;
  bool _hapticFeedback = true;
  String _selectedCity = 'Auto (GPS)';

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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Text('Settings', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Notifications
                    Text('Notifications', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryGold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildToggle(context, 'Push Notifications', 'Receive style updates', _notificationsEnabled,
                              (v) => setState(() => _notificationsEnabled = v)),
                          const Divider(height: 1),
                          _buildToggle(context, 'Daily Look Reminder', 'Get your daily outfit idea', _dailyLookReminder,
                              (v) => setState(() => _dailyLookReminder = v)),
                          const Divider(height: 1),
                          _buildToggle(context, 'Weather Updates', 'Weather-based outfit alerts', _weatherUpdates,
                              (v) => setState(() => _weatherUpdates = v)),
                          const Divider(height: 1),
                          _buildToggle(context, 'Trend Alerts', 'New fashion trend notifications', _trendAlerts,
                              (v) => setState(() => _trendAlerts = v)),
                        ],
                      ),
                    ).animate().slideY(begin: 0.3, delay: 100.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // Location
                    Text('Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryGold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            leading: const Icon(Icons.location_on_outlined, color: AppTheme.textSecondary),
                            title: Text('Weather Location', style: Theme.of(context).textTheme.bodyMedium),
                            subtitle: Text(_selectedCity, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                            onTap: () => _showCityPicker(context),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.3, delay: 200.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // App Preferences
                    Text('App', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryGold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildToggle(context, 'Haptic Feedback', 'Vibrations on interactions', _hapticFeedback,
                              (v) => setState(() => _hapticFeedback = v)),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            leading: const Icon(Icons.language_outlined, color: AppTheme.textSecondary),
                            title: Text('Language', style: Theme.of(context).textTheme.bodyMedium),
                            subtitle: Text('English', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                            onTap: () => AppSnackbar.info(context, 'More languages coming soon!'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            leading: const Icon(Icons.storage_outlined, color: AppTheme.textSecondary),
                            title: Text('Clear Cache', style: Theme.of(context).textTheme.bodyMedium),
                            subtitle: Text('Free up storage space', style: Theme.of(context).textTheme.bodySmall),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                            onTap: () => AppSnackbar.success(context, 'Cache cleared successfully!'),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.3, delay: 300.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // About
                    Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryGold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildInfoTile(context, 'Version', '1.0.0'),
                          const Divider(height: 1),
                          _buildInfoTile(context, 'Build', '2024.1'),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            leading: const Icon(Icons.code_outlined, color: AppTheme.textSecondary),
                            title: Text('Open Source', style: Theme.of(context).textTheme.bodyMedium),
                            subtitle: Text('View on GitHub', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold)),
                            trailing: const Icon(Icons.open_in_new, size: 14, color: AppTheme.textSecondary),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 400.ms),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGold,
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTheme.primaryGold.withOpacity(0.3)
              : AppTheme.borderGlass,
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold)),
    );
  }

  void _showCityPicker(BuildContext context) {
    final cities = ['Auto (GPS)', 'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad', 'Pune'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select City', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...cities.map((city) => ListTile(
              title: Text(city),
              trailing: city == _selectedCity ? const Icon(Icons.check, color: AppTheme.primaryGold) : null,
              onTap: () {
                setState(() => _selectedCity = city);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
}

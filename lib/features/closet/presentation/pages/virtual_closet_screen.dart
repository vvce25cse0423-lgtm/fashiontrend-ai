import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../themes/app_theme.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';

/// Virtual Closet - users upload and manage their wardrobe
class VirtualClosetScreen extends StatefulWidget {
  const VirtualClosetScreen({super.key});

  @override
  State<VirtualClosetScreen> createState() => _VirtualClosetScreenState();
}

class _VirtualClosetScreenState extends State<VirtualClosetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<_ClosetItem> _items = [];

  final _categories = ['All', 'Tops', 'Bottoms', 'Shoes', 'Accessories', 'Outerwear'];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    // Seed with demo items
    _items.addAll([
      _ClosetItem(name: 'White Oxford Shirt', category: 'Tops', color: 'White', emoji: '👔'),
      _ClosetItem(name: 'Black Slim Jeans', category: 'Bottoms', color: 'Black', emoji: '👖'),
      _ClosetItem(name: 'White Sneakers', category: 'Shoes', color: 'White', emoji: '👟'),
      _ClosetItem(name: 'Navy Blazer', category: 'Outerwear', color: 'Navy', emoji: '🥼'),
      _ClosetItem(name: 'Beige Chinos', category: 'Bottoms', color: 'Beige', emoji: '👖'),
      _ClosetItem(name: 'Leather Watch', category: 'Accessories', color: 'Brown', emoji: '⌚'),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddItemSheet(
        onAdd: (item) {
          setState(() => _items.add(item));
          AppSnackbar.success(context, 'Item added to closet!');
        },
      ),
    );
  }

  List<_ClosetItem> get _filteredItems {
    if (_selectedCategory == 'All') return _items;
    return _items.where((i) => i.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
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
                        Text('My Closet',
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text('${_items.length} items',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    // AI Mix button
                    GestureDetector(
                      onTap: () => AppSnackbar.info(context, 'AI is creating outfit combinations from your wardrobe!'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('AI Mix', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.2, duration: 400.ms),

              // Stats row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    _buildStatChip(context, '${_items.length}', 'Total Items'),
                    const SizedBox(width: 10),
                    _buildStatChip(context, '${_items.where((i) => i.category == 'Tops').length}', 'Tops'),
                    const SizedBox(width: 10),
                    _buildStatChip(context, '${_items.where((i) => i.category == 'Bottoms').length}', 'Bottoms'),
                    const SizedBox(width: 10),
                    _buildStatChip(context, '${_items.where((i) => i.category == 'Shoes').length}', 'Shoes'),
                  ],
                ),
              ).animate().fade(delay: 100.ms),

              // Category filter
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppTheme.goldGradient : null,
                            color: isSelected ? null : AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppTheme.borderGlass,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.black : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Grid of items
              Expanded(
                child: _filteredItems.isEmpty
                    ? _buildEmptyState(context)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, i) {
                          return _buildClosetCard(context, _filteredItems[i], i);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryGold,
                      fontWeight: FontWeight.w700,
                    )),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildClosetCard(BuildContext context, _ClosetItem item, int index) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(item),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Column(
          children: [
            // Image / emoji area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.surfaceBg, AppTheme.cardBg],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: item.imagePath != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.file(File(item.imagePath!), fit: BoxFit.cover, width: double.infinity),
                      )
                    : Center(
                        child: Text(item.emoji, style: const TextStyle(fontSize: 56)),
                      ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item.category,
                            style: const TextStyle(
                                color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(
            begin: const Offset(0.8, 0.8),
            delay: (index * 60).ms,
            duration: 300.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.checkroom_outlined, size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text('No items yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Add clothes to your virtual closet', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _showDeleteDialog(_ClosetItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Remove Item'),
        content: Text('Remove "${item.name}" from your closet?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _items.remove(item));
              Navigator.pop(ctx);
              AppSnackbar.info(context, 'Item removed');
            },
            child: const Text('Remove', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}

class _ClosetItem {
  final String name;
  final String category;
  final String color;
  final String emoji;
  final String? imagePath;

  _ClosetItem({
    required this.name,
    required this.category,
    required this.color,
    required this.emoji,
    this.imagePath,
  });
}

/// Bottom sheet for adding a new closet item
class _AddItemSheet extends StatefulWidget {
  final void Function(_ClosetItem) onAdd;
  const _AddItemSheet({required this.onAdd});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Tops';
  String _selectedColor = 'Black';
  String? _imagePath;

  final _categories = ['Tops', 'Bottoms', 'Shoes', 'Accessories', 'Outerwear'];
  final _emojiMap = {
    'Tops': '👔', 'Bottoms': '👖', 'Shoes': '👟', 'Accessories': '⌚', 'Outerwear': '🥼',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.borderGlass, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add to Closet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),

          // Name
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Item Name',
              hintText: 'e.g. White Oxford Shirt',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),

          // Category
          Text('Category', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((cat) {
              final isSelected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.goldGradient : null,
                    color: isSelected ? null : AppTheme.surfaceBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.transparent : AppTheme.borderGlass),
                  ),
                  child: Text(cat,
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        fontSize: 13,
                      )),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          GradientButton(
            onPressed: () {
              if (_nameController.text.isEmpty) return;
              widget.onAdd(_ClosetItem(
                name: _nameController.text,
                category: _selectedCategory,
                color: _selectedColor,
                emoji: _emojiMap[_selectedCategory] ?? '👕',
                imagePath: _imagePath,
              ));
              Navigator.pop(context);
            },
            text: 'ADD TO CLOSET',
            gradient: AppTheme.goldGradient,
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }
}

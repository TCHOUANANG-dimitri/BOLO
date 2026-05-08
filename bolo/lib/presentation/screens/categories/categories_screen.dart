import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/mock_data.dart';
import '../../widgets/category_icon.dart';

class CategoriesScreen extends StatefulWidget {
  final String? selectedGroup;

  const CategoriesScreen({super.key, this.selectedGroup});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = '';
  List<CategoryGroup> _groups = [];
  List<CategoryGroup> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    _groups = MockData.categoryGroups;
    _filteredGroups = _groups;
    _searchCtrl.addListener(_onFilterChange);
  }

  void _onFilterChange() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filter = q;
      if (q.isEmpty) {
        _filteredGroups = _groups;
      } else {
        _filteredGroups = _groups
            .map((g) => CategoryGroup(
                  name: g.name,
                  categories: g.categories
                      .where((c) =>
                          c.name.toLowerCase().contains(q) ||
                          c.groupName.toLowerCase().contains(q))
                      .toList(),
                ))
            .where((g) => g.categories.isNotEmpty)
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.categoriesTitle,
          style: AppTextStyles.headlineSmall,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: AppStrings.filterCategories,
                  hintStyle:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textLight, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filteredGroups.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: _filteredGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = _filteredGroups[groupIndex];
                return _CategoryGroup(group: group);
              },
            ),
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  final CategoryGroup group;

  const _CategoryGroup({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            group.name,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...group.categories.map((cat) => _CategoryItem(category: cat)),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryModel category;

  const _CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/search?q=${Uri.encodeComponent(category.name)}&category=${Uri.encodeComponent(category.groupName)}',
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CategoryIcon(
                  iconPath: category.iconPath,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${category.providerCount} ${AppStrings.providers}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64, color: AppColors.textLight.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('Aucune catégorie trouvée', style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}

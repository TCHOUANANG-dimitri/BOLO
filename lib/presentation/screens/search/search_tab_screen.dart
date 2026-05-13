import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/mock_data.dart';
import '../../providers/search_provider.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/category_icon.dart';

class SearchTabScreen extends StatefulWidget {
  const SearchTabScreen({super.key});

  @override
  State<SearchTabScreen> createState() => _SearchTabScreenState();
}

class _SearchTabScreenState extends State<SearchTabScreen> {
  final _searchCtrl = TextEditingController();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().search('');
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _doSearch(String q) {
    context.read<SearchProvider>().search(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppStrings.search, style: AppTextStyles.headlineSmall),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _SearchField(
              controller: _searchCtrl,
              onChanged: _doSearch,
              onClear: () {
                _searchCtrl.clear();
                _doSearch('');
              },
            ),
          ),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, search, _) {
          if (_searchCtrl.text.isEmpty) {
            return _SearchSuggestions();
          }
          return _SearchResults(search: search);
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: false,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textLight, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.textLight, size: 20),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groups = MockData.categoryGroups;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explorer les catégories', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          ...groups.map((group) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...group.categories.map((cat) => _CategoryRow(
                        name: cat.name,
                        iconPath: cat.iconPath,
                        count: cat.providerCount,
                        onTap: () => context.push(
                          '/search?category=${Uri.encodeComponent(cat.groupName)}&q=${Uri.encodeComponent(cat.name)}',
                        ),
                      )),
                  const SizedBox(height: 20),
                ],
              )),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final String iconPath;
  final int count;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.name,
    required this.iconPath,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CategoryIcon(iconPath: iconPath, size: 22),
        ),
      ),
      title: Text(name, style: AppTextStyles.titleSmall),
      subtitle: Text('$count prestataires', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textLight, size: 20),
      onTap: onTap,
    );
  }
}

class _SearchResults extends StatelessWidget {
  final SearchProvider search;

  const _SearchResults({required this.search});

  @override
  Widget build(BuildContext context) {
    if (search.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (search.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: AppColors.textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Aucun résultat', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Essayez un autre terme de recherche',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: search.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => ProviderCard(provider: search.results[i]),
    );
  }
}

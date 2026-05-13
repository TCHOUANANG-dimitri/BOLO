import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/search_provider.dart';
import '../../widgets/provider_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final String? categoryGroup;

  const SearchResultsScreen({
    super.key,
    required this.initialQuery,
    this.categoryGroup,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().search(
            widget.initialQuery,
            categoryGroup: widget.categoryGroup,
          );
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.searchResults, style: AppTextStyles.headlineSmall),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onSubmitted: (q) =>
                          context.read<SearchProvider>().search(q),
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        hintStyle: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textLight),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textLight, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, search, _) {
          return Column(
            children: [
              // Filter chips
              _FilterChips(search: search),

              // Results count
              if (!search.isLoading && search.results.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${search.results.length} ${AppStrings.found}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Results
              Expanded(
                child: search.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      )
                    : search.results.isEmpty
                        ? _EmptyResults()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: search.results.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                ProviderCard(provider: search.results[i]),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final SearchProvider search;

  const _FilterChips({required this.search});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (AppStrings.all, SearchFilter.all),
      (AppStrings.recommended, SearchFilter.popular),
      (AppStrings.nearMe, SearchFilter.near),
      (AppStrings.newProviders, SearchFilter.newProviders),
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, filter) = filters[i];
          final isActive = search.activeFilter == filter;
          return GestureDetector(
            onTap: () => context.read<SearchProvider>().setFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded,
              size: 72, color: AppColors.textLight.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(AppStrings.noResults, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Essayez un autre terme ou modifiez les filtres',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => context.read<SearchProvider>().clearFilters(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réinitialiser les filtres'),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  bool _onlineOnly = false;
  bool _verifiedOnly = false;
  double _maxPrice = 100000;
  double _minRating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtres', style: AppTextStyles.headlineSmall),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _onlineOnly = false;
                        _verifiedOnly = false;
                        _maxPrice = 100000;
                        _minRating = 0;
                      });
                    },
                    child: Text(
                      'Réinitialiser',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Online only
              _SwitchRow(
                label: 'En ligne uniquement',
                value: _onlineOnly,
                onChanged: (v) => setState(() => _onlineOnly = v),
              ),
              const SizedBox(height: 12),

              // Verified only
              _SwitchRow(
                label: 'Prestataires vérifiés',
                value: _verifiedOnly,
                onChanged: (v) => setState(() => _verifiedOnly = v),
              ),
              const SizedBox(height: 20),

              // Price range
              Text('Prix maximum: ${_maxPrice.toInt()} FCFA/h',
                  style: AppTextStyles.titleSmall),
              Slider(
                value: _maxPrice,
                min: 5000,
                max: 100000,
                divisions: 19,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _maxPrice = v),
              ),
              const SizedBox(height: 8),

              // Min rating
              Text(
                  'Note minimum: ${_minRating == 0 ? "Toutes" : _minRating.toStringAsFixed(1)}',
                  style: AppTextStyles.titleSmall),
              Slider(
                value: _minRating,
                min: 0,
                max: 5,
                divisions: 10,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _minRating = v),
              ),
              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final search = context.read<SearchProvider>();
                    search.setOnlineOnly(_onlineOnly ? true : null);
                    search.setVerifiedOnly(_verifiedOnly ? true : null);
                    search.setMaxPrice(
                        _maxPrice < 100000 ? _maxPrice.toInt() : null);
                    search.setMinRating(_minRating > 0 ? _minRating : null);
                    Navigator.pop(context);
                  },
                  child: const Text('Appliquer les filtres'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.titleSmall),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

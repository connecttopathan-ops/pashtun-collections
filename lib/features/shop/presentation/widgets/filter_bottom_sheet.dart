import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/products_provider.dart';

Future<FilterOptions?> showFilterSheet(
    BuildContext context, FilterOptions current) {
  return showModalBottomSheet<FilterOptions>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FilterBottomSheet(current: current),
  );
}

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions current;
  const FilterBottomSheet({super.key, required this.current});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _sortKey;
  late bool _reverse;
  late String? _selectedSize;
  late bool _saleOnly;

  static const _sortOptions = [
    _SortOption('Default', 'COLLECTION_DEFAULT', false),
    _SortOption('Price: Low to High', 'PRICE', false),
    _SortOption('Price: High to Low', 'PRICE', true),
    _SortOption('Newest', 'CREATED', true),
    _SortOption('Best Selling', 'BEST_SELLING', false),
  ];

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];

  @override
  void initState() {
    super.initState();
    _sortKey = widget.current.sortKey;
    _reverse = widget.current.reverse;
    _selectedSize = widget.current.selectedSize;
    _saleOnly = widget.current.saleOnly;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter & Sort',
                      style: AppTextStyles.headlineMedium),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortKey = 'COLLECTION_DEFAULT';
                        _reverse = false;
                        _selectedSize = null;
                        _saleOnly = false;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Sort
                  Text('Sort By', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortOptions.map((opt) {
                      final isSelected =
                          _sortKey == opt.key && _reverse == opt.reverse;
                      return ChoiceChip(
                        label: Text(opt.label),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _sortKey = opt.key;
                            _reverse = opt.reverse;
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Size
                  Text('Size', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedSize = isSelected ? null : size;
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Sale only
                  SwitchListTile(
                    value: _saleOnly,
                    onChanged: (v) => setState(() => _saleOnly = v),
                    title: Text('Sale Items Only',
                        style: AppTextStyles.labelLarge),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      FilterOptions(
                        sortKey: _sortKey,
                        reverse: _reverse,
                        selectedSize: _selectedSize,
                        saleOnly: _saleOnly,
                      ),
                    );
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption {
  final String label;
  final String key;
  final bool reverse;
  const _SortOption(this.label, this.key, this.reverse);
}

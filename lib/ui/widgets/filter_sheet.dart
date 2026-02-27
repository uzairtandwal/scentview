import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FilterSheet extends StatefulWidget {
  final Function(String category, double maxPrice, String sortBy) onApply;

  // ✅ Accept initial values so reopening sheet restores last filter
  final String initialCategory;
  final double initialMaxPrice;
  final String initialSortBy;

  const FilterSheet({
    super.key,
    required this.onApply,
    this.initialCategory = 'All',
    this.initialMaxPrice = 50000,
    this.initialSortBy = 'Newest',
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _selectedCategory;
  late double _maxPrice;
  late String _sortBy;

  static const double _minPrice = 500;
  static const double _maxPriceLimit = 50000;
  static const int _priceDivisions = 99;

  static const List<String> _categories = ['All', 'Men', 'Women', 'Unisex'];
  static const List<({String label, IconData icon})> _sortOptions = [
    (label: 'Newest', icon: Iconsax.clock),
    (label: 'Price: Low to High', icon: Iconsax.arrow_up_2),
    (label: 'Price: High to Low', icon: Iconsax.arrow_down_2),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _maxPrice = widget.initialMaxPrice;
    _sortBy = widget.initialSortBy;
  }

  void _reset() => setState(() {
        _selectedCategory = 'All';
        _maxPrice = _maxPriceLimit;
        _sortBy = 'Newest';
      });

  void _apply() {
    widget.onApply(_selectedCategory, _maxPrice, _sortBy);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ──────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Scrollable Content ───────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title Row ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Products',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _reset,
                        icon: Icon(Iconsax.refresh, size: 16, color: primary),
                        label: Text(
                          'Reset',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Category ───────────────────────────────
                  _SectionLabel(label: 'Category', icon: Iconsax.category),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary
                                : primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : primary.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.75),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── Price Range ────────────────────────────
                  _SectionLabel(label: 'Price Range', icon: Iconsax.money),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PKR ${_minPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Up to PKR ${_maxPrice.toInt()}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ),
                      Text(
                        'PKR ${_maxPriceLimit.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: primary,
                      inactiveTrackColor: primary.withValues(alpha: 0.15),
                      thumbColor: primary,
                      overlayColor: primary.withValues(alpha: 0.12),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _maxPrice,
                      min: _minPrice,
                      max: _maxPriceLimit,
                      divisions: _priceDivisions,
                      onChanged: (val) => setState(() => _maxPrice = val),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Sort By ────────────────────────────────
                  _SectionLabel(label: 'Sort By', icon: Iconsax.sort),
                  const SizedBox(height: 12),
                  Column(
                    children: _sortOptions.map((opt) {
                      final isSelected = _sortBy == opt.label;
                      return GestureDetector(
                        onTap: () => setState(() => _sortBy = opt.label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withValues(alpha: 0.08)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? primary.withValues(alpha: 0.4)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                opt.icon,
                                size: 18,
                                color: isSelected
                                    ? primary
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                opt.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? primary
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.75),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Iconsax.tick_circle,
                                  size: 18,
                                  color: primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ── Apply Button ─────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              MediaQuery.paddingOf(context).bottom + 20,
            ),
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
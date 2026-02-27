import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../database/db_helper.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/product_card.dart';
import 'widgets/product_shimmer.dart';

class ShopScreen extends StatefulWidget {
  static const routeName = '/shop';
  final String searchQuery;

  const ShopScreen({super.key, this.searchQuery = ''});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Product> _allProducts = [];
  bool _isLoading = true;
  bool _hasError = false;

  // ── Filter state ───────────────────────────────────────────────────────────
  String _selectedCategory = 'All';
  double _maxPrice         = 50000;
  String _sortBy           = 'Newest';
  String _currentSearch    = '';

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _currentSearch = widget.searchQuery;
    _searchCtrl.text = widget.searchQuery;
    _fetchProducts();

    if (_currentSearch.isNotEmpty) {
      DBHelper().saveSearchQuery(_currentSearch);
    }
  }

  // ✅ Parent (MainAppScreen) se query update hone par reflect karo
  @override
  void didUpdateWidget(ShopScreen old) {
    super.didUpdateWidget(old);
    if (old.searchQuery != widget.searchQuery) {
      setState(() {
        _currentSearch = widget.searchQuery;
        _searchCtrl.text = widget.searchQuery;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────────────────────
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError  = false;
    });
    try {
      final products = await _api.fetchProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _isLoading   = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError  = true;
        _isLoading = false;
      });
    }
  }

  // ── Filtered & sorted products ─────────────────────────────────────────────
  List<Product> get _displayed {
    var list = _allProducts.where((p) {
      final matchSearch = p.name
          .toLowerCase()
          .contains(_currentSearch.trim().toLowerCase());
      final matchCat = _selectedCategory == 'All' ||
          p.category?.name == _selectedCategory;
      final matchPrice =
          (p.salePrice ?? p.originalPrice) <= _maxPrice;
      return matchSearch && matchCat && matchPrice;
    }).toList();

    switch (_sortBy) {
      case 'Price: Low to High':
        list.sort((a, b) =>
            (a.salePrice ?? a.originalPrice)
                .compareTo(b.salePrice ?? b.originalPrice));
        break;
      case 'Price: High to Low':
        list.sort((a, b) =>
            (b.salePrice ?? b.originalPrice)
                .compareTo(a.salePrice ?? a.originalPrice));
        break;
      case 'Name A-Z':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  // ── Search overlay ─────────────────────────────────────────────────────────
  void _openSearchOverlay() async {
    final history = await DBHelper().getRecentSearches();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchOverlay(
        history: history,
        onSelect: (query) {
          setState(() {
            _currentSearch = query;
            _searchCtrl.text = query;
          });
          DBHelper().saveSearchQuery(query);
        },
        onClear: () async {
          await DBHelper().clearSearchHistory();
          // Reopen with empty history
          if (mounted) _openSearchOverlay();
        },
      ),
    );
  }

  // ── Filter sheet ───────────────────────────────────────────────────────────
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        onApply: (cat, price, sort) {
          setState(() {
            _selectedCategory = cat;
            _maxPrice         = price;
            _sortBy           = sort;
          });
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final primary  = theme.colorScheme.primary;
    final products = _displayed;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      // ✅ No AppBar here — CustomAppBar in MainAppScreen handles it
      body: Column(
        children: [
          // ── Search bar + filter row ───────────────────────
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: GestureDetector(
                    onTap: _openSearchOverlay,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline
                              .withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Iconsax.search_normal,
                              size: 18,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _currentSearch.isEmpty
                                  ? 'Search perfumes...'
                                  : _currentSearch,
                              style: TextStyle(
                                fontSize: 14,
                                color: _currentSearch.isEmpty
                                    ? theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4)
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.85),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_currentSearch.isNotEmpty)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _currentSearch = ''),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Filter button
                Material(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _openFilterSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Iconsax.filter_edit,
                          size: 20, color: primary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Results count + active filters ───────────────
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
              child: Row(
                children: [
                  Text(
                    '${products.length} item${products.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                  const Spacer(),
                  if (_selectedCategory != 'All' || _sortBy != 'Newest')
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = 'All';
                        _maxPrice         = 50000;
                        _sortBy           = 'Newest';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded,
                                size: 12, color: primary),
                            const SizedBox(width: 4),
                            Text(
                              'Clear filters',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ── Content ───────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: ProductShimmerGrid(itemCount: 6),
                  )
                : _hasError
                    ? _ErrorState(onRetry: _fetchProducts)
                    : products.isEmpty
                        ? _NoResults(
                            onReset: () =>
                                setState(() => _currentSearch = ''),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchProducts,
                            color: primary,
                            child: CustomScrollView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 10, 16, 80),
                                  sliver: SliverGrid(
                                    delegate:
                                        SliverChildBuilderDelegate(
                                      (_, i) => ProductCard(
                                        product: products[i],
                                        isCompact: false,
                                        showFavorite: true,
                                        showQuickAdd: true,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ProductDetailScreen(
                                              product: products[i],
                                              allProducts: _allProducts,
                                            ),
                                          ),
                                        ),
                                      ),
                                      childCount: products.length,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: 0.70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Overlay ───────────────────────────────────────────────────────────
class _SearchOverlay extends StatelessWidget {
  final List<String> history;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  const _SearchOverlay({
    required this.history,
    required this.onSelect,
    required this.onClear,
  });

  static const _popular = [
    'Oud Fragrances',
    'Summer Specials',
    'Luxury Collection',
    'Fresh & Light',
  ];

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Recent searches ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              if (history.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onClear();
                  },
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No recent searches',
                style: TextStyle(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.45),
                  fontSize: 13,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: history
                  .map((q) => _HistoryChip(
                        label: q,
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                          onSelect(q);
                        },
                      ))
                  .toList(),
            ),

          const SizedBox(height: 20),

          // ── Popular ──────────────────────────────────────
          Text(
            'Popular Searches',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),

          ..._popular.map((label) => _PopularTile(
                label: label,
                theme: theme,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(label);
                },
              )),
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;

  const _HistoryChip({
    required this.label,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.clock,
              size: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularTile extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;

  const _PopularTile({
    required this.label,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE65100).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Iconsax.flash_1,
            color: Color(0xFFE65100), size: 16),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        size: 14,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ─── No Results ───────────────────────────────────────────────────────────────
class _NoResults extends StatelessWidget {
  final VoidCallback onReset;
  const _NoResults({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.search_status,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No perfumes found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search\nor clear your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Iconsax.refresh, size: 16),
              label: const Text(
                'Show All Products',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.wifi_square,
                  size: 32, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
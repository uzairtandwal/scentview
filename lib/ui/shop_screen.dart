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
  double _maxPrice         = 100000;
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
          .contains(_currentSearch.trim().toLowerCase()) || 
          (p.category?.toLowerCase().contains(_currentSearch.trim().toLowerCase()) ?? false);
      
      final matchCat = _selectedCategory == 'All' ||
          p.category?.toLowerCase() == _selectedCategory.toLowerCase();
      
      final matchPrice = (p.price) <= _maxPrice;
      
      return matchSearch && matchCat && matchPrice;
    }).toList();

    switch (_sortBy) {
      case 'Price: Low to High':
        list.sort((a, b) => (a.price).compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => (b.price).compareTo(a.price));
        break;
      case 'Name A-Z':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openFilterSheet,
        backgroundColor: primary,
        child: const Icon(Iconsax.filter_edit, color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Results count ──────────────────────────────
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${products.length} fragrances found',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_selectedCategory != 'All' || _sortBy != 'Newest' || _currentSearch.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = 'All';
                        _maxPrice         = 100000;
                        _sortBy           = 'Newest';
                        _currentSearch    = '';
                        _searchCtrl.clear();
                      }),
                      child: Text(
                        'Reset Filters',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.error,
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
                            onReset: () {
                              _searchCtrl.clear();
                              setState(() {
                                _currentSearch = '';
                                _selectedCategory = 'All';
                              });
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchProducts,
                            color: primary,
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                                  sliver: SliverGrid(
                                    delegate: SliverChildBuilderDelegate(
                                      (_, i) => ProductCard(
                                        product: products[i],
                                        isCompact: false,
                                        showFavorite: true,
                                        showQuickAdd: true,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailScreen(
                                              product: products[i],
                                              allProducts: _allProducts,
                                            ),
                                          ),
                                        ),
                                      ),
                                      childCount: products.length,
                                    ),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: 0.68,
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
            Icon(Iconsax.search_status, size: 48, color: theme.colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No fragrances found',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            TextButton(onPressed: onReset, child: const Text('Clear Search', style: TextStyle(fontWeight: FontWeight.bold))),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.wifi_square, size: 40, color: Colors.red.shade300),
          const SizedBox(height: 16),
          const Text('Could not load products'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

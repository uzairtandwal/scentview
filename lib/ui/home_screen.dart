import 'package:flutter/material.dart' hide Category;
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/ui/product_list_screen.dart';
import '../models/banner.dart' as model;
import '../models/category.dart';
import '../services/api_service.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/product_card.dart';
import 'widgets/product_shimmer.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> _categories = [];
  List<Product> _featuredProducts = [];
  List<model.Banner> _banners = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _hasShownSalePopup = false;
  bool _isTokenSynced = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _checkAndSyncToken();
  }

  // ── FCM Token ──────────────────────────────────────────────────────────────
  Future<void> _checkAndSyncToken() async {
    if (_isTokenSynced) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _api.updateFcmToken(token);
        if (mounted) setState(() => _isTokenSynced = true);
      }
    } catch (_) {
      // Silent fail — non-critical
    }
  }

  // ── Load Data ──────────────────────────────────────────────────────────────
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await Future.wait([
        _api.fetchCategories(),
        _api.fetchFeaturedProducts(),
        _api.fetchBanners(),
        _api.fetchProducts(),
      ]);

      if (!mounted) return;
      setState(() {
        _categories     = results[0] as List<Category>;
        _featuredProducts = results[1] as List<Product>;
        _banners        = results[2] as List<model.Banner>;
        _allProducts    = results[3] as List<Product>;
        _filteredProducts = _allProducts;
        _isLoading      = false;
      });

      _showSalePopupIfNeeded();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError      = true;
        _errorMessage  = e.toString();
        _isLoading     = false;
      });
    }
  }

  // ── Filters ────────────────────────────────────────────────────────────────
  void _filterByCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _filteredProducts = categoryId == null
          ? _allProducts
          : _allProducts
              .where((p) => p.categoryId.toString() == categoryId)
              .toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredProducts = query.isEmpty
          ? _allProducts
          : _allProducts
              .where((p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  // ── Sale Popup ─────────────────────────────────────────────────────────────
  void _showSalePopupIfNeeded() {
    if (_hasShownSalePopup) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _allProducts.isEmpty || _hasShownSalePopup) return;
      final saleProducts = _allProducts
          .where((p) =>
              p.salePrice != null &&
              p.salePrice! > 0 &&
              p.salePrice! < p.originalPrice)
          .toList();
      if (saleProducts.isNotEmpty) {
        _hasShownSalePopup = true;
        _showSaleDialog(saleProducts.first);
      }
    });
  }

  void _showSaleDialog(Product product) {
    final discount = ((product.originalPrice - product.salePrice!) /
            product.originalPrice *
            100)
        .round();

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sale',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => _SaleDialog(
        product: product,
        discount: discount,
        onViewDeal: () {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: product,
                allProducts: _allProducts,
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.light ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        drawer: const Drawer(),
        appBar: CustomAppBar(
          onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          onSearchChanged: _onSearchChanged,
          showLogo: true,
        ),
        body: RefreshIndicator(
          onRefresh: _loadAllData,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Loading ───────────────────────────────────
              if (_isLoading)
                const SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: ProductShimmerGrid(itemCount: 6),
                  ),
                ),

              // ── Error ─────────────────────────────────────
              if (_hasError && !_isLoading)
                SliverFillRemaining(
                  child: _ErrorState(
                    message: _errorMessage,
                    onRetry: _loadAllData,
                  ),
                ),

              // ── Content ───────────────────────────────────
              if (!_isLoading && !_hasError) ...[
                // Banners
                if (_banners.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: BannerCarousel(
                        banners: _banners,
                        onTap: (_) {},
                        height: MediaQuery.sizeOf(context).width < 600
                            ? 180
                            : 220,
                        autoPlay: true,
                        showIndicators: true,
                      ),
                    ),
                  ),

                // Featured
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Featured Collection',
                    subtitle: 'Premium fragrances hand-picked for you',
                    icon: Iconsax.star,
                    showViewAll: _featuredProducts.length > 4,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductListScreen(
                          initialProducts: _featuredProducts,
                          screenTitle: 'Featured',
                        ),
                      ),
                    ),
                  ),
                ),
                if (_featuredProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _FeaturedCarousel(
                      products: _featuredProducts,
                      allProducts: _allProducts,
                    ),
                  ),

                // Categories
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Shop by Category',
                    subtitle: 'Find your perfect scent family',
                    icon: Iconsax.category,
                    showViewAll: false,
                  ),
                ),
                if (_categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _CategoryList(
                      categories: _categories,
                      selectedId: _selectedCategoryId,
                      onSelect: _filterByCategory,
                    ),
                  ),

                // All Products
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'All Products',
                    subtitle: '${_filteredProducts.length} fragrances available',
                    icon: Iconsax.shop,
                    showViewAll: false,
                  ),
                ),
                _filteredProducts.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _NoProducts(),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => ProductCard(
                              product: _filteredProducts[i],
                              isCompact: false,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    product: _filteredProducts[i],
                                    allProducts: _allProducts,
                                  ),
                                ),
                              ),
                              showFavorite: true,
                              showQuickAdd: true,
                            ),
                            childCount: _filteredProducts.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.68,
                          ),
                        ),
                      ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.paddingOf(context).bottom + 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sale Dialog ──────────────────────────────────────────────────────────────
class _SaleDialog extends StatelessWidget {
  final Product product;
  final int discount;
  final VoidCallback onViewDeal;

  const _SaleDialog({
    required this.product,
    required this.discount,
    required this.onViewDeal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(28),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: errorColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: errorColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hot Deal!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 120,
                      height: 120,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image_not_supported_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Rs ${product.originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.45),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$discount% OFF',
                          style: TextStyle(
                            color: errorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Rs ${product.salePrice!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: errorColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Later',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onViewDeal,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View Deal',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.showViewAll,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (showViewAll && onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: primary, size: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Featured Carousel ────────────────────────────────────────────────────────
class _FeaturedCarousel extends StatelessWidget {
  final List<Product> products;
  final List<Product> allProducts;

  const _FeaturedCarousel({
    required this.products,
    required this.allProducts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.45,
          child: ProductCard(
            product: products[i],
            isCompact: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(
                  product: products[i],
                  allProducts: allProducts,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category List ────────────────────────────────────────────────────────────
class _CategoryList extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  const _CategoryList({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isAll = i == 0;
          final isSelected =
              isAll ? selectedId == null : selectedId == categories[i - 1].id;
          final label = isAll ? 'All' : categories[i - 1].name;

          return GestureDetector(
            onTap: () => onSelect(isAll ? null : categories[i - 1].id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── No Products ──────────────────────────────────────────────────────────────
class _NoProducts extends StatelessWidget {
  const _NoProducts();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.search_normal,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.wifi_square,
                size: 32,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
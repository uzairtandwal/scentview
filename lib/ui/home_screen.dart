import 'dart:async';
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
  final String searchQuery;
  const HomeScreen({super.key, this.searchQuery = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> _categories       = [];
  List<Product>  _featuredProducts = [];
  List<model.Banner> _banners      = [];
  List<Product>  _allProducts      = [];
  List<Product>  _filteredProducts = [];
  String? _selectedCategoryId;
  bool    _isLoading               = true;
  bool    _hasError                = false;
  String  _errorMessage            = '';
  bool    _hasShownSalePopup       = false;
  bool    _isTokenSynced           = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _checkAndSyncToken();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _applyFilters();
    }
  }

  Future<void> _checkAndSyncToken() async {
    if (_isTokenSynced) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _api.updateFcmToken(token);
        if (mounted) setState(() => _isTokenSynced = true);
      }
    } catch (_) {}
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    
    // ✅ Har refresh par popup ko dobara allow karein
    _hasShownSalePopup = false;

    try {
      final localBanners    = await _api.fetchBannersLocal();
      final localCategories = await _api.fetchCategoriesLocal();
      final localProducts   = await _api.fetchProductsLocal();
      final localFeatured   = localProducts.where((p) => p.isFeatured).toList();
      if (mounted && (localProducts.isNotEmpty || localBanners.isNotEmpty)) {
        setState(() {
          _banners         = localBanners;
          _categories      = localCategories;
          _allProducts     = localProducts;
          _featuredProducts = localFeatured;
          _filteredProducts = _computeFiltered(localProducts, localCategories);
          _isLoading       = false;
        });
        // ✅ Local data milte hi popup check karein (taake intezar na karna paray)
        _showSalePopupIfNeeded();
      }
    } catch (e) { debugPrint("Local Data Error: $e"); }

    try {
      final results = await Future.wait([
        _api.fetchCategories().catchError((_) => <Category>[]),
        _api.fetchFeaturedProducts().catchError((_) => <Product>[]),
        _api.fetchBanners().catchError((_) => <model.Banner>[]),
        _api.fetchProducts().catchError((_) => <Product>[]),
      ]).timeout(const Duration(seconds: 45));

      if (!mounted) return;
      final categories = results[0] as List<Category>;
      final featured   = results[1] as List<Product>;
      final banners    = results[2] as List<model.Banner>;
      final all        = results[3] as List<Product>;
      final filtered   = _computeFiltered(all, categories);

      setState(() {
        _categories       = categories;
        _featuredProducts = featured;
        _banners          = banners;
        _allProducts      = all;
        _filteredProducts = filtered;
        _isLoading        = false;
        _hasError         = false;
        if (categories.isEmpty && featured.isEmpty && banners.isEmpty &&
            all.isEmpty && _allProducts.isEmpty) {
          _hasError     = true;
          _errorMessage = "No data received. Please check your connection.";
        }
      });
      // ✅ Fresh data aane par bhi aik baar check karein agar local se nahi aaya tha
      _showSalePopupIfNeeded();
    } catch (e) {
      debugPrint("Home Data Loading Error: $e");
      if (!mounted) return;
      if (_allProducts.isEmpty) {
        setState(() {
          _hasError     = true;
          _errorMessage = "Connection timeout. Please try again.";
          _isLoading    = false;
        });
      }
    }
  }

  List<Product> _computeFiltered(
      List<Product> products, List<Category> categories) {
    return products.where((p) {
      bool matchesCategory = true;
      if (_selectedCategoryId != null) {
        final category = categories.firstWhere(
          (c) => c.id == _selectedCategoryId,
          orElse: () => Category(id: '', name: ''),
        );
        if (category.id.isNotEmpty) {
          matchesCategory =
              p.category?.toLowerCase() == category.name.toLowerCase();
        }
      }
      bool matchesSearch = true;
      if (widget.searchQuery.isNotEmpty) {
        final q = widget.searchQuery.toLowerCase();
        matchesSearch = p.name.toLowerCase().contains(q) ||
            (p.description?.toLowerCase().contains(q) ?? false) ||
            (p.category?.toLowerCase().contains(q) ?? false);
      }
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _applyFilters() =>
      setState(() => _filteredProducts = _computeFiltered(_allProducts, _categories));

  void _filterByCategory(String? id) { _selectedCategoryId = id; _applyFilters(); }

  // ── Sale Popup ─────────────────────────────────────────────────────────────
  void _showSalePopupIfNeeded() {
    if (_hasShownSalePopup) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _allProducts.isEmpty || _hasShownSalePopup) return;
      final saleProducts = _allProducts
          .where((p) =>
              p.salePrice != null && p.salePrice! > 0 && p.salePrice! < p.price)
          .toList();
      if (saleProducts.isEmpty) return;
      
      _hasShownSalePopup = true;
      saleProducts.shuffle(); // ✅ Randomize the sale products
      _showSaleDialog(saleProducts.first);
    });
  }

  void _showSaleDialog(Product product) {
    final discount =
        ((product.price - product.salePrice!) / product.price * 100).round();

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sale',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.82, end: 1.0).animate(
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
    final theme      = Theme.of(context);
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
        body: RefreshIndicator(
          onRefresh: _loadAllData,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (_isLoading)
                const SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(child: ProductShimmerGrid(itemCount: 6)),
                ),
              if (_hasError && !_isLoading)
                SliverFillRemaining(
                  child: _ErrorState(message: _errorMessage, onRetry: _loadAllData),
                ),
              if (!_isLoading && !_hasError) ...[
                if (_banners.isNotEmpty && widget.searchQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: BannerCarousel(
                        banners: _banners,
                        onTap: (_) {},
                        height: MediaQuery.sizeOf(context).width < 600 ? 180 : 220,
                        autoPlay: true,
                        showIndicators: true,
                      ),
                    ),
                  ),
                if (_featuredProducts.isNotEmpty &&
                    widget.searchQuery.isEmpty &&
                    _selectedCategoryId == null) ...[
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
                  SliverToBoxAdapter(
                    child: _FeaturedCarousel(
                      products: _featuredProducts,
                      allProducts: _allProducts,
                    ),
                  ),
                ],
                if (_categories.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Shop by Category',
                      subtitle: 'Find your perfect scent family',
                      icon: Iconsax.category,
                      showViewAll: false,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _CategoryList(
                      categories: _categories,
                      selectedId: _selectedCategoryId,
                      onSelect: _filterByCategory,
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: widget.searchQuery.isNotEmpty ? 'Search Results' : 'All Products',
                    subtitle: '${_filteredProducts.length} fragrances found',
                    icon: widget.searchQuery.isNotEmpty
                        ? Iconsax.search_normal
                        : Iconsax.shop,
                    showViewAll: false,
                  ),
                ),
                _filteredProducts.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false, child: _NoProducts())
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
                      height: MediaQuery.paddingOf(context).bottom + 20),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ─── SALE DIALOG — ULTRA ATTRACTIVE ──────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _SaleDialog extends StatefulWidget {
  final Product product;
  final int discount;
  final VoidCallback onViewDeal;

  const _SaleDialog({
    required this.product,
    required this.discount,
    required this.onViewDeal,
  });

  @override
  State<_SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<_SaleDialog>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _badgeCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _shimmerAnim;
  late final Animation<double> _badgeAnim;

  // ── Countdown — 2h 47m 33s ────────────────────────────────────────────────
  late Timer _timer;
  int _secondsLeft = 2 * 3600 + 47 * 60 + 33;

  // ── Fire palette ───────────────────────────────────────────────────────────
  static const _fireRed    = Color(0xFFE53935);
  static const _fireOrange = Color(0xFFFF6D00);
  static const _fireAmber  = Color(0xFFFFAB00);

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _shimmerAnim = Tween(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    _badgeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _badgeAnim = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut));

    Future.delayed(const Duration(milliseconds: 350),
        () { if (mounted) _badgeCtrl.forward(); });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() { if (_secondsLeft > 0) _secondsLeft--; else _timer.cancel(); });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _badgeCtrl.dispose();
    _timer.cancel();
    super.dispose();
  }

  String get _h => (_secondsLeft ~/ 3600).toString().padLeft(2, '0');
  String get _m => ((_secondsLeft % 3600) ~/ 60).toString().padLeft(2, '0');
  String get _s => (_secondsLeft % 60).toString().padLeft(2, '0');
  bool   get _urgent => _secondsLeft < 600;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size  = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06, vertical: 48,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Main card ─────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _fireRed.withValues(alpha: 0.3),
                  blurRadius: 48,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Gradient header ────────────────────────────────────
                  _buildHeader(theme),

                  // ── Product row ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildProductRow(theme),
                  ),

                  // ── FOMO bar ───────────────────────────────────────────
                  _buildFomoBar(),

                  // ── Buttons ────────────────────────────────────────────
                  _buildButtons(theme),
                ],
              ),
            ),
          ),

          // ── Floating discount badge ────────────────────────────────────────
          Positioned(
            top: -28, left: 0, right: 0,
            child: Center(
              child: ScaleTransition(
                scale: _badgeAnim,
                child: _buildBadge(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFFF6D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(top: -20, right: 10,
            child: Container(width: 90, height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06)))),
          Positioned(bottom: -16, right: 70,
            child: Container(width: 55, height: 55,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04)))),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + close
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'LIMITED TIME SALE!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Countdown
              Row(
                children: [
                  Icon(Iconsax.timer_1,
                      color: Colors.white.withValues(alpha: 0.9), size: 13),
                  const SizedBox(width: 6),
                  Text(
                    'Ends in  ',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  _timerBox(_h), _colon(), _timerBox(_m), _colon(), _timerBox(_s),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timerBox(String val) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: _urgent
          ? Colors.white.withValues(alpha: 0.95)
          : Colors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(val,
      style: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1,
        color: _urgent ? _fireRed : Colors.white,
      )),
  );

  Widget _colon() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 2),
    child: Text(':', style: TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
  );

  // ── Product row ────────────────────────────────────────────────────────────
  Widget _buildProductRow(ThemeData theme) {
    final savings = widget.product.price - widget.product.salePrice!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            color: _fireRed.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _fireRed.withValues(alpha: 0.18), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: widget.product.imageUrl.isNotEmpty
                ? Image.network(widget.product.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Iconsax.shop,
                        color: _fireRed.withValues(alpha: 0.35), size: 34))
                : Icon(Iconsax.shop,
                    color: _fireRed.withValues(alpha: 0.35), size: 34),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(widget.product.name,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1.3, letterSpacing: -0.2,
                )),

              const SizedBox(height: 8),

              // Strike price
              Text(
                'Rs ${widget.product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 12, fontWeight: FontWeight.w500,
                ),
              ),

              // Sale price
              Text(
                'Rs ${widget.product.salePrice!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900,
                  color: _fireRed, letterSpacing: -0.5, height: 1.1,
                ),
              ),

              const SizedBox(height: 6),

              // You save pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _fireAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _fireAmber.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '🎉  You save Rs ${savings.toStringAsFixed(0)}!',
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800,
                    color: Color(0xFF7B5800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── FOMO bar ────────────────────────────────────────────────────────────────
  Widget _buildFomoBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _fireOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _fireOrange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _PulseDot(color: _fireOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '🔥  24 people are viewing this right now!',
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: _fireOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Buttons ─────────────────────────────────────────────────────────────────
  Widget _buildButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          // Maybe Later
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
              ),
              child: Text('Later',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )),
            ),
          ),

          const SizedBox(width: 12),

          // Grab Deal — pulse
          Expanded(
            flex: 3,
            child: ScaleTransition(
              scale: _pulseAnim,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: widget.onViewDeal,
                  borderRadius: BorderRadius.circular(14),
                  highlightColor: Colors.white.withValues(alpha: 0.15),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  child: Ink(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_fireRed, _fireOrange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _fireRed.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🛍️', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text('Grab This Deal!',
                          style: TextStyle(
                            color: Colors.white, fontSize: 13,
                            fontWeight: FontWeight.w900, letterSpacing: 0.2,
                          )),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating badge ──────────────────────────────────────────────────────────
  Widget _buildBadge() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [_fireOrange, _fireRed]),
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: _fireRed.withValues(alpha: 0.55),
            blurRadius: 20, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.discount}%',
            style: const TextStyle(
              color: Colors.white, fontSize: 22,
              fontWeight: FontWeight.w900, height: 1,
            ),
          ),
          const Text('OFF',
            style: TextStyle(
              color: Colors.white, fontSize: 10,
              fontWeight: FontWeight.w900, letterSpacing: 1.5,
            )),
        ],
      ),
    );
  }
}

// ─── Pulse Dot ────────────────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 8, height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
    ),
  );
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title, required this.subtitle,
    required this.icon, required this.showViewAll, this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
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
                Text(title, style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface, letterSpacing: -0.3)),
                Text(subtitle, style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
          if (showViewAll && onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('View All', style: TextStyle(
                    color: primary, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios_rounded, color: primary, size: 10),
              ]),
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
  const _FeaturedCarousel({required this.products, required this.allProducts});

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
            product: products[i], isCompact: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                  product: products[i], allProducts: allProducts))),
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
    required this.categories, required this.selectedId, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isAll      = i == 0;
          final isSelected = isAll ? selectedId == null : selectedId == categories[i - 1].id;
          final label      = isAll ? 'All' : categories[i - 1].name;
          return GestureDetector(
            onTap: () => onSelect(isAll ? null : categories[i - 1].id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: primary.withValues(alpha: 0.28),
                        blurRadius: 10, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Text(label, style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600, fontSize: 13,
              )),
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Iconsax.search_normal, size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text('No products found', style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ]),
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.wifi_square, size: 32, color: theme.colorScheme.error),
          ),
          const SizedBox(height: 16),
          Text('Something went wrong', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Iconsax.refresh, size: 18),
            label: const Text('Try Again',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ]),
      ),
    );
  }
}
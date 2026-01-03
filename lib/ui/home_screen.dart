import 'package:flutter/material.dart' hide Category;
import 'package:flutter/services.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/ui/product_list_screen.dart';
import '../models/banner.dart' as model;
import '../models/category.dart';
import '../services/api_service.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/product_card.dart';
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

  Future<void>? _dataLoadingFuture;
  List<Category> _categories = [];
  List<Product> _featuredProducts = [];
  List<model.Banner> _banners = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  late bool _isMobile;
  bool _hasShownSalePopup = false; // ADDED: Track if popup shown

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

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
        _categories = results[0] as List<Category>;
        _featuredProducts = results[1] as List<Product>;
        _banners = results[2] as List<model.Banner>;
        _allProducts = results[3] as List<Product>;
        _filteredProducts = _allProducts;
        _isLoading = false;
      });

      // ✅ ADDED: Show sale popup after data loads
      _showSalePopupIfNeeded();

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterProductsByCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId == null) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((p) => p.categoryId.toString() == categoryId)
            .toList();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isMobile = MediaQuery.of(context).size.width < 600;
  }

  // ✅ ADDED: Sale Popup Functions
  void _showSalePopupIfNeeded() {
    if (_hasShownSalePopup) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _allProducts.isEmpty) return;

      final saleProducts = _allProducts.where((product) {
        return product.salePrice != null &&
               product.salePrice! > 0 &&
               product.salePrice! < product.originalPrice;
      }).toList();

      if (saleProducts.isNotEmpty && mounted && !_hasShownSalePopup) {
        _hasShownSalePopup = true;
        _showSaleDialog(saleProducts.first);
      }
    });
  }

  void _showSaleDialog(Product product) {
    final discount = ((product.originalPrice - product.salePrice!) /
        product.originalPrice * 100).round();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.red),
              const SizedBox(width: 10),
              const Text('HOT DEAL!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18,
                  )),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: product.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rs ${product.originalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Rs ${product.salePrice!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Limited time offer!',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(fontSize: 15)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: product,
                      allProducts: _allProducts,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Product', style: TextStyle(fontSize: 15)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        
        // ================ SIDE DRAWER ================
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                accountName: const Text("ScentView"),
                accountEmail: const Text("Welcome to our store"),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, color: Colors.deepPurple, size: 30),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: NetworkImage(cat.imageUrl ?? ''),
                        onBackgroundImageError: (_, __) {},
                        child: const Icon(Icons.category, size: 16, color: Colors.grey),
                      ),
                      title: Text(cat.name),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          ProductListScreen.routeName,
                          arguments: ProductListArgs(categoryKey: cat.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ================ MAIN BODY ================
        body: Column(
          children: [
            
            // --- STATUS BAR SPACER ---
            Container(
              color: Colors.white, 
              height: topPadding, 
            ),

            // ================ CUSTOM HEADER ================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 1. MENU BUTTON
                  InkWell(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        Icons.menu,
                        color: Colors.grey.shade700,
                        size: 22,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 2. SEARCH BAR
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search perfumes...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(bottom: 2),
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 3. APP LOGO
                  InkWell(
                    onTap: _loadAllData,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "SV",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================ SCROLLABLE CONTENT ================
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAllData,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    
                    if (_isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                    if (_hasError && !_isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(_errorMessage),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadAllData,
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (!_isLoading && !_hasError)
                      SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),

                          // 1. BANNER SECTION
                          if (_banners.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24, top: 8),
                              child: BannerCarousel(
                                banners: _banners,
                                onTap: (_) {},
                                height: _isMobile ? 180 : 220,
                                showIndicators: true,
                                autoPlay: true,
                              ),
                            ),

                          // 2. FEATURED PRODUCTS
                          if (_featuredProducts.isNotEmpty)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Featured Products', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                                      if (_featuredProducts.length > 4)
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(initialProducts: _featuredProducts, screenTitle: 'Featured')));
                                          },
                                          child: const Text('View All'),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildProductCarousel(_featuredProducts),
                                const SizedBox(height: 32),
                              ],
                            ),

                          // 3. CATEGORIES SECTION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text('Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(height: 12),
                              _buildCategoryList(),
                              const SizedBox(height: 32),
                            ],
                          ),

                          // 4. ALL PRODUCTS SECTION
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('All Products', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                                      Badge(
                                        label: Text(_filteredProducts.length.toString()),
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        textColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildProductsGrid(),
                              ],
                            ),
                          ),

                          if (_filteredProducts.isEmpty)
                            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No products found"))),
                            
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                        ]),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCarousel(List<Product> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: _isMobile ? 280 : 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: _isMobile ? 170 : 200,
            child: ProductCard(
              product: products[index],
              isCompact: _isMobile,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: products[index], allProducts: _allProducts))),
              showFavorite: true, showQuickAdd: true, onFavoriteTap: () {}, onQuickAddTap: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategoryId == null;
            return ChoiceChip(
              label: const Text('All'),
              selected: isSelected,
              onSelected: (_) => _filterProductsByCategory(null),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }
          final cat = _categories[index - 1];
          final isSelected = _selectedCategoryId == cat.id;
          return ChoiceChip(
            label: Text(cat.name),
            selected: isSelected,
            onSelected: (_) => _filterProductsByCategory(cat.id),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          );
        },
      ),
    );
  }
  
  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) return const Center(child: Text("No products found"));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isMobile ? 1 : 4, // 1 for Mobile
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        // YEH HAI CORRECT SETTING (0.75)
        // Is se card vertical (lamba) ho jaye ga, aur screen par 1.5 ya 2 cards nazar ayen ge.
        childAspectRatio: _isMobile ? 0.75 : 0.72, 
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          isCompact: false,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product, allProducts: _allProducts))),
          showFavorite: true, showQuickAdd: true, onFavoriteTap: () {}, onQuickAddTap: () {},
        );
      },
    );
  }
}
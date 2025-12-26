import 'package:flutter/material.dart' hide Category;
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
  
  // Drawer Key added to open drawer from custom header
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
      final categoriesFuture = _api.fetchCategories();
      final featuredProductsFuture = _api.fetchFeaturedProducts();
      final bannersFuture = _api.fetchBanners();
      final allProductsFuture = _api.fetchProducts();

      final results = await Future.wait([
        categoriesFuture,
        featuredProductsFuture,
        bannersFuture,
        allProductsFuture,
      ]);

      setState(() {
        _categories = results[0] as List<Category>;
        _featuredProducts = results[1] as List<Product>;
        _banners = results[2] as List<model.Banner>;
        _allProducts = results[3] as List<Product>;
        _filteredProducts = _allProducts;
        _isLoading = false;
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      backgroundColor: Colors.white,
      
      // ================ SIDE DRAWER ================
      drawer: Drawer(
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
                      Navigator.pop(context); // Close drawer
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

      body: SafeArea(
        child: Column(
          children: [
            
            // ================ NEW FIXED TOP HEADER ================
            // Logo + Search Bar + Profile Icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  // 1. APP LOGO
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "SV",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 2. SEARCH BAR (Expanded to take remaining space)
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search perfumes, brands...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 3. PROFILE ICON
                  InkWell(
                    onTap: () {
                      // TODO: Navigate to Profile Screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile coming soon!")),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.grey.shade700,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================ SCROLLABLE BODY ================
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAllData,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: CustomScrollView(
                  slivers: [
                    
                    // Loading State
                    if (_isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                    // Error State
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

                    // Content State
                    if (!_isLoading && !_hasError)
                      SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),

                          // 1. BANNER SECTION (Immediately after header)
                          if (_banners.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24, top: 8),
                              child: BannerCarousel(
                                banners: _banners,
                                onTap: (banner) {
                                  // Handle Banner Tap
                                },
                                height: _isMobile ? 180 : 220,
                                showIndicators: true,
                                autoPlay: true,
                              ),
                            ),

                          // 2. CATEGORIES SECTION
                          Container(
                            margin: const EdgeInsets.only(bottom: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Categories',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      // Menu button for categories (drawer)
                                      InkWell(
                                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.menu,
                                                size: 18,
                                                color: Colors.grey.shade700,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Menu',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildCategoryList(),
                              ],
                            ),
                          ),

                          // 3. FEATURED PRODUCTS
                          Container(
                            margin: const EdgeInsets.only(bottom: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Featured Products',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (_featuredProducts.length > 4)
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProductListScreen(
                                                  initialProducts: _featuredProducts,
                                                  screenTitle: 'Featured Products',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('View All'),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildProductCarousel(_featuredProducts),
                              ],
                            ),
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
                                      Text(
                                        'All Products',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
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

                          // Empty State for Filter
                          if (_filteredProducts.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(40),
                              alignment: Alignment.center,
                              child: const Text("No products found in this category"),
                            ),
                            
                          const SizedBox(height: 20),
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
    if (products.isEmpty) {
      return const SizedBox(
        height: 100, 
        child: Center(child: Text("No featured products"))
      );
    }
    
    return SizedBox(
      height: _isMobile ? 280 : 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: _isMobile ? 170 : 200,
            child: ProductCard(
              product: products[index],
              isCompact: _isMobile,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: products[index],
                      allProducts: _allProducts,
                    ),
                  ),
                );
              },
              showFavorite: true,
              onFavoriteTap: () {},
              showQuickAdd: true,
              onQuickAddTap: () {},
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
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategoryId == null;
            return ChoiceChip(
              label: const Text('All'),
              selected: isSelected,
              onSelected: (selected) => _filterProductsByCategory(null),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }

          final category = _categories[index - 1];
          final isSelected = _selectedCategoryId == category.id;

          return ChoiceChip(
            label: Text(category.name),
            selected: isSelected,
            onSelected: (selected) => _filterProductsByCategory(category.id),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          );
        },
      ),
    );
  }
  
  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) return const SizedBox.shrink();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isMobile ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          isCompact: false,
          onTap: () {
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
          showFavorite: true,
          onFavoriteTap: () {},
          showQuickAdd: true,
          onQuickAddTap: () {},
        );
      },
    );
  }
}
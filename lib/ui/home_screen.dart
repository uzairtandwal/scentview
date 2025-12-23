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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  
  Future<void>? _dataLoadingFuture;
  List<Category> _categories = [];
  List<Product> _featuredProducts = [];
  List<model.Banner> _banners = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String? _selectedCategoryId;

  late bool _isMobile;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
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
    });
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
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_banners.isNotEmpty)
                BannerCarousel(
                  banners: _banners,
                  onTap: (banner) {
                    debugPrint("Banner tapped: ${banner.targetScreen} with ID ${banner.targetId}");
                    // TODO: Implement navigation
                  },
                ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Featured Products'),
              _buildProductCarousel(_featuredProducts),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Categories'),
              _buildCategoryList(),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Products'),
              _buildProductsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildProductCarousel(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No featured products available.'));
    }
    return SizedBox(
      height: _isMobile ? 280 : 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: _isMobile ? 160 : 200,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" category
            final isSelected = _selectedCategoryId == null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ChoiceChip(
                label: const Text('All'),
                selected: isSelected,
                onSelected: (selected) {
                  _filterProductsByCategory(null);
                },
                backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          final category = _categories[index - 1];
          final isSelected = _selectedCategoryId == category.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                _filterProductsByCategory(category.id);
              },
              backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
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
        );
      },
    );
  }
}

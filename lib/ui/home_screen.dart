import 'package:scentview/models/product_model.dart';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Category;
import 'package:slide_countdown/slide_countdown.dart';
import 'package:video_player/video_player.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; 
import 'package:cached_network_image/cached_network_image.dart';

import '../models/category.dart' as app_category;
import '../services/api_service.dart';
import 'product_list_screen.dart';
import 'shop_screen.dart';
import 'package:scentview/ui/widgets/product_card.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  Future<List<app_category.Category>>? _categoriesFuture;
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;
  int _selectedBannerIndex = 0;
  bool _isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // Populated from API
  List<Product> _featuredProducts = [];
  List<Product> _sliderProducts = [];
  List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    // Data load karein
    _categoriesFuture = _api.fetchCategories();
    _loadBanners(); 
    _loadFeaturedProducts();
    _loadSliderProducts();
    _loadAllProducts();

    // Video Player Logic
    if (!_isMobile) {
      _videoController = VideoPlayerController.asset(
        'assets/video/Home-Video.mp4',
      );
      _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
        _videoController!.play();
        _videoController!.setLooping(true);
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  // ---- API Loaders ----
  Future<void> _loadBanners() async {
    try {
      await _api.fetchBanners(); 
    } catch (e) {
      print('Failed to load banners: $e');
    }
  }

  Future<void> _loadSliderProducts() async {
    try {
      final products = await _api.fetchSliderProducts();
      if(mounted) setState(() => _sliderProducts = products);
    } catch (e) { print('Failed to load slider products: $e'); }
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final products = await _api.fetchFeaturedProducts();
      if(mounted) setState(() => _featuredProducts = products);
    } catch (e) { print('Failed to load featured products: $e'); }
  }

  // 🔥 UPDATED: Smart Logic for Scrolling (Products Repeat honge agar kam hain)
  Future<void> _loadAllProducts() async {
    try {
      final fetchedProducts = await _api.fetchProducts();

      if (mounted) {
        setState(() {
          // 1. Agar products 6 se kam hain to repeat karo (taake scroll ho sake)
          if (fetchedProducts.length < 6 && fetchedProducts.isNotEmpty) {
            List<Product> tempProducts = [];
            // Jab tak 10 items na ho jayen, copy karte raho
            while (tempProducts.length < 10) {
              tempProducts.addAll(fetchedProducts);
            }
            _allProducts = tempProducts;
          } 
          // 2. Agar products pehle se zyada hain to normal rakho
          else {
            _allProducts = List.from(fetchedProducts);
          }

          // 3. Shuffle (Randomize) karo taake har baar naya lage
          _allProducts.shuffle();
        });
      }
    } catch (e) {
      print('Failed to load all products: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _categoriesFuture = _api.fetchCategories();
      _loadFeaturedProducts();
      _loadSliderProducts();
      _loadAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: SingleChildScrollView(
        // ✅ YEH LINE SCROLLING FORCE KAREGI
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPlayer(),
            _buildBannerCarousel(),
            _buildFlashSaleSection(),
            const SectionTitle(title: 'Shop by Category'),
            _buildCategoryGrid(),
            const SectionTitle(title: 'Featured Fragrances'),
            _buildTopPicksSection(context),
            const SectionTitle(title: 'All Products'),
            _buildAllProductsGrid(),
            const SizedBox(height: 50), // Thori jagah neeche
          ],
        ),
      ),
    );
  }

  Widget _buildTopPicksSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Fragrances',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShopScreen(),
                    ),
                  );
                },
                child: const Text('View All >'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: _featuredProducts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _featuredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _featuredProducts[index];
                    return SizedBox(
                      width: 160,
                      child: ProductCard(
                        product: product,
                        isCompact: true,
                        onTap: () {
                          // Click Navigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                  product: product, allProducts: _allProducts),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_isMobile) {
      return SizedBox(
        height: 200,
        width: double.infinity,
        child: Image.asset(
          'assets/images/banner_1.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      );
    }

    if (_initializeVideoPlayerFuture == null) {
      return const SizedBox(height: 200);
    }

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || _videoController == null) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text('Video could not be played.')),
            );
          }
          return AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          );
        } else {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildBannerCarousel() {
    if (_sliderProducts.isEmpty) {
      return const SizedBox(
        height: 10,
      );
    }
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                _selectedBannerIndex = index;
              });
            },
          ),
          items: _sliderProducts.map((product) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                      product: product, allProducts: _allProducts),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    // Gradient Shadow
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: _selectedBannerIndex,
          count: _sliderProducts.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return FutureBuilder<List<app_category.Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return const Center(child: Text('No categories available.'));
        }
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                category: category,
                onTap: () => Navigator.pushNamed(
                  context,
                  ProductListScreen.routeName,
                  arguments: ProductListArgs(categoryKey: category.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFlashSaleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⚡ Flash Sale',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SlideCountdown(
                duration: Duration(days: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: _featuredProducts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _featuredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _featuredProducts[index];
                    return SizedBox(
                      width: 180,
                      child: ProductCard(
                        product: product,
                        isCompact: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                  product: product, allProducts: _allProducts),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAllProductsGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemCount: _allProducts.length,
      itemBuilder: (context, index) {
        final product = _allProducts[index];
        return ProductCard(
          product: product,
          isCompact: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                    product: product, allProducts: _allProducts),
              ),
            );
          },
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final app_category.Category category;
  final VoidCallback onTap;
  const CategoryCard({required this.category, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: (category.imageUrl != null &&
                        category.imageUrl!.isNotEmpty)
                    ? Image.network(
                        category.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Icon(Icons.category, size: 30, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
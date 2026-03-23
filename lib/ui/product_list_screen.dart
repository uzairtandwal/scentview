import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../models/category.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import 'widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';

class ProductListArgs {
  final String categoryKey;
  const ProductListArgs({required this.categoryKey});
}

class ProductListScreen extends StatefulWidget {
  static const routeName = '/products';
  final List<Product>? initialProducts;
  final String? screenTitle;

  const ProductListScreen({
    super.key,
    this.initialProducts,
    this.screenTitle,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _firestoreService = FirestoreService();
  late final ProductListArgs _args;
  late Stream<List<Product>> _productsStream;
  late Future<Category> _categoryFuture;
  
  bool _isGridLayout = true;
  int _crossAxisCount = 1; 
  final ScrollController _scrollController = ScrollController();

  final Set<String> _favoriteIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialProducts == null) {
      _args = ModalRoute.of(context)!.settings.arguments as ProductListArgs;
      _productsStream = _firestoreService.getProductsByCategoryStream(
        _args.categoryKey,
      );
      _categoryFuture = _firestoreService.getCategory(_args.categoryKey);
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    _crossAxisCount = screenWidth > 600 ? 3 : 2; 
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteIds.contains(product.id)) {
        _favoriteIds.remove(product.id);
      } else {
        _favoriteIds.add(product.id!);
      }
    });

    final isFav = _favoriteIds.contains(product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isFav ? Iconsax.heart5 : Iconsax.heart_slash, color: Colors.white),
            const SizedBox(width: 12),
            Text(isFav ? 'Added to favorites' : 'Removed from favorites'),
          ],
        ),
        backgroundColor: isFav ? Colors.red : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  bool _ensureAuthenticated() {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (!auth.isAuthenticated) {
      Navigator.pushNamed(context, LoginScreen.routeName);
      return false;
    }
    return true;
  }

  void _addToCart(Product product) {
    if (!_ensureAuthenticated()) return;

    final cart = Provider.of<CartService>(context, listen: false);
    cart.add(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: widget.screenTitle != null
            ? Text(
                widget.screenTitle!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                ),
              )
            : FutureBuilder<Category>(
                future: _categoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...', style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w600));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Text('Products', style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w600));
                  }
                  return Text(
                    snapshot.data!.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.grey.shade900),
                  );
                },
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade700),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.initialProducts == null) ...[
            StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _isGridLayout = !_isGridLayout;
                        });
                      },
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _isGridLayout ? Colors.blue.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isGridLayout ? Colors.blue.shade100 : Colors.grey.shade300, width: 1),
                        ),
                        child: Center(
                          child: Icon(
                            _isGridLayout ? Icons.grid_view_rounded : Icons.list_rounded,
                            color: _isGridLayout ? Colors.blue.shade700 : Colors.grey.shade700,
                            size: 20,
                          ),
                        ),
                      ),
                      tooltip: _isGridLayout ? 'List View' : 'Grid View',
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 16, color: Colors.blue.shade700),
                          SizedBox(width: 8),
                          Text('${snapshot.data!.length}', style: TextStyle(color: Colors.blue.shade800, fontSize: 16, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
      body: widget.initialProducts != null
          ? _buildProductsView(context, widget.initialProducts!)
          : StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return _buildLoadingState(context);
                if (snapshot.hasError) return _buildErrorState(context, snapshot.error.toString());
                final products = snapshot.data ?? [];
                if (products.isEmpty) return _buildEmptyState(context);
                return _buildProductsView(context, products);
              },
            ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: Colors.blue.shade600));
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(child: Text('Failed to load products: $error'));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(child: Text('No Products Found'));
  }

  Widget _buildProductsView(BuildContext context, List<Product> products) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _productsStream = _firestoreService.getProductsByCategoryStream(_args.categoryKey);
        });
      },
      color: Colors.blue.shade600,
      backgroundColor: Colors.white,
      child: _isGridLayout ? _buildGridView(context, products) : _buildListView(context, products),
    );
  }

  Widget _buildGridView(BuildContext context, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 24.0,
          // YEH HAI CHANGE (0.75 for Taller Cards)
          childAspectRatio: 0.75, 
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product, 
            isCompact: false,
            isFavorite: _favoriteIds.contains(product.id),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product, allProducts: products))),
            showFavorite: true, 
            onFavoriteTap: () => _toggleFavorite(product), 
            showQuickAdd: true, 
            onQuickAddTap: () => _addToCart(product),
          );
        },
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.separated(
        controller: _scrollController, itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final product = products[index];
          final String? imageUrl = ApiService.toAbsoluteUrl(product.imageUrl);
          final bool isFav = _favoriteIds.contains(product.id);
          
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product, allProducts: products))),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _buildListImage(imageUrl),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(product.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey.shade900), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                                IconButton(
                                  icon: Icon(isFav ? Iconsax.heart5 : Iconsax.heart, color: isFav ? Colors.red : Colors.grey),
                                  onPressed: () => _toggleFavorite(product),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rs ${product.price.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.blue.shade800)),
                                IconButton(
                                  icon: const Icon(Iconsax.add_circle, color: Colors.blue),
                                  onPressed: () => _addToCart(product),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Center(child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 30));
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) => Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
    );
  }
}

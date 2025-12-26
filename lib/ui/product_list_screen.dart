import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import 'widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListArgs {
  final String categoryKey;
  const ProductListArgs({required this.categoryKey});
}

class ProductListScreen extends StatefulWidget {
  static const routeName = '/products';
  final List<Product>? initialProducts; // Optional list of products to display directly
  final String? screenTitle; // Optional title for the screen

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
  
  // State variables for better UX
  bool _isGridLayout = true;
  int _crossAxisCount = 2;
  final ScrollController _scrollController = ScrollController();

  // List of local images to cycle through
  final _imagePaths = [
    'assets/images/product_11.webp',
    'assets/images/product_12.webp',
    'assets/images/product_13.webp',
    'assets/images/product_14.webp',
    'assets/images/product_15.webp',
    'assets/images/product_16.webp',
    'assets/images/product_17.webp',
    'assets/images/product_18.webp',
    'assets/images/product_19.webp',
    'assets/images/product_20.webp',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialProducts == null) {
      // Retrieve arguments here as it's safer than initState
      _args = ModalRoute.of(context)!.settings.arguments as ProductListArgs;
      _productsStream = _firestoreService.getProductsByCategoryStream(
        _args.categoryKey,
      );
      _categoryFuture = _firestoreService.getCategory(_args.categoryKey);
    }
    
    // Detect screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    _crossAxisCount = screenWidth > 600 ? 3 : 2;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.screenTitle != null
            ? Text(
                widget.screenTitle!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            : FutureBuilder<Category>(
                future: _categoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Loading...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Text(
                      'Products',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  }
                  return Text(
                    snapshot.data!.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (widget.initialProducts == null) ...[
            // Layout Toggle Button
            StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _isGridLayout = !_isGridLayout;
                      });
                    },
                    icon: Icon(
                      _isGridLayout ? Icons.list : Icons.grid_view,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: _isGridLayout ? 'List View' : 'Grid View',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            // Product Count Badge
            StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${snapshot.data!.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
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
                // ================ LOADING STATE ================
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(context);
                }
      
                // ================ ERROR STATE ================
                if (snapshot.hasError) {
                  return _buildErrorState(context, snapshot.error.toString());
                }
      
                final products = snapshot.data ?? [];
      
                // ================ EMPTY STATE ================
                if (products.isEmpty) {
                  return _buildEmptyState(context);
                }
      
                // ================ PRODUCTS LIST/GRID ================
                return _buildProductsView(context, products);
              },
            ),
    );
  }

  // ================ LOADING STATE ================
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Products...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting the best collection for you',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ================ ERROR STATE ================
  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load products',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retry logic
                setState(() {
                  _productsStream = _firestoreService.getProductsByCategoryStream(
                    _args.categoryKey,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 48),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ================ EMPTY STATE ================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no products in this category yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
              ),
              child: const Text('Browse Other Categories'),
            ),
          ],
        ),
      ),
    );
  }

  // ================ PRODUCTS VIEW (GRID/LIST) ================
  Widget _buildProductsView(BuildContext context, List<Product> products) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the stream
        setState(() {
          _productsStream = _firestoreService.getProductsByCategoryStream(
            _args.categoryKey,
          );
        });
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: _isGridLayout
          ? _buildGridView(context, products)
          : _buildListView(context, products),
    );
  }

  // ================ GRID VIEW ================
  Widget _buildGridView(BuildContext context, List<Product> products) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        // Create a new product instance with the local image path
        final productWithLocalImage = product.copyWith(
          imageUrl: _imagePaths[index % _imagePaths.length],
        );
        return ProductCard(
          product: productWithLocalImage,
          isCompact: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: productWithLocalImage,
                  allProducts: products,
                ),
              ),
            );
          },
          showFavorite: true,
          onFavoriteTap: () {
            // TODO: Implement favorite logic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${product.name} to favorites'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          showQuickAdd: true,
          onQuickAddTap: () {
            // TODO: Implement quick add to cart
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${product.name} to cart'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  // ================ LIST VIEW ================
  Widget _buildListView(BuildContext context, List<Product> products) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        // Create a new product instance with the local image path
        final productWithLocalImage = product.copyWith(
          imageUrl: _imagePaths[index % _imagePaths.length],
        );
        
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceVariant,
                image: _imagePaths[index % _imagePaths.length].isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(_imagePaths[index % _imagePaths.length]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imagePaths[index % _imagePaths.length].isEmpty
                  ? Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                    )
                  : null,
            ),
            title: Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '\$${product.originalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (product.category?.name.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      product.category!.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: productWithLocalImage,
                      allProducts: products,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: productWithLocalImage,
                    allProducts: products,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
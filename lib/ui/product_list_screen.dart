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
      _args = ModalRoute.of(context)!.settings.arguments as ProductListArgs;
      _productsStream = _firestoreService.getProductsByCategoryStream(
        _args.categoryKey,
      );
      _categoryFuture = _firestoreService.getCategory(_args.categoryKey);
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    _crossAxisCount = screenWidth > 600 ? 3 : 1; 
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          final productWithLocalImage = product.copyWith(imageUrl: _imagePaths[index % _imagePaths.length]);
          return ProductCard(
            product: productWithLocalImage, isCompact: false,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: productWithLocalImage, allProducts: products))),
            showFavorite: true, onFavoriteTap: () {}, showQuickAdd: true, onQuickAddTap: () {},
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
          final productWithLocalImage = product.copyWith(imageUrl: _imagePaths[index % _imagePaths.length]);
          
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: productWithLocalImage, allProducts: products))),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey.shade100, image: _imagePaths[index % _imagePaths.length].isNotEmpty ? DecorationImage(image: AssetImage(_imagePaths[index % _imagePaths.length]), fit: BoxFit.cover) : null),
                        child: _imagePaths[index % _imagePaths.length].isEmpty ? Center(child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 30)) : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey.shade900), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Text('\$${product.originalPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.blue.shade800)),
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
}
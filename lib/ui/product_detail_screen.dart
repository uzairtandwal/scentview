import 'package:flutter/material.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/ui/widgets/product_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scentview/services/cart_service.dart';
import 'package:scentview/services/auth_service.dart'; // ✅ Auth Service Import
import 'login_screen.dart'; // ✅ Login Screen Import

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';
  final Product product;
  final List<Product> allProducts;

  const ProductDetailScreen({
    required this.product,
    required this.allProducts,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  late final List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    _imageUrls = [widget.product.imageUrl];
  }

  // ✅ Auth Check Helper: Ye function check karega login hai ya nahi
  bool _ensureAuthenticated() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      // Agar guest hai to Login Screen par bhej do
      Navigator.of(context).pushNamed(LoginScreen.routeName).then((_) {
        // Login ho kar wapis aane par UI refresh karne ke liye
        setState(() {});
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to continue with your purchase'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  void _openWhatsApp() async {
    const phoneNumber = "+923079417399";
    const message = "Hello, I'm interested in your products.";
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open WhatsApp'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening WhatsApp'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _addToCart() {
    // ✅ Change: Check if user is logged in
    if (!_ensureAuthenticated()) return;

    final cartService = Provider.of<CartService>(context, listen: false);
    cartService.updateQuantity(widget.product, _quantity);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} (x$_quantity) added to cart!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.blue,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  void _buyNow() {
    // ✅ Change: Check if user is logged in
    if (!_ensureAuthenticated()) return;

    _addToCart();
    Navigator.pushNamed(context, '/checkout');
  }

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool onSale = widget.product.salePrice != null && widget.product.salePrice! > 0;
    final double discountPercent = onSale
        ? ((widget.product.originalPrice - widget.product.salePrice!) / 
           widget.product.originalPrice * 100)
        : 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite ? 'Added to favorites' : 'Removed from favorites',
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red.shade600 : Colors.grey.shade700,
                  size: 22,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _shareProduct,
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.share_outlined,
                  color: Colors.grey.shade700,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================ PRODUCT IMAGE ================
                      Container(
                        height: 320,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _imageUrls.isNotEmpty && _imageUrls[_selectedImageIndex].isNotEmpty
                              ? Image.network(
                                  _imageUrls[_selectedImageIndex],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 3,
                                          color: Colors.blue.shade600,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (c, e, s) => Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Image not available',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                        ),
                      ),

                      if (_imageUrls.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            height: 70,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageUrls.length,
                              separatorBuilder: (context, index) => 
                                const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedImageIndex = index;
                                  }),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedImageIndex == index 
                                            ? Colors.blue.shade600 
                                            : Colors.grey.shade300,
                                        width: _selectedImageIndex == index ? 2.5 : 1,
                                      ),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _imageUrls[index].isNotEmpty
                                          ? Image.network(
                                              _imageUrls[index],
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Center(
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.image_outlined,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      const SizedBox(height: 28),

                      // ================ PRODUCT TITLE ================
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade900,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================ SALE BADGE ================
                      if (onSale && discountPercent > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade500,
                                Colors.orange.shade500,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_offer_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SALE ${discountPercent.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ================ PRICE SECTION ================
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (onSale)
                                Text(
                                  '\$${widget.product.originalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey.shade500,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              SizedBox(height: onSale ? 4 : 0),
                              Text(
                                onSale
                                    ? '\$${widget.product.salePrice!.toStringAsFixed(2)}'
                                    : '\$${widget.product.originalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 32,
                                  color: onSale ? Colors.red.shade700 : Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (onSale)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade100,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.savings_outlined,
                                    size: 18,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Save \$${(widget.product.originalPrice - widget.product.salePrice!).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 28),
                      
                      // ================ QUANTITY SECTION ================
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Select how many you want',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _quantity > 1
                                        ? () => setState(() {
                                              _quantity--;
                                            })
                                        : null,
                                    icon: Icon(
                                      Icons.remove_rounded,
                                      color: _quantity > 1 
                                          ? Colors.grey.shade800 
                                          : Colors.grey.shade400,
                                      size: 22,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$_quantity',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() {
                                      _quantity++;
                                    }),
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: Colors.grey.shade800,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ================ DESCRIPTION ================
                      if (widget.product.description?.isNotEmpty == true)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                widget.product.description!,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // ================ PRODUCT DETAILS ================
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (widget.product.category != null)
                              _buildDetailRow(
                                Icons.category_outlined,
                                'Category',
                                widget.product.category!.name,
                              ),
                            const SizedBox(height: 12),
                            if (widget.product.brand != null && 
                                widget.product.brand!.isNotEmpty)
                              _buildDetailRow(
                                Icons.branding_watermark_outlined,
                                'Brand',
                                widget.product.brand!,
                              ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.inventory_2_outlined,
                              'Stock Status',
                              widget.product.stock != null && widget.product.stock! > 0
                                  ? '${widget.product.stock} units available'
                                  : 'Out of Stock',
                              isStock: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ================ RELATED PRODUCTS ================
                      _RelatedProductsSection(
                        product: widget.product,
                        allProducts: widget.allProducts,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ================ WHATSAPP FLOATING BUTTON ================
          Positioned(
            bottom: 100,
            right: 20,
            child: GestureDetector(
              onTap: _openWhatsApp,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(37, 211, 102, 0.4),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),

          // ================ BOTTOM ACTION BAR ================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Add to Cart Button
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Buy Now Button
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                        onPressed: _buyNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Buy Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildDetailRow(IconData icon, String title, String value, 
      {bool isStock = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isStock && widget.product.stock != null && 
                            widget.product.stock! > 0
                        ? Colors.green.shade700
                        : Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedProductsSection extends StatelessWidget {
  final Product product;
  final List<Product> allProducts;

  const _RelatedProductsSection({
    required this.product,
    required this.allProducts,
  });

  @override
  Widget build(BuildContext context) {
    final relatedProducts = allProducts.where((p) {
      return p.categoryId == product.categoryId && p.id != product.id;
    }).toList();

    if (relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You might also like",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Similar fragrances you may enjoy",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final relatedProduct = relatedProducts[index];
              return SizedBox(
                width: 200,
                child: ProductCard(
                  product: relatedProduct,
                  isCompact: true,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: relatedProduct,
                          allProducts: allProducts,
                        ),
                      ),
                    );
                  },
                  showFavorite: false,
                  showQuickAdd: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
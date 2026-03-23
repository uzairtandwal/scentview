import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/ui/widgets/product_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scentview/services/cart_service.dart';
import 'package:scentview/services/auth_service.dart';
import 'package:iconsax/iconsax.dart';
import 'login_screen.dart';

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

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  late final List<String> _imageUrls;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _imageUrls = [widget.product.imageUrl];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _ensureAuthenticated() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      Navigator.of(context).pushNamed(LoginScreen.routeName).then((_) {
        setState(() {});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Iconsax.warning_2, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please login to continue with your purchase',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return false;
    }
    return true;
  }

  void _openWhatsApp() async {
    const phoneNumber = "+923079417399";

    final onSale = widget.product.salePrice != null &&
        widget.product.salePrice! > 0 &&
        widget.product.salePrice! < widget.product.price;
    final price = onSale ? widget.product.salePrice! : widget.product.price;

    final StringBuffer buffer = StringBuffer();
    buffer.writeln("Assalamu Alaikum! I'm interested in this product:");
    buffer.writeln("*Name:* ${widget.product.name}");
    if (widget.product.brand != null) buffer.writeln("*Brand:* ${widget.product.brand}");
    if (widget.product.size != null) buffer.writeln("*Size:* ${widget.product.size}");
    buffer.writeln("*Price:* PKR ${price.toStringAsFixed(0)}");
    buffer.writeln("");
    buffer.writeln("Can you please provide more details?");

    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(buffer.toString())}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Iconsax.close_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Could not open WhatsApp'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Iconsax.danger, color: Colors.white),
                SizedBox(width: 12),
                Text('Error opening WhatsApp'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _addToCart() {
    if (!_ensureAuthenticated()) return;

    final cartService = Provider.of<CartService>(context, listen: false);
    cartService.updateQuantity(widget.product, _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.tick_circle5, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Added to Cart',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('${widget.product.name} (x$_quantity)',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  void _buyNow() {
    if (!_ensureAuthenticated()) return;
    _addToCart();
    Navigator.pushNamed(context, '/checkout');
  }

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Iconsax.share, color: Colors.white),
            SizedBox(width: 12),
            Text('Share functionality coming soon!',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool onSale = widget.product.salePrice != null &&
        widget.product.salePrice! > 0 &&
        widget.product.salePrice! < widget.product.price;
    final double discountPercent = onSale
        ? ((widget.product.price - widget.product.salePrice!) /
                widget.product.price *
                100)
            .roundToDouble()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ──
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: IconButton(
                      icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF1F2937)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  // Refresh button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: IconButton(
                        icon: const Icon(Iconsax.refresh, color: Color(0xFF1F2937)),
                        onPressed: () {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refreshing...'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ),
                  ),
                  // ✅ Favourite button — FIXED snackbar (no price code inside)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Iconsax.heart5 : Iconsax.heart,
                          color: _isFavorite ? Colors.red.shade600 : const Color(0xFF1F2937),
                        ),
                        onPressed: () {
                          setState(() => _isFavorite = !_isFavorite);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    _isFavorite ? Iconsax.heart5 : Iconsax.heart_slash,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  // ✅ Sirf message — koi price code nahi
                                  Text(
                                    _isFavorite ? 'Added to favorites' : 'Removed from favorites',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              backgroundColor: _isFavorite ? Colors.red : Colors.grey.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Share button
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: IconButton(
                        icon: const Icon(Iconsax.share, color: Color(0xFF1F2937)),
                        onPressed: _shareProduct,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // ✅ CachedNetworkImage — fast + cached
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => _selectedImageIndex = index),
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(left: 20, right: 20, top: 100, bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: _imageUrls[index].isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: _imageUrls[index],
                                      fit: BoxFit.cover,
                                      fadeInDuration: const Duration(milliseconds: 200),
                                      placeholder: (_, __) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: const Color(0xFF3B82F6),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Iconsax.gallery_slash, size: 60, color: Colors.grey.shade400),
                                            const SizedBox(height: 12),
                                            Text('Image not available',
                                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Icon(Iconsax.gallery, size: 80, color: Colors.grey.shade300),
                                    ),
                            ),
                          );
                        },
                      ),

                      // Sale Badge
                      if (onSale && discountPercent > 0)
                        Positioned(
                          top: 120,
                          left: 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.red.shade600, Colors.orange.shade500]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.discount_shape5, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '${discountPercent.toStringAsFixed(0)}% OFF',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Page Indicator
                      if (_imageUrls.length > 1)
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _imageUrls.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _selectedImageIndex == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _selectedImageIndex == index
                                      ? const Color(0xFF3B82F6)
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Product Details ──
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Info Card
                          Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                Text(widget.product.name,
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), height: 1.3)),

                                const SizedBox(height: 16),

                                // Price Section
                                if (onSale) ...[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PKR ${widget.product.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: Colors.grey.shade400,
                                              color: Colors.grey.shade400,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'PKR ${widget.product.salePrice!.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Colors.red, height: 1.1),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Iconsax.discount_shape, size: 14, color: Colors.red.shade600),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${discountPercent.toStringAsFixed(0)}% OFF',
                                              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w800, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else
                                  Text(
                                    'PKR ${widget.product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF3B82F6)),
                                  ),

                                const SizedBox(height: 24),

                                // Quick Attributes
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    if (widget.product.brand != null && widget.product.brand!.isNotEmpty)
                                      _buildQuickAttribute(Iconsax.tag_2, 'Brand', widget.product.brand!, const Color(0xFF8B5CF6)),
                                    if (widget.product.size != null && widget.product.size!.isNotEmpty)
                                      _buildQuickAttribute(Iconsax.maximize_21, 'Size', widget.product.size!, const Color(0xFFF59E0B)),
                                    if (widget.product.scentFamily != null && widget.product.scentFamily!.isNotEmpty)
                                      _buildQuickAttribute(Iconsax.status_up, 'Scent', widget.product.scentFamily!, const Color(0xFF10B981)),
                                    if (widget.product.category != null && widget.product.category!.isNotEmpty)
                                      _buildQuickAttribute(Iconsax.category_2, 'Type', widget.product.category!, const Color(0xFF3B82F6)),
                                  ],
                                ),

                                const SizedBox(height: 24),
                                Divider(color: Colors.grey.shade200, height: 1),
                                const SizedBox(height: 24),

                                // Product Description Section
                                if (widget.product.description?.isNotEmpty == true) ...[
                                  const Text(
                                    'Product Description',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.product.description!,
                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6),
                                  ),
                                  const SizedBox(height: 24),
                                  Divider(color: Colors.grey.shade200, height: 1),
                                  const SizedBox(height: 24),
                                ],

                                // Quantity Selector
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      const Color(0xFF3B82F6).withOpacity(0.05),
                                      const Color(0xFF8B5CF6).withOpacity(0.05),
                                    ]),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2), width: 2),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Iconsax.box_1, color: Colors.white, size: 16),
                                          ),
                                          const SizedBox(width: 10),
                                          const Expanded(
                                            child: Text('Quantity',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text('Select how many you want',
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 2),
                                            boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    child: Icon(Iconsax.minus,
                                                        color: _quantity > 1 ? const Color(0xFF3B82F6) : Colors.grey.shade400,
                                                        size: 20),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 45,
                                                alignment: Alignment.center,
                                                child: Text('$_quantity',
                                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                                              ),
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () => setState(() => _quantity++),
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    child: const Icon(Iconsax.add, color: Color(0xFF3B82F6), size: 20),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Trust Badges
                                Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Iconsax.shield_tick5, color: Colors.green.shade700, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Genuine Product',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Iconsax.truck_fast, color: Colors.blue.shade700, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Fast Delivery',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Description
                          if (widget.product.description?.isNotEmpty == true)
                            _buildSection(
                              icon: Iconsax.note_text,
                              title: 'Description',
                              child: Text(widget.product.description!,
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6)),
                            ),

                          // Fragrance Notes
                          if (widget.product.notesTop?.isNotEmpty == true ||
                              widget.product.notesMiddle?.isNotEmpty == true ||
                              widget.product.notesBase?.isNotEmpty == true)
                            _buildSection(
                              icon: Iconsax.mask,
                              title: 'Fragrance Notes',
                              child: Column(
                                children: [
                                  if (widget.product.notesTop?.isNotEmpty == true)
                                    _buildNoteRow('Top Notes', widget.product.notesTop!, Colors.blue),
                                  if (widget.product.notesMiddle?.isNotEmpty == true)
                                    _buildNoteRow('Middle Notes', widget.product.notesMiddle!, Colors.purple),
                                  if (widget.product.notesBase?.isNotEmpty == true)
                                    _buildNoteRow('Base Notes', widget.product.notesBase!, Colors.deepOrange),
                                ],
                              ),
                            ),

                          // Product Details
                          _buildSection(
                            icon: Iconsax.info_circle,
                            title: 'Product Details',
                            child: Column(
                              children: [
                                if (widget.product.category != null) ...[
                                  _buildDetailRow(icon: Iconsax.category_2, title: 'Category', value: widget.product.category!, color: const Color(0xFF3B82F6)),
                                  const SizedBox(height: 16),
                                ],
                                if (widget.product.brand != null && widget.product.brand!.isNotEmpty) ...[
                                  _buildDetailRow(icon: Iconsax.tag_2, title: 'Brand', value: widget.product.brand!, color: const Color(0xFF8B5CF6)),
                                  const SizedBox(height: 16),
                                ],
                                if (widget.product.scentFamily != null && widget.product.scentFamily!.isNotEmpty) ...[
                                  _buildDetailRow(icon: Iconsax.status_up, title: 'Scent Family', value: widget.product.scentFamily!, color: const Color(0xFF10B981)),
                                  const SizedBox(height: 16),
                                ],
                                if (widget.product.size != null && widget.product.size!.isNotEmpty) ...[
                                  _buildDetailRow(icon: Iconsax.maximize_21, title: 'Size', value: widget.product.size!, color: const Color(0xFFF59E0B)),
                                  const SizedBox(height: 16),
                                ],
                                _buildDetailRow(
                                  icon: Iconsax.box_1,
                                  title: 'Stock Status',
                                  value: widget.product.quantity > 0 ? '${widget.product.quantity} units available' : 'Out of Stock',
                                  color: widget.product.quantity > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                              ],
                            ),
                          ),

                          // Delivery
                          _buildSection(
                            icon: Iconsax.truck_fast,
                            title: 'Delivery Information',
                            child: Column(
                              children: [
                                _buildInfoRow(icon: Iconsax.location5, title: 'Delivery to', value: 'Karachi, Pakistan', color: const Color(0xFF3B82F6)),
                                const SizedBox(height: 12),
                                _buildInfoRow(icon: Iconsax.clock5, title: 'Estimated Delivery', value: '2-3 Business Days', color: const Color(0xFF10B981)),
                                const SizedBox(height: 12),
                                _buildInfoRow(icon: Iconsax.wallet_money, title: 'Shipping Fee', value: 'PKR 200', color: const Color(0xFFF59E0B)),
                                const SizedBox(height: 12),
                                _buildInfoRow(icon: Iconsax.refresh_circle, title: 'Return Policy', value: '7 Days Easy Return', color: const Color(0xFF8B5CF6)),
                              ],
                            ),
                          ),

                          // Reviews
                          _buildSection(
                            icon: Iconsax.star_1,
                            title: 'Customer Reviews',
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Colors.amber.shade50, Colors.orange.shade50]),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.amber.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          const Text('4.8',
                                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B))),
                                          Row(
                                            children: List.generate(5,
                                                (i) => Icon(i < 4 ? Iconsax.star5 : Iconsax.star_15, color: const Color(0xFFF59E0B), size: 16)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('234 Reviews',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            _buildRatingBar(5, 156, 234),
                                            const SizedBox(height: 6),
                                            _buildRatingBar(4, 52, 234),
                                            const SizedBox(height: 6),
                                            _buildRatingBar(3, 18, 234),
                                            const SizedBox(height: 6),
                                            _buildRatingBar(2, 6, 234),
                                            const SizedBox(height: 6),
                                            _buildRatingBar(1, 2, 234),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildReviewCard(name: 'Ahmed Khan', rating: 5, date: '2 days ago', review: 'Amazing fragrance! Lasts all day and smells incredible. Highly recommend!'),
                                const SizedBox(height: 12),
                                _buildReviewCard(name: 'Sarah Ali', rating: 5, date: '1 week ago', review: 'Best perfume I have bought. Original product and fast delivery.'),
                              ],
                            ),
                          ),

                          _RelatedProductsSection(product: widget.product, allProducts: widget.allProducts),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // WhatsApp Button
          Positioned(
            bottom: 130,
            right: 20,
            child: GestureDetector(
              onTap: _openWhatsApp,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: const Color(0xFF25D366).withOpacity(0.5), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 6))],
                ),
                child: const Center(child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 30)),
              ),
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, spreadRadius: 2, offset: const Offset(0, -5))],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [const Color(0xFF3B82F6), const Color(0xFF3B82F6).withOpacity(0.8)]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Iconsax.shopping_cart5, size: 18),
                              SizedBox(width: 6),
                              Flexible(child: Text('Add to Cart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [const Color(0xFF10B981), const Color(0xFF10B981).withOpacity(0.8)]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: ElevatedButton(
                          onPressed: _buyNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Iconsax.flash_15, size: 18),
                              SizedBox(width: 6),
                              Flexible(child: Text('Buy Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAttribute(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    return Row(
      children: [
        Text('$stars', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(width: 4),
        Icon(Iconsax.star5, size: 12, color: Colors.amber.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: count / total,
              child: Container(decoration: BoxDecoration(color: Colors.amber.shade500, borderRadius: BorderRadius.circular(3))),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildNoteRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)))),
        ],
      ),
    );
  }

  Widget _buildReviewCard({required String name, required int rating, required String date, required String review}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Row(children: List.generate(5, (i) => Icon(i < rating ? Iconsax.star5 : Iconsax.star,
                            color: i < rating ? const Color(0xFFF59E0B) : Colors.grey.shade400, size: 14))),
                        const SizedBox(width: 8),
                        Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }
}

class _RelatedProductsSection extends StatelessWidget {
  final Product product;
  final List<Product> allProducts;

  const _RelatedProductsSection({Key? key, required this.product, required this.allProducts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final relatedProducts = allProducts.where((p) => p.category == product.category && p.id != product.id).toList();
    if (relatedProducts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.heart_search, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('You might also like',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                  Text('Similar fragrances for you', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: relatedProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final p = relatedProducts[index];
                return SizedBox(
                  width: 200,
                  child: ProductCard(
                    product: p,
                    isCompact: true,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p, allProducts: allProducts)),
                    ),
                    showFavorite: false,
                    showQuickAdd: false,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
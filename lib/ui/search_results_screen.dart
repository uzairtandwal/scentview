import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'widgets/product_card.dart';
import 'product_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  static const routeName = '/search-results';
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with TickerProviderStateMixin {
  // ── Aapka existing ApiService — same rakha ──
  final ApiService _apiService = ApiService();
  Future<List<Product>>? _productsFuture;

  // ── New state ────────────────────────────────────────────────
  String _selectedSort = 'Popular';
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 50000);
  bool _isGridView = true;
  bool _showFilters = false;

  // ── Animation controllers ────────────────────────────────────
  late AnimationController _fadeController;
  late AnimationController _filterController;
  late Animation<double> _fadeAnim;
  late Animation<double> _filterAnim;

  final List<String> _sortOptions = [
    'Popular',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
    'Top Rated',
  ];

  final List<String> _categories = [
    'All', 'Floral', 'Woody', 'Fresh',
    'Oriental', 'Citrus', 'Aquatic',
  ];

  @override
  void initState() {
    super.initState();
    // ── Aapka existing fetch — same ──
    _productsFuture = _apiService.fetchProducts(query: widget.query);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _filterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _filterAnim = CurvedAnimation(
        parent: _filterController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  // ── Sort + filter logic (client-side on top of API results) ──
  List<Product> _applyFilters(List<Product> products) {
    var list = products.where((p) {
      // Price filter — use p.price if your Product model has it
      // final matchPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
      // return matchPrice;
      return true; // remove this line when you add price field
    }).toList();

    switch (_selectedSort) {
      case 'Price: Low to High':
        // list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        // list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Top Rated':
        // list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return list;
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
    if (_showFilters) {
      _filterController.forward();
    } else {
      _filterController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Color(0xFF1F2937), size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${widget.query}"',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Search Results',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              actions: [
                // Grid / List toggle
                IconButton(
                  onPressed: () =>
                      setState(() => _isGridView = !_isGridView),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isGridView ? Iconsax.row_vertical : Iconsax.element_4,
                      key: ValueKey(_isGridView),
                      color: const Color(0xFF1F2937),
                      size: 22,
                    ),
                  ),
                ),
                // Filter toggle
                IconButton(
                  onPressed: _toggleFilters,
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _showFilters
                          ? const Color(0xFF6C63FF)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.setting_4,
                      color:
                          _showFilters ? Colors.white : const Color(0xFF1F2937),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              // ── Category chips ──
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(_showFilters ? 130 : 52),
                child: Column(
                  children: [
                    // Category chips
                    Container(
                      color: Colors.white,
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _categories.length,
                        itemBuilder: (_, i) {
                          final isSelected =
                              _selectedCategory == _categories[i];
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedCategory = _categories[i]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                            color: const Color(0xFF6C63FF)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2))
                                      ]
                                    : [],
                              ),
                              child: Text(
                                _categories[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── Expandable filter panel ──
                    if (_showFilters)
                      Container(
                        color: Colors.white,
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                // Sort dropdown
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Sort by',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey.shade500,
                                              letterSpacing: 0.5)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedSort,
                                            isDense: true,
                                            isExpanded: true,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1F2937)),
                                            items: _sortOptions
                                                .map((s) => DropdownMenuItem(
                                                    value: s,
                                                    child: Text(s,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis)))
                                                .toList(),
                                            onChanged: (val) => setState(
                                                () => _selectedSort = val!),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Price range
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Price range',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey.shade500,
                                              letterSpacing: 0.5)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'PKR ${_priceRange.start.toInt()} – ${_priceRange.end.toInt()}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF6C63FF)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Price slider
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                activeTrackColor: const Color(0xFF6C63FF),
                                inactiveTrackColor: Colors.grey.shade200,
                                thumbColor: const Color(0xFF6C63FF),
                                overlayColor: const Color(0xFF6C63FF)
                                    .withOpacity(0.15),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7),
                                rangeThumbShape:
                                    const RoundRangeSliderThumbShape(
                                        enabledThumbRadius: 7),
                              ),
                              child: RangeSlider(
                                values: _priceRange,
                                min: 0,
                                max: 50000,
                                divisions: 100,
                                onChanged: (v) =>
                                    setState(() => _priceRange = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── FutureBuilder body ─────────────────────────────
            SliverFillRemaining(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  // ── Loading ──
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoading();
                  }

                  // ── Error ──
                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }

                  // ── Empty ──
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmpty();
                  }

                  // ── Results ──
                  final products = _applyFilters(snapshot.data!);

                  if (products.isEmpty) {
                    return _buildEmpty(isFiltered: true);
                  }

                  return _buildResults(products);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading State ────────────────────────────────────────────
  Widget _buildLoading() {
    return Column(
      children: [
        // Count shimmer
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          height: 16,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemCount: 6,
            itemBuilder: (_, i) => _ShimmerCard(delay: i * 100),
          ),
        ),
      ],
    );
  }

  // ── Error State ──────────────────────────────────────────────
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.wifi_square,
                  size: 44, color: Colors.red.shade400),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _productsFuture =
                      _apiService.fetchProducts(query: widget.query);
                });
              },
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────
  Widget _buildEmpty({bool isFiltered = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.search_status,
                  size: 48, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered
                  ? 'No results with these filters'
                  : 'No results for "${widget.query}"',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try adjusting your filters or\nsearch something different'
                  : 'Check the spelling or try a\ndifferent keyword',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isFiltered)
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _selectedCategory = 'All';
                  _priceRange = const RangeValues(0, 50000);
                  _selectedSort = 'Popular';
                }),
                icon: const Icon(Iconsax.filter_remove, size: 16),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C63FF),
                  side: const BorderSide(color: Color(0xFF6C63FF)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.arrow_left, size: 18),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Results ──────────────────────────────────────────────────
  Widget _buildResults(List<Product> products) {
    return Column(
      children: [
        // ── Results count bar ──
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${products.length} ',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6C63FF)),
                    ),
                    TextSpan(
                      text: 'results found',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Active filter chips
              if (_selectedSort != 'Popular' ||
                  _selectedCategory != 'All')
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedSort = 'Popular';
                    _selectedCategory = 'All';
                    _priceRange = const RangeValues(0, 50000);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.filter_remove,
                            size: 13, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Text('Clear',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade400)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Grid or List ──
        Expanded(
          child: _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _AnimatedProductItem(
                      index: index,
                      // ── Aapka existing ProductCard — same rakha ──
                      child: ProductCard(
                        product: product,
                        isCompact: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                product: product,
                                allProducts: products,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _AnimatedProductItem(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        // ── List view uses ProductCard in compact mode ──
                        child: ProductCard(
                          product: product,
                          isCompact: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  product: product,
                                  allProducts: products,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Animated wrapper for staggered entrance ──────────────────
class _AnimatedProductItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedProductItem(
      {required this.child, required this.index});

  @override
  State<_AnimatedProductItem> createState() =>
      _AnimatedProductItemState();
}

class _AnimatedProductItemState extends State<_AnimatedProductItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacity =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    ));

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(
      Duration(milliseconds: widget.index * 60),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Shimmer Loading Card ──────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  final int delay;
  const _ShimmerCard({this.delay = 0});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.linear));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image shimmer
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment(_anim.value - 1, 0),
                    end: Alignment(_anim.value, 0),
                    colors: [
                      Colors.grey.shade200,
                      Colors.grey.shade100,
                      Colors.grey.shade200,
                    ],
                  ).createShader(bounds),
                  child: Container(
                      height: 130, color: Colors.grey.shade200),
                ),
              ),
              // Text shimmer
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerLine(width: 60, height: 10),
                    const SizedBox(height: 6),
                    _shimmerLine(width: double.infinity, height: 13),
                    const SizedBox(height: 4),
                    _shimmerLine(width: 100, height: 10),
                    const SizedBox(height: 10),
                    _shimmerLine(width: 80, height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerLine({required double width, required double height}) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment(_anim.value - 1, 0),
        end: Alignment(_anim.value, 0),
        colors: [
          Colors.grey.shade200,
          Colors.grey.shade100,
          Colors.grey.shade200,
        ],
      ).createShader(bounds),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
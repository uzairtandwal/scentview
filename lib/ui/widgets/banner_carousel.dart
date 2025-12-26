import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scentview/models/banner.dart' as model;
import 'package:scentview/services/api_service.dart';

class BannerCarousel extends StatefulWidget {
  final List<model.Banner> banners;
  final Function(model.Banner) onTap;
  final double height;
  final double borderRadius;
  final bool showIndicators;
  final bool autoPlay;

  const BannerCarousel({
    super.key,
    required this.banners,
    required this.onTap,
    this.height = 220.0,
    this.borderRadius = 20.0,
    this.showIndicators = true,
    this.autoPlay = true,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.9,
    );
    
    if (widget.autoPlay && widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!_isUserScrolling && mounted) {
          if (_currentPage < widget.banners.length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    } else {
      _timer = Timer.periodic(Duration.zero, (_) {}); // Dummy timer
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return Container(
        height: widget.height,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 48,
          ),
        ),
      );
    }

    return Column(
      children: [
        // ================ BANNER CAROUSEL ================
        SizedBox(
          height: widget.height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollStartNotification) {
                _isUserScrolling = true;
              } else if (notification is ScrollEndNotification) {
                _isUserScrolling = false;
              }
              return false; // Return false to allow the notification to continue to be dispatched to further listeners.
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  // _isUserScrolling = false; // Already handled by ScrollEndNotification
                });
              },
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => widget.onTap(banner),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: _currentPage == index ? 1.0 : 0.95,
                      curve: Curves.easeOut,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Banner Image
                              banner.imageUrl != null && banner.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      ApiService.toAbsoluteUrl(banner.imageUrl)!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.grey.shade100,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                              color: Colors.blue.shade300,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported_outlined,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                              
                              // Gradient Overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.4),
                                      Colors.transparent,
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.7, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        
        const SizedBox(height: 12),
        
        // ================ INDICATORS ================
        if (widget.showIndicators && widget.banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _currentPage == index ? 28.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _currentPage == index
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
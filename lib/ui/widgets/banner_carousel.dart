import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scentview/models/banner.dart' as model;
import 'package:scentview/services/api_service.dart';

class BannerCarousel extends StatefulWidget {
  final List<model.Banner> banners;
  final Function(model.Banner) onTap;

  const BannerCarousel({
    super.key,
    required this.banners,
    required this.onTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.banners.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final banner = widget.banners[index];
          return GestureDetector(
            onTap: () => widget.onTap(banner),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: banner.imageUrl != null && banner.imageUrl!.isNotEmpty
                  ? Image.network(
                      ApiService.toAbsoluteUrl(banner.imageUrl)!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    )
                  : const Center(child: Icon(Icons.image_not_supported)),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:astrokavach/core/providers/home_providers.dart';

class HomeBannerSection extends ConsumerWidget {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Watch the FutureProvider for banners
    final bannerAsync = ref.watch(bannerProvider('home'));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      // Handle the 3 states of a FutureProvider: loading, error, data
      child: bannerAsync.when(
        loading: () => _buildShimmer(screenHeight),
        error: (err, stack) => _buildErrorState(screenHeight),
        data: (banners) {
          if (banners.isEmpty) return const SizedBox.shrink();

          return CarouselSlider.builder(
            itemCount: banners.length,
            options: CarouselOptions(
              height: screenHeight * 0.22,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              autoPlayInterval: const Duration(seconds: 4),
            ),
            itemBuilder: (context, index, realIndex) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    banners[index].image ?? '',
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey, size: 50),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Professional Shimmer Loading Skeleton
  Widget _buildShimmer(double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: screenHeight * 0.22,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Graceful Error State
  Widget _buildErrorState(double screenHeight) {
    return Container(
      height: screenHeight * 0.22,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, color: Colors.grey),
            SizedBox(height: 8),
            Text('Could not load banners', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

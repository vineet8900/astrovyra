import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:astrokavach/core/providers/astrologer_providers.dart';
import 'package:astrokavach/screen/astrologer/astrologer_list_screen.dart';
import 'package:astrokavach/screen/livestreamscreen.dart';
import 'package:astrokavach/core/utils/translation_ext.dart';

class HomeLiveAstrologerSection extends ConsumerWidget {
  final double screenWidth;
  final double screenHeight;

  const HomeLiveAstrologerSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the master future provider for loading state, but use the derived provider for the actual data
    final astrologersAsync = ref.watch(homeAstrologersProvider);
    final liveAstrologerList = ref.watch(liveAstrologersProvider);

    return Column(
      children: [
        _buildSectionHeader(context, 'live_astrologer'.tr, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveAstrologerListScreen()));
        }),
        SizedBox(
          height: screenHeight * 0.17,
          child: astrologersAsync.when(
            loading: () => _buildShimmer(),
            error: (err, stack) => const Center(child: Text("Could not load live astrologers")),
            data: (_) {
              if (liveAstrologerList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("No astrologers are live right now", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                itemCount: liveAstrologerList.length,
                itemBuilder: (context, index) {
                  final astrologer = liveAstrologerList[index];
                  bool isScheduled = astrologer.status?.toLowerCase() == 'scheduled';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LiveAstrologerListScreen()),
                      );
                    },
                    child: Container(
                      width: screenWidth * 0.28,
                      margin: EdgeInsets.only(right: screenWidth * 0.04),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              astrologer.image ?? '',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.person, color: Colors.grey, size: 50),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                astrologer.name ?? "",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isScheduled ? Colors.blue : Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isScheduled)
                                    const Icon(Icons.circle, color: Colors.white, size: 6),
                                  if (!isScheduled) const SizedBox(width: 4),
                                  Text(
                                    isScheduled ? 'Scheduled' : 'Live',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text('view_all'.tr, style: const TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 4,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      itemBuilder: (context, index) {
        return Container(
          width: screenWidth * 0.28,
          margin: EdgeInsets.only(right: screenWidth * 0.04),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}

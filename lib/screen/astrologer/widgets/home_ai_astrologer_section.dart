import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:astrokavach/core/providers/astrologer_providers.dart';
import 'package:astrokavach/screen/Ai_astrologer_list.dart';
import 'package:astrokavach/screen/AiAstrologer.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrokavach/core/utils/translation_ext.dart';

class HomeAiAstrologerSection extends ConsumerWidget {
  final double screenWidth;
  final double screenHeight;

  const HomeAiAstrologerSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final astrologersAsync = ref.watch(homeAstrologersProvider);
    final aiAstrologerList = ref.watch(aiAstrologersProvider);

    return Column(
      children: [
        _buildSectionHeader(context, 'ai_astrologer'.tr, () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? apiToken = prefs.getString('api_token');
          if (apiToken == null || apiToken.isEmpty) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AiAstrologerListScreen()));
          }
        }),
        SizedBox(
          height: 200,
          child: astrologersAsync.when(
            loading: () => _buildShimmer(),
            error: (err, stack) => const Center(child: Text("Could not load AI astrologers")),
            data: (_) {
              if (aiAstrologerList.isEmpty) return const Center(child: Text("No AI Astrologers available"));

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: aiAstrologerList.length,
                itemBuilder: (context, index) {
                  final astrologer = aiAstrologerList[index];
                  final hasSpecialPrice = astrologer.chatSpecialPrice != null &&
                      astrologer.chatPrice != null &&
                      astrologer.chatSpecialPrice! > 0 &&
                      astrologer.chatSpecialPrice! < astrologer.chatPrice!;

                  return GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? apiToken = prefs.getString('api_token');
                      if (apiToken == null || apiToken.isEmpty) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Aiastrologer(
                              astrologer: astrologer,
                              allAstrologers: aiAstrologerList,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: screenWidth * 0.35,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: astrologer.image != null ? NetworkImage(astrologer.image!) : null,
                            child: astrologer.image == null ? const Icon(Icons.person, color: Colors.grey) : null,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              astrologer.name ?? "AI Astrologer",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            astrologer.specialty ?? "Vedic Astrology",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          const Spacer(),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A3665),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Chat Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      itemCount: 3,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        return Container(
          width: screenWidth * 0.35,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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

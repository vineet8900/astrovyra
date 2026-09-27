
import 'package:astrokavach/api/searchapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/searchbanado.dart';
import 'package:astrokavach/screen/astrologer/astrologer_list_screen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/livestreamscreen.dart';
import 'package:astrokavach/screen/supportscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:astrokavach/screen/astrologer/astrologer_detail_screen.dart';
import 'package:astrokavach/screen/Ai_astrologer_list.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';

class AppSearchDelegate extends SearchDelegate<UnifiedSearchResult?> {
  final SearchApiService _searchApiService = SearchApiService();


  Future<bool> _isGuestUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    if (token == null || token.isEmpty) return true;
    if (token.length == 12 && int.tryParse(token) != null) return true;
    return false;
  }


  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
  
    if (query.isNotEmpty) {
      return [
        IconButton(
          icon: Icon(Icons.clear, color: Colors.black),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      ];
    }
    return [];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Top Services',
                  style: TextStyle(
                    fontSize: 14,
                   
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildServiceButton(
                        context,
                        imagePath: "assets/callring.png",
                        label: 'Call',
                        color: CustomStyles.callActionBackground,
                        iconColor: Colors.white,
                        labelColor: Colors.white,
                        onTap: () async {
                          final isGuest = await _isGuestUser();
                          if (!context.mounted) return;
                          if (isGuest) {
                            close(context, null);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen(
                                          redirectScreen:
                                              AstrologerListScreen(mode: "call"),
                                        )));
                          } else {
                            close(context, null);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AstrologerListScreen(
                                          mode: "call",
                                        )));
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      _buildServiceButton(
                        context,
                        
                        imagePath: "assets/chat-dots-fill.png",
                        label: 'Chat',

                        color: Colors.orange.shade100,
                        iconColor: Colors.black,
                        onTap: () async {
                          final isGuest = await _isGuestUser();
                          if (!context.mounted) return;
                          if (isGuest) {
                            close(context, null);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen(
                                          redirectScreen:
                                              AstrologerListScreen(mode: "chat"),
                                        )));
                          } else {
                            close(context, null);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AstrologerListScreen(
                                          mode: "chat",
                                        )));
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      _buildServiceButton(
                        context,
                       

                        imagePath: "assets/camera-video-fill.png",
                        label: 'Live',
                        color: Colors.blue.shade100,
                        iconColor: Color(0xFFF57C00),
                        onTap: () async {
                          final isGuest = await _isGuestUser();
                          if (!context.mounted) return;
                          if (isGuest) {
                            close(context, null);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen(
                                          redirectScreen:
                                              LiveAstrologerListScreen(),
                                        )));
                          } else {
                            close(context, null);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LiveAstrologerListScreen()));
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      _buildServiceButton(
                        context,
                        imagePath: "assets/supportremove.png",
                      
                        label: 'support',
                        color: CustomStyles.offerCountdownSecondsBg,
                        iconColor: Colors.black,
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SupportScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
             
            ],
          ),
        ),
      );
    }

 
    return FutureBuilder<List<UnifiedSearchResult>>(
      future: _searchApiService.search(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                SizedBox(height: 16),
                Text(
                  'No results found for "$query"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        final results = snapshot.data!;

        return Container(
          color: Colors.grey.shade50,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () async {
                    await _navigateToDetail(context, item);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Image or Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade100,
                          ),
                          child: item.image != null && item.image!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        _getIconForType(item.type),
                                        size: 28,
                                        color: Colors.grey.shade400,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  _getIconForType(item.type),
                                  size: 28,
                                  color: Colors.grey.shade400,
                                ),
                        ),
                        SizedBox(width: 14),
                     
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _getColorForType(item.type)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getTypeString(item.type),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _getColorForType(item.type),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow Icon
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


  Widget _buildServiceButton(
    BuildContext context, {
    IconData? icon,
    String? imagePath,
    required String label,
    required Color color,
    Color iconColor = Colors.white,
    Color labelColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.24,
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade500,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 3,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor,
                  size: 14,
                )
              else if (imagePath != null)
                Image.asset(
                  imagePath,
                  width: 14,
                  height: 14,
                  fit: BoxFit.contain,
                  color: iconColor,
                ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDetailScreenTypeString(SearchItemType type) {
    switch (type) {
      case SearchItemType.product:
        return 'product';
      case SearchItemType.pooja:
        return 'pooja';
      case SearchItemType.service:
        return 'service';
      default:
        return 'product';
    }
  }

  Future<void> _navigateToDetail(
      BuildContext context, UnifiedSearchResult item) async {
    close(context, item);

    switch (item.type) {
      case SearchItemType.astrologer:
        if (item.slug != null) {
          final isGuest = await _isGuestUser();
          if (isGuest) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    redirectScreen: AstrologerDetailScreen(
                        astrologerId: item.id, slug: item.slug!),
                  ),
                ),
              );
            }
          } else {
            Get.to(() => AstrologerDetailScreen(
                astrologerId: item.id, slug: item.slug!));
          }
        }
        break;

      case SearchItemType.aiAstrologer:
        final isGuest = await _isGuestUser();
        if (isGuest) {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(
                  redirectScreen: AiAstrologerListScreen(),
                ),
              ),
            );
          }
        } else {
          Get.to(() => AiAstrologerListScreen());
        }
        break;

      case SearchItemType.product:
      case SearchItemType.pooja:
      case SearchItemType.service:
     
        Get.to(() => ProductDetailScreen(
              itemId: item.id,
              slug: item.slug,
              productname: item.name,
              type: _getDetailScreenTypeString(item.type),
            ));
        break;

      default:
        print("Navigation not implemented for this type");
    }
  }

  IconData _getIconForType(SearchItemType type) {
    switch (type) {
      case SearchItemType.astrologer:
        return Icons.person;
      case SearchItemType.aiAstrologer:
        return Icons.smart_toy_outlined;
      case SearchItemType.product:
        return Icons.shopping_bag;
      case SearchItemType.pooja:
        return Icons.wb_sunny;
      case SearchItemType.service:
        return Icons.book_online;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForType(SearchItemType type) {
    switch (type) {
      case SearchItemType.astrologer:
        return Colors.black;
      case SearchItemType.aiAstrologer:
        return Colors.black;
      case SearchItemType.product:
        return Colors.black;
      case SearchItemType.pooja:
        return Colors.black;
      case SearchItemType.service:
        return Colors.black;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getTypeString(SearchItemType type) {
    String typeName = type.toString().split('.').last;
    if (typeName == 'aiAstrologer') {
      return 'AI Astrologer';
    }
    return typeName.capitalizeFirst ?? '';
  }
}



import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrokavach/api/zodiacservice.dart/zodiac_api_service.dart';
import 'package:astrokavach/api/zodiacservice.dart/zodiac_api_horse.dart';
import 'package:astrokavach/controller/zodiac/zodiacmodel.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/horsescode/horsce.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen>
    with SingleTickerProviderStateMixin {
  final ZodiacApiService _apiService = ZodiacApiService();
  final HoroscopeApiService _horoscopeApiService = HoroscopeApiService();
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  List<ZodiacSign> zodiacSigns = [];
  bool isLoading = true;
  String? errorMessage;
  String currentTimeframe = "today";
  int _currentPage = 0;

  ZodiacSign? selectedZodiac;
  HoroscopeResponse? horoscopeData;
  bool isLoadingDetails = false;

  late TabController _timeframeTabController;

  final GlobalKey _detailsSectionKey = GlobalKey();

  final List<Map<String, dynamic>> timeframes = [
    {'key': 'today', 'label': 'Today'},
    {'key': 'tomorrow', 'label': 'Tomorrow'},
    {'key': 'yesterday', 'label': 'Yesterday'},
    {'key': 'weekly', 'label': 'Weekly'},
    {'key': 'yearly', 'label': 'Yearly'},
  ];

  final List<Map<String, dynamic>> _contentConfig = [
    {
      'icon': Icons.favorite_rounded,
      'name': 'Love',
      'color': Color(0xFFE91E63),
    },
    {
      'icon': Icons.health_and_safety_rounded,
      'name': 'Health and Wellness',
      'color': Color(0xFF4CAF50),
    },
    {
      'icon': Icons.work_rounded,
      'name': 'Career and Education',
      'color': Color(0xFF2196F3),
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'name': 'Money and Finances',
      'color': Color(0xFFFF9800),
    },
    {
      'icon': Icons.people_rounded,
      'name': 'Family and Friends',
      'color': Color(0xFF9C27B0),
    },
    {
      'icon': Icons.tips_and_updates_rounded,
      'name': 'Tips',
      'color': Color(0xFFFFB300),
    },
  ];

  @override
  void initState() {
    super.initState();
    _timeframeTabController =
        TabController(length: timeframes.length, vsync: this);
    _timeframeTabController.addListener(_onTimeframeTabChanged);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    _fetchZodiacSigns();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timeframeTabController.removeListener(_onTimeframeTabChanged);
    _timeframeTabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTimeframeTabChanged() {
    if (_timeframeTabController.indexIsChanging && selectedZodiac != null) {
      final selectedTimeframe =
          timeframes[_timeframeTabController.index]['key'];
      currentTimeframe = selectedTimeframe;
      _fetchHoroscopeDetails(selectedZodiac!);
    }
  }

  Future<void> _fetchZodiacSigns() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response =
          await _apiService.fetchZodiacSigns(timeframe: currentTimeframe);
      if (response != null && response.success) {
        setState(() {
          zodiacSigns = response.data;
          isLoading = false;
          if (zodiacSigns.isNotEmpty) {
            _fetchHoroscopeDetails(zodiacSigns[0]);
          }
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load zodiac signs';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchHoroscopeDetails(ZodiacSign sign) async {
    setState(() {
      isLoadingDetails = true;
      selectedZodiac = sign;
    });

    if (selectedZodiac != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToDetails();
      });
    }

    try {
      final response = await _horoscopeApiService.fetchHoroscopeDetail(
        zodiacId: sign.id,
        timeFrame: currentTimeframe,
      );

      setState(() {
        horoscopeData = response;
        isLoadingDetails = false;
      });
    } catch (e) {
      setState(() {
        isLoadingDetails = false;
        horoscopeData = HoroscopeResponse(
          success: false,
          message: 'Failed to load horoscope: $e',
        );
      });
    }
  }

  void _scrollToDetails() {
    final context = _detailsSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onZodiacTap(ZodiacSign sign) {
    _fetchHoroscopeDetails(sign);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: 'daily_horoscope'.tr,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // Share functionality
        //     },
        //     icon: Icon(Icons.share, color: Colors.green),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildZodiacRow(),
            const SizedBox(height: 16),
            if (selectedZodiac != null) _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacRow() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: zodiacSigns.length,
        itemBuilder: (context, index) {
          final sign = zodiacSigns[index];
          final isSelected = selectedZodiac?.id == sign.id;

          return GestureDetector(
            onTap: () => _onZodiacTap(sign),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              width: 80,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: isSelected ? 72 : 60,
                    height: isSelected ? 72 : 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.grey.shade300 : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.grey.shade500
                            : Colors.grey.shade300,
                        width: isSelected ? 1.7 : 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                                color: Colors.grey,
                              ),
                            ]
                          : [],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: (sign.url.isEmpty)
                          ? Icon(
                              Icons.stars,
                              size: 26,
                              color: isSelected
                                  ? Colors.blueGrey
                                  : Colors.grey.shade600,
                            )
                          : Image.network(
                              sign.url,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.stars,
                                size: 26,
                                color: isSelected
                                    ? Colors.blueGrey
                                    : Colors.grey.shade600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 70,
                    child: Text(
                      sign.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // if (sign.dateRange != null) ...[
                  //   const SizedBox(height: 2),
                  //   Text(
                  //     sign.dateRange!,
                  //     style: TextStyle(
                  //       fontSize: 9,
                  //       color: Colors.grey.shade600,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      key: _detailsSectionKey,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeframe Tabs with shadow
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _timeframeTabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              //padding: EdgeInsets.zero,  // ✅ Ye add karo
              labelPadding: const EdgeInsets.symmetric(
                  horizontal: 16), // ✅ Custom padding
              dividerColor: Colors.transparent,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Colors.orange.shade600,
                  width: 3,
                ),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              tabs: timeframes.map((tf) {
                return Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12), // ✅ Yaha se bhi padding hatao
                    child: Text(tf['label']),
                  ),
                );
              }).toList(),
            ),
            // TabBar(
            //   controller: _timeframeTabController,
            //   isScrollable: false,
            //   dividerColor: Colors.transparent,
            //   indicator: UnderlineTabIndicator(
            //     borderSide: BorderSide(
            //       color: Colors.orange.shade600,
            //       width: 3,
            //     ),
            //   ),
            //   labelColor: Colors.black,
            //   unselectedLabelColor: Colors.grey.shade500,
            //   labelStyle: const TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 15,
            //   ),
            //   unselectedLabelStyle: const TextStyle(
            //     fontWeight: FontWeight.normal,
            //     fontSize: 15,
            //   ),
            //   tabs: timeframes.map((tf) {
            //     return Tab(
            //       child: Padding(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            //         child: Text(tf['label']),
            //       ),
            //     );
            //   }).toList(),
            // ),
          ),
          const SizedBox(height: 20),

          // What Horoscope Says Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'What Horoscope says about you',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (isLoadingDetails)
            const Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            )
          else if (horoscopeData?.success == true)
            _buildHoroscopeContent()
          else
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Failed to load horoscope data'),
            ),
          const SizedBox(height: 20),
          // Safe Area padding at bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildLuckyItemsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Colours',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Numbers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '17, 73, 10',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alphabets',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'N, E',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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

  Widget _buildHoroscopeContent() {
    final sections = horoscopeData!.data!.prediction.getAllSections();
    final limitedSections = sections.take(6).toList();

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.55,
          child: PageView.builder(
            controller: _pageController,
            itemCount: limitedSections.length,
            itemBuilder: (context, index) {
              final section = limitedSections[index];
              final config = _contentConfig[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSectionCard(section, config),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicator(limitedSections.length),
      ],
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                _currentPage == index ? Colors.blueGrey : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard(
      HoroscopeSection section, Map<String, dynamic> config) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        // ✅ Border color changed → grey.shade500
        border: Border.all(
          color: Colors.grey.shade500,
          width: 1.4,
        ),

        // ✅ Strong shadow added
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (config['color'] as Color).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    config['icon'],
                    color: config['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade400),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                section.value.join(' '),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSectionCard(
  //     HoroscopeSection section, Map<String, dynamic> config) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: Colors.grey.shade300,
  //         width: 1,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: const BorderRadius.only(
  //               topLeft: Radius.circular(16),
  //               topRight: Radius.circular(16),
  //             ),
  //           ),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: (config['color'] as Color).withOpacity(0.1),
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: Icon(
  //                   config['icon'],
  //                   color: config['color'],
  //                   size: 24,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   section.name,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black87,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Divider(height: 1, color: Colors.grey.shade200),
  //         Expanded(
  //           child: SingleChildScrollView(
  //             padding: const EdgeInsets.all(20),
  //             child: Text(
  //               section.value.join(' '),
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 height: 1.6,
  //                 color: Colors.grey.shade700,
  //                 letterSpacing: 0.2,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

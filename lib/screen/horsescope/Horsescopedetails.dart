import 'package:flutter/material.dart';
import 'package:astrokavach/api/zodiacservice.dart/zodiac_api_horse.dart';
import 'package:astrokavach/model/horsescode/horsce.dart'
    show HoroscopeResponse, HoroscopeSection;

class HorsescopeDetails extends StatefulWidget {
  final int zodiacId;
  final String timeframe;
  final String signName;
  final String signUrl;

  const HorsescopeDetails({
    super.key,
    required this.zodiacId,
    required this.timeframe,
    required this.signName,
    required this.signUrl,
  });

  @override
  State<HorsescopeDetails> createState() => _HorsescopeDetailsState();
}

class _HorsescopeDetailsState extends State<HorsescopeDetails>
    with TickerProviderStateMixin {
  late TabController _contentTabController;
  late TabController _timeframeTabController;
  final HoroscopeApiService _apiService = HoroscopeApiService();
  HoroscopeResponse? _horoscopeData;
  bool _isLoading = false;
  String _currentTimeframe = '';

  // Timeframe configuration
  final List<Map<String, dynamic>> _timeframes = [
    {
      'key': 'today',
      'label': 'Today',
      'icon': Icons.today_rounded,
      // 'color': Color(0xFF4CAF50),
      // 'gradient': [Color(0xFF4CAF50), Color(0xFF2E7D32)]
      'color': Colors.grey.shade800,
      'gradient': [Colors.grey.shade800, Colors.grey.shade800]
    },
    {
      'key': 'tomorrow',
      'label': 'Tomorrow',
      'icon': Icons.arrow_forward_rounded,
      'color': Colors.grey.shade800,
      'gradient': [Colors.grey.shade800, Colors.grey.shade800]
    },
    {
      'key': 'yesterday',
      'label': 'Yesterday',
      'icon': Icons.arrow_back_rounded,
      'color': Colors.grey.shade800,
      'gradient': [Colors.grey.shade800, Colors.grey.shade800]
    },
    {
      'key': 'weekly',
      'label': 'Weekly',
      'icon': Icons.date_range_rounded,
      'color': Colors.grey.shade800,
      'gradient': [Colors.grey.shade800, Colors.grey.shade800]
    },
    {
      'key': 'yearly',
      'label': 'Yearly',
      'icon': Icons.calendar_month,
      'color': Colors.grey.shade800,
      'gradient': [Colors.grey.shade800, Colors.grey.shade800]
    },
  ];

  // Professional tab configuration for content
  final List<Map<String, dynamic>> _tabConfig = [
    {
      'icon': Icons.favorite_rounded,
      'name': 'Love',
      'color': Color(0xFFE91E63),
      'gradient': [Color(0xFFE91E63), Color(0xFFAD1457)]
    },
    {
      'icon': Icons.health_and_safety_rounded,
      'name': 'Health',
      'color': Color(0xFF4CAF50),
      'gradient': [Color(0xFF4CAF50), Color(0xFF2E7D32)]
    },
    {
      'icon': Icons.work_rounded,
      'name': 'Career',
      'color': Color(0xFF2196F3),
      'gradient': [Color(0xFF2196F3), Color(0xFF1565C0)]
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'name': 'Money',
      'color': Color(0xFFFF9800),
      'gradient': [Color(0xFFFF9800), Color(0xFFE65100)]
    },
    {
      'icon': Icons.people_rounded,
      'name': 'Family',
      'color': Color(0xFF9C27B0),
      'gradient': [Color(0xFF9C27B0), Color(0xFF6A1B9A)]
    },
    {
      'icon': Icons.tips_and_updates_rounded,
      'name': 'Tips',
      'color': Color(0xFFFFB300),
      'gradient': [Color(0xFFFFB300), Color(0xFFFF8F00)]
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentTimeframe = widget.timeframe;

    // Initialize timeframe tab controller
    final initialTimeframeIndex = _timeframes.indexWhere(
      (tf) => tf['key'] == _currentTimeframe,
    );
    _timeframeTabController = TabController(
      length: _timeframes.length,
      vsync: this,
      initialIndex: initialTimeframeIndex >= 0 ? initialTimeframeIndex : 0,
    );
    _timeframeTabController.addListener(_onTimeframeTabChanged);

    // Initialize content tab controller
    _contentTabController = TabController(length: 6, vsync: this);

    _fetchHoroscope();
  }

  @override
  void dispose() {
    _timeframeTabController.removeListener(_onTimeframeTabChanged);
    _timeframeTabController.dispose();
    _contentTabController.dispose();
    super.dispose();
  }

  void _onTimeframeTabChanged() {
    if (_timeframeTabController.indexIsChanging) {
      final selectedTimeframe =
          _timeframes[_timeframeTabController.index]['key'];
      if (selectedTimeframe != _currentTimeframe) {
        setState(() {
          _currentTimeframe = selectedTimeframe;
        });
        
        _fetchHoroscope();
      }
    }
  }

  Map<String, dynamic> get _currentTimeframeData {
    return _timeframes.firstWhere(
      (tf) => tf['key'] == _currentTimeframe,
      orElse: () => _timeframes[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: _isLoading
          ? _buildLoadingWidget()
          : _horoscopeData?.success == true
              ? _buildContent()
              : _buildErrorWidget(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Professional Header with dynamic colors
        _buildProfessionalHeader(),

        // Timeframe Tabs
        _buildTimeframeTabs(),

        // Content Tab Section
        Expanded(
          child: _buildContentTabSection(),
        ),
      ],
    );
  }

  Widget _buildProfessionalHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 320;

    return Container(
      decoration: BoxDecoration(color: Colors.white
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //    // Color(0xFFFFF9C4),
          //    // // Light Yellow
          //      Colors.white,
          //      Color(0xFFFFF9C4),
          //     // Color(0xFFFFF59D), // Slightly darker light yellow
          //   ],
          // ),
          ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20, vertical: 16),
          child: Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(width: 16),

              // Zodiac Image - Responsive
              Container(
                width: MediaQuery.of(context).size.width * 0.12,
                height: MediaQuery.of(context).size.width * 0.12,
                constraints: BoxConstraints(
                  minWidth: 45,
                  maxWidth: 60,
                  minHeight: 45,
                  maxHeight: 60,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black)
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black,
                    //     blurRadius: 10,
                    //     offset: const Offset(0, 3),
                    //   ),
                    // ],
                    ),
                child: ClipOval(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: widget.signUrl.isNotEmpty
                        ? Image.network(
                            widget.signUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF6B7280),
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFF9C4), Color(0xFFFFF59D)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.black,
                              size: MediaQuery.of(context).size.width * 0.06,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Title and Timeframe - Responsive
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.signName,
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 16 : 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black, // Dark gray text
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: isSmallScreen ? 8 : 12,
                      //     vertical: isSmallScreen ? 2 : 4
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Color(0xFF374151).withOpacity(0.1), // Dark gray with opacity
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       // Icon(
                      //       //   _currentTimeframeData['icon'],
                      //       //   color: Color(0xFF6B7280), // Gray color for icon
                      //       //   size: isSmallScreen ? 12 : 14,
                      //       // ),
                      //      // SizedBox(width: 4),
                      //       // Text(
                      //       //   //_currentTimeframeData['label'].toUpperCase(),
                      //       //   // style: TextStyle(
                      //       //   //   color: Color(0xFF374151), // Dark gray text
                      //       //   //   fontSize: isSmallScreen ? 9 : 11,
                      //       //   //   fontWeight: FontWeight.w600,
                      //       //   //   letterSpacing: 1.2,
                      //       //   // ),
                      //       // ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),

              // Refresh Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)),
                  onPressed: _fetchHoroscope,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _timeframeTabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: _currentTimeframeData['gradient'],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _currentTimeframeData['color'].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.all(6),
        dividerColor: Colors.transparent,
        tabs: _timeframes.map((timeframe) {
          return Tab(
            height: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    timeframe['icon'],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(timeframe['label']),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentTabSection() {
    if (_horoscopeData?.data?.prediction == null) {
      return const Center(child: Text('No prediction data available'));
    }

    final sections = _horoscopeData!.data!.prediction.getAllSections();
    final availableSections = sections.take(6).toList();

    return Column(
      children: [
        // Content Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _contentTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade800, Colors.grey.shade800],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.all(6),
            dividerColor: Colors.transparent,
            tabs: List.generate(availableSections.length, (index) {
              final config = _tabConfig[index];
              return Tab(
                height: 60,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        config['icon'],
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getShortTabName(availableSections[index].name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        // Tab Content with Scrollable Views
        Expanded(
          child: TabBarView(
            controller: _contentTabController,
            children: List.generate(availableSections.length, (index) {
              return _buildScrollableTabContent(
                  availableSections[index], index);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableTabContent(HoroscopeSection section, int index) {
    final config = _tabConfig[index];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomScrollView(
        slivers: [
          // Section Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: config['gradient'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: config['color'].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      config['icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _currentTimeframeData['label'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, contentIndex) {
                final text = section.value[contentIndex];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: config['color'].withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: config['gradient'],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: section.value.length,
            ),
          ),

          // Bottom padding
          SliverToBoxAdapter(
            child: const SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    final currentData = _currentTimeframeData;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: currentData['color'],
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading ${currentData['label'].toLowerCase()} horoscope...',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    final currentData = _currentTimeframeData;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            // Text(
            //   _horoscopeData?.message ?? 'Unable to load horoscope data',
            //   style: const TextStyle(
            //     fontSize: 14,
            //     color: Color(0xFF6B7280),
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchHoroscope,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentData['color'],
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShortTabName(String fullName) {
    switch (fullName.toLowerCase()) {
      case 'love and relationships':
        return 'Love';
      case 'health and wellness':
        return 'Health';
      case 'career and education':
        return 'Career';
      case 'money and finances':
        return 'Money';
      case 'family and friends':
        return 'Family';
      case 'tip of the month for the year:':
        return 'Tips';
      default:
        return fullName.length > 8 ? fullName.substring(0, 8) : fullName;
    }
  }

  Future<void> _fetchHoroscope() async {
    setState(() {
      _isLoading = true;
    });

    try {
     

      final response = await _apiService.fetchHoroscopeDetail(
        zodiacId: widget.zodiacId,
        timeFrame: _currentTimeframe,
      );

      setState(() {
        _horoscopeData = response;
        _isLoading = false;
      });

      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _horoscopeData = HoroscopeResponse(
          success: false,
          message: 'Failed to load horoscope: $e',
        );
      });
      
    }
  }
}

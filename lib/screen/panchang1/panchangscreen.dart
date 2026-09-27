

import 'dart:ui';
import 'package:astrokavach/custom_widgets/app_date_time_picker_theme.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:astrokavach/api/auth_api/panchangapi.dart';
import 'package:astrokavach/controller/panchang/panchang.dart';

class PanchangScreen extends StatefulWidget {
  @override
  _PanchangScreenState createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen>
    with SingleTickerProviderStateMixin {
  PanchangResponse? panchangData;
  bool isLoading = false;
  String? errorMessage;
  DateTime selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fetchPanchangData(DateFormat('yyyy-MM-dd').format(selectedDate));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchPanchangData(String date) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await PanchangService.fetchPanchang(date);
      setState(() {
        panchangData = response;
        isLoading = false;
      });
      _animationController.forward(from: 0.0);
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) =>
          AppDateTimePickerTheme.wrap(context, child),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _animationController.reset();
      _fetchPanchangData(DateFormat('yyyy-MM-dd').format(selectedDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BottomAppBarScreen())),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: 'panchang'.tr,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Date Selection Header
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            color: Colors.white,
            child: _buildDateSelectionHeader(screenWidth),
          ),

          // Scrollable Content
          Expanded(
            child: _buildBodyContent(screenHeight, screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionHeader(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Today Dropdown
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: screenWidth * 0.05),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${DateFormat('EEEE').format(selectedDate)} | ${DateFormat('MMMM dd, yyyy').format(selectedDate)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyContent(double screenHeight, double screenWidth) {
    if (isLoading) {
      return _buildLoadingWidget(screenHeight);
    }

    if (errorMessage != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: _buildErrorWidget(screenHeight, screenWidth),
      );
    }

    if (panchangData != null) {
      return SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: () => _fetchPanchangData(
                DateFormat('yyyy-MM-dd').format(selectedDate)),
            color: Colors.orange,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              physics: AlwaysScrollableScrollPhysics(),
              child: _buildScrollablePanchangContent(screenWidth),
            ),
          ),
        ),
      );
    }

    return Container();
  }

  Widget _buildScrollablePanchangContent(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sun/Moon Timings Card
        _buildSunMoonTimingsCard(screenWidth),
        SizedBox(height: screenWidth * 0.04),

        // Auspicious/Inauspicious Times Section
        Text(
          'auspicious_inauspicious_times'.tr,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        _buildTimingsGrid(screenWidth),

        SizedBox(height: screenWidth * 0.04),

        _buildChoghadiyaSection(screenWidth),

        SizedBox(height: screenWidth * 0.04),

        // Hindu Calendar Section
        Text(
          'panchang_calendar'.tr,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        _buildCalendarCard(screenWidth),
        SizedBox(height: screenWidth * 0.04),

        // Disha Shoola
        _buildDishashoolaCard(screenWidth),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSunMoonTimingsCard(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025, vertical: screenWidth * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          // Sunrise
          Expanded(
            child: Column(
              children: [
                Icon(Icons.wb_sunny,
                    color: Colors.orange, size: screenWidth * 0.1),
                SizedBox(height: 8),
                Text(
                  'sunrise'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  panchangData!.data.response.sunAndMoon.sunRise,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Sunset
          Expanded(
            child: Column(
              children: [
                Icon(Icons.wb_sunny_outlined,
                    color: Colors.orange, size: screenWidth * 0.1),
                SizedBox(height: 8),
                Text(
                  'sunset'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  panchangData!.data.response.sunAndMoon.sunSet,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Moonrise
          Expanded(
            child: Column(
              children: [
                Icon(Icons.nightlight_round,
                    color: Colors.blue.shade100, size: screenWidth * 0.1),
                SizedBox(height: 8),
                Text(
                  'moonrise'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  panchangData!.data.response.sunAndMoon.moonRise,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Moonset
          Expanded(
            child: Column(
              children: [
                Icon(Icons.nightlight,
                    color: Colors.blue.shade200, size: screenWidth * 0.1),
                SizedBox(height: 8),
                Text(
                  'moonset'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  panchangData!.data.response.sunAndMoon.moonSet,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingsGrid(double screenWidth) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTimingCard(
                'abhijit'.tr,
                panchangData!.data.response.auspiciousTiming.abhijit,
                Colors.green.shade100, // Changed background to white
                screenWidth,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: _buildTimingCard(
                'gulika_kaal'.tr,
                panchangData!.data.response.inauspiciousTiming.gulika,
                Colors.orange.shade100,
                screenWidth,
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.03),
        Row(
          children: [
            Expanded(
              child: _buildTimingCard(
                'Rahukaal',
                '${panchangData!.data.response.inauspiciousTiming.yamakanta}', // Using yamakanta as placeholder
                Colors.blue.shade100,
                screenWidth,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: _buildTimingCard(
                'yamakanta'.tr,
                panchangData!.data.response.inauspiciousTiming.yamakanta,
                CustomStyles.offerCountdownSecondsBg,
                screenWidth,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimingCard(
      String label, String time, Color bgColor, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: screenWidth * 0.026,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        children: [
          _buildCalendarRow('purnimanta_month'.tr,
              panchangData!.data.response.monthAndYear.purnimanta, screenWidth),
          _buildCalendarRow('amanta_month'.tr,
              panchangData!.data.response.monthAndYear.amanta, screenWidth),
          _buildCalendarRow(
              'shaka_samvat'.tr,
              panchangData!.data.response.monthAndYear.shakaSamvat,
              screenWidth),
          _buildCalendarRow(
              'vikram_samvat'.tr,
              panchangData!.data.response.monthAndYear.vikramSamvat.toString(),
              screenWidth),
          _buildCalendarRow(
              'kali_samvat'.tr,
              panchangData!.data.response.monthAndYear.kaliSamvat.toString(),
              screenWidth,
              isLast: false),
          _buildCalendarRow('moon_sign'.tr,
              panchangData!.data.response.sunAndMoon.moonSign, screenWidth,
              isLast: false),
          _buildCalendarRow('season'.tr,
              panchangData!.data.response.sunAndMoon.ritu, screenWidth,
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildCalendarRow(String label, String value, double screenWidth,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600]!,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1),
      ],
    );
  }

  Widget _buildDishashoolaCard(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'disha_shoola'.tr,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.navigation,
                    color: Colors.orange, size: screenWidth * 0.08),
                SizedBox(width: screenWidth * 0.04),
                Text(
                  panchangData!.data.response.dishaShoola.dishaShoola,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _choghadiyaColorForType(String type) {
    final t = type.toLowerCase().trim();
    if (t.contains('inauspicious')) return Colors.red.shade700;
    if (t.contains('auspicious')) return const Color(0xFF2E7D32);
    if (t == 'good') return const Color(0xFF1565C0);
    return Colors.black87;
  }

  Widget _buildChoghadiyaSection(double screenWidth) {
    final day = panchangData!.data.response.dayChoghadiya;
    final night = panchangData!.data.response.nightChoghadiya;
    if (day.isEmpty && night.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'choghadiya'.tr,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        _buildChoghadiyaCard(
          screenWidth: screenWidth,
          titleKey: 'day_choghadiya',
          icon: Icons.wb_sunny_rounded,
          iconColor: Colors.orange.shade700,
          items: day,
          emptyMessage: 'choghadiya_day_empty'.tr,
        ),
        SizedBox(height: screenWidth * 0.04),
        _buildChoghadiyaCard(
          screenWidth: screenWidth,
          titleKey: 'night_choghadiya',
          icon: Icons.nightlight_round,
          iconColor: Colors.indigo.shade700,
          items: night,
          emptyMessage: 'choghadiya_night_empty'.tr,
        ),
      ],
    );
  }

  Widget _buildChoghadiyaCard({
    required double screenWidth,
    required String titleKey,
    required IconData icon,
    required Color iconColor,
    required List<ChoghadiyaItem> items,
    String? emptyMessage,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.03,
            ),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: screenWidth * 0.06),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  titleKey.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Text(
                emptyMessage ?? 'choghadiya_empty'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            ...List.generate(items.length, (index) {
              final row = items[index];
              final lineColor = _choghadiyaColorForType(row.type);
              return Column(
                children: [
                  if (index > 0)
                    Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenWidth * 0.028,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: screenWidth * 0.036,
                                height: 1.25,
                              ),
                              children: [
                                TextSpan(
                                  text: row.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: lineColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' - ${row.type}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: lineColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                          ),
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: Text(
                            row.time,
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'loading_panchang_data'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'please_wait'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(double screenHeight, double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[50]!, Colors.red[100]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.red[200]!, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child:
                      Icon(Icons.error_outline, color: Colors.white, size: 32),
                ),
                SizedBox(height: 16),
                Text(
                  'Unable to Load Data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _fetchPanchangData(
                      DateFormat('yyyy-MM-dd').format(selectedDate)),
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

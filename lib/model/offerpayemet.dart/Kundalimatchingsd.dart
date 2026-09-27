import 'package:astrokavach/api/Kundlimatching/kundalimatching.dart';
import 'package:astrokavach/api/product_api/WishlistApi.dart/matchingresult.dart';
import 'package:flutter/material.dart';

// --- Imports from your project ---
// Make sure these paths are correct for your project structure
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/custom_widgets/app_date_time_picker_theme.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:get/get.dart';
// NOTE: I am assuming your Kundali matching API service is in this location.
// Please adjust the import path if it's different.
//import 'package:astrokavach/api/kundalimatching/kundali_api_service.dart';

class Kundalimatching extends StatefulWidget {
  const Kundalimatching({super.key});

  @override
  State<Kundalimatching> createState() => _KundalimatchingState();
}

class _KundalimatchingState extends State<Kundalimatching> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Boy's details
  final _boyNameController = TextEditingController();
  final _boyBirthDateController = TextEditingController();
  final _boyBirthTimeController = TextEditingController();
  final _boyBirthPlaceController = TextEditingController();
  final _boyLocationFocusNode = FocusNode();

  // Controllers for Girl's details
  final _girlNameController = TextEditingController();
  final _girlBirthDateController = TextEditingController();
  final _girlBirthTimeController = TextEditingController();
  final _girlBirthPlaceController = TextEditingController();
  final _girlLocationFocusNode = FocusNode();

  // State for location search
  List<LocationData> _boyLocationSuggestions = [];
  bool _isLoadingBoyLocations = false;
  List<LocationData> _girlLocationSuggestions = [];
  bool _isLoadingGirlLocations = false;

  // General UI State
  bool _isGeneratingReport = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Hide dropdown when user taps outside the location field
    _boyLocationFocusNode.addListener(() {
      if (!_boyLocationFocusNode.hasFocus) {
        _removeLocationOverlay();
      }
    });
    _girlLocationFocusNode.addListener(() {
      if (!_girlLocationFocusNode.hasFocus) {
        _removeLocationOverlay();
      }
    });
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes to prevent memory leaks
    _boyNameController.dispose();
    _boyBirthDateController.dispose();
    _boyBirthTimeController.dispose();
    _boyBirthPlaceController.dispose();
    _boyLocationFocusNode.dispose();
    _girlNameController.dispose();
    _girlBirthDateController.dispose();
    _girlBirthTimeController.dispose();
    _girlBirthPlaceController.dispose();
    _girlLocationFocusNode.dispose();
    super.dispose();
  }

  // --- CORE LOGIC ---

  // Add this helper method after _selectTime method
  String _convertDateFormat(String ddMMyyyy) {
    try {
      final parts = ddMMyyyy.split('-');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day'; // YYYY-MM-DD format
      }
    } catch (e) {}
    return ddMMyyyy;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
    ));
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final DateTime firstDate = DateTime(1900);
    // Birth date cannot be today or future in Kundli matching.
    final DateTime lastSelectable = today.subtract(const Duration(days: 1));

    // Open calendar on last selectable day when the field is empty.
    DateTime initialDate = lastSelectable;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      try {
        final parts = text.split('-');
        if (parts.length == 3) {
          final d = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final y = int.parse(parts[2]);
          final parsed = DateTime(y, m, d);
          if (!parsed.isBefore(firstDate) && !parsed.isAfter(lastSelectable)) {
            initialDate = parsed;
          }
        }
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastSelectable,
      builder: (context, child) => AppDateTimePickerTheme.wrap(
        context,
        child,
        neutralTodayInCalendar: true,
      ),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => AppDateTimePickerTheme.wrap(context, child),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _searchLocation(
      String query, bool isForBoy, BuildContext fieldContext) async {
    if (query.length < 2) {
      _removeLocationOverlay();
      return;
    }

    _removeLocationOverlay(); // Remove previous overlay

    setState(() {
      if (isForBoy)
        _isLoadingBoyLocations = true;
      else
        _isLoadingGirlLocations = true;
    });

    try {
      final response = await AstroApiService.searchLocations(query);
      if (response != null && response.success) {
        if (isForBoy) {
          _boyLocationSuggestions = response.data;
        } else {
          _girlLocationSuggestions = response.data;
        }
        _showLocationOverlay(isForBoy, fieldContext);
      }
    } catch (e) {
      _showSnackBar('Error searching locations: $e', isError: true);
    } finally {
      setState(() {
        if (isForBoy)
          _isLoadingBoyLocations = false;
        else
          _isLoadingGirlLocations = false;
      });
    }
  }

  Future<void> _getMatchingReport() async {
    _removeLocationOverlay();
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGeneratingReport = true);

    try {
      final matchingData = await Kundaliapiservice.fetchMatchingDetails(
        boyName: _boyNameController.text.trim(),
        boyBirthDate: _convertDateFormat(
            _boyBirthDateController.text.trim()), // ✅ Convert here
        boyBirthTime: _boyBirthTimeController.text.trim(),
        boyBirthPlace: _boyBirthPlaceController.text.trim(),
        girlName: _girlNameController.text.trim(),
        girlBirthDate: _convertDateFormat(
            _girlBirthDateController.text.trim()), // ✅ Convert here
        girlBirthTime: _girlBirthTimeController.text.trim(),
        girlBirthPlace: _girlBirthPlaceController.text.trim(),
      );

      _showSnackBar('Report generated successfully!', isError: false);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MatchingResultScreen(data: matchingData)));
    } catch (e) {
      _showSnackBar('Error: ${e.toString().replaceFirst("Exception: ", "")}',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }

  // --- DYNAMIC OVERLAY FOR LOCATION SUGGESTIONS ---

  void _showLocationOverlay(bool isForBoy, BuildContext fieldContext) {
    _removeLocationOverlay();
    final overlay = Overlay.of(context)!;
    final renderBox = fieldContext.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            constraints: BoxConstraints(maxHeight: 200),
            child: (isForBoy ? _isLoadingBoyLocations : _isLoadingGirlLocations)
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator()))
                : (isForBoy
                            ? _boyLocationSuggestions
                            : _girlLocationSuggestions)
                        .isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No locations found'))
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: isForBoy
                            ? _boyLocationSuggestions.length
                            : _girlLocationSuggestions.length,
                        separatorBuilder: (_, __) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final location = isForBoy
                              ? _boyLocationSuggestions[index]
                              : _girlLocationSuggestions[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(Icons.location_on,
                                color: Colors.blue[600], size: 18),
                            title: Text(
                              location.name,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              location.fullName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () {
                              final controller = isForBoy
                                  ? _boyBirthPlaceController
                                  : _girlBirthPlaceController;
                              controller.text = location.fullName;
                              _removeLocationOverlay();
                            },
                          );
                        },
                      ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeLocationOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // --- WIDGET BUILDERS ---

  Widget _buildDetailsForm({
    required String title,
    required String avatarAsset,
    required TextEditingController nameController,
    required TextEditingController dateController,
    required TextEditingController timeController,
    required TextEditingController placeController,
    required FocusNode placeFocusNode,
    required bool isForBoy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  avatarAsset,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          'full_name'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'enter_full_name'.tr,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
        ),
        SizedBox(height: 16),
        Text(
          'birth_date'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: dateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'select_birth_date'.tr,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[100],
            suffixIcon: Icon(Icons.calendar_today_outlined,
                color: Colors.grey[600], size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onTap: () => _selectDate(dateController),
          validator: (v) => v!.isEmpty ? 'Date is required' : null,
        ),
        SizedBox(height: 16),
        Text(
          'birth_time'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: timeController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'select_birth_time'.tr,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[100],
            suffixIcon: Icon(Icons.access_time_outlined,
                color: Colors.grey[600], size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onTap: () => _selectTime(timeController),
          validator: (v) => v!.isEmpty ? 'Time is required' : null,
        ),
        SizedBox(height: 16),
        Text(
          'birth_place'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Builder(builder: (context) {
          return TextFormField(
            controller: placeController,
            focusNode: placeFocusNode,
            decoration: InputDecoration(
              hintText: 'type_search_location'.tr,
              hintStyle: TextStyle(color: Colors.grey[500]),
              suffixIcon: Icon(Icons.location_on, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (query) => _searchLocation(query, isForBoy, context),
            validator: (v) => v!.trim().isEmpty ? 'Place is required' : null,
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomStyles.whiteColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BottomAppBarScreen())),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: 'kundali_matching'.tr,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CustomStyles.pinki,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'enter_details'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 650;

                      if (isWideScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDetailsForm(
                                title: 'boy_details'.tr,
                                avatarAsset: '👨',
                                nameController: _boyNameController,
                                dateController: _boyBirthDateController,
                                timeController: _boyBirthTimeController,
                                placeController: _boyBirthPlaceController,
                                placeFocusNode: _boyLocationFocusNode,
                                isForBoy: true,
                              ),
                            ),
                            SizedBox(width: 32),
                            Expanded(
                              child: _buildDetailsForm(
                                title: 'girl_details'.tr,
                                avatarAsset: '👩',
                                nameController: _girlNameController,
                                dateController: _girlBirthDateController,
                                timeController: _girlBirthTimeController,
                                placeController: _girlBirthPlaceController,
                                placeFocusNode: _girlLocationFocusNode,
                                isForBoy: false,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildDetailsForm(
                              title: 'boy_details'.tr,
                              avatarAsset: '👨',
                              nameController: _boyNameController,
                              dateController: _boyBirthDateController,
                              timeController: _boyBirthTimeController,
                              placeController: _boyBirthPlaceController,
                              placeFocusNode: _boyLocationFocusNode,
                              isForBoy: true,
                            ),
                            SizedBox(height: 32),
                            _buildDetailsForm(
                              title: 'girl_details'.tr,
                              avatarAsset: '👩',
                              nameController: _girlNameController,
                              dateController: _girlBirthDateController,
                              timeController: _girlBirthTimeController,
                              placeController: _girlBirthPlaceController,
                              placeFocusNode: _girlLocationFocusNode,
                              isForBoy: false,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 24),
                _isGeneratingReport
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _getMatchingReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomStyles.pinki,
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(
                              horizontal: 60, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          'get_report'.tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

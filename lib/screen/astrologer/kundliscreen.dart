import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/app_date_time_picker_theme.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalichange/kundlinew1.dart';
import 'package:astrokavach/model/kundalimodel/kundalicreate.dart';
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/screen/astrologer/kundlichartscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewKundliScreen extends StatefulWidget {
  @override
  _NewKundliScreenState createState() => _NewKundliScreenState();
}

class _NewKundliScreenState extends State<NewKundliScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthTimeController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedLang = 'en';

  static const List<Map<String, String>> _indianLanguageOptions = [
    {'label': 'English', 'value': 'en'},
    {'label': 'Hindi', 'value': 'hi'},
    {'label': 'Bengali', 'value': 'be'},
    {'label': 'Telugu', 'value': 'te'},
    {'label': 'Marathi', 'value': 'mr'},
    {'label': 'Tamil', 'value': 'ta'},
    {'label': 'Gujarati', 'value': 'gu'},
    {'label': 'Kannada', 'value': 'ka'},
    {'label': 'Malayalam', 'value': 'ml'},
    {'label': 'Nepali', 'value': 'ne'},
  ];

  List<LocationData> _locationSuggestions = [];
  bool _isLoadingLocations = false;
  bool _isGeneratingKundli = false;
  bool _showLocationDropdown = false;

  @override
  void initState() {
    super.initState();
    final localeLang = Get.locale?.languageCode;
    final supported = _indianLanguageOptions
        .map((e) => e['value'])
        .whereType<String>()
        .toSet();
    _selectedLang = (localeLang != null && supported.contains(localeLang))
        ? localeLang
        : 'en';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  static int? _kundaliIdFromRedirect(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;
    for (final key in ['kundali_id', 'kundaliId', 'id']) {
      final q = uri.queryParameters[key];
      if (q != null) {
        final v = int.tryParse(q);
        if (v != null) return v;
      }
    }
    if (uri.pathSegments.isNotEmpty) {
      return int.tryParse(uri.pathSegments.last);
    }
    return null;
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 2) {
      setState(() {
        _locationSuggestions = [];
        _showLocationDropdown = false;
      });
      return;
    }

    setState(() {
      _isLoadingLocations = true;
      _showLocationDropdown = true;
    });

    try {
      final locationResponse = await AstroApiService.searchLocations(query);

      if (locationResponse != null && locationResponse.success) {
        setState(() {
          _locationSuggestions = locationResponse.data;
          _isLoadingLocations = false;
        });
      } else {
        setState(() {
          _locationSuggestions = [];
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocations = false;
        _locationSuggestions = [];
      });
      _showSnackBar('Error searching locations: $e', isError: true);
    }
  }

  Future<void> _generateKundli() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGeneratingKundli = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneFromLogin = (prefs.getString('phone') ?? '').trim();
      final phoneToSend =
          phoneFromLogin.isNotEmpty ? phoneFromLogin : '9999999999';

      final request = KundaliRequest(
        name: _nameController.text.trim(),
        gender: _selectedGender.toLowerCase(),
        date: _birthDateController.text.trim(),
        time: _birthTimeController.text.trim(),
        lang: _selectedLang,
        city: _birthPlaceController.text.trim(),
        phone: phoneToSend,
      );

      KundaliCreateResponse createResponse =
          await AstroApiService.createKundali(request);

      int? kundaliId = createResponse.kundaliId;
      if (createResponse.success && kundaliId == null) {
        kundaliId = _kundaliIdFromRedirect(createResponse.redirectTo);
      }

      if (createResponse.success && kundaliId == null) {
        const pollInterval = Duration(seconds: 5);
        const maxPolls = 12;
        for (var i = 0; i < maxPolls && mounted; i++) {
          await Future<void>.delayed(pollInterval);
          createResponse = await AstroApiService.createKundali(request);
          kundaliId = createResponse.kundaliId;
          if (kundaliId == null && createResponse.success) {
            kundaliId = _kundaliIdFromRedirect(createResponse.redirectTo);
          }
          if (kundaliId != null) break;
          if (!createResponse.success) {
            final msg = createResponse.message?.trim();
            throw Exception((msg != null && msg.isNotEmpty)
                ? msg
                : 'Failed to generate Kundli. Please check details and try again.');
          }
        }
      }

      if (!createResponse.success || kundaliId == null) {
        final msg = createResponse.message?.trim();
        throw Exception((msg != null && msg.isNotEmpty)
            ? msg
            : 'Failed to generate Kundli. Please check details and try again.');
      }

      _showSnackBar('Kundli generated successfully!', isError: false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KundliChartScreen(kundaliId: kundaliId!),
        ),
      );
    } catch (e) {
      _showSnackBar('Error generating Kundli: $e', isError: true);
      print('kundli error $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingKundli = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => AppDateTimePickerTheme.wrap(context, child),
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => AppDateTimePickerTheme.wrap(context, child),
    );

    if (picked != null) {
      setState(() {
        _birthTimeController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 16),
              ...List.generate(
                  5,
                  (index) => Column(
                        children: [
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      )),
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey[600])
                : null,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    if (!_showLocationDropdown) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      constraints: BoxConstraints(maxHeight: 200),
      child: _isLoadingLocations
          ? Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Searching...',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          : _locationSuggestions.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            color: Colors.grey[400], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'No locations found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _locationSuggestions.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final LocationData location = _locationSuggestions[index];
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
                        _birthPlaceController.text = location.fullName;
                        setState(() {
                          _showLocationDropdown = false;
                          _locationSuggestions = [];
                        });

                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isGeneratingKundli) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: CustomStyles.whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: null,
          ),
          title: Text(
            'new_kundli'.tr,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildShimmerCard(),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Generating your Kundli...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This may take a few moments',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
        title: 'new_kundli'.tr,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            color: Colors.white,
            margin: EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CustomStyles.ctaColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'create_your_kundli'.tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'kundli_details_instruction'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildInputField(
                    label: 'name'.tr,
                    controller: _nameController,
                    hintText: 'enter_full_name'.tr,
                    suffixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'gender'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: _selectedGender,
                    decoration: InputDecoration(
                      hintText: 'select_gender'.tr,
                      prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
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
                        borderSide:
                            BorderSide(color: Colors.blueGrey!, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: _selectedLang,
                    decoration: InputDecoration(
                      hintText: 'Select language',
                      prefixIcon: Icon(Icons.language_outlined,
                          color: Colors.grey[600]),
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
                        borderSide:
                            BorderSide(color: Colors.blueGrey!, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: _indianLanguageOptions.map((m) {
                      final label = m['label'] ?? '';
                      final value = m['value'] ?? 'en';
                      return DropdownMenuItem(
                        value: value,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedLang = value);
                    },
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    label: 'birth_date'.tr,
                    controller: _birthDateController,
                    hintText: 'select_birth_date'.tr,
                    suffixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select birth date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    label: 'birth_time'.tr,
                    controller: _birthTimeController,
                    hintText: 'select_birth_time'.tr,
                    suffixIcon: Icons.access_time,
                    readOnly: true,
                    onTap: _selectTime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select birth time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'birth_place'.tr,
                        controller: _birthPlaceController,
                        hintText: 'type_search_location'.tr,
                        suffixIcon: Icons.location_on,
                        onChanged: _searchLocation,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter birth place';
                          }
                          return null;
                        },
                      ),
                      _buildLocationDropdown(),
                    ],
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _generateKundli,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomStyles.pinki,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'generate_kundli'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'data_security_note'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

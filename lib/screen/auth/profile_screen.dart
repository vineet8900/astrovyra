import 'dart:convert';
import 'dart:io';
import 'package:astrokavach/api/auth_api/place_api.dart';
import 'package:astrokavach/api/auth_api/profile_save_Api.dart';
import 'package:astrokavach/api/auth_api/user_data_api.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_dropdown.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/app_date_time_picker_theme.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/places_model.dart/city_api_model.dart';
import 'package:astrokavach/model/places_model.dart/country_Api_model.dart';
import 'package:astrokavach/model/places_model.dart/state_api_model.dart';
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/model/user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({
    super.key,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController placeofbirthcontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController pincodecontroller = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController birthTimeController = TextEditingController();
  TextEditingController birthPlaceController = TextEditingController();

  List<LocationData> _locationSuggestions = [];
  bool _isLoadingLocations = false;
  bool _showLocationDropdown = false;

  int _selectedGender = 1;
  UserDataModel? userData;
  UserDataApi userDataApi = UserDataApi();
  String? apiToken;
  String? username;
  List<CountryDatum> countrydatalist = [];
  List<StateDatum> statedatalist = [];
  List<CityDatum> citydatalist = [];
  CountryModel? countryModel;
  StateModel? stateModel;
  CityModel? cityModel;
  CountryDatum? selectcountry;
  StateDatum? selectstate;
  CityDatum? selectcity;
  CountryApiService countryApiService = CountryApiService();
  StateApiService stateApiService = StateApiService();
  CityApiService cityApiService = CityApiService();
  UserDataSaveApiServices userDataSaveApiServices = UserDataSaveApiServices();

  bool obscureText = true;
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  String? imagess;
  Future<void> _openImagePicker(ImageSource source) async {
    if (source == ImageSource.gallery) {
      await Permission.camera.request();
    } else {
      await Permission.storage.request();
    }

    if (await Permission.camera.isGranted ||
        await Permission.storage.isGranted) {
      XFile? pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
      }
    } else {
      print("Permission denied");
    }
  }

  bool isloading = false;
  Future<void> getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    if (apiToken != null) {
      countryModel = await countryApiService.fetchCountrydata();
      countrydatalist = countryModel?.data ?? [];

      fetchUserData();
    }
  }

  ReusableFunction reusableFunction = ReusableFunction();
  Map<String, dynamic>? user;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => AppDateTimePickerTheme.wrap(context, child),
    );
    if (picked != null) {
      setState(() {
        birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => AppDateTimePickerTheme.wrap(context, child),
    );
    if (picked != null) {
      setState(() {
        birthTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (!mounted) return;
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

      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _isLoadingLocations = false;
        _locationSuggestions = [];
      });
    }
  }

  Widget _buildLocationDropdown() {
    if (!_showLocationDropdown) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: _isLoadingLocations
          ? Padding(
              padding: const EdgeInsets.all(16),
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
                    const SizedBox(width: 12),
                    Text('Searching...',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          : _locationSuggestions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            color: Colors.grey[400], size: 20),
                        const SizedBox(width: 8),
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
                  physics: const ClampingScrollPhysics(),
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
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        location.fullName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        birthPlaceController.text = location.fullName;
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

  Future<void> fetchUserData() async {
    if (!mounted) return;

    setState(() {
      isloading = true;
    });

    Map<String, dynamic>? userData =
        await reusableFunction.getUserDataFromPrefs();

    if (!mounted) return;

    if (userData != null) {
      dynamic countryId = userData['country_id'];
      dynamic stateId = userData['state_id'];
      dynamic cityId = userData['city_id'];
      imagess = userData['image'];

      if (mounted) {
        setState(() {
          usernamecontroller.text = userData['name'] ?? '';
          phonecontroller.text = userData['phone'] ?? '';
          emailcontroller.text = userData['email'] ?? '';
          _selectedGender = userData['gender_id'];
          placeofbirthcontroller.text = userData['address'];
          pincodecontroller.text = userData['pincode']?.toString() ?? '';
          birthDateController.text = userData['birth_date'] ?? '';
          birthTimeController.text = userData['birth_time'] ?? '';
          birthPlaceController.text = userData['birth_place'] ?? '';
        });
      }

      countryModel = await countryApiService.fetchCountrydata();
      countrydatalist = countryModel?.data ?? [];

      try {
        selectcountry = countrydatalist.firstWhere((c) => c.id == countryId);
      } catch (e) {
        selectcountry = null;
      }

      if (mounted) setState(() {});

      stateModel =
          await stateApiService.fetchstatedata(selectcountry!.id.toString());
      statedatalist = stateModel?.data ?? [];

      try {
        selectstate = statedatalist.firstWhere((s) => s.id == stateId);
      } catch (e) {
        selectstate = null;
      }

      if (mounted) setState(() {});

      if (selectstate != null) {
        cityModel =
            await cityApiService.fetchcitydata(selectstate!.id.toString());
        citydatalist = cityModel?.data ?? [];

        try {
          selectcity = citydatalist.firstWhere((c) => c.id == cityId);
        } catch (e) {
          selectcity = null;
        }

        if (mounted) setState(() {});
      }
    } else {
      print("No user data found.");
    }

    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
  }

  bool isloadingbtn = false;
  savedata() async {
    if (!mounted) return;

    setState(() {
      isloadingbtn = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      apiToken = prefs.getString('api_token');
      String? base64Image = '';
      if (_image != null) {
        Uint8List imageBytes = await _image!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      // API call ko await karein
      await userDataSaveApiServices.saveuserdata(
          context,
          apiToken.toString(),
          usernamecontroller.text,
          _selectedGender,
          selectcountry!.id,
          selectstate!.id,
          selectcity!.id,
          base64Image,
          placeofbirthcontroller.text,
          pincodecontroller.text,
          birthDateController.text, // New
          birthTimeController.text, // New
          birthPlaceController.text);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomAppBarScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isloadingbtn = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getuserdata();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomAppBarScreen()));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BottomAppBarScreen()));
              },
              icon: Icon(Icons.arrow_back_ios)),
          title: 'my_profile'.tr,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
          actions: [],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        height: 110,
                        width: 110,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CustomStyles.bgcolor, width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: _image != null
                                    ? Image.file(File(_image!.path),
                                        fit: BoxFit.cover)
                                    : (user != null &&
                                            user!['image'] != null &&
                                            user!['image'].toString().isNotEmpty
                                        ? Image.network(user!['image'],
                                            fit: BoxFit.cover)
                                        : (imagess != null &&
                                                imagess!.isNotEmpty
                                            ? Image.network(imagess!,
                                                fit: BoxFit.cover)
                                            : Container(
                                                color: Colors.grey[300],
                                                alignment: Alignment.center,
                                                child: Icon(Icons.person,
                                                    size: 60,
                                                    color: Colors.grey[700]),
                                              ))),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  _openImagePicker(ImageSource.gallery);
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.cloud_upload,
                                      color: Colors.blueGrey),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                starsign: "*",
                                title: "Name",
                                label: "Enter Name",
                                controller: usernamecontroller,
                                validator: (id) {
                                  if (id == null || id.isEmpty) {
                                    return 'Name is Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: CustomTextField(
                                  starsign: "*",
                                  readOnly: user != null && user!.isNotEmpty
                                      ? true
                                      : false,
                                  fillColor: user != null && user!.isNotEmpty
                                      ? Colors.grey.shade300
                                      : Colors.white,
                                  textInputType:
                                      TextInputType.numberWithOptions(
                                          decimal: false, signed: false),
                                  maxLength: 10,
                                  title: "Phone",
                                  label: "Enter Phone",
                                  controller: phonecontroller,
                                  validator: (id) {
                                    if (id == null || id.isEmpty) {
                                      return 'Phone is Required';
                                    } else if (id.length != 10) {
                                      return 'Phone number should be 10 digits';
                                    }
                                    return null;
                                  }),
                            )
                          ],
                        ),

                        CustomTextField(
                          readOnly: true,
                          title: "Birth Date",
                          label: "YYYY-MM-DD",
                          controller: birthDateController,
                          starsign: "*",
                          onTap: () => _selectDate(context),
                          validator: (v) =>
                              v!.isEmpty ? 'Select Birth Date' : null,
                        ),

                        // Birth Time (With Picker)
                        CustomTextField(
                          readOnly: true,
                          title: "Birth Time",
                          label: "Select Time",
                          controller: birthTimeController,
                          starsign: "*",
                          onTap: () => _selectTime(context),
                          validator: (v) =>
                              v!.isEmpty ? 'Select Birth Time' : null,
                        ),

                        // Birth Place (location suggestions — same API as Kundli)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              title: "Birth Place",
                              label: "type_search_location".tr,
                              controller: birthPlaceController,
                              starsign: "*",
                              suffixIcon: Icon(
                                Icons.location_on,
                                color: Colors.grey[600],
                              ),
                              onChanged: _searchLocation,
                              validator: (v) =>
                                  v!.isEmpty ? 'Required' : null,
                            ),
                            _buildLocationDropdown(),
                          ],
                        ),

                        CustomTextField(
                          readOnly:
                              user != null && user!.isNotEmpty ? true : false,
                          fillColor: user != null && user!.isNotEmpty
                              ? Colors.grey.shade300
                              : Colors.white,
                          title: "Email (Optional)",
                          label: "Enter Email",
                          controller: emailcontroller,
                          textInputType: TextInputType.emailAddress,
                          validator: (id) {
                            if (id == null || id.isEmpty) return null;
                            String pattern =
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                            RegExp regex = RegExp(pattern);
                            if (!regex.hasMatch(id)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Gender',
                                  style: CustomStyles.black14500,
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _selectedGender = 1;
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: Radio<int>(
                                      activeColor: Colors.blueGrey,
                                      value: 1,
                                      groupValue: _selectedGender,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedGender = val!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Male'),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectedGender = 2;
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: Radio(
                                      activeColor: Colors.blueGrey,
                                      value: 2,
                                      groupValue: _selectedGender,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedGender = val!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Female'),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectedGender = 3;
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: Radio(
                                      activeColor: Colors.blueGrey,
                                      value: 3,
                                      groupValue: _selectedGender,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedGender = val!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Other'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CustomDropdownField<CountryDatum>(
                          hintText: "Select Country",
                          title: "Country",
                          starsign: '*',
                          value: selectcountry,
                          items: countrydatalist.map((CountryDatum values) {
                            return DropdownMenuItem<CountryDatum>(
                              value: values,
                              child: Text(values.name.toString()),
                            );
                          }).toList(),
                          onChanged: (id) async {
                            setState(() {
                              selectcountry = id;
                              selectstate = null;
                              selectcity = null;
                            });
                            if (id != null) {
                              stateModel = await stateApiService
                                  .fetchstatedata(selectcountry!.id.toString());
                              statedatalist = stateModel!.data ?? [];

                              setState(() {});
                            }
                          },
                          validator: (id) {
                            if (id == null) {
                              return 'Please select a state';
                            }
                            return null;
                          },
                        ),
                        CustomDropdownField<StateDatum>(
                          hintText: "Select State",
                          title: "State",
                          starsign: '*',
                          value: selectstate,
                          items: statedatalist.map((StateDatum values) {
                            return DropdownMenuItem<StateDatum>(
                              value: values,
                              child: Text(values.name.toString()),
                            );
                          }).toList(),
                          onChanged: (id) async {
                            setState(() {
                              selectstate = id;
                              selectcity = null;
                            });
                            if (id != null) {
                              cityModel = await cityApiService
                                  .fetchcitydata(selectstate!.id.toString());
                              citydatalist = cityModel!.data ?? [];
                              print(citydatalist);
                              setState(() {});
                            }
                          },
                          validator: (id) {
                            if (id == null) {
                              return 'Please select a state';
                            }
                            return null;
                          },
                        ),
                        CustomDropdownField<CityDatum>(
                          hintText: "Select City",
                          title: "City",
                          starsign: '*',
                          value: selectcity,
                          items: citydatalist.map((CityDatum values) {
                            return DropdownMenuItem<CityDatum>(
                              value: values,
                              child: Text(values.name.toString()),
                            );
                          }).toList(),
                          onChanged: (id) {
                            setState(() {
                              selectcity = id;
                            });
                          },
                          validator: (id) {
                            if (id == null) {
                              return 'Please select city';
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          label: "Zip Code",
                          maxLength: 6,
                          controller: pincodecontroller,
                          title: "Zip Code",
                          starsign: "*",
                          textInputType: TextInputType.number,
                          maxline: 1,
                          validator: (id) {
                            if (id == null || id.isEmpty) {
                              return 'Zip Code is Required';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        CustomTextField(
                          height: 60,
                          label: "Address",
                          controller: placeofbirthcontroller,
                          title: "Address",
                          textInputType: TextInputType.streetAddress,
                          maxline: 3,
                          starsign: "*",
                          validator: (id) {
                            if (id == null || id.isEmpty) {
                              return 'Address is Required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        isloadingbtn
                            ? CircularProgressIndicator()
                            : CustomElevatedButton(
                                backgroundColor: CustomStyles.pinki,
                                text: "Save",
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await savedata();
                                  }
                                })
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

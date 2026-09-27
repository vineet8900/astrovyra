import 'package:astrokavach/api/Address_Api/add_address_Api.dart';
import 'package:astrokavach/api/Address_Api/address_api.dart';
import 'package:astrokavach/api/Address_Api/delete_address_Api.dart';
import 'package:astrokavach/api/auth_api/place_api.dart';
import 'package:astrokavach/model/AddressModel/address_api_model.dart';
import 'package:astrokavach/model/places_model.dart/city_api_model.dart';
import 'package:astrokavach/model/places_model.dart/country_Api_model.dart';
import 'package:astrokavach/model/places_model.dart/state_api_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ManageAddressController extends GetxController {
  var editAddressId = 0.obs;
  DeleteAddressApiService deleteAddressApiService = DeleteAddressApiService();
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final placeOfBirthController = TextEditingController();
  final pincodecontroller = TextEditingController();

  var countryList = <CountryDatum>[].obs;
  var stateList = <StateDatum>[].obs;
  var cityList = <CityDatum>[].obs;

  Rxn<CountryDatum> selectedCountry = Rxn<CountryDatum>();
  Rxn<StateDatum> selectedState = Rxn<StateDatum>();
  Rxn<CityDatum> selectedCity = Rxn<CityDatum>();

  final countryService = CountryApiService();
  final stateService = StateApiService();
  final cityService = CityApiService();
  var token = '';
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
    fetchCountryList();
  }

  void clearAll() {
    usernameController.clear();
    phoneController.clear();
    emailController.clear();
    placeOfBirthController.clear();
    pincodecontroller.clear();
    selectedCountry.value = null;
    selectedState.value = null;
    selectedCity.value = null;

    stateList.clear();
    cityList.clear();
  }

  Future<void> fetchCountryList() async {
    isLoading.value = true;
    final response = await countryService.fetchCountrydata();
    if (response != null && response.data != null) {
      countryList.value = response.data!;
    }
    isLoading.value = false;
  }

  Future<void> fetchStates(String countryId) async {
    selectedState.value = null;
    selectedCity.value = null;
    stateList.clear();
    cityList.clear();

    final stateRes = await stateService.fetchstatedata(countryId);
    if (stateRes != null && stateRes.data != null) {
      stateList.value = stateRes.data!;
    }
  }

  Future<void> fetchCities(String stateId) async {
    selectedCity.value = null;
    cityList.clear();

    final cityRes = await cityService.fetchcitydata(stateId);
    if (cityRes != null && cityRes.data != null) {
      cityList.value = cityRes.data!;
    }
  }

  RxList<AddressDatum> addressList = <AddressDatum>[].obs;
  SubmitAddressApiService submitAddressApiService = SubmitAddressApiService();
  AddressApiService addressapiService = AddressApiService();
  Future<void> fetchAddresses() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('api_token') ?? '';

    final result = await addressapiService.getaddressapidata(token);

    if (result != null && result.data != null) {
      addressList.value = result.data!;
       
    }

    isLoading.value = false;
  }

  Future<void> submitAddressForm({int addressId = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token') ?? '';

    final response = await submitAddressApiService.submitAddress(
      token: token,
      addressId: addressId,
      fullName: usernameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      countryId: selectedCountry.value?.id ?? '',
      stateId: selectedState.value?.id ?? '',
      cityId: selectedCity.value?.id ?? '',
      zipcode: int.tryParse(pincodecontroller.text.trim()) ?? 0,
      address: placeOfBirthController.text.trim(),
    );

     
    if (response != null && response['success'] == true) {
      Get.back();
      clearAll();
      fetchAddresses();
    }
  }

  deleteaddres(int id) async {
    await deleteAddressApiService.deleteaddressapi(token: token, addressId: id);
  }

  @override
  void onClose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    placeOfBirthController.dispose();
    pincodecontroller.dispose();
    super.onClose();
  }
}

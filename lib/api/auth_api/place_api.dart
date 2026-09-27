import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/places_model.dart/city_api_model.dart';
import 'package:astrokavach/model/places_model.dart/country_Api_model.dart';
import 'package:astrokavach/model/places_model.dart/state_api_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CountryApiService {
  Future<CountryModel?> fetchCountrydata() async {
    try {
      final response =
          await http.post(Uri.parse('${CustomStyles.baseUrl}countries'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        
        return CountryModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch country data: ${response.statusCode}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
     
    }
    return null;
  }
}

class StateApiService {
  Future<StateModel?> fetchstatedata(String countryid) async {
    try {
      Map<String, dynamic> body = {
        'country_id': countryid,
      };
      final response = await http.post(
          Uri.parse(
            '${CustomStyles.baseUrl}states',
          ),
          body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
       
        return StateModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch state data: ${response.statusCode}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
     
    }
    return null;
  }
}

class CityApiService {
  Future<CityModel?> fetchcitydata(String stateid) async {
    try {
      Map<String, dynamic> body = {
        'state_id': stateid,
      };
      final response = await http.post(
          Uri.parse(
            '${CustomStyles.baseUrl}cities',
          ),
          body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        
        return CityModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch city data: ${response.statusCode}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
     
    }
    return null;
  }
}

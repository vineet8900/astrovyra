import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalimodelsmatching/kundalimodelmatching.dart';
import 'package:http/http.dart' as http;

class Kundaliapiservice {
  static const String _path = '/api/kundali-matching/detail';

  static Future<KundaliMatchingData> fetchMatchingDetails({
    required String boyName,
    required String boyBirthDate,
    required String boyBirthTime,
    required String boyBirthPlace,
    required String girlName,
    required String girlBirthDate,
    required String girlBirthTime,
    required String girlBirthPlace,
  }) async {
    final url = Uri.https(CustomStyles.apiHost, _path);
    

    try {
      final requestBody = {
        "boy_name": boyName,
        "boy_birth_date": boyBirthDate,
        "boy_birth_time": boyBirthTime,
        "boy_birth_place": boyBirthPlace,
        "girl_name": girlName,
        "girl_birth_date": girlBirthDate,
        "girl_birth_time": girlBirthTime,
        "girl_birth_place": girlBirthPlace,
      };

       

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      

      if (response.statusCode == 200) {
        try {
          final decodedJson = jsonDecode(response.body);
          final matchingResponse =
              KundaliMatchingResponse.fromJson(decodedJson);

          if (matchingResponse.success && matchingResponse.data != null) {
            return matchingResponse.data!;
          } else {
            throw Exception('API returned no data');
          }
        } on FormatException catch (e) {
           
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
       
      rethrow;
    }
  }
}

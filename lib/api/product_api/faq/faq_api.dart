import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/faqmodel.dart';
import 'package:http/http.dart' as http;

class FAQApiService {
  Future<FaqModel?> getFaqApi(
      String? page, int? limit, String? categoryslug) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'content-type': 'application/json',
      };
      final response = await http.post(Uri.parse('${CustomStyles.baseUrl}faqs'),
          headers: headers,
          body: jsonEncode(
              {"page": page, "limit": limit, "category_slug": categoryslug}));
      
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(
          response.body,
        );
        
        return FaqModel.fromJson(jsonResponse);
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
         
        return null;
      }
    } catch (e) {
       
      return null;
    }
  }
}

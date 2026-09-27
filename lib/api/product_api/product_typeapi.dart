import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/product_type_model.dart';
import 'package:http/http.dart' as http;

class ProducTypeApiService {
  Future<ProductTypeApiModel> fetchproducttypeapidata() async {
    final response =
        await http.post(Uri.parse('${CustomStyles.baseUrl}product/types'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return ProductTypeApiModel.fromJson(data);
    } else {
      throw Exception('Failed to load product list');
    }
  }
}

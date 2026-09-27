import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/product_sortby_model.dart';
import 'package:http/http.dart' as http;

class ProducSortbyApiService {
  Future<ProductSortByApiModel> fetchproductsortbyapidata() async {
    final response =
        await http.post(Uri.parse('${CustomStyles.baseUrl}product/sortby'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return ProductSortByApiModel.fromJson(data);
    } else {
      throw Exception('Failed to load product list');
    }
  }
}

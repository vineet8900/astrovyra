import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/product_list_api_model.dart';
import 'package:http/http.dart' as http;

class ProducListApiService {
  Future<ProductListApiModel> fetchproductlistapidata(
    int? category,
    String? type,
    String? sortby,
    String? pricefrom,
    String? priceto,
    int pageindex,
    int? exceptid,
  ) async {
    final response = await http.post(
      Uri.parse(
        '${CustomStyles.baseUrl}product/list?page=$pageindex',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "category_id": category,
        "type": type,
        "sortBy": sortby,
        "priceFrom": pricefrom,
        "priceTo": priceto,
        "except_id": exceptid
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(
        response.body,
      );
      return ProductListApiModel.fromJson(data);
    } else {
      throw Exception('Failed to load product list');
    }
  }
}

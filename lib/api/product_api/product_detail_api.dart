import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/product_Detail_api_model.dart';
import 'package:http/http.dart' as http;

class ProductDetailApiService {
  Future<ProductDetailModel> fetchproductDetailsdata(int? id, String apitoken,
      int? parentid, List<dynamic> attributevalue) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'content-type': 'application/json',
    };

    final response =
        await http.post(Uri.parse('${CustomStyles.baseUrl}product/detail'),
            headers: headers,
            body: jsonEncode({
              'id': id,
              'api_token': apitoken,
              'parent_id': parentid,
              'attributes_value': attributevalue
            }));
    print("modiji${jsonEncode({
          'id': id,
          'api_token': apitoken,
          'parent_id': parentid,
          'attributes_value': attributevalue
        })}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return ProductDetailModel.fromJson(data);
    } else {
      throw Exception(
          'Failed to load product  details: ${response.reasonPhrase}');
    }
  }
}

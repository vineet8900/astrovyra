// import 'dart:convert';
// import 'package:advolive/Apimodel.dart/Product_Api_Model/product_list_api_model.dart';
// import 'package:advolive/styles.dart';
// import 'package:http/http.dart' as http;

// class ProducListApiService {
// Future<ProductListApiModel> fetchproductlistapidata(String?category,String?type,String?sortby,String? pricefrom,String?priceto,int pageindex) async {
// final response = await http.post(Uri.parse('${CustomStyles.baseUrl}product/list?page=$pageindex',), headers: {
// 'Content-Type': 'application/json',
//       },
//  body: json.encode({
// "category":category,
// "type":type,
// "sortBy":sortby,
// "priceFrom":pricefrom,
// "priceTo":priceto
//       }), );
// if (response.statusCode == 200) {
//  Map<String, dynamic> data = jsonDecode(response.body,);
// return  ProductListApiModel.fromJson(data);
// } else {
// throw Exception('Failed to load product list');
//  }
//   }
// }

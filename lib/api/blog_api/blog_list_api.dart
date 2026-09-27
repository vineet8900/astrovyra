import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/blog_model/blog_list_model.dart';
import 'package:http/http.dart' as http;

class BlogListApi {
  Future<BlogListModel> fetchBolgApidata(
      int? category, int expectedid, int? limit, int page) async {
    final response = await http.post(
      Uri.parse(
        '${CustomStyles.baseUrl}blog/list?page=$page',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "categoryId": category,
        "exceptId": expectedid,
        "limit": limit,
        "page": page
      }),
    );

    
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(
        response.body,
      );
      return BlogListModel.fromJson(data);
    } else {
      throw Exception('Failed to load Blog list');
    }
  }
}

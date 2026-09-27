import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/blog_model/blog_detail_model.dart';
import 'package:http/http.dart' as http;

class BlogDetailApiService {
  Future<BlogDetailApiModel> fetchBlogDetail(
    int? id,
  ) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'content-type': 'application/json',
    };

    final response =
        await http.post(Uri.parse('${CustomStyles.baseUrl}blog/detail'),
            headers: headers,
            body: jsonEncode({
              'id': id,
            }));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
     
      return BlogDetailApiModel.fromJson(data);
    } else {
      throw Exception('Failed to load blog  details: ${response.reasonPhrase}');
    }
  }
}

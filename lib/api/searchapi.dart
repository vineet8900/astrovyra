// lib/api/search_api.dart

import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/searchbanado.dart';
import 'package:http/http.dart' as http;


class SearchApiService {
  final String _baseUrl = '${CustomStyles.apiBaseUrl}/search';

  Future<List<UnifiedSearchResult>> search(String query) async {
    if (query.isEmpty) {
      return []; 
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': query}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body)['data'];
        final List<UnifiedSearchResult> results = [];

     
        (data['astrologers'] as List?)?.forEach((item) {
          results.add(
              UnifiedSearchResult.fromJson(item, SearchItemType.astrologer));
        });

       

        (data['products'] as List?)?.forEach((item) {
          results
              .add(UnifiedSearchResult.fromJson(item, SearchItemType.product));
        });

     

        (data['services'] as List?)?.forEach((item) {
          results
              .add(UnifiedSearchResult.fromJson(item, SearchItemType.service));
        });

        void addPoojaList(String key) {
          (data[key] as List?)?.forEach((item) {
            results.add(
                UnifiedSearchResult.fromJson(item, SearchItemType.pooja));
          });
        }

        addPoojaList('poojas');
        addPoojaList('pujas');

        final poojaSingular = data['pooja'];
        if (poojaSingular is List) {
          for (final item in poojaSingular) {
            if (item is Map<String, dynamic>) {
              results.add(
                  UnifiedSearchResult.fromJson(item, SearchItemType.pooja));
            }
          }
        }

        (data['ai_astrologers'] as List?)?.forEach((item) {
          results.add(
              UnifiedSearchResult.fromJson(item, SearchItemType.aiAstrologer));
        });
        (data['aiAstrologers'] as List?)?.forEach((item) {
          results.add(
              UnifiedSearchResult.fromJson(item, SearchItemType.aiAstrologer));
        });

        return results;
      } else {
      
        throw Exception('Failed to load search results');
      }
    } catch (e) {
     
     
      throw Exception('Failed to connect to the server');
    }
  }
}

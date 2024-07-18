import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/coinHistory/coinHistoryException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class CoinHistoryRemoteDataSource {
  Future<({int total, List<Map<String, dynamic>> data})> getCoinHistory({
    required String limit,
    required String offset,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        limitKey: limit,
        offsetKey: offset,
      };

      if (limit.isEmpty) body.remove(limitKey);

      if (offset.isEmpty) body.remove(offsetKey);

      final response = await http.post(
        Uri.parse(getCoinHistoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw CoinHistoryException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (
        total: int.parse(responseJson['total'] as String? ?? '0'),
        data: (responseJson['data'] as List).cast<Map<String, dynamic>>()
      );
    } on SocketException catch (_) {
      throw CoinHistoryException(errorMessageCode: errorCodeNoInternet);
    } on CoinHistoryException catch (e) {
      throw CoinHistoryException(errorMessageCode: e.toString());
    } catch (e) {
      throw CoinHistoryException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}

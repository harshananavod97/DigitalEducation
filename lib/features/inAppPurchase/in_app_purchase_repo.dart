import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/inAppPurchase/in_app_product.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class InAppPurchaseRepo {
  static Future<List<InAppProduct>> fetchInAppProducts() async {
    try {
      final rawRes = await http.post(Uri.parse(getCoinStoreData));
      final res = jsonDecode(rawRes.body) as Map<String, dynamic>;

      if (res['error'] as bool) {
        throw Exception(res['message'].toString());
      }

      final result = (res['data'] as List).cast<Map<String, dynamic>>();

      return result.map(InAppProduct.fromJson).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyAndPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      final rawRes = await http.post(
        Uri.parse(purchaseIAP),
        body: {
          productIdKey: productId,
          purchaseTokenKey: purchaseToken,
          payFromKey: Platform.isAndroid ? '1' : '2',
        },
        headers: await ApiUtils.getHeaders(),
      );

      final res = jsonDecode(rawRes.body) as Map<String, dynamic>;

      if (res['error'] as bool) {
        throw Exception(res['message'].toString());
      }

      return (res['message'] as String) == errorCodeDataInsertSuccess;
    } catch (e) {
      rethrow;
    }
  }
}

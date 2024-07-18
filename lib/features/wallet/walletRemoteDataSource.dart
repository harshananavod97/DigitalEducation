import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/wallet/walletException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class WalletRemoteDataSource {
  Future<void> makePaymentRequest({
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        paymentTypeKey: paymentType,
        paymentAddressKey: paymentAddress,
        paymentAmountKey: paymentAmount,
        coinUsedKey: coinUsed,
        detailsKey: details,
      };

      final response = await http.post(
        Uri.parse(makePaymentRequestUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw WalletException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw WalletException(errorMessageCode: errorCodeNoInternet);
    } on WalletException catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    } catch (e) {
      throw WalletException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<({int total, List<Map<String, dynamic>> data})> getTransactions({
    required String limit,
    required String offset,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        limitKey: limit,
        offsetKey: offset,
      };

      final response = await http.post(
        Uri.parse(getTransactionsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw WalletException(
          errorMessageCode: responseJson['message'] == errorCodeDataNotFound
              ? errorCodeNoTransactions
              : responseJson['message'].toString(),
        );
      }

      return (
        total: int.parse(responseJson['total'] as String? ?? '0'),
        data: (responseJson['data'] as List).cast<Map<String, dynamic>>(),
      );
    } on SocketException catch (_) {
      throw WalletException(errorMessageCode: errorCodeNoInternet);
    } on WalletException catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    } catch (e) {
      throw WalletException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<bool> cancelPaymentRequest({required String paymentId}) async {
    try {
      final body = <String, String>{
        paymentIdKey: paymentId,
      };

      final response = await http.post(
        Uri.parse(cancelPaymentRequestUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw WalletException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return responseJson['message'] as String == errorCodeDataUpdateSuccess;
    } on SocketException catch (_) {
      throw WalletException(errorMessageCode: errorCodeNoInternet);
    } on WalletException catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    } catch (e) {
      throw WalletException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}

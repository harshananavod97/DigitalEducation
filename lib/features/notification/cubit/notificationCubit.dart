import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/notification/notificationException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationProgress extends NotificationState {}

class NotificationSuccess extends NotificationState {
  NotificationSuccess(
    this.notifications,
    this.totalData, {
    required this.hasMore,
  });

  final List<Map<String, dynamic>> notifications;
  final int totalData;
  final bool hasMore;
}

class NotificationFailure extends NotificationState {
  NotificationFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  Future<({List<Map<String, dynamic>> data, int total})> _fetchData({
    String limit = '20',
    String offset = '',
  }) async {
    try {
      final body = <String, String>{
        limitKey: limit,
        offsetKey: offset,
      };

      if (offset.isEmpty) body.remove(offset);

      final response = await http.post(
        Uri.parse(getNotificationUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw NotificationException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (
        total: int.parse(responseJson['total'] as String? ?? '0'),
        data: (responseJson['data'] as List).cast<Map<String, dynamic>>()
      );
    } on SocketException catch (_) {
      throw NotificationException(errorMessageCode: errorCodeNoInternet);
    } on NotificationException catch (e) {
      throw NotificationException(errorMessageCode: e.toString());
    } catch (e) {
      throw NotificationException(errorMessageCode: e.toString());
    }
  }

  void fetchNotifications({String limit = '20'}) {
    emit(NotificationProgress());

    _fetchData(limit: limit).then((v) {
      emit(
        NotificationSuccess(
          v.data,
          v.total,
          hasMore: v.total > v.data.length,
        ),
      );
    }).catchError((e) {
      emit(NotificationFailure(errorCodeDefaultMessage));
    });
  }

  void fetchMoreNotifications({String limit = '20'}) {
    _fetchData(
      limit: limit,
      offset: (state as NotificationSuccess).notifications.length.toString(),
    ).then((value) {
      final oldState = state as NotificationSuccess;
      final updatedUserDetails = oldState.notifications..addAll(value.data);

      emit(
        NotificationSuccess(
          updatedUserDetails,
          oldState.totalData,
          hasMore: oldState.totalData > updatedUserDetails.length,
        ),
      );
    }).catchError((e) {
      emit(NotificationFailure(errorCodeDefaultMessage));
    });
  }

  // ignore: avoid_bool_literals_in_conditional_expressions
  bool get hasMore => state is NotificationSuccess
      ? (state as NotificationSuccess).hasMore
      : false;
}

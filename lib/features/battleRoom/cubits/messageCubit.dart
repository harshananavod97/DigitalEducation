import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageAddInProgress extends MessageState {}

class MessageFetchedSuccess extends MessageState {
  MessageFetchedSuccess(this.messages);

  final List<Message> messages;
}

class MessageAddedFailure extends MessageState {
  MessageAddedFailure(this.errorCode);

  String errorCode;
}

class MessageCubit extends Cubit<MessageState> {
  MessageCubit(this._battleRoomRepository)
      : super(MessageFetchedSuccess(List<Message>.from([])));
  final BattleRoomRepository _battleRoomRepository;

  late StreamSubscription<List<Message>> streamSubscription;

  //subscribe to messages stream
  void subscribeToMessages(String roomId) {
    streamSubscription = _battleRoomRepository
        .subscribeToMessages(roomId: roomId)
        .listen((messages) {
      //messages
      emit(MessageFetchedSuccess(messages));
    });
  }

  Future<void> addMessage({
    required String message,
    required String by,
    required String roomId,
    required bool isTextMessage,
  }) async {
    try {
      await _battleRoomRepository.addMessage(
        Message(
          by: by,
          isTextMessage: isTextMessage,
          message: message,
          messageId: '',
          roomId: roomId,
          timestamp: Timestamp.now(),
        ),
      );
    } catch (e) {
      emit(MessageAddedFailure(e.toString()));
    }
  }

  void deleteMessages(String roomId, String by) {
    streamSubscription.cancel();
    _battleRoomRepository.deleteMessagesByUserId(roomId, by);
  }

  Message getUserLatestMessage(String userId, {String? messageId}) {
    if (state is MessageFetchedSuccess) {
      final messages = (state as MessageFetchedSuccess).messages;
      final messagesByUser = messages.where((element) => element.by == userId);

      if (messagesByUser.isEmpty) {
        return Message.empty();
      }
      //If message id is passed that means we are checking for latest message
      //else we are fetching latest message to diplay

      //messageId is null means we are fethcing latest message to display
      if (messageId == null) {
        return messagesByUser.first;
      }

      //messageId is not null so we are checking if there is any latest message or not

      //
      return messagesByUser.first.messageId == messageId
          ? Message.empty()
          : messagesByUser.first;
    }
    return Message.empty();
  }

  @override
  Future<void> close() async {
    await streamSubscription.cancel();
    await super.close();
  }
}

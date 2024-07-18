import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';
import 'package:flutterquiz/features/systemConfig/model/room_code_char_type.dart';
import 'package:flutterquiz/utils/constants/constants.dart';

@immutable
class MultiUserBattleRoomState {}

class MultiUserBattleRoomInitial extends MultiUserBattleRoomState {}

class MultiUserBattleRoomInProgress extends MultiUserBattleRoomState {}

class MultiUserBattleRoomSuccess extends MultiUserBattleRoomState {
  MultiUserBattleRoomSuccess({
    required this.battleRoom,
    required this.isRoomExist,
    required this.questions,
  });

  final BattleRoom battleRoom;

  final bool isRoomExist;
  final List<Question> questions;
}

class MultiUserBattleRoomFailure extends MultiUserBattleRoomState {
  MultiUserBattleRoomFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class MultiUserBattleRoomCubit extends Cubit<MultiUserBattleRoomState> {
  MultiUserBattleRoomCubit(this._battleRoomRepository)
      : super(MultiUserBattleRoomInitial());
  final BattleRoomRepository _battleRoomRepository;

  StreamSubscription<DocumentSnapshot>? _battleRoomStreamSubscription;

  final _rnd = Random.secure();

  void updateState(
    MultiUserBattleRoomState newState, {
    bool cancelSubscription = false,
  }) {
    if (cancelSubscription) {
      _battleRoomStreamSubscription?.cancel();
    }
    emit(newState);
  }

  //subscribe battle room
  void subscribeToMultiUserBattleRoom(
    String battleRoomDocumentId,
    List<Question> questions,
  ) {
    _battleRoomStreamSubscription = _battleRoomRepository
        .subscribeToBattleRoom(battleRoomDocumentId, forMultiUser: true)
        .listen(
      (event) {
        //to check if room destroyed by owner
        if (event.exists) {
          emit(
            MultiUserBattleRoomSuccess(
              battleRoom: BattleRoom.fromDocumentSnapshot(event),
              isRoomExist: true,
              questions: questions,
            ),
          );
        } else {
          //update state with room does not exist
          emit(
            MultiUserBattleRoomSuccess(
              battleRoom: (state as MultiUserBattleRoomSuccess).battleRoom,
              isRoomExist: false,
              questions: (state as MultiUserBattleRoomSuccess).questions,
            ),
          );
        }
      },
      onError: (e) {
        emit(MultiUserBattleRoomFailure(errorCodeDefaultMessage));
      },
      cancelOnError: true,
    );
  }

  //to create room for multiuser
  Future<void> createRoom({
    required String categoryId,
    required String categoryName,
    required RoomCodeCharType charType,
    String? name,
    String? profileUrl,
    String? uid,
    String? roomType,
    int? entryFee,
    String? questionLanguageId,
  }) async {
    emit(MultiUserBattleRoomInProgress());
    try {
      final roomCode = generateRoomCode(charType, 6);
      final documentSnapshot =
          await _battleRoomRepository.createMultiUserBattleRoom(
        categoryId: categoryId,
        categoryName: categoryName,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
        roomCode: roomCode,
        roomType: 'public',
        entryFee: entryFee,
        questionLanguageId: questionLanguageId,
      );
      final questions = await _battleRoomRepository.getQuestions(
        categoryId: '',
        forMultiUser: true,
        matchId: roomCode,
        roomDocumentId: documentSnapshot.id,
        roomCreator: true,
        languageId: questionLanguageId!,
      );
      subscribeToMultiUserBattleRoom(documentSnapshot.id, questions);
    } catch (e) {
      emit(MultiUserBattleRoomFailure(e.toString()));
    }
  }

  //to join multi user battle room
  Future<void> joinRoom({
    required String currentCoin,
    String? name,
    String? profileUrl,
    String? uid,
    String? roomCode,
  }) async {
    emit(MultiUserBattleRoomInProgress());
    try {
      final (:roomId, :questions) =
          await _battleRoomRepository.joinMultiUserBattleRoom(
        name: name,
        profileUrl: profileUrl,
        roomCode: roomCode,
        uid: uid,
        currentCoin: int.parse(currentCoin),
      );

      subscribeToMultiUserBattleRoom(roomId, questions);
    } catch (e) {
      emit(MultiUserBattleRoomFailure(e.toString()));
    }
  }

  //this will be call when user submit answer and marked questions attempted
  //if time expired for given question then default "-1" answer will be submitted
  void updateQuestionAnswer(String questionId, String submittedAnswerId) {
    if (state is MultiUserBattleRoomSuccess) {
      final updatedQuestions = (state as MultiUserBattleRoomSuccess).questions;
      //fetching index of question that need to update with submittedAnswer
      final questionIndex =
          updatedQuestions.indexWhere((element) => element.id == questionId);
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex]
          .updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId);
      emit(
        MultiUserBattleRoomSuccess(
          isRoomExist: (state as MultiUserBattleRoomSuccess).isRoomExist,
          battleRoom: (state as MultiUserBattleRoomSuccess).battleRoom,
          questions: updatedQuestions,
        ),
      );
    }
  }

  //delete room after quiting the game or finishing the game
  void deleteMultiUserBattleRoom() {
    if (state is MultiUserBattleRoomSuccess) {
      _battleRoomRepository.deleteBattleRoom(
        (state as MultiUserBattleRoomSuccess).battleRoom.roomId,
        isGroupBattle: true,
        roomCode: (state as MultiUserBattleRoomSuccess).battleRoom.roomCode,
      );
    }
  }

  void deleteUserFromRoom(String userId) {
    if (state is MultiUserBattleRoomSuccess) {
      final battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      if (userId == battleRoom.user1!.uid) {
        _battleRoomRepository.deleteUserFromMultiUserRoom(1, battleRoom);
      } else if (userId == battleRoom.user2!.uid) {
        _battleRoomRepository.deleteUserFromMultiUserRoom(2, battleRoom);
      } else if (userId == battleRoom.user3!.uid) {
        _battleRoomRepository.deleteUserFromMultiUserRoom(3, battleRoom);
      } else {
        _battleRoomRepository.deleteUserFromMultiUserRoom(4, battleRoom);
      }
    }
  }

  void startGame() {
    if (state is MultiUserBattleRoomSuccess) {
      _battleRoomRepository.startMultiUserQuiz(
        (state as MultiUserBattleRoomSuccess).battleRoom.roomId,
        isMultiUserRoom: true,
      );
    }
  }

  void submitAnswer(
    String currentUserId,
    String submittedAnswer, {
    required bool isCorrectAnswer,
  }) {
    if (state is MultiUserBattleRoomSuccess) {
      final battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      final questions = (state as MultiUserBattleRoomSuccess).questions;

      //need to check submitting answer for user1
      if (currentUserId == battleRoom.user1!.uid) {
        if (battleRoom.user1!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
            battleRoomDocumentId: battleRoom.roomId,
            correctAnswers: isCorrectAnswer
                ? (battleRoom.user1!.correctAnswers + 1)
                : battleRoom.user1!.correctAnswers,
            userNumber: '1',
            submittedAnswer: List.from(battleRoom.user1!.answers)
              ..add(submittedAnswer),
          );
        }
      } else if (currentUserId == battleRoom.user2!.uid) {
        //submit answer for user2
        if (battleRoom.user2!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
            submittedAnswer: List.from(battleRoom.user2!.answers)
              ..add(submittedAnswer),
            battleRoomDocumentId: battleRoom.roomId,
            correctAnswers: isCorrectAnswer
                ? (battleRoom.user2!.correctAnswers + 1)
                : battleRoom.user2!.correctAnswers,
            userNumber: '2',
          );
        }
      } else if (currentUserId == battleRoom.user3!.uid) {
        //submit answer for user3
        if (battleRoom.user3!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
            submittedAnswer: List.from(battleRoom.user3!.answers)
              ..add(submittedAnswer),
            battleRoomDocumentId: battleRoom.roomId,
            correctAnswers: isCorrectAnswer
                ? (battleRoom.user3!.correctAnswers + 1)
                : battleRoom.user3!.correctAnswers,
            userNumber: '3',
          );
        }
      } else {
        //submit answer for user4
        if (battleRoom.user4!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
            submittedAnswer: List.from(battleRoom.user4!.answers)
              ..add(submittedAnswer),
            battleRoomDocumentId: battleRoom.roomId,
            correctAnswers: isCorrectAnswer
                ? (battleRoom.user4!.correctAnswers + 1)
                : battleRoom.user4!.correctAnswers,
            userNumber: '4',
          );
        }
      }
    }
  }

  //get questions in quiz battle
  List<Question> getQuestions() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).questions;
    }
    return [];
  }

  String getRoomCode() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.roomCode!;
    }
    return '';
  }

  String getRoomId() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.roomId!;
    }
    return '';
  }

  //get questions in quiz battle
  int getEntryFee() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.entryFee!;
    }
    return 0;
  }

  String get categoryName => state is MultiUserBattleRoomSuccess
      ? (state as MultiUserBattleRoomSuccess).battleRoom.categoryName!
      : '';

  List<UserBattleRoomDetails?> getUsers() {
    if (state is MultiUserBattleRoomSuccess) {
      final users = <UserBattleRoomDetails?>[];
      final battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      if (battleRoom.user1!.uid.isNotEmpty) {
        users.add(battleRoom.user1);
      }
      if (battleRoom.user2!.uid.isNotEmpty) {
        users.add(battleRoom.user2);
      }
      if (battleRoom.user3!.uid.isNotEmpty) {
        users.add(battleRoom.user3);
      }
      if (battleRoom.user4!.uid.isNotEmpty) {
        users.add(battleRoom.user4);
      }

      return users;
    }
    return [];
  }

  UserBattleRoomDetails? getUser(String userId) {
    final users = getUsers();
    return users[users.indexWhere((element) => element!.uid == userId)];
  }

  List<UserBattleRoomDetails?> getOpponentUsers(String userId) {
    return getUsers()..removeWhere((e) => e!.uid == userId);
  }

  String generateRoomCode(RoomCodeCharType charType, int length) =>
      String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => charType.value.codeUnitAt(_rnd.nextInt(charType.value.length)),
        ),
      );

  //to close the stream subscription
  @override
  Future<void> close() async {
    await _battleRoomStreamSubscription?.cancel();
    return super.close();
  }
}

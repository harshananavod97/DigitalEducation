import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';
import 'package:flutterquiz/features/systemConfig/model/room_code_char_type.dart';
import 'package:flutterquiz/utils/constants/constants.dart';

@immutable
class BattleRoomState {}

class BattleRoomInitial extends BattleRoomState {}

class BattleRoomSearchInProgress extends BattleRoomState {}

class BattleRoomDeleted extends BattleRoomState {}

class BattleRoomJoining extends BattleRoomState {}

class BattleRoomCreating extends BattleRoomState {}

class BattleRoomCreated extends BattleRoomState {
  BattleRoomCreated(this.battleRoom);

  final BattleRoom battleRoom;
}

class BattleRoomUserFound extends BattleRoomState {
  BattleRoomUserFound({
    required this.battleRoom,
    required this.hasLeft,
    required this.questions,
    required this.isRoomExist,
  });

  final BattleRoom battleRoom;
  final bool hasLeft;
  final bool isRoomExist;
  final List<Question> questions;
}

class BattleRoomFailure extends BattleRoomState {
  BattleRoomFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class BattleRoomCubit extends Cubit<BattleRoomState> {
  BattleRoomCubit(this._battleRoomRepository) : super(BattleRoomInitial());
  final BattleRoomRepository _battleRoomRepository;

  StreamSubscription<DocumentSnapshot>? _battleRoomStreamSubscription;
  final Random _rnd = Random.secure();

  void updateState(
    BattleRoomState newState, {
    bool cancelSubscription = false,
  }) {
    if (cancelSubscription) {
      _battleRoomStreamSubscription?.cancel();
    }
    emit(newState);
  }

  //subscribe battle room
  void subscribeToBattleRoom(
    String battleRoomDocumentId,
    List<Question> questions, {
    required bool isGroupBattle,
  }) {
    _battleRoomStreamSubscription = _battleRoomRepository
        .subscribeToBattleRoom(
      battleRoomDocumentId,
      forMultiUser: isGroupBattle,
    )
        .listen(
      (event) {
        if (event.exists) {
          //emit new state
          final battleRoom = BattleRoom.fromDocumentSnapshot(event);
          final userNotFound = battleRoom.user2?.uid.isEmpty;
          //if opponent userId is empty menas we have not found any user

          if (userNotFound == true) {
            if (state is BattleRoomUserFound) {
              //if one of the user has left the game while playing
              emit(
                BattleRoomUserFound(
                  battleRoom: (state as BattleRoomUserFound).battleRoom,
                  hasLeft: true,
                  isRoomExist: true,
                  questions: (state as BattleRoomUserFound).questions,
                ),
              );
              return;
            }

            //if currentRoute is not battleRoomOpponent and battle room created then we
            //have to delete the room so other user can not join the room

            //If roomCode is empty means room is created for playing random battle
            //else room is created for play with friend battle
            if (Routes.currentRoute != Routes.battleRoomFindOpponent &&
                battleRoom.roomCode!.isEmpty) {
              deleteBattleRoom(isGroupBattle: false);
            }
            //if user not found yet
            emit(BattleRoomCreated(battleRoom));
          } else {
            emit(
              BattleRoomUserFound(
                battleRoom: battleRoom,
                isRoomExist: true,
                questions: questions,
                hasLeft: false,
              ),
            );
          }
        } else {
          if (state is BattleRoomUserFound) {
            //if one of the user has left the game while playing
            emit(
              BattleRoomUserFound(
                battleRoom: (state as BattleRoomUserFound).battleRoom,
                hasLeft: true,
                isRoomExist: false,
                questions: (state as BattleRoomUserFound).questions,
              ),
            );
          }
        }
      },
      onError: (e) {
        emit(BattleRoomFailure(errorCodeDefaultMessage));
      },
      cancelOnError: true,
    );
  }

  void joinBattleRoomWithBot(
    String battleRoomDocumentId,
    List<Question> questions, {
    required bool type,
  }) {
    _battleRoomStreamSubscription = _battleRoomRepository
        .subscribeToBattleRoom(battleRoomDocumentId, forMultiUser: type)
        .listen(
      (event) {
        if (event.exists) {
          //emit new state
          final battleRoom = BattleRoom.fromDocumentSnapshot(event);

          emit(
            BattleRoomUserFound(
              battleRoom: battleRoom,
              isRoomExist: true,
              questions: questions,
              hasLeft: false,
            ),
          );
        }
      },
      onError: (e) => emit(BattleRoomFailure(errorCodeDefaultMessage)),
      cancelOnError: true,
    );
  }

  Future<void> searchRoom({
    required String categoryId,
    required String name,
    required String profileUrl,
    required String uid,
    required String questionLanguageId,
    required int entryFee,
  }) async {
    emit(BattleRoomSearchInProgress());
    try {
      final documents = await _battleRoomRepository.searchBattleRoom(
        questionLanguageId: questionLanguageId,
        categoryId: categoryId,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
      );

      if (documents.isNotEmpty) {
        //find any random room
        final room = documents[Random.secure().nextInt(documents.length)];
        emit(BattleRoomJoining());
        final questions = await _battleRoomRepository.getQuestions(
          categoryId: categoryId,
          matchId: room.id,
          forMultiUser: false,
          roomDocumentId: room.id,
          languageId: questionLanguageId,
          roomCreator: false,
          destroyBattleRoom: '0',
        );
        final searchAgain = await _battleRoomRepository.joinBattleRoom(
          battleRoomDocumentId: room.id,
          name: name,
          profileUrl: profileUrl,
          uid: uid,
        );
        if (searchAgain) {
          //if user fails to join room then searchAgain
          await searchRoom(
            categoryId: categoryId,
            name: name,
            profileUrl: profileUrl,
            uid: uid,
            questionLanguageId: questionLanguageId,
            entryFee: entryFee,
          );
        } else {
          subscribeToBattleRoom(room.id, questions, isGroupBattle: false);
        }
      } else {
        await createRoom(
          categoryId: categoryId,
          categoryName: '',
          entryFee: entryFee,
          name: name,
          profileUrl: profileUrl,
          questionLanguageId: questionLanguageId,
          uid: uid,
        );
      }
    } catch (e) {
      emit(BattleRoomFailure(e.toString()));
    }
  }

  String generateRoomCode(RoomCodeCharType charType, int length) =>
      String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => charType.value.codeUnitAt(_rnd.nextInt(charType.value.length)),
        ),
      );

  //to create room for battle
  /// Used for both random battle as well as one vs one battle.
  /// if [[charType]] is null, it will be used for random battle as it doesn't require roomCode.
  /// but for oneVsOneBattle roomCode is Required, so [[charType]] shouldn't be null in that case.
  Future<void> createRoom({
    required String categoryId,
    required String categoryName,
    RoomCodeCharType?
        charType, // make it show if it is not null then generate otherwise don't
    String? name,
    String? profileUrl,
    String? uid,
    int? entryFee,
    String? questionLanguageId,
  }) async {
    emit(BattleRoomCreating());
    try {
      var roomCode = '';
      if (charType != null) {
        roomCode = generateRoomCode(charType, 6);
      }
      final documentSnapshot = await _battleRoomRepository.createBattleRoom(
        categoryId: categoryId,
        categoryName: categoryName,
        name: name!,
        profileUrl: profileUrl!,
        uid: uid!,
        roomCode: roomCode,
        roomType: 'public',
        entryFee: entryFee,
        questionLanguageId: questionLanguageId!,
      );

      emit(
        BattleRoomCreated(BattleRoom.fromDocumentSnapshot(documentSnapshot)),
      );
      final questions = await _battleRoomRepository.getQuestions(
        categoryId: categoryId,
        forMultiUser: false,
        matchId: charType != null ? roomCode : documentSnapshot.id,
        roomDocumentId: documentSnapshot.id,
        roomCreator: true,
        languageId: questionLanguageId,
        destroyBattleRoom: '0',
      );

      subscribeToBattleRoom(
        documentSnapshot.id,
        questions,
        isGroupBattle: false,
      );
    } catch (e) {
      emit(BattleRoomFailure(e.toString()));
    }
  }

  Future<void> createRoomWithBot({
    required String categoryId,
    required BuildContext context,
    RoomCodeCharType? charType,
    String? name,
    String? profileUrl,
    String? uid,
    int? entryFee,
    String? botName,
    String? questionLanguageId,
  }) async {
    emit(BattleRoomCreating());
    try {
      var roomCode = '';
      if (charType != null) {
        roomCode = generateRoomCode(charType, 6);
      }
      final documentSnapshot =
          await _battleRoomRepository.createBattleRoomWithBot(
        categoryId: categoryId,
        name: name!,
        profileUrl: profileUrl!,
        uid: uid!,
        roomCode: roomCode,
        botName: botName,
        roomType: 'public',
        entryFee: entryFee,
        questionLanguageId: questionLanguageId!,
        context: context,
      );

      emit(
        BattleRoomCreated(BattleRoom.fromDocumentSnapshot(documentSnapshot)),
      );
      final questions = await _battleRoomRepository.getQuestions(
        categoryId: categoryId,
        forMultiUser: false,
        matchId: charType != null ? roomCode : documentSnapshot.id,
        roomDocumentId: documentSnapshot.id,
        roomCreator: true,
        languageId: questionLanguageId,
        destroyBattleRoom: '0',
      );

      joinBattleRoomWithBot(documentSnapshot.id, questions, type: false);
    } catch (e) {
      emit(BattleRoomFailure(e.toString()));
    }
  }

  //to join battle room
  Future<void> joinRoom({
    required String currentCoin,
    String? name,
    String? profileUrl,
    String? uid,
    String? roomCode,
  }) async {
    emit(BattleRoomJoining());
    try {
      final (:roomId, :questions) =
          await _battleRoomRepository.joinBattleRoomFrd(
        name: name,
        profileUrl: profileUrl,
        roomCode: roomCode,
        uid: uid,
        currentCoin: int.parse(currentCoin),
      );

      subscribeToBattleRoom(roomId, questions, isGroupBattle: false);
    } catch (e) {
      emit(BattleRoomFailure(e.toString()));
    }
  }

  //this will be call when user submit answer and marked questions attempted
  //if time expired for given question then default "-1" answer will be submitted
  void updateQuestionAnswer(String? questionId, String? submittedAnswerId) {
    if (state is BattleRoomUserFound) {
      final updatedQuestions = (state as BattleRoomUserFound).questions;
      //fetching index of question that need to update with submittedAnswer
      final questionIndex =
          updatedQuestions.indexWhere((element) => element.id == questionId);
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex]
          .updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId!);
      emit(
        BattleRoomUserFound(
          isRoomExist: (state as BattleRoomUserFound).isRoomExist,
          hasLeft: (state as BattleRoomUserFound).hasLeft,
          battleRoom: (state as BattleRoomUserFound).battleRoom,
          questions: updatedQuestions,
        ),
      );
    }
  }

  void deleteBattleRoom({required bool isGroupBattle}) {
    if (state is BattleRoomUserFound) {
      final battleRoom = (state as BattleRoomUserFound).battleRoom;
      _battleRoomRepository
        ..destroyBattleRoomInDatabase(
          languageId: battleRoom.languageId!,
          categoryId: battleRoom.categoryId!,
          matchId: battleRoom.roomCode!.isEmpty
              ? battleRoom.roomId!
              : battleRoom.roomCode!,
        )
        ..deleteBattleRoom(battleRoom.roomId, isGroupBattle: isGroupBattle);
      emit(BattleRoomDeleted());
    } else if (state is BattleRoomCreated) {
      final battleRoom = (state as BattleRoomCreated).battleRoom;
      _battleRoomRepository
        ..destroyBattleRoomInDatabase(
          languageId: battleRoom.languageId!,
          categoryId: battleRoom.categoryId!,
          matchId: battleRoom.roomCode!.isEmpty
              ? battleRoom.roomId!
              : battleRoom.roomCode!,
        )
        ..deleteBattleRoom(battleRoom.roomId, isGroupBattle: isGroupBattle);
      emit(BattleRoomDeleted());
    }
  }

  void deleteUserFromRoom(String userId) {
    if (state is BattleRoomUserFound) {
      final room = (state as BattleRoomUserFound).battleRoom;
      if (userId == room.user1!.uid) {
        _battleRoomRepository.deleteUserFromRoom(1, room);
      } else {
        _battleRoomRepository.deleteUserFromRoom(2, room);
      }
    }
  }

  void removeOpponentFromBattleRoom() {
    if (state is BattleRoomUserFound) {
      _battleRoomRepository.removeOpponentFromBattleRoom(
        (state as BattleRoomUserFound).battleRoom.roomId!,
      );
    }
  }

  void startGame() {
    if (state is BattleRoomUserFound) {
      _battleRoomRepository.startMultiUserQuiz(
        (state as BattleRoomUserFound).battleRoom.roomId,
        isMultiUserRoom: false,
      );
    }
  }

  //get questions in quiz battle
  int getEntryFee() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).battleRoom.entryFee!;
    }
    if (state is BattleRoomCreated) {
      return (state as BattleRoomCreated).battleRoom.entryFee!;
    }
    return 0;
  }

  String get categoryName {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).battleRoom.categoryName!;
    }
    if (state is BattleRoomCreated) {
      return (state as BattleRoomCreated).battleRoom.categoryName!;
    }
    return '';
  }

  //get questions in quiz battle
  String getRoomCode() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).battleRoom.roomCode!;
    }
    if (state is BattleRoomCreated) {
      return (state as BattleRoomCreated).battleRoom.roomCode!;
    }
    return '';
  }

  void submitAnswer(
    String? currentUserId,
    String? submittedAnswer,
    int points, {
    required bool isAnswerCorrect,
  }) {
    if (state is BattleRoomUserFound) {
      final battleRoom = (state as BattleRoomUserFound).battleRoom;
      final questions = (state as BattleRoomUserFound).questions;

      //need to check submitting answer for user1 or user2
      if (currentUserId == battleRoom.user1!.uid) {
        if (battleRoom.user1!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswer(
            battleRoomDocumentId: battleRoom.roomId,
            points: isAnswerCorrect
                ? (battleRoom.user1!.points + points)
                : battleRoom.user1!.points,
            correctAnswers: isAnswerCorrect
                ? (battleRoom.user1!.correctAnswers + 1)
                : battleRoom.user1!.correctAnswers,
            forUser1: true,
            submittedAnswer: List.from(battleRoom.user1!.answers)
              ..add(submittedAnswer),
          );
        }
      } else {
        //submit answer for user2
        if (battleRoom.user2!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswer(
            submittedAnswer: List.from(battleRoom.user2!.answers)
              ..add(submittedAnswer),
            battleRoomDocumentId: battleRoom.roomId,
            points: isAnswerCorrect
                ? (battleRoom.user2!.points + points)
                : battleRoom.user2!.points,
            correctAnswers: isAnswerCorrect
                ? (battleRoom.user2!.correctAnswers + 1)
                : battleRoom.user2!.correctAnswers,
            forUser1: false,
          );
        }
      }
    }
  }

  //currentQuestionIndex will be same as given answers length(since index start with 0 in arrary)
  int getCurrentQuestionIndex() {
    if (state is BattleRoomUserFound) {
      final currentState = state as BattleRoomUserFound;
      int currentQuestionIndex;

      //if both users has submitted answer means currentQuestionIndex will be
      //as (answers submitted by users) + 1
      if (currentState.battleRoom.user1!.answers.length ==
          currentState.battleRoom.user2!.answers.length) {
        currentQuestionIndex = currentState.battleRoom.user1!.answers.length;
      } else if (currentState.battleRoom.user1!.answers.length <
          currentState.battleRoom.user2!.answers.length) {
        currentQuestionIndex = currentState.battleRoom.user1!.answers.length;
      } else {
        currentQuestionIndex = currentState.battleRoom.user2!.answers.length;
      }

      //need to decrease index by one in order to remove index out of range error
      //after game has finished
      if (currentQuestionIndex == currentState.questions.length) {
        currentQuestionIndex--;
      }
      return currentQuestionIndex;
    }

    return 0;
  }

  //get questions in quiz battle
  List<Question> getQuestions() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).questions;
    }
    return [];
  }

  String getRoomId() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).battleRoom.roomId!;
    }
    if (state is BattleRoomCreated) {
      return (state as BattleRoomCreated).battleRoom.roomId!;
    }
    return '';
  }

  UserBattleRoomDetails getCurrentUserDetails(String currentUserId) {
    if (state is BattleRoomUserFound) {
      if (currentUserId ==
          (state as BattleRoomUserFound).battleRoom.user1?.uid) {
        return (state as BattleRoomUserFound).battleRoom.user1!;
      } else {
        return (state as BattleRoomUserFound).battleRoom.user2!;
      }
    }
    return const UserBattleRoomDetails(
      answers: [],
      correctAnswers: 0,
      name: 'name',
      profileUrl: 'profileUrl',
      uid: 'uid',
      points: 0,
    );
  }

  UserBattleRoomDetails getOpponentUserDetails(String currentUserId) {
    if (state is BattleRoomUserFound) {
      if (currentUserId ==
          (state as BattleRoomUserFound).battleRoom.user1?.uid) {
        return (state as BattleRoomUserFound).battleRoom.user2!;
      } else {
        return (state as BattleRoomUserFound).battleRoom.user1!;
      }
    }
    return const UserBattleRoomDetails(
      points: 0,
      answers: [],
      correctAnswers: 0,
      name: 'name',
      profileUrl: 'profileUrl',
      uid: 'uid',
    );
  }

  bool opponentLeftTheGame(String userId) {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).hasLeft &&
          getCurrentUserDetails(userId).answers.length !=
              (state as BattleRoomUserFound).questions.length;
    }

    return false;
  }

  List<UserBattleRoomDetails?> getUsers() {
    if (state is BattleRoomUserFound) {
      final users = <UserBattleRoomDetails?>[];
      final battleRoom = (state as BattleRoomUserFound).battleRoom;
      if (battleRoom.user1!.uid.isNotEmpty) {
        users.add(battleRoom.user1);
      }
      if (battleRoom.user2!.uid.isNotEmpty) {
        users.add(battleRoom.user2);
      }

      return users;
    }
    return [];
  }

  //to close the stream subsciption
  @override
  Future<void> close() async {
    await _battleRoomStreamSubscription?.cancel();
    return super.close();
  }
}

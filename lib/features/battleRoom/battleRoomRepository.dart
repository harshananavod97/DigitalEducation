import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomException.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRemoteDataSource.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/utils/constants/constants.dart';

class BattleRoomRepository {
  factory BattleRoomRepository() {
    _battleRoomRepository._battleRoomRemoteDataSource =
        BattleRoomRemoteDataSource();

    return _battleRoomRepository;
  }

  BattleRoomRepository._internal();

  static final BattleRoomRepository _battleRoomRepository =
      BattleRoomRepository._internal();
  late BattleRoomRemoteDataSource _battleRoomRemoteDataSource;

  //search battle room
  Future<List<DocumentSnapshot>> searchBattleRoom({
    required String categoryId,
    required String name,
    required String profileUrl,
    required String uid,
    required String questionLanguageId,
  }) async {
    try {
      final documents = await _battleRoomRemoteDataSource.searchBattleRoom(
        categoryId,
        questionLanguageId,
      );

      //if room is created by user who is searching the room then delete room
      //so user will not join room that was created by him/her self
      final index = documents.indexWhere(
        (e) => (e.data()! as Map<String, dynamic>)['createdBy'] == uid,
      );
      if (index != -1) {
        await deleteBattleRoom(documents[index].id, isGroupBattle: false);
        documents.removeAt(index);
      }
      return documents;
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  Future<DocumentSnapshot> createBattleRoom({
    required String categoryId,
    required String categoryName,
    required String name,
    required String profileUrl,
    required String uid,
    required String questionLanguageId,
    String? roomCode,
    String? roomType,
    int? entryFee,
  }) async {
    try {
      return await _battleRoomRemoteDataSource.createBattleRoom(
        categoryId: categoryId,
        categoryName: categoryName,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
        entryFee: entryFee,
        roomCode: roomCode,
        roomType: roomType,
        questionLanguageId: questionLanguageId,
      );
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  Future<DocumentSnapshot> createBattleRoomWithBot({
    required String categoryId,
    required String name,
    required String profileUrl,
    required String uid,
    required String questionLanguageId,
    required BuildContext context,
    String? roomCode,
    String? roomType,
    int? entryFee,
    String? botName,
  }) async {
    try {
      return await _battleRoomRemoteDataSource.createBattleRoomWithBot(
        categoryId: categoryId,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
        botName: botName,
        entryFee: entryFee,
        roomCode: roomCode,
        roomType: roomType,
        questionLanguageId: questionLanguageId,
        context: context,
      );
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //join multi user battle room
  Future<({String roomId, List<Question> questions})> joinBattleRoomFrd({
    String? name,
    String? profileUrl,
    String? uid,
    String? roomCode,
    int? currentCoin,
  }) async {
    try {
      //verify roomCode is valid or not
      final querySnapshot = await _battleRoomRemoteDataSource
          .getMultiUserBattleRoom(roomCode, 'battle');

      //invalid room code
      if (querySnapshot.docs.isEmpty) {
        throw BattleRoomException(errorMessageCode: errorCodeRoomCodeInvalid);
      }

      final roomData = querySnapshot.docs.first.data()! as Map<String, dynamic>;

      //game started code
      if (roomData['readyToPlay'] as bool) {
        throw BattleRoomException(errorMessageCode: errorCodeGameStarted);
      }

      //not enough coins
      final entryFee = roomData['entryFee'] as int;
      if (entryFee > currentCoin!) {
        throw BattleRoomException(errorMessageCode: errorCodeNotEnoughCoins);
      }

      //fetch questions for quiz
      final questions = await getQuestions(
        categoryId: '',
        matchId: roomCode!,
        forMultiUser: false,
        roomCreator: false,
        roomDocumentId: querySnapshot.docs.first.id,
        languageId: defaultQuestionLanguageId,
        destroyBattleRoom: '0',
      );

      //get roomRef
      final documentReference = querySnapshot.docs.first.reference;
      //using transaction so we get latest document before updating roomDocument
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        //get latest document
        final documentSnapshot = await documentReference.get();
        final docData = documentSnapshot.data()! as Map<String, dynamic>;

        final user2 = docData['user2'] as Map<String, dynamic>;

        if (user2['uid'].toString().isEmpty) {
          //join as user2
          transaction.update(documentReference, {
            'user2.name': name,
            'user2.uid': uid,
            'user2.profileUrl': profileUrl,
          });
        } else {
          //room is full
          throw BattleRoomException(errorMessageCode: errorCodeRoomIsFull);
        }
        return (
          roomId: documentSnapshot.id,
          questions: questions,
        );
      });
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //create multi user battle room
  Future<DocumentSnapshot> createMultiUserBattleRoom({
    required String categoryId,
    required String categoryName,
    String? name,
    String? profileUrl,
    String? uid,
    String? roomCode,
    String? roomType,
    int? entryFee,
    String? questionLanguageId,
  }) async {
    try {
      return await _battleRoomRemoteDataSource.createMultiUserBattleRoom(
        categoryId: categoryId,
        categoryName: categoryName,
        name: name,
        profileUrl: profileUrl,
        roomCode: roomCode,
        uid: uid,
        roomType: roomType,
        entryFee: entryFee,
        questionLanguageId: questionLanguageId,
      );
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //join multi user battle room
  Future<({String roomId, List<Question> questions})> joinMultiUserBattleRoom({
    String? name,
    String? profileUrl,
    String? uid,
    String? roomCode,
    int? currentCoin,
  }) async {
    try {
      //verify roomCode is valid or not
      final querySnapshot = await _battleRoomRemoteDataSource
          .getMultiUserBattleRoom(roomCode, '');

      //invalid room code
      if (querySnapshot.docs.isEmpty) {
        throw BattleRoomException(errorMessageCode: errorCodeRoomCodeInvalid);
      }

      final roomData = querySnapshot.docs.first.data()! as Map<String, dynamic>;

      //game started code
      if (roomData['readyToPlay'] as bool) {
        throw BattleRoomException(errorMessageCode: errorCodeGameStarted);
      }

      //not enough coins
      if (roomData['entryFee'] as int > currentCoin!) {
        throw BattleRoomException(errorMessageCode: errorCodeNotEnoughCoins);
      }

      //fetch questions for quiz
      final questions = await getQuestions(
        categoryId: '',
        matchId: roomCode!,
        forMultiUser: true,
        roomCreator: false,
        roomDocumentId: querySnapshot.docs.first.id,
        languageId: defaultQuestionLanguageId,
      );

      //get roomRef
      final documentReference = querySnapshot.docs.first.reference;

      //using transaction so we get latest document before updating roomDocument
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        //get latest document
        final documentSnapshot = await documentReference.get();
        final docData = documentSnapshot.data()! as Map<String, dynamic>;

        final user2 = docData['user2'] as Map<String, dynamic>;
        final user3 = docData['user3'] as Map<String, dynamic>;
        final user4 = docData['user4'] as Map<String, dynamic>;

        /// Join as available user
        if (user2['uid'].toString().isEmpty) {
          //join as user2
          transaction.update(documentReference, {
            'user2.name': name,
            'user2.uid': uid,
            'user2.profileUrl': profileUrl,
          });
        } else if (user3['uid'].toString().isEmpty) {
          //join as user3
          transaction.update(documentReference, {
            'user3.name': name,
            'user3.uid': uid,
            'user3.profileUrl': profileUrl,
          });
        } else if (user4['uid'].toString().isEmpty) {
          //join as user4
          transaction.update(documentReference, {
            'user4.name': name,
            'user4.uid': uid,
            'user4.profileUrl': profileUrl,
          });
        } else {
          //room is full
          throw BattleRoomException(errorMessageCode: errorCodeRoomIsFull);
        }

        return (
          roomId: documentSnapshot.id,
          questions: questions,
        );
      });
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //subscribe to battle room
  Stream<DocumentSnapshot> subscribeToBattleRoom(
    String? battleRoomDocumentId, {
    required bool forMultiUser,
  }) {
    return _battleRoomRemoteDataSource.subscribeToBattleRoom(
      battleRoomDocumentId,
      forMultiUser: forMultiUser,
    );
  }

  //delete room by id
  Future<void> deleteBattleRoom(
    String? documentId, {
    required bool isGroupBattle,
    String? roomCode,
  }) async {
    try {
      await _battleRoomRemoteDataSource.deleteBattleRoom(
        documentId,
        isGroupBattle: isGroupBattle,
        roomCode: roomCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeOpponentFromBattleRoom(String roomId) async {
    try {
      await _battleRoomRemoteDataSource.removeOpponentFromBattleRoom(roomId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUnusedBattleRoom(String userId) async {
    try {
      final rooms =
          await _battleRoomRemoteDataSource.getRoomCreatedByUser(userId);
      for (final element in rooms['groupBattle']!) {
        final battleRoom = BattleRoom.fromDocumentSnapshot(element);
        if (!battleRoom.readyToPlay!) {
          await _battleRoomRemoteDataSource.deleteBattleRoom(
            battleRoom.roomId,
            isGroupBattle: true,
            roomCode: battleRoom.roomCode,
          );
        }
      }
      for (final element in rooms['battle']!) {
        await _battleRoomRemoteDataSource.deleteBattleRoom(
          element.id,
          isGroupBattle: false,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  //get quesitons for battle
  Future<List<Question>> getQuestions({
    required String languageId,
    required String categoryId,
    required String matchId,
    required bool forMultiUser,
    required bool roomCreator,
    required String roomDocumentId,
    String? destroyBattleRoom,
  }) async {
    try {
      List<Map<String, dynamic>>? questions;
      if (forMultiUser) {
        questions = await _battleRoomRemoteDataSource
            .getMultiUserBattleQuestions(matchId);
      } else {
        questions = await _battleRoomRemoteDataSource.getQuestions(
          destroyRoom: destroyBattleRoom ?? '1',
          categoryId: categoryId,
          languageId: languageId,
          matchId: matchId,
        );
      }

      return questions!.map(Question.fromJson).toList();
    } catch (e) {
      if (roomCreator) {
        //if any error occurs while fetching question deleteRoom
        await deleteBattleRoom(roomDocumentId, isGroupBattle: forMultiUser);
      }
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  Future<void> destroyBattleRoomInDatabase({
    required String languageId,
    required String categoryId,
    required String matchId,
  }) async {
    try {
      await _battleRoomRemoteDataSource.getQuestions(
        languageId: languageId,
        categoryId: categoryId,
        matchId: matchId,
        destroyRoom: '1',
      );
    } catch (e) {
      rethrow;
    }
  }

  //to join battle room (one to one)
  Future<bool> joinBattleRoom({
    String? battleRoomDocumentId,
    String? name,
    String? profileUrl,
    String? uid,
  }) async {
    try {
      return await _battleRoomRemoteDataSource.joinBattleRoom(
        battleRoomDocumentId: battleRoomDocumentId,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
      );
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //submit answer and update correct answer count and points
  Future<void> submitAnswer({
    required bool forUser1,
    List<String?>? submittedAnswer,
    String? battleRoomDocumentId,
    int? points,
    int? correctAnswers,
  }) async {
    try {
      final submitAnswer = <String, dynamic>{};
      if (forUser1) {
        submitAnswer.addAll({
          'user1.answers': submittedAnswer,
          'user1.points': points,
          'user1.correctAnswers': correctAnswers,
        });
      } else {
        submitAnswer.addAll({
          'user2.answers': submittedAnswer,
          'user2.points': points,
          'user2.correctAnswers': correctAnswers,
        });
      }
      await _battleRoomRemoteDataSource.submitAnswer(
        battleRoomDocumentId: battleRoomDocumentId,
        submitAnswer: submitAnswer,
        forMultiUser: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  //submit answer and update correct answer count
  Future<void> submitAnswerForMultiUserBattleRoom({
    String? userNumber,
    List<String>? submittedAnswer,
    String? battleRoomDocumentId,
    int? correctAnswers,
  }) async {
    try {
      final submitAnswer = <String, dynamic>{};
      if (userNumber == '1') {
        submitAnswer.addAll({
          'user1.answers': submittedAnswer,
          'user1.correctAnswers': correctAnswers,
        });
      } else if (userNumber == '2') {
        submitAnswer.addAll({
          'user2.answers': submittedAnswer,
          'user2.correctAnswers': correctAnswers,
        });
      } else if (userNumber == '3') {
        submitAnswer.addAll({
          'user3.answers': submittedAnswer,
          'user3.correctAnswers': correctAnswers,
        });
      } else {
        submitAnswer.addAll({
          'user4.answers': submittedAnswer,
          'user4.correctAnswers': correctAnswers,
        });
      }

      await _battleRoomRemoteDataSource.submitAnswer(
        battleRoomDocumentId: battleRoomDocumentId,
        submitAnswer: submitAnswer,
        forMultiUser: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Delete User from room
  Future<void> deleteUserFromRoom(int userNumber, BattleRoom battleRoom) async {
    try {
      final updatedData = <String, dynamic>{};
      if (userNumber == 1) {
        updatedData['user1'] = {
          'name': '',
          'points': 0,
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        };
        updatedData['user2'] = {
          'name': battleRoom.user2!.name,
          'points': battleRoom.user2!.points,
          'correctAnswers': battleRoom.user2!.correctAnswers,
          'answers': battleRoom.user2!.answers,
          'uid': battleRoom.user2!.uid,
          'profileUrl': battleRoom.user2!.profileUrl,
        };
      } else {
        updatedData['user1'] = {
          'name': battleRoom.user1!.name,
          'points': battleRoom.user1!.points,
          'correctAnswers': battleRoom.user1!.correctAnswers,
          'answers': battleRoom.user1!.answers,
          'uid': battleRoom.user1!.uid,
          'profileUrl': battleRoom.user1!.profileUrl,
        };
        updatedData['user2'] = {
          'name': '',
          'points': 0,
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        };
      }
      await _battleRoomRemoteDataSource.updateUserDataInRoom(
        battleRoom.roomId,
        updatedData,
        isMultiUserRoom: false,
      );
    } catch (e) {
      log(e.toString(), name: 'DeleteUserFromRoom');
    }
  }

  //delete user from multi user battle room (this will be call when user left the game)
  Future<void> deleteUserFromMultiUserRoom(
    int userNumber,
    BattleRoom battleRoom,
  ) async {
    try {
      final updatedData = <String, dynamic>{};
      if (userNumber == 1) {
        //move users to one step ahead
        updatedData['user1'] = {
          'name': battleRoom.user2!.name,
          'correctAnswers': battleRoom.user2!.correctAnswers,
          'answers': battleRoom.user2!.answers,
          'uid': battleRoom.user2!.uid,
          'profileUrl': battleRoom.user2!.profileUrl,
        };
        updatedData['user2'] = {
          'name': battleRoom.user3!.name,
          'correctAnswers': battleRoom.user3!.correctAnswers,
          'answers': battleRoom.user3!.answers,
          'uid': battleRoom.user3!.uid,
          'profileUrl': battleRoom.user3!.profileUrl,
        };
        updatedData['user3'] = {
          'name': battleRoom.user4!.name,
          'correctAnswers': battleRoom.user4!.correctAnswers,
          'answers': battleRoom.user4!.answers,
          'uid': battleRoom.user4!.uid,
          'profileUrl': battleRoom.user4!.profileUrl,
        };
        updatedData['user4'] = {
          'name': '',
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        };
      } else if (userNumber == 2) {
        updatedData['user2'] = {
          'name': battleRoom.user3!.name,
          'correctAnswers': battleRoom.user3!.correctAnswers,
          'answers': battleRoom.user3!.answers,
          'uid': battleRoom.user3!.uid,
          'profileUrl': battleRoom.user3!.profileUrl,
        };
        updatedData['user3'] = {
          'name': battleRoom.user4!.name,
          'correctAnswers': battleRoom.user4!.correctAnswers,
          'answers': battleRoom.user4!.answers,
          'uid': battleRoom.user4!.uid,
          'profileUrl': battleRoom.user4!.profileUrl,
        };
        updatedData['user4'] = {
          'name': '',
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        };
      } else if (userNumber == 3) {
        updatedData['user3'] = {
          'name': battleRoom.user4!.name,
          'correctAnswers': battleRoom.user4!.correctAnswers,
          'answers': battleRoom.user4!.answers,
          'uid': battleRoom.user4!.uid,
          'profileUrl': battleRoom.user4!.profileUrl,
        };
        updatedData['user4'] = {
          'name': '',
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        };
      } else {
        updatedData['user4'] = {
          'name': '',
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        };
      }
      await _battleRoomRemoteDataSource.updateUserDataInRoom(
        battleRoom.roomId,
        updatedData,
        isMultiUserRoom: true,
      );
    } catch (e) {
      log(e.toString(), name: 'deleteUserFromMultiUserRoom');
    }
  }

  Future<void> startMultiUserQuiz(
    String? battleRoomDocumentId, {
    required bool isMultiUserRoom,
  }) async {
    try {
      await _battleRoomRemoteDataSource.updateUserDataInRoom(
        battleRoomDocumentId,
        {'readyToPlay': true},
        isMultiUserRoom: isMultiUserRoom,
      );
    } catch (e) {
      rethrow;
    }
  }

  //All the message related code start from here
  Stream<List<Message>> subscribeToMessages({required String roomId}) {
    return _battleRoomRemoteDataSource
        .subscribeToMessages(roomId: roomId)
        .map((event) {
      if (event.docs.isEmpty) {
        return [];
      } else {
        return event.docs.map(Message.fromDocumentSnapshot).toList();
      }
    });
  }

  //to add messgae
  Future<String> addMessage(Message message) async {
    try {
      return await _battleRoomRemoteDataSource.addMessage(message.toJson());
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //to delete messgae
  Future<void> deleteMessage(Message message) async {
    try {
      await _battleRoomRemoteDataSource.deleteMessage(message.messageId);
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //to delete messgae
  Future<void> deleteMessagesByUserId(String roomId, String by) async {
    try {
      //fetch all messages of given roomId
      final messages =
          await _battleRoomRemoteDataSource.getMessagesByUserId(roomId, by);
      //delete all messages
      for (final element in messages) {
        try {
          await _battleRoomRemoteDataSource.deleteMessage(element.id);
        } catch (e) {
          rethrow;
        }
      }
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }
}

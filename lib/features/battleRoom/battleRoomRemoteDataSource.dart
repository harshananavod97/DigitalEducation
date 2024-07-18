import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomException.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/internet_connectivity.dart';
import 'package:http/http.dart' as http;

class BattleRoomRemoteDataSource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //While starting app
  static Future<void> deleteBattleRoomCreatedByUser() async {
    await FirebaseFirestore.instance
        .collection(battleRoomCollection)
        .get()
        .then((value) => null);
  }

  /*
  access_key:8525
	match_id:your_match_id
	language_id:2   //{optional}
  category:1
  */

  Future<List<Map<String, dynamic>>?> getQuestions({
    required String languageId,
    required String categoryId,
    required String matchId,
    required String destroyRoom,
  }) async {
    try {
      final body = <String, String>{
        languageIdKey: languageId,
        matchIdKey: matchId,
        categoryKey: categoryId,
        destroyRoomKey: destroyRoom, //0 do not destroy and 1 destroy
      };
      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionForOneToOneBattle),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw BattleRoomException(
          errorMessageCode: responseJson['message'] as String,
        ); //error
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on BattleRoomException catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    } catch (e) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>?> getMultiUserBattleQuestions(
    String? roomCode,
  ) async {
    try {
      final body = <String, String?>{
        roomIdKey: roomCode,
      };

      final response = await http.post(
        Uri.parse(getQuestionForMultiUserBattle),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw BattleRoomException(
          errorMessageCode: responseJson['message'].toString(),
        ); //error
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on BattleRoomException catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    } catch (e) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //subscribe to battle room
  Stream<DocumentSnapshot> subscribeToBattleRoom(
    String? battleRoomDocumentId, {
    required bool forMultiUser,
  }) {
    if (forMultiUser) {
      return _firebaseFirestore
          .collection(multiUserBattleRoomCollection)
          .doc(battleRoomDocumentId)
          .snapshots();
    }
    return _firebaseFirestore
        .collection(battleRoomCollection)
        .doc(battleRoomDocumentId)
        .snapshots();
  }

  Future<void> removeOpponentFromBattleRoom(String roomId) async {
    try {
      await _firebaseFirestore
          .collection(battleRoomCollection)
          .doc(roomId)
          .update({
        'user2': {
          'name': '',
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        },
      });
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //to find room to play quiz
  Future<List<DocumentSnapshot>> searchBattleRoom(
    String categoryId,
    String questionLanguageId,
  ) async {
    try {
      QuerySnapshot querySnapshot;
      if (await InternetConnectivity.isUserOffline()) {
        throw const SocketException('');
      }

      querySnapshot = await _firebaseFirestore
          .collection(battleRoomCollection)
          .where('languageId', isEqualTo: questionLanguageId)
          .where('categoryId', isEqualTo: categoryId)
          .where('roomCode', isEqualTo: '')
          .where('user2.uid', isEqualTo: '')
          .get();

      return querySnapshot.docs;
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeUnableToFindRoom);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //delete battle room
  Future<void> deleteBattleRoom(
    String? documentId, {
    required bool isGroupBattle,
    String? roomCode,
  }) async {
    try {
      if (isGroupBattle) {
        final body = <String, String>{
          roomIdKey: roomCode!,
        };
        await _firebaseFirestore
            .collection(multiUserBattleRoomCollection)
            .doc(documentId)
            .delete();
        await http.post(
          Uri.parse(deleteMultiUserBattleRoom),
          body: body,
          headers: await ApiUtils.getHeaders(),
        );
      } else {
        await _firebaseFirestore
            .collection(battleRoomCollection)
            .doc(documentId)
            .delete();
      }
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //get battle room
  Future<Map<String, List<DocumentSnapshot>>> getRoomCreatedByUser(
    String userId,
  ) async {
    try {
      final QuerySnapshot multiUserBattleQuerySnapshot =
          await _firebaseFirestore
              .collection(multiUserBattleRoomCollection)
              .where('createdBy', isEqualTo: userId)
              .get();
      final QuerySnapshot battleQuerySnapshot = await _firebaseFirestore
          .collection(battleRoomCollection)
          .where('createdBy', isEqualTo: userId)
          .get();

      return {
        'battle': battleQuerySnapshot.docs,
        'groupBattle': multiUserBattleQuerySnapshot.docs,
      };
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //to create room to play quiz
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
      //hasLeft,categoryId
      final DocumentReference documentReference =
          await _firebaseFirestore.collection(battleRoomCollection).add({
        'createdBy': uid,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'languageId': questionLanguageId,
        'roomCode': roomCode ?? '',
        'entryFee': entryFee ?? 0,
        'readyToPlay': false,
        'user1': {
          'name': name,
          'points': 0,
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': uid,
          'profileUrl': profileUrl,
        },
        'user2': {
          'name': '',
          'points': 0,
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        },
        'createdAt': Timestamp.now(),
      });
      return await documentReference.get();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeUnableToCreateRoom);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
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
      //hasLeft,categoryId
      final DocumentReference documentReference =
          await _firebaseFirestore.collection(battleRoomCollection).add({
        'createdBy': uid,
        'categoryId': categoryId,
        'languageId': questionLanguageId,
        'roomCode': roomCode ?? '',
        'entryFee': entryFee ?? 0,
        'readyToPlay': true,
        'user1': {
          'name': name,
          'points': 0,
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': uid,
          'profileUrl': profileUrl,
        },
        'user2': {
          'name': botName ?? 'Robot',
          'points': 0,
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '000',
          'profileUrl': context.read<SystemConfigCubit>().botImage,
        },
        'createdAt': Timestamp.now(),
      });
      return await documentReference.get();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeUnableToCreateRoom);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

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
      final body = <String, String>{
        roomIdKey: roomCode!,
        roomTypeKey: roomType!,
        categoryKey: categoryId,
        numberOfQuestionsKey: '10',
        languageIdKey: questionLanguageId!,
      };
      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }
      if (questionLanguageId.isEmpty) {
        body.remove(languageIdKey);
      }
      final response = await http.post(
        Uri.parse(createMultiUserBattleRoomUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw BattleRoomException(
          errorMessageCode: responseJson['message'].toString(),
        ); //error
      }

      final DocumentReference documentReference = await _firebaseFirestore
          .collection(multiUserBattleRoomCollection)
          .add({
        'createdBy': uid,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'roomCode': roomCode,
        'entryFee': entryFee,
        'readyToPlay': false,
        'user1': {
          'name': name,
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': uid,
          'profileUrl': profileUrl,
        },
        'user2': {
          'name': '',
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        },
        'user3': {
          'name': '',
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        },
        'user4': {
          'name': '',
          'correctAnswers': 0,
          'answers': <String>[],
          'uid': '',
          'profileUrl': '',
        },
        'createdAt': Timestamp.now(),
      });
      return documentReference.get();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeUnableToCreateRoom);
    } on BattleRoomException catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //to create room to play quiz
  Future<bool> joinBattleRoom({
    String? name,
    String? profileUrl,
    String? uid,
    String? battleRoomDocumentId,
  }) async {
    try {
      final DocumentReference documentReference = (await _firebaseFirestore
              .collection(battleRoomCollection)
              .doc(battleRoomDocumentId)
              .get())
          .reference;

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        //get latest document
        final documentSnapshot = await documentReference.get();
        final user2Details = Map<String, dynamic>.from(
          documentSnapshot.data()! as Map<String, dynamic>,
        )['user2'] as Map<String, dynamic>;

        if (user2Details['uid'].toString().isEmpty) {
          //
          //join as user2
          transaction.update(documentReference, {
            'user2.name': name,
            'user2.uid': uid,
            'user2.profileUrl': profileUrl,
          });
          return false;
        }
        return true; //search for other room
      });
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeUnableToJoinRoom);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //get room by roomCode (multiUserBattleRoom)
  Future<QuerySnapshot> getMultiUserBattleRoom(
    String? roomCode,
    String? type,
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection(
            type == 'battle'
                ? battleRoomCollection
                : multiUserBattleRoomCollection,
          )
          .where('roomCode', isEqualTo: roomCode)
          .get();
      return querySnapshot;
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeUnableToFindRoom);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //submit answer
  Future<void> submitAnswer({
    required Map<String, dynamic> submitAnswer,
    required bool forMultiUser,
    String? battleRoomDocumentId,
  }) async {
    try {
      if (forMultiUser) {
        await _firebaseFirestore
            .collection(multiUserBattleRoomCollection)
            .doc(battleRoomDocumentId)
            .update(submitAnswer);
      } else {
        await _firebaseFirestore
            .collection(battleRoomCollection)
            .doc(battleRoomDocumentId)
            .update(submitAnswer);
      }
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(
        errorMessageCode: errorCodeUnableToSubmitAnswer,
      );
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //delete user from multiple user room
  Future<void> updateUserDataInRoom(
    String? documentId,
    Map<String, dynamic> updatedData, {
    required bool isMultiUserRoom,
  }) async {
    try {
      await _firebaseFirestore
          .collection(
            !isMultiUserRoom
                ? battleRoomCollection
                : multiUserBattleRoomCollection,
          )
          .doc(documentId)
          .update(updatedData);
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //All the message related code start from here

  //subscribe to messages in room
  Stream<QuerySnapshot> subscribeToMessages({required String roomId}) {
    return _firebaseFirestore
        .collection(messagesCollection)
        .where('roomId', isEqualTo: roomId)
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots();
  }

  //add message
  Future<String> addMessage(Map<String, dynamic> data) async {
    try {
      final DocumentReference documentReference =
          await _firebaseFirestore.collection(messagesCollection).add(data);

      return documentReference.id;
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firebaseFirestore
          .collection(messagesCollection)
          .doc(messageId)
          .delete();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //to get all messages by it's roomId
  Future<List<DocumentSnapshot>> getMessagesByUserId(
    String roomId,
    String by,
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection(messagesCollection)
          .where('roomId', isEqualTo: roomId)
          .where('by', isEqualTo: by)
          .get();
      return querySnapshot.docs;
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeNoInternet);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';

class BattleRoom {
  BattleRoom({
    this.roomId,
    this.categoryId,
    this.categoryName,
    this.user1,
    this.user2,
    this.createdBy,
    this.readyToPlay,
    this.roomCode,
    this.user3,
    this.user4,
    this.entryFee,
    this.languageId,
  });

  final String? roomId;
  final String? categoryId;
  final String? categoryName;
  final String? createdBy;
  final String? languageId;

  //it will be in use for multiUserBattleRoom
  //user1 will be the creator of this room
  final UserBattleRoomDetails? user1;
  final UserBattleRoomDetails? user2;
  final UserBattleRoomDetails? user3;
  final UserBattleRoomDetails? user4;
  final int? entryFee;
  final String? roomCode;
  final bool? readyToPlay;

  // TODO(J): issue with making it constructor.
  static BattleRoom fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;

    return BattleRoom(
      languageId: data['languageId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      roomId: documentSnapshot.id,
      readyToPlay: data['readyToPlay'] as bool? ?? false,
      entryFee: data['entryFee'] as int? ?? 0,
      roomCode: data['roomCode'] as String? ?? '',
      user3: UserBattleRoomDetails.fromJson(
        Map.from(data['user3'] as Map<String, dynamic>? ?? {}),
      ),
      user4: UserBattleRoomDetails.fromJson(
        Map.from(data['user4'] as Map<String, dynamic>? ?? {}),
      ),
      user1: UserBattleRoomDetails.fromJson(
        Map.from(data['user1'] as Map<String, dynamic>),
      ),
      user2: UserBattleRoomDetails.fromJson(
        Map.from(data['user2'] as Map<String, dynamic>),
      ),
    );
  }
}

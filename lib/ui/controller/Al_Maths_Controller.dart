import 'package:cloud_firestore/cloud_firestore.dart';

class AlMathsController {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('AL_Maths');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

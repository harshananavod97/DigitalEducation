import 'package:cloud_firestore/cloud_firestore.dart';

class AlsciencefortechnologyController {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('Al_Science_For_Technology');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

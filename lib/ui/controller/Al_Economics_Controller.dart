import 'package:cloud_firestore/cloud_firestore.dart';

class AlEconomicsController {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('Al_Economics');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

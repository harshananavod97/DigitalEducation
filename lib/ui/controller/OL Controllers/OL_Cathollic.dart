import 'package:cloud_firestore/cloud_firestore.dart';

class Ol_Catholiccontroller {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('OL_Catholic');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

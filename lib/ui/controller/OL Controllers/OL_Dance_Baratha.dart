import 'package:cloud_firestore/cloud_firestore.dart';

class Ol_Dancing_Baratha_Controller {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('OL_Dance_Baratha');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

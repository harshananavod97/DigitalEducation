import 'package:cloud_firestore/cloud_firestore.dart';

class Ol_Music_Carnaticcontroller {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('OL_Music_Carnatic');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

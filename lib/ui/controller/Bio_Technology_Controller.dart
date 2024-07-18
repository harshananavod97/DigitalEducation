import 'package:cloud_firestore/cloud_firestore.dart';

class AlBioTechnology {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('Al_Bio_Technology');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

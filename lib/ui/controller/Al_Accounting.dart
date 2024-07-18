import 'package:cloud_firestore/cloud_firestore.dart';

class Al_AcountingController {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('Al_Accounting');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

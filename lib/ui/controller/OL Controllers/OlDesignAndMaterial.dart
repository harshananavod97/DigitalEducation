import 'package:cloud_firestore/cloud_firestore.dart';

class Ol_DesignAndMaterialcontroller {
  CollectionReference playmartCollection =
      FirebaseFirestore.instance.collection('OL_Design_AND_Material');

  // Stream<QuerySnapshot> getItemsStream() {
  //   return PlayMartItems.snapshots();
  // }

  //Retrive Coversation Stream
  Stream<QuerySnapshot> getItems(String conID) => playmartCollection
      .orderBy('CreatedAt', descending: true)
      .where('ConId', isEqualTo: conID)
      .snapshots();
}

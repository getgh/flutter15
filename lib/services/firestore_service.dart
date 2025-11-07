import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/item.dart';

class FirestoreService {
  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(Item item) async {
    await _itemsRef.add(item.toMap());
  }

  Stream<List<Item>> getItemsStream() {
    return _itemsRef.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<void> updateItem(Item item) async {
    if (item.id == null) return;
    await _itemsRef.doc(item.id).update(item.toMap());
  }

  Future<void> deleteItem(String itemId) async {
    await _itemsRef.doc(itemId).delete();
  }

  Future<List<Item>> getItemsOnce() async {
    final snapshot = await _itemsRef.get();
    return snapshot.docs
        .map((d) => Item.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }
}
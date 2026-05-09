import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _i = FirestoreService._();
  factory FirestoreService() => _i;
  FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> col(String path) =>
      _db.collection(path);

  Future<Map<String, dynamic>?> getDoc(
      String collection, String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> setDoc(
      String collection, String id, Map<String, dynamic> data,
      {bool merge = true}) async {
    await _db
        .collection(collection)
        .doc(id)
        .set(data, SetOptions(merge: merge));
  }

  Future<void> updateDoc(
      String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).update(data);
  }

  Future<String> addDoc(
      String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  Future<void> deleteDoc(String collection, String id) async =>
      await _db.collection(collection).doc(id).delete();

  Future<List<Map<String, dynamic>>> queryDocs(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection(collection);
    if (whereField != null) q = q.where(whereField, isEqualTo: whereValue);
    if (orderBy != null) q = q.orderBy(orderBy, descending: descending);
    if (limit != null) q = q.limit(limit);
    final snap = await q.get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> streamDocs(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> q = _db.collection(collection);
    if (whereField != null) q = q.where(whereField, isEqualTo: whereValue);
    if (orderBy != null) q = q.orderBy(orderBy, descending: descending);
    return q
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<void> arrayUnion(
      String collection, String id, String field, dynamic value) async {
    await _db.collection(collection).doc(id).update({
      field: FieldValue.arrayUnion([value])
    });
  }

  Future<void> arrayRemove(
      String collection, String id, String field, dynamic value) async {
    await _db.collection(collection).doc(id).update({
      field: FieldValue.arrayRemove([value])
    });
  }
}

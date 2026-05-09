import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Base de données locale in-memory + persistance SharedPreferences.
/// Remplace Firestore pour le développement local.
class LocalDbService {
  static final LocalDbService _instance = LocalDbService._();
  factory LocalDbService() => _instance;
  LocalDbService._();

  // store[collection][docId] = data
  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  // Streams par collection
  final Map<String, StreamController<List<Map<String, dynamic>>>> _streams = {};

  bool _loaded = false;

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('local_db');
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final col in decoded.entries) {
        _store[col.key] = {};
        final docs = col.value as Map<String, dynamic>;
        for (final doc in docs.entries) {
          _store[col.key]![doc.key] = Map<String, dynamic>.from(doc.value);
        }
      }
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_db', jsonEncode(_store));
  }

  Map<String, Map<String, dynamic>> _col(String collection) {
    _store.putIfAbsent(collection, () => {});
    return _store[collection]!;
  }

  void _notifyStream(String collection) {
    final ctrl = _streams[collection];
    if (ctrl != null && !ctrl.isClosed) {
      ctrl.add(_col(collection).values.toList());
    }
  }

  // ─── CRUD ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getDoc(String collection, String id) async {
    await _ensureLoaded();
    final doc = _col(collection)[id];
    return doc != null ? Map<String, dynamic>.from(doc) : null;
  }

  Future<void> setDoc(
    String collection,
    String id,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    await _ensureLoaded();
    if (merge && _col(collection).containsKey(id)) {
      _col(collection)[id]!.addAll(data);
    } else {
      _col(collection)[id] = Map<String, dynamic>.from(data);
    }
    _notifyStream(collection);
    await _persist();
  }

  Future<void> updateDoc(
      String collection, String id, Map<String, dynamic> data) async {
    await _ensureLoaded();
    _col(collection).putIfAbsent(id, () => {});
    _col(collection)[id]!.addAll(data);
    _notifyStream(collection);
    await _persist();
  }

  Future<String> addDoc(
      String collection, Map<String, dynamic> data) async {
    await _ensureLoaded();
    final id = '${collection[0]}_${DateTime.now().millisecondsSinceEpoch}';
    _col(collection)[id] = {'id': id, ...data};
    _notifyStream(collection);
    await _persist();
    return id;
  }

  Future<void> deleteDoc(String collection, String id) async {
    await _ensureLoaded();
    _col(collection).remove(id);
    _notifyStream(collection);
    await _persist();
  }

  // ─── Query ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> queryDocs(
    String collection, {
    String? whereField,
    dynamic whereValue,
    Map<String, dynamic>? where, // conditions multiples
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    await _ensureLoaded();
    var docs = _col(collection).values
        .map((d) => Map<String, dynamic>.from(d))
        .toList();

    // Filtre simple
    if (whereField != null) {
      docs = docs.where((d) => d[whereField] == whereValue).toList();
    }
    // Filtres multiples
    if (where != null) {
      for (final entry in where.entries) {
        docs = docs.where((d) => d[entry.key] == entry.value).toList();
      }
    }

    // Tri
    if (orderBy != null) {
      docs.sort((a, b) {
        final av = a[orderBy];
        final bv = b[orderBy];
        if (av == null || bv == null) return 0;
        final cmp = av.toString().compareTo(bv.toString());
        return descending ? -cmp : cmp;
      });
    }

    // Limite
    if (limit != null && docs.length > limit) {
      docs = docs.sublist(0, limit);
    }

    return docs;
  }

  Stream<List<Map<String, dynamic>>> streamDocs(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
  }) {
    _streams.putIfAbsent(
      collection,
      () => StreamController<List<Map<String, dynamic>>>.broadcast(),
    );
    // Émettre l'état initial
    _ensureLoaded().then((_) => _notifyStream(collection));
    return _streams[collection]!.stream.map((docs) {
      var filtered = docs.map((d) => Map<String, dynamic>.from(d)).toList();
      if (whereField != null) {
        filtered =
            filtered.where((d) => d[whereField] == whereValue).toList();
      }
      if (orderBy != null) {
        filtered.sort((a, b) {
          final cmp =
              (a[orderBy]?.toString() ?? '').compareTo(b[orderBy]?.toString() ?? '');
          return descending ? -cmp : cmp;
        });
      }
      return filtered;
    });
  }

  // ─── Array helpers ─────────────────────────────────────────────────────────

  Future<void> arrayUnion(
      String collection, String id, String field, dynamic value) async {
    await _ensureLoaded();
    _col(collection).putIfAbsent(id, () => {});
    final doc = _col(collection)[id]!;
    final list = List<dynamic>.from(doc[field] ?? []);
    if (!list.contains(value)) list.add(value);
    doc[field] = list;
    _notifyStream(collection);
    await _persist();
  }

  Future<void> arrayRemove(
      String collection, String id, String field, dynamic value) async {
    await _ensureLoaded();
    final doc = _col(collection)[id];
    if (doc == null) return;
    final list = List<dynamic>.from(doc[field] ?? []);
    list.remove(value);
    doc[field] = list;
    _notifyStream(collection);
    await _persist();
  }

  // ─── Utilitaires ───────────────────────────────────────────────────────────

  /// Efface toute la base locale (utile pour les tests).
  Future<void> clearAll() async {
    _store.clear();
    _loaded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_db');
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class AccountService {
  AccountService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(Uint8List bytes) async {
    final user = _requireUser();
    if (bytes.isEmpty) throw StateError('The selected image is empty or invalid.');
    final reference = _storage
        .ref()
        .child('profiles')
        .child(user.uid)
        .child('avatar-${DateTime.now().millisecondsSinceEpoch}.jpg');
    debugPrint('PROFILE IMAGE: authenticated uid=${user.uid}');
    debugPrint('PROFILE IMAGE: storage bucket=${_storage.bucket}');
    debugPrint('PROFILE IMAGE: upload path=${reference.fullPath}');
    debugPrint('PROFILE IMAGE: upload starting');
    final snapshot = await reference.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    debugPrint('PROFILE IMAGE: upload completed state=${snapshot.state}');
    if (snapshot.state != TaskState.success) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'upload-failed',
        message: 'Profile image upload did not complete successfully.',
      );
    }
    debugPrint('PROFILE IMAGE: getDownloadURL starting from uploaded snapshot ref');
    final url = await snapshot.ref.getDownloadURL();
    debugPrint('PROFILE IMAGE: getDownloadURL completed');
    await user.updatePhotoURL(url);
    await _firestore.collection('users').doc(user.uid).set(
      {'photoUrl': url},
      SetOptions(merge: true),
    );
    debugPrint('PROFILE IMAGE: users/${user.uid}.photoUrl persisted');
    return url;
  }

  Future<void> updateProfileName(String name) async {
    final user = _requireUser();
    final trimmedName = name.trim();
    await user.updateDisplayName(trimmedName);
    await _firestore.collection('users').doc(user.uid).set({
      'name': trimmedName,
    }, SetOptions(merge: true));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'This account does not have an email address.',
      );
    }

    await _reauthenticate(user, email, currentPassword);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({required String password}) async {
    final user = _requireUser();
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'This account does not have an email address.',
      );
    }

    await _reauthenticate(user, email, password);
    await _deleteUserCollection(user.uid, 'favorites');
    await _deleteUserCollection(user.uid, 'savedRecipes');
    await _deleteOwnedRecipes(user.uid);
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No user is currently signed in.');
    }
    return user;
  }

  Future<void> _reauthenticate(User user, String email, String password) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _deleteUserCollection(String uid, String collectionName) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection(collectionName)
        .get();
    await _deleteDocuments(snapshot.docs);
  }

  Future<void> _deleteOwnedRecipes(String uid) async {
    final snapshot = await _firestore
        .collection('recipes')
        .where('createdBy', isEqualTo: uid)
        .get();
    await _deleteDocuments(snapshot.docs);
  }

  Future<void> _deleteDocuments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) async {
    for (var index = 0; index < documents.length; index += 400) {
      final batch = _firestore.batch();
      final end = (index + 400 < documents.length)
          ? index + 400
          : documents.length;
      for (final document in documents.sublist(index, end)) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }
}

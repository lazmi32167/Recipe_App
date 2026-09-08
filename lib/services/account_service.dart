import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  AccountService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

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

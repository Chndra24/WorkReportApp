import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserData?> login(String identifier, String password) async {
    try {
      String email = identifier;

      // Jika input bukan format email (tidak ada '@'), cari email berdasarkan employeeId di Firestore
      if (!identifier.contains('@')) {
        final query = await _firestore
            .collection('users')
            .where('employeeId', isEqualTo: identifier)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'ID Karyawan tidak terdaftar.',
          );
        }
        email = query.docs.first.data()['email'] as String;
      }

      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userData = await getUserData(credential.user!.uid);
        if (userData == null) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Profil user tidak ditemukan di database.',
          );
        }
        return userData;
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(UserData userData) async {
    try {
      // 1. Buat User di Firebase Auth terlebih dahulu (di luar transaksi)
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: userData.email,
        password: userData.password,
      );

      final String uid = credential.user!.uid;

      // 2. Gunakan Transaction hanya untuk data Firestore
      await _firestore.runTransaction((transaction) async {
        final counterDocRef = _firestore.collection('settings').doc('counters');
        final counterSnapshot = await transaction.get(counterDocRef);

        int nextId = 1;
        if (counterSnapshot.exists) {
          int lastId = counterSnapshot.data()?['lastEmployeeId'] ?? 0;
          nextId = lastId + 1;
        }

        final generatedEmployeeId = 'KRY-${nextId.toString().padLeft(3, '0')}';

        final newUser = userData.copyWith(
          id: uid,
          employeeId: generatedEmployeeId,
        );

        // Simpan Data User ke Firestore
        transaction.set(
          _firestore.collection('users').doc(uid),
          newUser.toJson(),
        );

        // Update Counter
        transaction.set(
          counterDocRef,
          {'lastEmployeeId': nextId},
          SetOptions(merge: true),
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<UserData?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        debugPrint('DEBUG: Data dari Firestore: ${doc.data()}');
        return UserData.fromJson(doc.data()!);
      }
      debugPrint('DEBUG: Document tidak ditemukan untuk UID: $uid');
      return null;
    } catch (e) {
      debugPrint('DEBUG: Error di getUserData: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Periksa apakah email terdaftar di Firestore
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Email tidak terdaftar di sistem kami.',
        );
      }

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de l'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Inscription avec email et mot de passe
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String organisation,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le profil utilisateur dans Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'organisation': organisation,
        'role': 'user', // Rôle par défaut
        'dateCreation': FieldValue.serverTimestamp(),
        'dernierAcces': FieldValue.serverTimestamp(),
      });

      // Envoyer email de vérification
      await userCredential.user!.sendEmailVerification();

      if (kDebugMode) {
        debugPrint('✅ Utilisateur créé: ${userCredential.user!.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur inscription: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur inscription: $e');
      }
      rethrow;
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour la date de dernier accès
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'dernierAcces': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('✅ Connexion réussie: ${userCredential.user!.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur connexion: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur connexion: $e');
      }
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        debugPrint('✅ Déconnexion réussie');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur déconnexion: $e');
      }
      rethrow;
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        debugPrint('✅ Email de réinitialisation envoyé à: $email');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur réinitialisation: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur réinitialisation: $e');
      }
      rethrow;
    }
  }

  // Obtenir le profil utilisateur depuis Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur récupération profil: $e');
      }
      return null;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      if (kDebugMode) {
        debugPrint('✅ Profil mis à jour');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur mise à jour profil: $e');
      }
      rethrow;
    }
  }

  // Obtenir le message d'erreur en français
  String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'Le mot de passe est trop faible (minimum 6 caractères)';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email';
      case 'invalid-email':
        return 'L\'adresse email est invalide';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion';
      default:
        return 'Une erreur est survenue: $errorCode';
    }
  }
}

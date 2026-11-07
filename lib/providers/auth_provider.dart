import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// State management provider for User Authentication
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Check current session on app start
  Future<void> checkAuthState() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        try {
          final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (doc.exists && doc.data() != null) {
            _currentUser = UserModel.fromMap(doc.data()!, doc.id);
          } else {
            _currentUser = UserModel(
              uid: firebaseUser.uid,
              name: firebaseUser.email?.split('@').first ?? 'Student',
              email: firebaseUser.email ?? '',
              role: 'student',
            );
          }
        } catch (e) {
          debugPrint('Firestore profile fetch notice: $e');
          _currentUser = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.email?.split('@').first ?? 'Student',
            email: firebaseUser.email ?? '',
            role: 'student',
          );
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
    }
  }

  // Register new user with ALU email constraint
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String department = 'Computer Science',
    String campus = 'Kigali, Rwanda',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Check ALU email constraint
    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.endsWith('@alueducation.com')) {
      _isLoading = false;
      _errorMessage = 'Registration is restricted to ALU emails (@alueducation.com).';
      notifyListeners();
      return false;
    }

    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      // Create user model and save to Firestore
      final newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: cleanEmail,
        role: role,
        department: department,
        campus: campus,
      );

      // Attempt to save user to Firestore (safe fallback if rules locked)
      try {
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
      } catch (firestoreError) {
        debugPrint('Firestore save error (check Firestore Security Rules): $firestoreError');
      }

      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('General signup error: $e');
      _isLoading = false;
      _errorMessage = 'An error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  // Sign in existing user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Validate ALU domain
    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.endsWith('@alueducation.com')) {
      _isLoading = false;
      _errorMessage = 'Please sign in using your @alueducation.com email address.';
      notifyListeners();
      return false;
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Fetch user profile from Firestore safely
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        } else {
          // Fallback if document not found in Firestore
          _currentUser = UserModel(
            uid: uid,
            name: cleanEmail.split('@').first,
            email: cleanEmail,
            role: 'student',
          );
        }
      } catch (firestoreError) {
        debugPrint('Firestore profile fetch notice during login: $firestoreError');
        _currentUser = UserModel(
          uid: uid,
          name: cleanEmail.split('@').first,
          email: cleanEmail,
          role: 'student',
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('General signIn error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to sign in ($e). Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Clear any existing error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper function for user-friendly error messages
  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this ALU email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:van_ber_passenger/models/user_model.dart';
import 'package:van_ber_passenger/services/firestore_service.dart';

enum UserState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  profileIncomplete,
  error,
}

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserState _state = UserState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  UserState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isProfileComplete => _user?.isProfileComplete ?? false;

  // Initialize user from Firebase Auth and Firestore
  Future<void> initializeFromFirebaseUser(User firebaseUser) async {
    debugPrint('🔄 Initializing user from Firebase: ${firebaseUser.uid}');
    _setLoading(true);

    try {
      // First, try to get user from Firestore
      final existingUser = await FirestoreService.getUser(firebaseUser.uid);

      if (existingUser != null) {
        // User exists in Firestore, use that data
        _user = existingUser;
        debugPrint(
          '✅ User loaded from Firestore: ${_user!.fullName} (ID: ${_user!.id})',
        );
      } else {
        // User doesn't exist in Firestore, create new user
        _user = await FirestoreService.createUserFromFirebaseAuth(firebaseUser);
        debugPrint('🆕 New user created in Firestore: ${_user!.id}');
      }

      if (_user!.isProfileComplete) {
        _setState(UserState.authenticated);
        debugPrint(
          '✅ User profile is complete, setting state to authenticated',
        );
      } else {
        _setState(UserState.profileIncomplete);
        debugPrint(
          '⚠️ User profile is incomplete, setting state to profileIncomplete',
        );
      }
    } catch (e) {
      debugPrint('❌ Error initializing user: $e');
      _setError('Failed to initialize user: ${e.toString()}');
    } finally {
      _setLoading(false);
      debugPrint('🏁 User initialization completed');
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? email,
    String? region,
  }) async {
    if (_user == null) {
      _setError('No user to update');
      return;
    }

    _setLoading(true);

    try {
      // Update local user model first
      _user = _user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
        email: email ?? _user!.email,
        region: region ?? _user!.region,
        updatedAt: DateTime.now(),
      );

      // Then update in Firestore
      await FirestoreService.updateUserFields(_user!.id!, {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber ?? _user!.phoneNumber,
        'email': email ?? _user!.email,
        'region': region ?? _user!.region,
        'updatedAt': DateTime.now(),
      });

      _setState(UserState.authenticated);
      debugPrint('✅ Profile updated successfully');
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      debugPrint('❌ Error updating profile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Clear user data (logout)
  Future<void> clearUser() async {
    debugPrint('🚪 Clearing user data...');
    try {
      if (_user?.id != null) {
        debugPrint('🗑️ Clearing Firestore data for user: ${_user!.id}');
        // Add timeout to prevent hanging
        await FirestoreService.clearUserData(
          _user!.id!,
        ).timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      debugPrint('❌ Error clearing user data: $e');
    } finally {
      // Always clear the local state regardless of Firestore success/failure
      _user = null;
      _state = UserState.unauthenticated;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      debugPrint('✅ User data cleared successfully');
    }
  }

  // Update phone number specifically
  Future<void> updatePhoneNumber(String phoneNumber) async {
    if (_user != null) {
      try {
        await FirestoreService.updateUserFields(_user!.id!, {
          'phoneNumber': phoneNumber,
        });

        _user = _user!.copyWith(
          phoneNumber: phoneNumber,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      } catch (e) {
        _setError('Failed to update phone number: ${e.toString()}');
      }
    }
  }

  // Update region specifically
  Future<void> updateRegion(String region) async {
    if (_user != null) {
      try {
        await FirestoreService.updateUserFields(_user!.id!, {'region': region});

        _user = _user!.copyWith(region: region, updatedAt: DateTime.now());
        notifyListeners();
      } catch (e) {
        _setError('Failed to update region: ${e.toString()}');
      }
    }
  }

  // Check if user data is valid for completion
  bool isUserDataValid({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String region,
    String? email,
  }) {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        phoneNumber.trim().isNotEmpty &&
        region.trim().isNotEmpty &&
        _isValidPhoneNumber(phoneNumber);
  }

  // Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    // Basic phone number validation
    final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phoneNumber.trim());
  }

  // Validate email format
  bool isValidEmail(String email) {
    if (email.isEmpty) return true; // Email is optional
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set state
  void _setState(UserState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  // Set error state
  void _setError(String error) {
    _errorMessage = error;
    _state = UserState.error;
    _isLoading = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == UserState.error) {
      _setState(
        _user?.isProfileComplete == true
            ? UserState.authenticated
            : UserState.profileIncomplete,
      );
    }
  }

  // Get authentication method
  String getAuthMethod() {
    if (_user == null) return 'Unknown';

    if (_user!.phoneNumber.isNotEmpty && _user!.email.isEmpty) {
      return 'Phone';
    } else if (_user!.email.isNotEmpty) {
      return 'Google';
    }
    return 'Unknown';
  }

  // Check if user is new (first-time signup)
  bool get isNewUser {
    if (_user == null) return false;

    // User is considered new if profile is not complete
    // OR if they just signed up (created recently and profile incomplete)
    return !_user!.isProfileComplete;
  }

  // Load user from Firestore by ID
  Future<void> loadUserById(String userId) async {
    _setLoading(true);

    try {
      final user = await FirestoreService.getUser(userId);
      if (user != null) {
        _user = user;
        if (_user!.isProfileComplete) {
          _setState(UserState.authenticated);
        } else {
          _setState(UserState.profileIncomplete);
        }
      } else {
        _setState(UserState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to load user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset provider state
  void reset() {
    _user = null;
    _state = UserState.initial;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markUserAsEstablished() async {
    if (_user == null) return;

    try {
      // Update in Firestore
      await FirestoreService.updateUserFields(_user!.id!, {'isNewUser': false});

      // Update local state
      _user = _user!.copyWith(isNewUser: false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking user as established: $e');
      rethrow;
    }
  }

  bool get isNewUserAccount {
    if (_user == null) return false;
    return _user!.isNewUser;
  }

  // Add this method to your UserProvider class
  Future<void> saveProfile() async {
    if (_user == null) {
      _setError('No user to save');
      return;
    }

    _setLoading(true);

    try {
      // First validate the required fields
      if (_user!.firstName.isEmpty ||
          _user!.lastName.isEmpty ||
          _user!.phoneNumber.isEmpty ||
          _user!.region.isEmpty) {
        throw Exception('Required profile fields are missing');
      }

      // Update the user in Firestore
      await FirestoreService.updateUserFields(_user!.id!, {
        'firstName': _user!.firstName,
        'lastName': _user!.lastName,
        'phoneNumber': _user!.phoneNumber,
        'email': _user!.email,
        'region': _user!.region,
        'isProfileComplete': true,
        'updatedAt': DateTime.now(),
      });

      // Update local user model
      _user = _user!.copyWith(
        isProfileComplete: true,
        updatedAt: DateTime.now(),
      );

      _setState(UserState.authenticated);
      debugPrint('✅ Profile saved successfully');
    } catch (e) {
      _setError('Failed to save profile: ${e.toString()}');
      debugPrint('❌ Error saving profile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Temporary profile storage method - saves to local state only
  Future<void> saveTemporaryProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String region,
    String? email,
  }) async {
    if (_user == null) {
      _setError('No user to update');
      return;
    }

    try {
      // Update local user model only (not Firestore)
      _user = _user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email ?? _user!.email,
        region: region,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      debugPrint('✅ Temporary profile saved locally');
    } catch (e) {
      _setError('Failed to save temporary profile: ${e.toString()}');
      debugPrint('❌ Error saving temporary profile: $e');
      rethrow;
    }
  }
}

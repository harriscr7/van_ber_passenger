import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:van_ber_passenger/models/user_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // Get current user ID
  static String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Create or update user in Firestore
  static Future<void> saveUser(UserModel user) async {
    try {
      if (user.id == null) {
        throw Exception('User ID cannot be null when saving to Firestore');
      }

      final userData = user.toMap();
      userData['updatedAt'] = FieldValue.serverTimestamp();

      // If it's a new user (no createdAt), add server timestamp
      if (user.createdAt == null) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(userData, SetOptions(merge: true));

      debugPrint('User saved to Firestore: ${user.id}');
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  // Get user from Firestore
  static Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = userId; // Ensure ID is included

        // Convert Firestore timestamps to DateTime
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] =
              (data['updatedAt'] as Timestamp).millisecondsSinceEpoch;
        }

        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user from Firestore: $e');
      rethrow;
    }
  }

  // Get current user from Firestore
  static Future<UserModel?> getCurrentUser() async {
    final userId = _currentUserId;
    if (userId == null) return null;
    return await getUser(userId);
  }

  // Check if user exists in Firestore
  static Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking if user exists: $e');
      return false;
    }
  }

  // Update specific user fields
  static Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_usersCollection).doc(userId).update(fields);

      debugPrint('User fields updated in Firestore: $userId');
    } catch (e) {
      debugPrint('Error updating user fields: $e');
      rethrow;
    }
  }

  // Delete user from Firestore
  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();

      debugPrint('User deleted from Firestore: $userId');
    } catch (e) {
      debugPrint('Error deleting user from Firestore: $e');
      rethrow;
    }
  }

  // Create user from Firebase Auth user (for first-time signup)
  static Future<UserModel> createUserFromFirebaseAuth(User firebaseUser) async {
    try {
      UserModel user;

      if (firebaseUser.phoneNumber != null &&
          firebaseUser.phoneNumber!.isNotEmpty) {
        // Phone authentication - profile incomplete, needs setup
        user = UserModel.fromPhoneAuth(
          id: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber!,
        );
      } else {
        // Google authentication - profile may be complete or need phone number
        user = UserModel.fromFirebaseUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber,
        );
      }

      // Save to Firestore
      await saveUser(user);
      debugPrint('New user created and saved to Firestore: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('Error creating user from Firebase Auth: $e');
      rethrow;
    }
  }

  // Complete user profile setup with region
  static Future<UserModel> completeUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String region,
    String? email,
  }) async {
    try {
      // Get existing user
      final existingUser = await getUser(userId);
      if (existingUser == null) {
        throw Exception('User not found in Firestore');
      }

      // Update user with completed profile
      final updatedUser = existingUser.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email ?? existingUser.email,
        region: region,
        isProfileComplete: true,
        updatedAt: DateTime.now(),
      );

      // Save updated user to Firestore
      await saveUser(updatedUser);
      debugPrint(
        'User profile completed and saved to Firestore: ${updatedUser.fullName}',
      );
      return updatedUser;
    } catch (e) {
      debugPrint('Error completing user profile: $e');
      rethrow;
    }
  }

  // Update user's region specifically
  static Future<void> updateUserRegion(String userId, String region) async {
    try {
      await updateUserFields(userId, {'region': region});
      debugPrint('User region updated for: $userId');
    } catch (e) {
      debugPrint('Error updating user region: $e');
      rethrow;
    }
  }

  // Listen to user changes (real-time updates)
  static Stream<UserModel?> listenToUser(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = userId;

        // Convert Firestore timestamps to DateTime
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] =
              (data['updatedAt'] as Timestamp).millisecondsSinceEpoch;
        }

        return UserModel.fromMap(data);
      }
      return null;
    });
  }

  // Get users by phone number (for checking duplicates)
  static Future<List<UserModel>> getUsersByPhoneNumber(
    String phoneNumber,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Convert Firestore timestamps
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] =
              (data['updatedAt'] as Timestamp).millisecondsSinceEpoch;
        }

        return UserModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting users by phone number: $e');
      return [];
    }
  }

  // Update user profile completion status
  static Future<void> markProfileComplete(String userId) async {
    try {
      await updateUserFields(userId, {'isProfileComplete': true});
    } catch (e) {
      debugPrint('Error marking profile complete: $e');
      rethrow;
    }
  }

  // Get all users (for admin purposes - use with caution)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Convert Firestore timestamps
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] =
              (data['updatedAt'] as Timestamp).millisecondsSinceEpoch;
        }

        return UserModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  // Clear user data from Firestore (for logout - optional)
  static Future<void> clearUserData(String userId) async {
    try {
      // Note: This doesn't delete the user document, just clears sensitive data
      // You might want to keep the user document for analytics
      debugPrint('User data cleared for: $userId');
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }
}

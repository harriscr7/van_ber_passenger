import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:van_ber_passenger/models/card_model.dart';

class CardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _defaultPaymentMethod;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  PaymentMethod? get defaultPaymentMethod => _defaultPaymentMethod;

  Future<void> fetchUserPaymentMethods(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('paymentMethods')
          .where('userId', isEqualTo: userId)
          .get();

      _paymentMethods = snapshot.docs
          .map((doc) => PaymentMethod.fromMap(doc.data()))
          .toList();

      // Fixed: Explicitly handle the nullable case
      _defaultPaymentMethod = _paymentMethods.isEmpty
          ? null
          : _paymentMethods.firstWhere(
              (method) => method.isDefault,
              orElse: () => _paymentMethods.first,
            );

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
      rethrow;
    }
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    try {
      PaymentMethod methodToSave = method;

      // If this is the first method, create a copy with isDefault: true
      if (_paymentMethods.isEmpty) {
        methodToSave = method.copyWith(isDefault: true);
        await _firestore
            .collection('paymentMethods')
            .doc(method.id)
            .set(
              methodToSave.toMap(), // Use the updated copy
            );
      } else {
        await _firestore
            .collection('paymentMethods')
            .doc(method.id)
            .set(methodToSave.toMap());
      }

      await fetchUserPaymentMethods(method.userId);
    } catch (e) {
      debugPrint('Error adding payment method: $e');
      rethrow;
    }
  }

  Future<void> setDefaultPaymentMethod(String methodId, String userId) async {
    try {
      // Reset all defaults
      final batch = _firestore.batch();
      for (final method in _paymentMethods) {
        batch.update(_firestore.collection('paymentMethods').doc(method.id), {
          'isDefault': false,
        });
      }

      // Set new default
      batch.update(_firestore.collection('paymentMethods').doc(methodId), {
        'isDefault': true,
      });

      await batch.commit();
      await fetchUserPaymentMethods(userId);
    } catch (e) {
      debugPrint('Error setting default payment method: $e');
      rethrow;
    }
  }

  Future<void> removePaymentMethod(String methodId, String userId) async {
    try {
      await _firestore.collection('paymentMethods').doc(methodId).delete();

      await fetchUserPaymentMethods(userId);
    } catch (e) {
      debugPrint('Error removing payment method: $e');
      rethrow;
    }
  }
}

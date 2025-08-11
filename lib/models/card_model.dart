import 'package:flutter/foundation.dart';

class PaymentMethod {
  final String id;
  final String userId;
  final String last4Digits;
  final String cardBrand;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentProviderId; // For Stripe/other payment processors

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.last4Digits,
    required this.cardBrand,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.paymentProviderId,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'last4Digits': last4Digits,
      'cardBrand': cardBrand,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (paymentProviderId != null) 'paymentProviderId': paymentProviderId,
    };
  }

  // Create from Map
  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      last4Digits: map['last4Digits'] ?? '',
      cardBrand: map['cardBrand'] ?? 'Unknown',
      cardHolderName: map['cardHolderName'] ?? '',
      expiryMonth: map['expiryMonth'] ?? '',
      expiryYear: map['expiryYear'] ?? '',
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      paymentProviderId: map['paymentProviderId'],
    );
  }

  // Copy with method for immutable updates
  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? last4Digits,
    String? cardBrand,
    String? cardHolderName,
    String? expiryMonth,
    String? expiryYear,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentProviderId,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      last4Digits: last4Digits ?? this.last4Digits,
      cardBrand: cardBrand ?? this.cardBrand,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentProviderId: paymentProviderId ?? this.paymentProviderId,
    );
  }

  // Helper getters
  String get formattedExpiry => '$expiryMonth/${expiryYear.substring(2)}';

  String get maskedNumber => '•••• •••• •••• $last4Digits';

  // Equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod &&
        other.id == id &&
        other.userId == userId &&
        other.last4Digits == last4Digits &&
        other.cardBrand == cardBrand &&
        other.cardHolderName == cardHolderName &&
        other.expiryMonth == expiryMonth &&
        other.expiryYear == expiryYear &&
        other.isDefault == isDefault &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.paymentProviderId == paymentProviderId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      last4Digits,
      cardBrand,
      cardHolderName,
      expiryMonth,
      expiryYear,
      isDefault,
      createdAt,
      updatedAt,
      paymentProviderId,
    );
  }

  // For debugging
  @override
  String toString() {
    return 'PaymentMethod(\n'
        '  id: $id,\n'
        '  userId: $userId,\n'
        '  last4Digits: $last4Digits,\n'
        '  cardBrand: $cardBrand,\n'
        '  cardHolderName: $cardHolderName,\n'
        '  expiry: $formattedExpiry,\n'
        '  isDefault: $isDefault,\n'
        '  providerId: $paymentProviderId\n'
        ')';
  }
}

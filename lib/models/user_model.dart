class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String region;
  final bool isProfileComplete;
  final bool isNewUser; // Added field to track new users
  final String? signupMethod; // 'phone' or 'google'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.region,
    this.isProfileComplete = false,
    this.isNewUser = true, // Default to true for new users
    this.signupMethod,
    this.createdAt,
    this.updatedAt,
  });

  // Create empty user
  factory UserModel.empty() {
    return UserModel(
      firstName: '',
      lastName: '',
      phoneNumber: '',
      email: '',
      region: '',
      isProfileComplete: false,
      isNewUser: true,
    );
  }

  // Create user from Firebase Auth user (for Google login)
  factory UserModel.fromFirebaseUser({
    required String id,
    required String email,
    String? displayName,
    String? phoneNumber,
  }) {
    final nameParts = displayName?.split(' ') ?? ['', ''];
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return UserModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber ?? '',
      email: email,
      region: '',
      isProfileComplete:
          phoneNumber?.isNotEmpty == true && firstName.isNotEmpty,
      isNewUser: true, // New users from auth are always new initially
      signupMethod: 'google',
      createdAt: DateTime.now(),
    );
  }

  // Create user from phone authentication
  factory UserModel.fromPhoneAuth({
    required String id,
    required String phoneNumber,
  }) {
    return UserModel(
      id: id,
      firstName: '',
      lastName: '',
      phoneNumber: phoneNumber,
      email: '',
      region: '',
      isProfileComplete: false,
      isNewUser: true, // New users from auth are always new initially
      signupMethod: 'phone',
      createdAt: DateTime.now(),
    );
  }

  // Copy with method for updating user
  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? region,
    bool? isProfileComplete,
    bool? isNewUser, // Added isNewUser to copyWith
    String? signupMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      region: region ?? this.region,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isNewUser: isNewUser ?? this.isNewUser, // Include isNewUser
      signupMethod: signupMethod ?? this.signupMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'region': region,
      'isProfileComplete': isProfileComplete,
      'isNewUser': isNewUser, // Added to map
      'signupMethod': signupMethod,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Create from map (for database retrieval)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      region: map['region'] ?? '',
      isProfileComplete: map['isProfileComplete'] ?? false,
      isNewUser: map['isNewUser'] ?? true, // Default to true if not specified
      signupMethod: map['signupMethod'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  // Get full name
  String get fullName {
    return '$firstName $lastName'.trim();
  }

  // Get initials
  String get initials {
    String firstInitial = firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, '
        'email: $email, region: $region, isProfileComplete: $isProfileComplete, '
        'isNewUser: $isNewUser)'; // Added isNewUser to toString
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.region == region &&
        other.isProfileComplete == isProfileComplete &&
        other.isNewUser == isNewUser; // Added isNewUser to equality check
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        region.hashCode ^
        isProfileComplete.hashCode ^
        isNewUser.hashCode; // Added isNewUser to hashCode
  }
}

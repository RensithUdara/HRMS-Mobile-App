import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User roles in the HR system
enum UserRole {
  employee,
  hr,
  manager,
  admin
}

/// User authentication and profile model
@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;
  final List<UserRole> roles;
  final bool isActive;
  final bool isProfileComplete;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? customClaims;

  const UserModel({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
    required this.roles,
    this.isActive = true,
    this.isProfileComplete = false,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.customClaims,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? profilePhotoUrl,
    List<UserRole>? roles,
    bool? isActive,
    bool? isProfileComplete,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customClaims,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customClaims: customClaims ?? this.customClaims,
    );
  }

  bool hasRole(UserRole role) => roles.contains(role);

  bool get isEmployee => hasRole(UserRole.employee);
  bool get isHR => hasRole(UserRole.hr);
  bool get isManager => hasRole(UserRole.manager);
  bool get isAdmin => hasRole(UserRole.admin);

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        firstName,
        lastName,
        profilePhotoUrl,
        roles,
        isActive,
        isProfileComplete,
        lastLoginAt,
        createdAt,
        updatedAt,
        customClaims,
      ];
        isActive,
        lastLoginAt,
        createdAt,
        updatedAt,
        customClaims,
      ];
}

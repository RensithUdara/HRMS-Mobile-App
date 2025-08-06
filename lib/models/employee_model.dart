import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employee_model.g.dart';

/// Employee designation levels
enum DesignationLevel { junior, senior, lead, manager, director, executive }

/// Department types in the company
enum Department {
  engineering,
  hr,
  finance,
  marketing,
  sales,
  operations,
  qa,
  devops,
  design,
  product
}

/// Employment status
enum EmploymentStatus { active, inactive, terminated, resigned, onLeave }

/// Employee profile model
@JsonSerializable()
class EmployeeModel extends Equatable {
  final String id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String email;
  final String phoneNumber;
  final String? alternatePhoneNumber;
  final String nicNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String nationality;
  final String religion;
  final String maritalStatus;

  // Address Information
  final String permanentAddress;
  final String currentAddress;
  final String city;
  final String province;
  final String postalCode;

  // Emergency Contact
  final String emergencyContactName;
  final String emergencyContactRelationship;
  final String emergencyContactPhone;

  // Professional Information
  final Department department;
  final String designation;
  final DesignationLevel designationLevel;
  final String? reportingManagerId;
  final DateTime joinDate;
  final DateTime? probationEndDate;
  final DateTime? confirmationDate;
  final EmploymentStatus status;
  final String employmentType; // permanent, contract, intern
  final String workLocation; // office, remote, hybrid

  // Salary Information
  final double basicSalary;
  final double? allowances;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankBranch;

  // Documents
  final String? profilePhotoUrl;
  final String? cvUrl;
  final String? nicCopyUrl;
  final List<String> certificateUrls;

  // System Information
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const EmployeeModel({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    required this.phoneNumber,
    this.alternatePhoneNumber,
    required this.nicNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.religion,
    required this.maritalStatus,
    required this.permanentAddress,
    required this.currentAddress,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.emergencyContactName,
    required this.emergencyContactRelationship,
    required this.emergencyContactPhone,
    required this.department,
    required this.designation,
    required this.designationLevel,
    this.reportingManagerId,
    required this.joinDate,
    this.probationEndDate,
    this.confirmationDate,
    this.status = EmploymentStatus.active,
    required this.employmentType,
    required this.workLocation,
    required this.basicSalary,
    this.allowances,
    this.bankName,
    this.bankAccountNumber,
    this.bankBranch,
    this.profilePhotoUrl,
    this.cvUrl,
    this.nicCopyUrl,
    this.certificateUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);

  String get fullName {
    final middle = middleName != null ? ' $middleName ' : ' ';
    return '$firstName$middle$lastName';
  }

  String get displayName => '$firstName $lastName';

  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  int get yearsOfService {
    final now = DateTime.now();
    int years = now.year - joinDate.year;
    if (now.month < joinDate.month ||
        (now.month == joinDate.month && now.day < joinDate.day)) {
      years--;
    }
    return years;
  }

  bool get isOnProbation {
    if (probationEndDate == null) return false;
    return DateTime.now().isBefore(probationEndDate!);
  }

  bool get isConfirmed {
    if (confirmationDate == null) return false;
    return DateTime.now().isAfter(confirmationDate!);
  }

  double get totalSalary => basicSalary + (allowances ?? 0);

  // EPF calculation (Employee: 8%, Employer: 12%)
  double get epfEmployeeContribution => basicSalary * 0.08;
  double get epfEmployerContribution => basicSalary * 0.12;
  double get totalEpfContribution =>
      epfEmployeeContribution + epfEmployerContribution;

  // ETF calculation (Employer: 3%)
  double get etfContribution => basicSalary * 0.03;

  EmployeeModel copyWith({
    String? id,
    String? employeeId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? phoneNumber,
    String? alternatePhoneNumber,
    String? nicNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? nationality,
    String? religion,
    String? maritalStatus,
    String? permanentAddress,
    String? currentAddress,
    String? city,
    String? province,
    String? postalCode,
    String? emergencyContactName,
    String? emergencyContactRelationship,
    String? emergencyContactPhone,
    Department? department,
    String? designation,
    DesignationLevel? designationLevel,
    String? reportingManagerId,
    DateTime? joinDate,
    DateTime? probationEndDate,
    DateTime? confirmationDate,
    EmploymentStatus? status,
    String? employmentType,
    String? workLocation,
    double? basicSalary,
    double? allowances,
    String? bankName,
    String? bankAccountNumber,
    String? bankBranch,
    String? profilePhotoUrl,
    String? cvUrl,
    String? nicCopyUrl,
    List<String>? certificateUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternatePhoneNumber: alternatePhoneNumber ?? this.alternatePhoneNumber,
      nicNumber: nicNumber ?? this.nicNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      currentAddress: currentAddress ?? this.currentAddress,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelationship:
          emergencyContactRelationship ?? this.emergencyContactRelationship,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      designationLevel: designationLevel ?? this.designationLevel,
      reportingManagerId: reportingManagerId ?? this.reportingManagerId,
      joinDate: joinDate ?? this.joinDate,
      probationEndDate: probationEndDate ?? this.probationEndDate,
      confirmationDate: confirmationDate ?? this.confirmationDate,
      status: status ?? this.status,
      employmentType: employmentType ?? this.employmentType,
      workLocation: workLocation ?? this.workLocation,
      basicSalary: basicSalary ?? this.basicSalary,
      allowances: allowances ?? this.allowances,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankBranch: bankBranch ?? this.bankBranch,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      cvUrl: cvUrl ?? this.cvUrl,
      nicCopyUrl: nicCopyUrl ?? this.nicCopyUrl,
      certificateUrls: certificateUrls ?? this.certificateUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        firstName,
        lastName,
        middleName,
        email,
        phoneNumber,
        alternatePhoneNumber,
        nicNumber,
        dateOfBirth,
        gender,
        nationality,
        religion,
        maritalStatus,
        permanentAddress,
        currentAddress,
        city,
        province,
        postalCode,
        emergencyContactName,
        emergencyContactRelationship,
        emergencyContactPhone,
        department,
        designation,
        designationLevel,
        reportingManagerId,
        joinDate,
        probationEndDate,
        confirmationDate,
        status,
        employmentType,
        workLocation,
        basicSalary,
        allowances,
        bankName,
        bankAccountNumber,
        bankBranch,
        profilePhotoUrl,
        cvUrl,
        nicCopyUrl,
        certificateUrls,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    EmployeeModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      alternatePhoneNumber: json['alternatePhoneNumber'] as String?,
      nicNumber: json['nicNumber'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      religion: json['religion'] as String,
      maritalStatus: json['maritalStatus'] as String,
      permanentAddress: json['permanentAddress'] as String,
      currentAddress: json['currentAddress'] as String,
      city: json['city'] as String,
      province: json['province'] as String,
      postalCode: json['postalCode'] as String,
      emergencyContactName: json['emergencyContactName'] as String,
      emergencyContactRelationship:
          json['emergencyContactRelationship'] as String,
      emergencyContactPhone: json['emergencyContactPhone'] as String,
      department: $enumDecode(_$DepartmentEnumMap, json['department']),
      designation: json['designation'] as String,
      designationLevel:
          $enumDecode(_$DesignationLevelEnumMap, json['designationLevel']),
      reportingManagerId: json['reportingManagerId'] as String?,
      joinDate: DateTime.parse(json['joinDate'] as String),
      probationEndDate: json['probationEndDate'] == null
          ? null
          : DateTime.parse(json['probationEndDate'] as String),
      confirmationDate: json['confirmationDate'] == null
          ? null
          : DateTime.parse(json['confirmationDate'] as String),
      status: $enumDecodeNullable(_$EmploymentStatusEnumMap, json['status']) ??
          EmploymentStatus.active,
      employmentType: json['employmentType'] as String,
      workLocation: json['workLocation'] as String,
      basicSalary: (json['basicSalary'] as num).toDouble(),
      allowances: (json['allowances'] as num?)?.toDouble(),
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankBranch: json['bankBranch'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      cvUrl: json['cvUrl'] as String?,
      nicCopyUrl: json['nicCopyUrl'] as String?,
      certificateUrls: (json['certificateUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$EmployeeModelToJson(EmployeeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'middleName': instance.middleName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'alternatePhoneNumber': instance.alternatePhoneNumber,
      'nicNumber': instance.nicNumber,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': instance.gender,
      'nationality': instance.nationality,
      'religion': instance.religion,
      'maritalStatus': instance.maritalStatus,
      'permanentAddress': instance.permanentAddress,
      'currentAddress': instance.currentAddress,
      'city': instance.city,
      'province': instance.province,
      'postalCode': instance.postalCode,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactRelationship': instance.emergencyContactRelationship,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'department': _$DepartmentEnumMap[instance.department]!,
      'designation': instance.designation,
      'designationLevel': _$DesignationLevelEnumMap[instance.designationLevel]!,
      'reportingManagerId': instance.reportingManagerId,
      'joinDate': instance.joinDate.toIso8601String(),
      'probationEndDate': instance.probationEndDate?.toIso8601String(),
      'confirmationDate': instance.confirmationDate?.toIso8601String(),
      'status': _$EmploymentStatusEnumMap[instance.status]!,
      'employmentType': instance.employmentType,
      'workLocation': instance.workLocation,
      'basicSalary': instance.basicSalary,
      'allowances': instance.allowances,
      'bankName': instance.bankName,
      'bankAccountNumber': instance.bankAccountNumber,
      'bankBranch': instance.bankBranch,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'cvUrl': instance.cvUrl,
      'nicCopyUrl': instance.nicCopyUrl,
      'certificateUrls': instance.certificateUrls,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
    };

const _$DepartmentEnumMap = {
  Department.engineering: 'engineering',
  Department.hr: 'hr',
  Department.finance: 'finance',
  Department.marketing: 'marketing',
  Department.sales: 'sales',
  Department.operations: 'operations',
  Department.qa: 'qa',
  Department.devops: 'devops',
  Department.design: 'design',
  Department.product: 'product',
};

const _$DesignationLevelEnumMap = {
  DesignationLevel.junior: 'junior',
  DesignationLevel.senior: 'senior',
  DesignationLevel.lead: 'lead',
  DesignationLevel.manager: 'manager',
  DesignationLevel.director: 'director',
  DesignationLevel.executive: 'executive',
};

const _$EmploymentStatusEnumMap = {
  EmploymentStatus.active: 'active',
  EmploymentStatus.inactive: 'inactive',
  EmploymentStatus.terminated: 'terminated',
  EmploymentStatus.resigned: 'resigned',
  EmploymentStatus.onLeave: 'onLeave',
};

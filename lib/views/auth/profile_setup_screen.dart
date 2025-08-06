import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../config/app_theme.dart';
import '../../controllers/auth_bloc.dart';
import '../../utils/validators.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _epfController = TextEditingController();
  final _etfController = TextEditingController();
  final _baseSalaryController = TextEditingController();

  File? _profileImage;
  String? _selectedGender;
  DateTime? _dateOfBirth;
  String? _selectedMaritalStatus;
  String? _selectedDepartment;
  String? _selectedPosition;
  String? _selectedEmploymentType;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _maritalStatuses = ['Single', 'Married', 'Divorced', 'Widowed'];
  final List<String> _departments = [
    'Human Resources',
    'Information Technology',
    'Finance',
    'Operations',
    'Sales',
    'Marketing',
    'Administration',
    'Customer Service'
  ];
  final List<String> _positions = [
    'Manager',
    'Assistant Manager',
    'Executive',
    'Senior Executive',
    'Officer',
    'Assistant',
    'Director',
    'Team Lead',
    'Specialist',
    'Coordinator'
  ];
  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Intern',
    'Consultant'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _addressController.dispose();
    _epfController.dispose();
    _etfController.dispose();
    _baseSalaryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 6570)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _validateRequiredFields()) {
      // For now, show success message and navigate to dashboard
      // In a real app, you would save this to Firebase Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile setup completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to dashboard
      context.go('/dashboard');
    }
  }

  bool _validateRequiredFields() {
    if (_selectedGender == null) {
      _showError('Please select your gender');
      return false;
    }
    if (_dateOfBirth == null) {
      _showError('Please select your date of birth');
      return false;
    }
    if (_selectedMaritalStatus == null) {
      _showError('Please select your marital status');
      return false;
    }
    if (_selectedDepartment == null) {
      _showError('Please select your department');
      return false;
    }
    if (_selectedPosition == null) {
      _showError('Please select your position');
      return false;
    }
    if (_selectedEmploymentType == null) {
      _showError('Please select your employment type');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.go('/login'),
        ),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section
                _buildProfileImageSection(),
                const SizedBox(height: 30),

                // Personal Information Header
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Name Fields
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person_outline,
                        validator: Validators.name,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        validator: Validators.name,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // NIC Field
                _buildTextField(
                  controller: _nicController,
                  label: 'NIC Number',
                  icon: Icons.badge_outlined,
                  validator: Validators.nic,
                ),
                const SizedBox(height: 16),

                // Phone Field
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phoneNumber,
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                _buildDropdown(
                  label: 'Gender',
                  icon: Icons.wc_outlined,
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 16),

                // Date of Birth
                _buildDateField(),
                const SizedBox(height: 16),

                // Marital Status Dropdown
                _buildDropdown(
                  label: 'Marital Status',
                  icon: Icons.favorite_outline,
                  value: _selectedMaritalStatus,
                  items: _maritalStatuses,
                  onChanged: (value) => setState(() => _selectedMaritalStatus = value),
                ),
                const SizedBox(height: 16),

                // Address Field
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Emergency Contact Fields
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emergencyContactController,
                        label: 'Emergency Contact',
                        icon: Icons.contact_emergency_outlined,
                        validator: Validators.name,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _emergencyPhoneController,
                        label: 'Emergency Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phoneNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Employment Information Header
                const Text(
                  'Employment Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Department Dropdown
                _buildDropdown(
                  label: 'Department',
                  icon: Icons.business_outlined,
                  value: _selectedDepartment,
                  items: _departments,
                  onChanged: (value) => setState(() => _selectedDepartment = value),
                ),
                const SizedBox(height: 16),

                // Position Dropdown
                _buildDropdown(
                  label: 'Position',
                  icon: Icons.work_outline,
                  value: _selectedPosition,
                  items: _positions,
                  onChanged: (value) => setState(() => _selectedPosition = value),
                ),
                const SizedBox(height: 16),

                // Employment Type Dropdown
                _buildDropdown(
                  label: 'Employment Type',
                  icon: Icons.schedule_outlined,
                  value: _selectedEmploymentType,
                  items: _employmentTypes,
                  onChanged: (value) => setState(() => _selectedEmploymentType = value),
                ),
                const SizedBox(height: 16),

                // Base Salary Field
                _buildTextField(
                  controller: _baseSalaryController,
                  label: 'Base Salary (LKR)',
                  icon: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                  validator: Validators.salary,
                ),
                const SizedBox(height: 16),

                // EPF/ETF Fields (Optional)
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _epfController,
                        label: 'EPF Number (Optional)',
                        icon: Icons.account_balance_outlined,
                        validator: _epfController.text.isNotEmpty ? Validators.epfNumber : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _etfController,
                        label: 'ETF Number (Optional)',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Complete Profile Setup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: AppTheme.primaryColor, width: 3),
              ),
              child: _profileImage != null
                  ? ClipOval(
                      child: Image.file(
                        _profileImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add profile photo',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dateOfBirth != null
                    ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                    : 'Date of Birth',
                style: TextStyle(
                  fontSize: 16,
                  color: _dateOfBirth != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

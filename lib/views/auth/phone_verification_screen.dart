import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../controllers/auth_bloc.dart';
import '../../utils/validators.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _codeSent = false;
  String _verificationId = '';
  String _phoneNumber = '';
  int _resendTime = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSendOTP() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthPhoneVerificationRequested(phoneNumber: _phoneController.text.trim()),
      );
    }
  }

  void _handleVerifyOTP() {
    if (_otpController.text.length == 6) {
      context.read<AuthBloc>().add(
        AuthSignInWithPhoneRequested(
          phoneNumber: _phoneNumber,
          smsCode: _otpController.text,
          verificationId: _verificationId,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTime = 60;
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTime > 0) {
        setState(() => _resendTime--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
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
          } else if (state is AuthPhoneVerificationSent) {
            setState(() {
              _codeSent = true;
              _verificationId = state.verificationId;
              _phoneNumber = state.phoneNumber;
            });
            _startResendTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthAuthenticated) {
            // Redirect to profile setup if user data is incomplete
            if (state.userModel?.isProfileComplete == false) {
              context.go('/auth/profile-setup');
            } else {
              context.go('/dashboard');
            }
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: _codeSent ? _buildOTPView() : _buildPhoneView(),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          
          // Header
          const Text(
            'Phone Verification',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your phone number to receive a verification code',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 60),

          // Phone Number Field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+94 77 123 4567',
              prefixIcon: const Icon(Icons.phone, color: AppTheme.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: Validators.phoneNumber,
          ),
          const SizedBox(height: 40),

          // Send OTP Button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Send Verification Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // Back to Login Link
          Center(
            child: TextButton(
              onPressed: () => context.go('/auth/login'),
              child: RichText(
                text: const TextSpan(
                  text: 'Want to use email instead? ',
                  style: TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(
                      text: 'Sign In with Email',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        
        // Header
        const Text(
          'Enter Verification Code',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a 6-digit code to $_phoneNumber',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 60),

        // OTP Input Field
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Enter 6-digit code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            counterText: '',
          ),
          onChanged: (value) {
            if (value.length == 6) {
              _handleVerifyOTP();
            }
          },
        ),
        const SizedBox(height: 40),

        // Verify Button
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleVerifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Verify Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),

        // Resend Code
        Center(
          child: _canResend
              ? TextButton(
                  onPressed: _handleSendOTP,
                  child: const Text(
                    'Didn\'t receive the code? Resend',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Text(
                  'Resend code in $_resendTime seconds',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
        ),
        const SizedBox(height: 20),

        // Change Phone Number
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _codeSent = false;
                _otpController.clear();
              });
            },
            child: const Text(
              'Change phone number',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

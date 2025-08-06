import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_bloc.dart';
import '../config/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _listenToAuthState();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });
  }

  void _listenToAuthState() {
    // Listen to authentication state changes
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        _navigateBasedOnAuthState(authState);
      }
    });
  }

  void _navigateBasedOnAuthState(AuthState state) {
    if (!mounted) return;

    if (state is AuthAuthenticated) {
      if (state.userModel != null && state.userModel!.isProfileComplete) {
        context.go('/dashboard');
      } else {
        context.go('/profile-setup');
      }
    } else if (state is AuthUnauthenticated) {
      context.go('/login');
    } else if (state is AuthError) {
      context.go('/login');
    }
    // If still loading, stay on splash screen
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle auth state changes after initial load
        if (state is AuthAuthenticated ||
            state is AuthUnauthenticated ||
            state is AuthError) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _navigateBasedOnAuthState(state);
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo
                        AnimatedBuilder(
                          animation: _logoScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScale.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.business_center,
                                  size: 60,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Animated App Title
                        AnimatedBuilder(
                          animation: _textOpacity,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textOpacity.value,
                              child: Column(
                                children: [
                                  Text(
                                    'HR Mobile',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Human Resource Management System',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 0.5,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading Section
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading Indicator
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Loading Text
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          String loadingText = 'Initializing...';

                          if (state is AuthLoading) {
                            loadingText = 'Checking authentication...';
                          } else if (state is AuthAuthenticated) {
                            loadingText = 'Welcome back!';
                          } else if (state is AuthUnauthenticated) {
                            loadingText = 'Ready to login';
                          } else if (state is AuthError) {
                            loadingText = 'Something went wrong';
                          }

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              loadingText,
                              key: ValueKey(loadingText),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Company Info Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      Text(
                        'Made for Sri Lankan IT Companies',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sri Lanka',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard/dashboard_screen.dart';

final emailController = TextEditingController();
final passwordController = TextEditingController();

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: isMobile
          ? const _MobileLoginView()
          : const _DesktopLoginView(),
    );
  }
}

class _DesktopLoginView extends StatefulWidget {
  const _DesktopLoginView();

  @override
  State<_DesktopLoginView> createState() =>
      _DesktopLoginViewState();
}

class _DesktopLoginViewState
    extends State<_DesktopLoginView> {

  bool obscurePassword = true;



  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/login_bg.jpg',
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.45),
              ),
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/pkr_logo.png',
                          height: 50,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'P.K.R Arts College\nFor Women',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      'STAFF SALARY MANAGEMENT',
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 3,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Manage staff salaries\nwith accuracy &\ntransparency.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 54,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 600,
                      child: Text(
                        'Track staff records, calculate CL, LOP and deductions, and maintain secure salary history for the institution.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '© 2026 P.K.R Arts College for Women',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Center(
            child: SizedBox(
              width: 450,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ADMINISTRATOR SIGN-IN',
                      style: TextStyle(
                        letterSpacing: 3,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use your administrator credentials to access the payroll console.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    const Text('Email'),
                    const SizedBox(height: 10),
                    CustomTextField(
                      hintText: 'example@gmail.com',
                      controller: emailController,
                    ),

                    const SizedBox(height: 10),
                    const Text('Password'),

                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    PrimaryButton(
                      text: 'Sign In',
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Login Successful ✅'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.message ?? 'Invalid Email or Password ❌',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileLoginView extends StatelessWidget {
  const _MobileLoginView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mobile Login Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:navi_voice_app/views/signup_page.dart';

import '../constants/constants.dart';
import '../utils/constants.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isChecked = false;

 // Default value for checkbox
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Welcome!',
                    style: AppStyles.h2, // Using AppStyles for heading
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Sign in to continue',
                    style: AppStyles.t3Regular.copyWith(
                      color: const Color(0xffABAAB1), // Light grey color
                    ), // Using AppStyles for regular text
                  ),
                ),
                const SizedBox(height: 30),
                _buildStyledTextField(
                  context,
                  icon: Icons.email_outlined,
                  hintText: 'Email',
                ),
                const SizedBox(height: 20),
                _buildStyledTextField(
                  context,
                  icon: Icons.lock_outline,
                  hintText: 'Password',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? newValue) {
                         // Update checkbox state
                        setState(() {
                          isChecked = newValue ?? true;
                        });
                      },
                      activeColor: const Color(0xff6D5AE6),
                      checkColor: Colors.white, // Checkbox check color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Text(
                      'Remember me',
                      style:
                      AppStyles.t3Regular, // Using AppStyles for small text
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Sign in logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.primary, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: AppStyles.button.copyWith(
                      color: Colors.white, // Button text white
                    ), // Using AppStyles for button text
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Or Continue with',
                      style: AppStyles.t3Regular.copyWith(
                        color: const Color(0xffABAAB1),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Here you can add social media buttons if needed
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Forgot your password? ',
                      style:
                      AppStyles.t3Regular, // Using AppStyles for small text
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to SignUpPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: AppStyles.t3Regular.copyWith(
                          color: const Color(0xff6D5AE6), // Sign up text purple
                        ), // Using AppStyles for button text
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField(BuildContext context,
      {required IconData icon, required String hintText}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: AppStyles.t3Regular.copyWith(
            color: Colors.black.withOpacity(0.4), // Opaque hint text
          ),
          border: InputBorder.none,
          // No border
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
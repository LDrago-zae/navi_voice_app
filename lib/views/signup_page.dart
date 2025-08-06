import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/constants.dart'; // Assuming AppStyles is in this file

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Sign up',
                    style: AppStyles.h2, // Using AppStyles for heading
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Sign up to get started',
                    style: AppStyles.t3Regular.copyWith(
                      color: const Color(0xffABAAB1), // Light grey color
                    ), // Using AppStyles for regular text
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  context,
                  icon: Icons.person_outline,
                  hintText: 'Name',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  context,
                  icon: Icons.email_outlined,
                  hintText: 'Email',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  context,
                  icon: Icons.lock_open_rounded,
                  hintText: 'Password',
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'By continuing Sign up you agree to the following ',
                      style: AppStyles.t3Regular.copyWith(
                        color: const Color(0xffABAAB1), // Light grey color
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: AppStyles.t3Regular.copyWith(
                            color: const Color(0xff6D5AE6), // Purple color
                          ),
                        ),
                        const TextSpan(
                          text: ' without reservation',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Sign up logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sign up',
                    style: AppStyles.button.copyWith(
                      color: Colors.white, // Button text white
                    ), // Using AppStyles for button text
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 160,),
                    Text(
                      'Already have an account? ',
                      style: AppStyles.t3Regular.copyWith(
                        color: const Color(0xffABAAB1),
                      ), // Using AppStyles for small text
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Navigate to login page
                      },
                      child: Text(
                        'Log in',
                        style: AppStyles.t3Regular.copyWith(
                          color: const Color(0xff6D5AE6), // Log in text purple
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

  Widget _buildTextField(BuildContext context, {required IconData icon, required String hintText}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          border: InputBorder.none, // No border
        ),
      ),
    );
  }
}
















// import 'package:flutter/material.dart';
// import '../../Constants/fonts_style.dart'; // Assuming AppStyles is in this file
//
// class SignUpPage extends StatelessWidget {
//   const SignUpPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             Text(
//               'Sign up',
//               style: AppStyles.h2, // Using AppStyles for heading
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Sign up to get started',
//               style: AppStyles.t3Regular.copyWith(
//                 color: const Color(0xffABAAB1), // Light grey color
//               ), // Using AppStyles for regular text
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.person_outline),
//                 hintText: 'Name',
//                 hintStyle: AppStyles.t3Regular.copyWith(
//                   color: Colors.black.withOpacity(0.4), // Opaque hint text
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.email_outlined),
//                 hintText: 'Email',
//                 hintStyle: AppStyles.t3Regular.copyWith(
//                   color: Colors.black.withOpacity(0.4), // Opaque hint text
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.lock_open_rounded),
//                 hintText: 'Password',
//                 hintStyle: AppStyles.t3Regular.copyWith(
//                   color: Colors.black.withOpacity(0.4), // Opaque hint text
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//             ),
//             const SizedBox(height: 10),
//             Column(
//               children: [
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Text(
//                     'By continuing Sign up you agree to the following Terms & Conditions without reservation',
//                     style: AppStyles.t3Regular.copyWith(
//                       color: const Color(0xffABAAB1),
//                     ),
//                     textAlign: TextAlign.center,// Using AppStyles for small text
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Sign up logic
//               },
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//                 backgroundColor: const Color(0xff6D5AE6),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Text(
//                 'Sign up',
//                 style: AppStyles.button.copyWith(
//                   color: Colors.white, // Button text white
//                 ), // Using AppStyles for button text
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 160,),
//                 Text(
//                   'Already have an account?',
//                   style: AppStyles.t3Regular.copyWith(
//                     color: const Color(0xffABAAB1),
//                   ), // Using AppStyles for small text
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Navigate to login page
//                   },
//                   child: Text(
//                     'Log in',
//                     style: AppStyles.t3Regular.copyWith(
//                       color: const Color(0xff6D5AE6), // Log in text purple
//                     ), // Using AppStyles for button text
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

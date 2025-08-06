import 'package:flutter/material.dart';

import '../constants/constants.dart';


class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  PhoneVerificationScreenState createState() =>
      PhoneVerificationScreenState();
}

class PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  // List of country codes for the dropdown
  final List<String> countryCodes = ['+92', '+1', '+44', '+91', '+61'];
  String selectedCode = '+92'; // Default selected country code

  final TextEditingController _phoneController = TextEditingController();
  bool isValidNumber = true; // Validation state
  bool showValidationError = false; // Error state to show red border

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F6F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Your phone!',
              style: AppStyles.h2,
            ),
            const SizedBox(height: 10),
            Text(
              'A 4 digit security code will be sent via SMS \n'
                  'to verify your mobile number!',
              style: AppStyles.t3Regular.copyWith(
                color: const Color(0xffABAAB1), // Light grey color
              ),
            ),
            const SizedBox(height: 30),
            _buildPhoneNumberField(),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _onContinuePressed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: const Color(0xff6D5AE6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppStyles.button.copyWith(
                    color: Colors.white, // Button text white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          _buildCountryCodeDropdown(),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  _validatePhoneNumber(value);
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: showValidationError
                      ? const BorderSide(color: Colors.red) // Error border
                      : BorderSide.none, // No border by default
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: showValidationError
                      ? const BorderSide(color: Colors.red) // Error border
                      : BorderSide.none, // No border if valid
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: showValidationError
                      ? const BorderSide(color: Colors.red) // Error border
                      : const BorderSide(color: Colors.green), // Normal focus border
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red), // Error border
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red), // Error border
                ),
                hintStyle: AppStyles.t3Regular.copyWith(
                  color: Colors.black.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
                suffixIcon: isValidNumber && _phoneController.text.isNotEmpty
                    ? const Icon(Icons.check_circle_outline, color: Colors.green)
                    : null, // Show green check icon if valid
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown for country codes
  Widget _buildCountryCodeDropdown() {
    return DropdownButton<String>(
      value: selectedCode, // Currently selected country code
      underline: Container(), // No underline
      items: countryCodes.map((String code) {
        return DropdownMenuItem<String>(
          value: code,
          child: Text(
            code,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedCode = newValue ?? '+92';
        });
      },
    );
  }

  // Validate phone number and set the valid state
  void _validatePhoneNumber(String value) {
    if (value.length >= 10) {
      isValidNumber = true; // Valid number
    } else {
      isValidNumber = false; // Invalid number
    }
    showValidationError = !isValidNumber; // Show error if invalid
  }

  // Handle Continue button press
  void _onContinuePressed() {
    if (_phoneController.text.length < 10) {
      setState(() {
        showValidationError = true; // Trigger red border if number is invalid
      });
    } else {
      setState(() {
        showValidationError = false; // Reset validation state
      });
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const OtpScreen(),
      //   ),
      // );
    }
  }
}



// import 'package:barbers_app/Screens/Auth/otp_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:barbers_app/Constants/fonts_style.dart';
//
// class PhoneVerificationScreen extends StatefulWidget {
//   const PhoneVerificationScreen({super.key});
//
//   @override
//   _PhoneVerificationScreenState createState() =>
//       _PhoneVerificationScreenState();
// }
//
// class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
//   final List<String> countryCodes = ['+92', '+1', '+44', '+91', '+61'];
//   String selectedCode = '+92';
//
//   final TextEditingController _phoneController = TextEditingController();
//   bool isValidNumber = true; // Number validation
//   bool showValidationError = false; // Used to show red border if invalid
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF6F6F6),
//       appBar: AppBar(
//         backgroundColor: const Color(0xffF6F6F6),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             Text(
//               'Your phone!',
//               style: AppStyles.h2,
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'A 4 digit security code will be sent via SMS \n'
//                   'to verify your mobile number!',
//               style: AppStyles.t3Regular.copyWith(
//                 color: const Color(0xffABAAB1),
//               ),
//             ),
//             const SizedBox(height: 30),
//             _buildPhoneNumberField(),
//             const SizedBox(height: 60),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   _onContinuePressed();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 60),
//                   backgroundColor: const Color(0xff6D5AE6),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   'Continue',
//                   style: AppStyles.button.copyWith(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPhoneNumberField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 10),
//           _buildCountryCodeDropdown(),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextFormField(
//               controller: _phoneController,
//               keyboardType: TextInputType.phone,
//               onChanged: (value) {
//                 setState(() {
//                   _validatePhoneNumber(value);
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Enter number',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(
//                     color: showValidationError
//                         ? Colors.red // Red border if validation error
//                         : isValidNumber
//                         ? Colors.green // Green if valid
//                         : Colors.grey, // Default border color
//                   ),
//                 ),
//                 hintStyle: AppStyles.t3Regular.copyWith(
//                   color: Colors.black.withOpacity(0.4),
//                   fontSize: 12,
//                 ),
//                 suffixIcon: isValidNumber && _phoneController.text.isNotEmpty
//                     ? const Icon(Icons.check_circle_outline, color: Colors.green)
//                     : null, // Green check icon for valid number
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCountryCodeDropdown() {
//     return DropdownButton<String>(
//       value: selectedCode,
//       underline: Container(),
//       items: countryCodes.map((String code) {
//         return DropdownMenuItem<String>(
//           value: code,
//           child: Text(
//             code,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         );
//       }).toList(),
//       onChanged: (String? newValue) {
//         setState(() {
//           selectedCode = newValue ?? '+92';
//         });
//       },
//     );
//   }
//
//   // Validate phone number and set the valid state
//   void _validatePhoneNumber(String value) {
//     if (value.length >= 10) {
//       isValidNumber = true; // Valid number
//     } else {
//       isValidNumber = false; // Invalid number
//     }
//     showValidationError = !isValidNumber; // Show error if invalid
//   }
//
//   // Handle Continue button press
//   void _onContinuePressed() {
//     if (_phoneController.text.length < 10) {
//       setState(() {
//         showValidationError = true; // Trigger red border if number is invalid
//       });
//     } else {
//       setState(() {
//         showValidationError = false; // Reset validation state
//       });
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const OtpScreen(),
//         ),
//       );
//     }
//   }
// }

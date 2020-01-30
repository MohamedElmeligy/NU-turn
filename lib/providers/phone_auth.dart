// import 'package:flutter/material.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// enum AuthMode { Confirm, Login }

// class Auth with ChangeNotifier {
//   AuthMode _authMode = AuthMode.Login;
//   Map<String, String> _authData = {'name': '', 'phone': '', 'uid': ''};
//   bool _isLoading = false;
//   bool _signedUp = false;
//   final _phoneController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _codeController = TextEditingController();

//   String smsCode;
//   AuthCredential _authCredential;
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   String _verificationId;

//   //method 2

//   // final GoogleSignIn googleSignIn = GoogleSignIn();
//   // final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   SharedPreferences prefs;

//   bool isLoading = false;
//   bool isLoggedIn = false;
//   FirebaseUser currentUser;

//   Future<void> verifyeNumber() async {
//     final PhoneCodeSent smsCodeSent =
//         (String verificationId, [int forceResendingToken]) async {
//       this._verificationId = verificationId;
//       Fluttertoast.showToast(msg: 'Code sent to ${_phoneController.text}');
//       // print('Code sent to ${_phoneController.text}');
//     };

//     final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
//         (String verificationId) {
//       this._verificationId = verificationId;
//       setState(() {
//         _isLoading = false;
//         _switchAuthMode();
//       });
//     };

//     //called when Auto verified
//     final PhoneVerificationCompleted verificationCompleted =
//         (AuthCredential auth) {
//       _authCredential = auth;

//       firebaseAuth.signInWithCredential(_authCredential).catchError(
//         (error) {
//           setState(() {
//             _isLoading = false;
//           });

//           var errorMsg = '';
//           print(error.toString());
//           if (error.toString().contains('ERROR_INVALID_VERIFICATION_CODE'))
//             errorMsg = 'الكود غير صحيح';
//           else if (error.toString().contains('Network'))
//             errorMsg = 'تحقق من إتصال الانترنت';
//           else
//             errorMsg = 'لقد حدث خطأ، حاول لاحقًا';
//           _hasError = true;

//           errorDialog(errorMsg);
//         },
//       ).then(
//         (user) async {
//           if (user != null) {
//             // Update data to server if new user
//             print(user.additionalUserInfo.toString());
//             print(user.user.getIdToken(refresh: true));
//             // Write data to local
//             currentUser = user.user;
//             // print(user.user.providerData.toString());
//             if (user.additionalUserInfo.isNewUser) {
//               setState(() {
//                 _signedUp = true;
//                 _isLoading = false;
//               });
//             } else {
//               prefs = await SharedPreferences.getInstance();
//               await prefs.setString('id', currentUser.uid);
//               bool doc = prefs.getBool('doctor');

//               if (doc)
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             MainScreen(currentUserId: currentUser.uid)));
//               else
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => Homepage()));
//             }
//           }
//         },
//       );
//     };

//     final PhoneVerificationFailed verificationFailed =
//         (AuthException authException) {
//       print(authException.message);
//       if (authException.message.contains('blocked')) {
//         setState(() {
//           _isLoading = false;
//         });
//         errorDialog('دخول متكرر، يرجى المحاولة لاحقًا');
//       }
//     };

//     await firebaseAuth.verifyPhoneNumber(
//       phoneNumber: _authData['phone'],
//       timeout: const Duration(seconds: 2),
//       codeSent: smsCodeSent,
//       codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
//       verificationCompleted: verificationCompleted,
//       verificationFailed: verificationFailed,
//     );
//   }

//   signInManually() async {
//     _authCredential = PhoneAuthProvider.getCredential(
//         verificationId: _verificationId, smsCode: smsCode);

//     firebaseAuth.signInWithCredential(_authCredential).catchError(
//       (error) {
//         var errorMsg = '';
//         print(error.message.toString());
//         if (error.toString().contains('ERROR_INVALID_VERIFICATION_CODE'))
//           errorMsg = 'الكود غير صحيح';
//         else if (error.toString().contains('Network'))
//           errorMsg = 'تحقق من إتصال الانترنت';
//         else
//           errorMsg = 'لقد حدث خطأ، حاول لاحقًا';
//         _hasError = true;
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _codeController.clear();
//         });

//         errorDialog(errorMsg);
//       },
//     ).then((user) async {
//       if (user != null) {
//         currentUser = user.user;
//         // Check is already sign up
//         if (user.additionalUserInfo.isNewUser) {
//           setState(() {
//             _signedUp = true;
//             _isLoading = false;
//           });
//         } else {
//           prefs = await SharedPreferences.getInstance();
//           prefs.setString('id', currentUser.uid);
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       MainScreen(currentUserId: prefs.getString('id'))));
//         }
//       }
//     });
//   }

//   void _submit() async {
//     if (!_formKey.currentState.validate()) {
//       // Invalid!
//       return;
//     }
//     _formKey.currentState.save();

//     setState(() {
//       _isLoading = true;
//     });
//     if (!_signedUp) {
//       if (_authMode == AuthMode.Login) {
//         verifyeNumber();
//       } else {
//         signInManually();
//       }
//     } else {
//       if (_radioValue != 0) {
//         Navigator.push(context,
//             MaterialPageRoute(builder: (context) => UserSignup(currentUser)));
//       } else {
//         Navigator.push(context,
//             MaterialPageRoute(builder: (context) => DoctorSignup(currentUser)));
//       }
//     }
//   }

//   void _switchAuthMode() {
//     if (_authMode == AuthMode.Login) {
//       setState(() {
//         _authMode = AuthMode.Confirm;
//         _codeController.clear();
//         _hasError = false;
//       });
//     } else {
//       setState(() {
//         _authMode = AuthMode.Login;
//         _nameController.clear();
//         _phoneController.clear();
//         _hasError = false;
//       });
//     }
//   }

//   void errorDialog(String msg) {
//     showDialog(
//         context: context,
//         builder: (ctx) => Directionality(
//               textDirection: TextDirection.rtl,
//               child: AlertDialog(
//                 title: Text(
//                   'خطأ',
//                   style: TextStyle(fontSize: 20),
//                 ),
//                 content: Text(
//                   msg,
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 actions: <Widget>[
//                   FlatButton(
//                     child: Text('حسنا'),
//                     onPressed: () {
//                       Navigator.of(ctx).pop();
//                     },
//                   )
//                 ],
//               ),
//             ));
//   }
// }

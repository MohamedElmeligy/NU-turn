// import 'package:flutter/material.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// enum AuthMode { Confirm, Login }

// class Auth with ChangeNotifier {
//   final GlobalKey _formKey = GlobalKey();

//   AuthMode _authMode = AuthMode.Login;
//   Map<String, String> _authData = {'name': '', 'phone': '', 'uid': ''};

//   bool _signedUp = false;
//   bool _hasError = false;
//   bool _isLoading = false;
//   bool _isLoggedIn = false;

//   final _phoneController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _uniIdController = TextEditingController();
//   final _codeController = TextEditingController();

//   String _smsCode;
//   AuthCredential _authCredential;
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   String _verificationCode;
//   static SharedPreferences _prefs;

//   FirebaseUser _currentUser;

//   PhoneCodeSent _codeIsSent;
//   PhoneCodeAutoRetrievalTimeout _codeAutoRetrievalTimeout;
//   PhoneVerificationCompleted _verificationCompleted;
//   PhoneVerificationFailed _verificationFailed;

//   Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//     String name = _prefs.getString('name');
//     print(name);

//     // notifyListeners();
//   }

//   GlobalKey getkey(){
//     return _formKey;
//   }

//   Future<void> verifyeNumber() async {
//     _codeIsSent = (String verificationId, [int forceResendingToken]) async {
//       this._verificationCode = verificationId;
//     };

//     _codeAutoRetrievalTimeout = (String verificationId) {
//       this._verificationCode = verificationId;
//       // setState(() {
//       _isLoading = false;
//       _switchAuthMode();
//       // });
//     };

//     //called when Auto verified
//     _verificationCompleted = (AuthCredential auth) {
//       _verification(auth);
//     };

//     _verificationFailed = (AuthException authException) {
//       print(authException.message);
//       if (authException.message.contains('blocked')) {
//         // setState(() {
//         _isLoading = false;
//         // });
//         errorDialog('دخول متكرر، يرجى المحاولة لاحقًا');
//       }
//     };

//     await firebaseAuth.verifyPhoneNumber(
//       phoneNumber: _authData['phone'],
//       timeout: const Duration(milliseconds: 0),
//       codeSent: _codeIsSent,
//       codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
//       verificationCompleted: _verificationCompleted,
//       verificationFailed: _verificationFailed,
//     );
  
//   }

//   signInManually() async {
//     _verification(PhoneAuthProvider.getCredential(
//         verificationId: _verificationCode, smsCode: _smsCode));
//   }

//   void submit() async {
//     if (!_formKey.currentState.validate()) {
//       // Invalid!
//       return;
//     }
//     _formKey.currentState.save();

//     // setState(() {
//     _isLoading = true;
//     // });
//     if (!_signedUp) {
//       if (_authMode == AuthMode.Login) {
//         verifyeNumber();
//       } else {
//         signInManually();
//       }
//     }
//   }

//   void _switchAuthMode() {
//     if (_authMode == AuthMode.Login) {
//       // setState(() {
//       _authMode = AuthMode.Confirm;
//       _codeController.clear();
//       _hasError = false;
//       // });
//     } else {
//       // setState(() {
//       _authMode = AuthMode.Login;
//       _nameController.clear();
//       _phoneController.clear();
//       _hasError = false;
//       // });
//     }
//   }

//   void errorDialog(String msg) {
//     showDialog(
//       context: context,
//       builder: (ctx) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           title: Text(
//             'خطأ',
//             style: TextStyle(fontSize: 20),
//           ),
//           content: Text(
//             msg,
//             style: TextStyle(fontSize: 16),
//           ),
//           actions: <Widget>[
//             FlatButton(
//               child: Text('حسنا'),
//               onPressed: () {
//                 Navigator.of(ctx).pop();
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   void _verification(AuthCredential auth) {
//     _authCredential = auth;
//     firebaseAuth.signInWithCredential(_authCredential).catchError(
//       (error) {
//         // setState(() {
//         _isLoading = false;
//         // });

//         var errorMsg = '';
//         print(error.toString());
//         if (error.toString().contains('ERROR_INVALID_VERIFICATION_CODE'))
//           errorMsg = 'الكود غير صحيح';
//         else if (error.toString().contains('Network'))
//           errorMsg = 'تحقق من إتصال الانترنت';
//         else
//           errorMsg = 'لقد حدث خطأ، حاول لاحقًا';
//         _hasError = true;

//         errorDialog(errorMsg);
//       },
//     ).then(
//       (user) async {
//         if (user != null) {
//           // Update data to server if new user
//           print(user.additionalUserInfo.toString());
//           print(user.user.getIdToken(refresh: true));
//           // Write data to local
//           _currentUser = user.user;
//           // print(user.user.providerData.toString());
//           if (user.additionalUserInfo.isNewUser) {
//             // setState(() {
//             _signedUp = true;
//             _isLoading = false;
//             // });
//           } else {
//             await _prefs.setString('id', _currentUser.uid);
//           }
//         }
//       },
//     );
//   }


// }

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class Auth with ChangeNotifier {
  final GlobalKey _formKey = GlobalKey();

  User _user;

  bool _signedUp = false;
  bool _hasError = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _showPins = false;

  static SharedPreferences _prefs;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthCredential _authCredential;

  PhoneCodeSent _codeIsSent;
  PhoneCodeAutoRetrievalTimeout _codeAutoRetrievalTimeout;
  PhoneVerificationCompleted _verificationCompleted;
  PhoneVerificationFailed _verificationFailed;

  String _verificationCode;
  String _errorMsg;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    String name = _prefs.getString('name');
    print(name);

    // notifyListeners();
  }

  Future<void> automaticSignIn() async {
    _codeIsSent = (String verificationId, [int forceResendingToken]) async {
      this._verificationCode = verificationId;
    };

    _codeAutoRetrievalTimeout = (String verificationId) {
      this._verificationCode = verificationId;
      _showPins = true;
      notifyListeners();
    };

    //called when Auto verified
    _verificationCompleted = (AuthCredential auth) {
      _verification(auth);
    };

    _verificationFailed = (AuthException authException) {
      print(authException.message);
    };

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: _user.phone,
      timeout: const Duration(milliseconds: 0),
      codeSent: _codeIsSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      verificationCompleted: _verificationCompleted,
      verificationFailed: _verificationFailed,
    );
  }

  void manualSignIn(String code) async {
    _verification(PhoneAuthProvider.getCredential(
        verificationId: _verificationCode, smsCode: code));
  }

  void _verification(AuthCredential auth) {
    _authCredential = auth;
    firebaseAuth.signInWithCredential(_authCredential).catchError(
      (error) {
        print(error.toString());
        if (error.toString().contains('ERROR_INVALID_VERIFICATION_CODE'))
          _errorMsg = 'الكود غير صحيح';
        else if (error.toString().contains('Network'))
          _errorMsg = 'تحقق من إتصال الانترنت';
        else
          _errorMsg = 'لقد حدث خطأ، حاول لاحقًا';

        _hasError = true;
        print('error: '+ _errorMsg);
        notifyListeners();

        // errorDialog(errorMsg);
      },
    ).then(
      (user) {
        if (user != null) {
          print("signed In!!!!!!!!!!!!!!!!");
        }
      },
    );
  }

  bool getShowPins(bool autoVerified) {
    return autoVerified;
  }

  bool getShowpins() {
    return _showPins;
  }

  bool getPinHasError() {
    return _hasError;
  }

  GlobalKey getFormKey() {
    return _formKey;
  }

  String getErrorMsg() {
    return _errorMsg;
  }

  User getProfile() {
    _user.name = _prefs.getString('name');
    _user.phone = _prefs.getString('phone');
    _user.id = _prefs.getString('id');
    return _user;
  }

  void setProfile(User user) {
    _user.phone = user.phone;
    _user.name = user.name;
    _user.id = user.id;

    _prefs.setString('phone', _user.phone);
    _prefs.setString('name', _user.name);
    _prefs.setString('id', _user.id);
  }
}

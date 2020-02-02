import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class Auth with ChangeNotifier {
  Auth() {
    init();
  }
  final GlobalKey _formKey = GlobalKey();

  User user;

  bool _showDialog = false;
  bool _hasError = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _loginSuccess = false;
  bool _showPins = false;

  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  static SharedPreferences _prefs;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthCredential _authCredential;

  PhoneCodeSent _codeIsSent;
  PhoneCodeAutoRetrievalTimeout _codeAutoRetrievalTimeout;
  PhoneVerificationCompleted _verificationCompleted;
  PhoneVerificationFailed _verificationFailed;

  String _verificationCode;
  String _smsCode;
  String _errorMsg = "";

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    String _phone = _prefs.getString('phone');
    String _name = _prefs.getString('name');
    String _id = _prefs.getString('id');
    user = new User(phone: _phone, name: _name, id: _id);

    // notifyListeners();
  }

  Future<void> automaticSignIn(Function goToMap, Function errorDialog) async {
    _isLoading = true;
    notifyListeners();

    _codeIsSent = (String verificationId, [int forceResendingToken]) async {
      this._verificationCode = verificationId;
    };

    _codeAutoRetrievalTimeout = (String verificationId) {
      this._verificationCode = verificationId;
      _isLoading = false;
      _showPins = true;
      notifyListeners();
    };

    //called when Auto verified
    _verificationCompleted = (AuthCredential auth) {
      _verification(auth).then((succeeded) {
        print('excuuuuu   ');
        if (succeeded)
          goToMap();
        else
          errorDialog(_errorMsg);
      });
    };

    _verificationFailed = (AuthException authException) {
      print(authException.message);
      _isLoading = false;

      _errorMsg = "Tried Logging in frequently, please try again later!";
      errorDialog(_errorMsg);
      notifyListeners();
      _loginSuccess = false;
    };

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: user.phone,
      timeout: const Duration(milliseconds: 0),
      codeSent: _codeIsSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      verificationCompleted: _verificationCompleted,
      verificationFailed: _verificationFailed,
    );
  }

  Future<void> manualSignIn(Function goToMap, Function errorDialog) async {
    _isLoading = true;
    notifyListeners();

    _verification(
      PhoneAuthProvider.getCredential(
          verificationId: _verificationCode, smsCode: _smsCode),
    ).then((succeeded) {
      print('excuuuuu   ');
      if (succeeded)
        goToMap();
      else
        errorDialog(_errorMsg);
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> _verification(AuthCredential auth) async {
    _authCredential = auth;
    await firebaseAuth.signInWithCredential(_authCredential).catchError(
      (error) {
        print(error.toString());
        if (error.toString().contains('ERROR_INVALID_VERIFICATION_CODE')) {
          _errorMsg = 'Invalid Code';
          _hasError = true;
        } else if (error.toString().contains('ERROR_NETWORK_REQUEST_FAILED'))
          _errorMsg = 'Network Error!';
        else
          _errorMsg = 'Error, please try again later!';

        print('error: ' + _errorMsg);

        _isLoading = false;
        notifyListeners();
        _loginSuccess = false;
      },
    ).then(
      (_user) {
        if (_user != null) {
          user.uid = _user.user.uid;
          _isLoading = false;
          notifyListeners();
          _loginSuccess = true;
          print("success");
          _loginSuccess = true;
        }
      },
    );
    return _loginSuccess;
  }

  bool getShowpins() {
    return _showPins;
  }

  bool getPinHasError() {
    return _hasError;
  }

  bool getLoginSuccess() {
    return _loginSuccess;
  }

  bool getIsLoading() {
    return _isLoading;
  }

  GlobalKey getFormKey() {
    return _formKey;
  }

  String getErrorMsg() {
    return _errorMsg;
  }

  User getProfile() {
    user.name = _prefs.getString('name');
    user.phone = _prefs.getString('phone');
    user.id = _prefs.getString('id');
    return user;
  }

  TextEditingController getPhoneController() {
    return _phoneController;
  }

  TextEditingController getNameController() {
    return _nameController;
  }

  TextEditingController getIdController() {
    return _idController;
  }

  String getSmsCode() {
    return _smsCode;
  }

  void setSmsCode(String code) {
    _smsCode = code;
  }

  bool getShowDialog() {
    return _showDialog;
  }

  void setShowDialog(bool showDialog) {
    _showDialog = showDialog;
  }

  void setProfile(User user) {
    user.phone = user.phone;
    user.name = user.name;
    user.id = user.id;
    _prefs.setString('phone', user.phone);
    _prefs.setString('name', user.name);
    _prefs.setString('id', user.id);
  }

  void signout() {
    _prefs.clear();
  }
}

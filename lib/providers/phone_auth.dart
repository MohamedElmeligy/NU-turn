import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class Auth with ChangeNotifier {
  Auth() {
    init();
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static User _user;

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
    _user = new User(phone: _phone, name: _name, id: _id);

    // notifyListeners();
  }

  Future<void> automaticSignIn() async {
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
      _verification(auth);
    };

    _verificationFailed = (AuthException authException) {
      print(authException.message);
      _isLoading = false;
      _showDialog = true;
      _errorMsg = "Tried Logging in frequently, please try again later!";
      notifyListeners();
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

  Future<void> manualSignIn() async {
    _isLoading = true;
    notifyListeners();
    await _verification(PhoneAuthProvider.getCredential(
        verificationId: _verificationCode, smsCode: _smsCode));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _verification(AuthCredential auth) {
    _authCredential = auth;
    firebaseAuth.signInWithCredential(_authCredential).catchError(
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
        _showDialog = true;
        _isLoading = false;
        notifyListeners();

        // errorDialog(errorMsg);
      },
    ).then(
      (data) {
        if (data != null) {
          _user.userId = data.user.uid;
          _prefs.setString('userId', _user.userId);
          _isLoading = false;
          _loginSuccess = true;
          notifyListeners();
        }
      },
    );
  }

  Future<bool> getIsLoggedIn() async {
    _prefs = await SharedPreferences.getInstance();
    String x = _prefs.getString('phone');
    if (x != null)
      _isLoggedIn = true;
    else
      _isLoggedIn = false;
    return _isLoggedIn;
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
    _user.name = _prefs.getString('name');
    _user.phone = _prefs.getString('phone');
    _user.id = _prefs.getString('id');
    return _user;
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
    _user.phone = user.phone;
    _user.name = user.name;
    _user.id = user.id;
    _prefs.setString('phone', _user.phone);
    _prefs.setString('name', _user.name);
    _prefs.setString('id', _user.id);
  }

  void signout() {
    _prefs.clear();
  }
}

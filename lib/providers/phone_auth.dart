import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class Auth with ChangeNotifier {
  Auth() {
    init();
  }
  final GlobalKey _formKey = GlobalKey();

  static User _user;

  bool _hasError = false;
  bool _isLoading = false;
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

  Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();
    String _phone = _prefs.getString('phone');
    String _name = _prefs.getString('name');
    String _id = _prefs.getString('id');
    String _identity = _prefs.getString('identity');
    _user = new User(phone: _phone, name: _name, id: _id, identity: _identity);

    if (_prefs.containsKey('phone'))
      return true;
    else
      return false;

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
      phoneNumber: _user.phone,
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
      (result) {
        if (result != null) {
          _user.uid = result.user.uid;
          _prefs.setString('uid', _user.uid);
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

  String getIdentity() {
    return _user.identity;
    // set student pin info 'myPinInfo'
  }

  User getUser() {
    print(_user);
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

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
  }

  void setSmsCode(String code) {
    _smsCode = code;
  }

  void setProfile(User newUser) async {
    print(newUser.phone);
    _user.phone = newUser.phone;
    _user.name = newUser.name;
    _user.id = newUser.id;
    _prefs.setString('phone', _user.phone);
    _prefs.setString('name', _user.name);
    _prefs.setString('id', _user.id);

    Firestore dbRef = new Firestore();
    await dbRef
        .collection('licencedDrivers')
        .document(_user.phone)
        .get()
        .then((result) {
      if (result.exists) {
        _user.identity = "driver";
        _prefs.setString('identity', 'driver');
      } else {
        _prefs.setString('identity', 'student');
      }
    });
  }

  void signout() {
    _prefs.clear();
  }
}

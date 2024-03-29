import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

import '../models/user.dart';

import './map_screen.dart';
import '../components/custom_dialog.dart';

import '../providers/phone_auth.dart';

class LoginPage extends StatelessWidget {
  static const routeName = '/auth';
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider<Auth>(
      create: (ctx) => Auth(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Consumer<Auth>(
          builder: (ctx, auth, ch) {
            Key _form = auth.getFormKey();
            FormState _formState = auth.getFormKey().currentState;

            TextEditingController _phoneController = auth.getPhoneController();
            TextEditingController _nameController = auth.getNameController();
            TextEditingController _idController = auth.getIdController();

            String _name, _phone, _id;

            bool _loading = auth.getIsLoading();
            bool _showPins = auth.getShowpins();
            bool _pinHasError = auth.getPinHasError();
            bool _buttonDisabled = auth.getButtonDisabled();

            void goToMap() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(),
                ),
              );
              auth.setIsLoading(false);
              auth.setButtonDisabled(false);
              // auth.setIsLoading(false);
            }

            void errorDialog(String msg) {
              auth.setIsLoading(false);
              auth.setButtonDisabled(false);
              showDialog(
                  context: context,
                  builder: (ctx) => CustomDialog(
                        title: "Error",
                        description: msg,
                        positiveButtonText: "back",
                        negativeButtonText: "ok",
                        image: Image.asset("assets/cross.png"),
                      ));
              // auth.setIsLoading(false);
            }

            void submit() async {
              if (!_formState.validate()) {
                // Invalid!
                return;
              }

              _formState.save();
              auth.setButtonDisabled(true);
              if (!_showPins) {
                User user = new User(phone: "+2$_phone", name: _name, id: _id);
                auth.setProfile(user);
              }

              if (!_showPins) {
                auth.automaticSignIn(goToMap, errorDialog);
              } else {
                auth.manualSignIn(goToMap, errorDialog);
              }
            }

            _getSignIn(context) {
              return Container(
                height: screenHeight * 0.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Sign in',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                    InkWell(
                      onTap: () {
                        if (!_buttonDisabled) {
                          print("clicked");
                          submit();
                        }
                      },
                      onDoubleTap: () {
                        print('double');
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade800,
                        radius: 40,
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }

            _getTextFields() {
              return Container(
                height: screenHeight * 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      validator: (value) {
                        if (value.length != 11) {
                          return 'Invalid Number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Phone'),
                      onChanged: (value) {
                        _phone = value;
                      },
                      onSaved: (value) {
                        _phone = value;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value.length < 5) {
                          return 'Please Enter Full Name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (value) {
                        _name = value;
                      },
                      onSaved: (value) {
                        _name = value;
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: _idController,
                      validator: (value) {
                        if (value.length != 8 && value.length != 7) {
                          return 'Invalid ID';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'University ID',
                        helperText: "Your 8 or 7 digits ID",
                      ),
                      onChanged: (value) {
                        _id = value;
                      },
                      onSaved: (value) {
                        _id = value;
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              );
            }

            _getPinField() {
              return Container(
                padding: EdgeInsets.only(top: 70),
                margin: EdgeInsets.only(left: 30),
                height: screenHeight * 0.45,
                child: Center(
                  child: Container(
                    height: 70,
                    child: PinCodeTextField(
                      pinBoxWidth: 30,
                      pinBoxHeight: 50,
                      autofocus: true,
                      highlight: true,
                      highlightColor: Colors.blue,
                      defaultBorderColor: Colors.black,
                      hasTextBorderColor: Colors.blue,
                      hasError: _pinHasError,
                      maxLength: 6,
                      pinTextAnimatedSwitcherTransition:
                          ProvidedPinBoxTextAnimation.scalingTransition,
                      pinTextAnimatedSwitcherDuration:
                          Duration(milliseconds: 200),
                      highlightAnimationBeginColor: Colors.blue,
                      highlightAnimationEndColor: Colors.black87,
                      highlightAnimationDuration: Duration(milliseconds: 1000),
                      keyboardType: TextInputType.phone,
                      onDone: (String s) {
                        auth.setSmsCode(s);
                      },
                    ),
                  ),
                ),
              );
            }

            _getCircle() {
              return Container(
                height: screenHeight * 0.5,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            _getHeader() {
              return Container(
                height: screenHeight * 0.3,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Welcome\nBack',
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                ),
              );
            }

            return WillPopScope(
              onWillPop: () async {
                if (_showPins) {
                  auth.setShowPins(false);
                }
                return false;
              },
              child: Scaffold(
                backgroundColor: Colors.grey.shade100,
                body: Container(
                  height: screenHeight,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _form,
                      child: CustomPaint(
                        painter: BackgroundSignIn(),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 35),
                              child: Column(
                                children: <Widget>[
                                  _getHeader(),
                                  _loading
                                      ? _getCircle()
                                      : !_showPins
                                          ? _getTextFields()
                                          : _getPinField(),
                                  _getSignIn(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BackgroundSignIn extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var sw = size.width;
    var sh = size.height;
    var paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, sw, sh));
    paint.color = Colors.grey.shade100;
    canvas.drawPath(mainBackground, paint);

    Path blueWave = Path();
    blueWave.lineTo(sw, 0);
    blueWave.lineTo(sw, sh * 0.5);
    blueWave.quadraticBezierTo(sw * 0.5, sh * 0.45, sw * 0.2, 0);
    blueWave.close();
    paint.color = Colors.lightBlue.shade300;
    canvas.drawPath(blueWave, paint);

    Path greyWave = Path();
    greyWave.lineTo(sw, 0);
    greyWave.lineTo(sw, sh * 0.1);
    greyWave.cubicTo(
        sw * 0.95, sh * 0.25, sw * 0.65, sh * 0.15, sw * 0.6, sh * 0.38);
    greyWave.cubicTo(sw * 0.52, sh * 0.52, sw * 0.05, sh * 0.45, 0, sh * 0.4);
    greyWave.close();
    paint.color = Colors.grey.shade800;
    canvas.drawPath(greyWave, paint);

    Path yellowWave = Path();
    yellowWave.lineTo(sw * 0.7, 0);
    yellowWave.cubicTo(
        sw * 0.6, sh * 0.05, sw * 0.27, sh * 0.01, sw * 0.18, sh * 0.12);
    yellowWave.quadraticBezierTo(sw * 0.12, sh * 0.2, 0, sh * 0.2);
    yellowWave.close();
    paint.color = Colors.orange.shade300;
    canvas.drawPath(yellowWave, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

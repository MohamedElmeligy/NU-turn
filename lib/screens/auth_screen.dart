import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

import '../models/user.dart';
import './map_screen.dart';
import '../providers/phone_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<Auth>(
        builder: (ctx, auth, ch) {
          Key _form = auth.getFormKey();
          FormState _formState = auth.getFormKey().currentState;

          TextEditingController _phoneController = new TextEditingController();
          TextEditingController _nameController = new TextEditingController();
          TextEditingController _idController = new TextEditingController();

          User _user;

          bool _loading;
          bool _showPins = auth.getShowpins();
          bool _pinHasError = auth.getPinHasError();
          String _errorMsg = auth.getErrorMsg();

          void submit() async {
            if (!_formState.validate()) {
              // Invalid!
              return;
            }
            _formState.save();
            setState(() {
              _loading = true;
            });
            auth.setProfile(_user);
            auth.automaticSignIn();
            setState(() {
              _loading = false;
            });

            // if (true) {
            //   auth.verifyeNumber();
            // } else {
            //   auth.signInManually();
            // }
          }

          void errorDialog(String msg) {
            showDialog(
              context: context,
              builder: (ctx) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text(
                    'خطأ',
                    style: TextStyle(fontSize: 20),
                  ),
                  content: Text(
                    msg,
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('حسنا'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ),
              ),
            );
          }

          _getTextFields() {
            return Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    validator: (value) {
                      if (value.length != 11) {
                        return 'Invalid Number';
                      }
                    },
                    decoration: InputDecoration(labelText: 'Phone'),
                    onChanged: (value) {
                      _user.phone = value;
                      print("dsssssss");
                      print(_user.phone);
                    },
                    onSaved: (value) {
                      _user.phone = value;
                      print("dsssssss");
                      print(_user.phone);
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
                    },
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      _user.name = value;
                      print(_user.name);
                    },
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: _idController,
                    validator: (value) {
                      if (value.length != 8) {
                        return 'Invalid ID';
                      }
                    },
                    decoration: InputDecoration(labelText: 'University ID'),
                    onChanged: (value) {
                      _user.id = value;
                      print(_user.id);
                    },
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            );
          }

          _getSignIn(context) {
            return Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Sign in',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                    onTap: () {
                      submit();
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

          _getPinField() {
            return Center(
              child: PinCodeTextField(
                pinBoxWidth: 30,
                pinBoxHeight: 50,
                autofocus: true,
                highlight: true,
                highlightColor: Colors.blue,
                defaultBorderColor: Colors.black,
                hasTextBorderColor: Colors.green,
                hasError: _pinHasError,
                maxLength: 6,
                pinTextAnimatedSwitcherTransition:
                    ProvidedPinBoxTextAnimation.scalingTransition,
                pinTextAnimatedSwitcherDuration: Duration(milliseconds: 200),
                highlightAnimationBeginColor: Colors.blue,
                highlightAnimationEndColor: Colors.black87,
                highlightAnimationDuration: Duration(milliseconds: 1000),
                keyboardType: TextInputType.phone,
                onDone: (String s) {
                  auth.manualSignIn(s);
                },
              ),
            );
          }

          return Container(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _form,
              child: CustomPaint(
                painter: BackgroundSignIn(),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        children: <Widget>[
                          _getHeader(),
                          !_showPins ? _getTextFields() : _getPinField(),
                          _getSignIn(context),
                          _getBottomRow(),
                        ],
                      ),
                    ),
                    // _loading
                    //     ? Center(child: CircularProgressIndicator())
                    //     : Container(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

_getBottomRow() {
  return Expanded(
    flex: 1,
    child: SizedBox(),
  );
}

_getHeader() {
  return Expanded(
    flex: 3,
    child: Container(
      alignment: Alignment.bottomLeft,
      child: Text(
        'Welcome\nBack',
        style: TextStyle(color: Colors.white, fontSize: 40),
      ),
    ),
  );
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

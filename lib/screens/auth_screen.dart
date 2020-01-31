import 'package:flutter/material.dart';

import './map_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: BackgroundSignIn(),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                children: <Widget>[
                  _getHeader(),
                  _getTextFields(),
                  _getSignIn(context),
                  _getBottomRow(),
                ],
              ),
            ),
          ],
        ),
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MapScreen()));
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
  return Expanded(
    flex: 4,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: 15,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Phone'),
        ),
        SizedBox(
          height: 15,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Name'),
        ),
        SizedBox(
          height: 25,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'University ID'),
        ),
        SizedBox(
          height: 25,
        ),
      ],
    ),
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

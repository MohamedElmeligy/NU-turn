import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title, description, positiveButtonText, negativeButtonText;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.positiveButtonText,
    @required this.negativeButtonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    double padding = 0.06 * MediaQuery.of(context).size.width;
    double avatarRadius = 0.1 * MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: avatarRadius + padding,
              bottom: padding,
              left: padding,
              right: padding,
            ),
            margin: EdgeInsets.symmetric(vertical: avatarRadius),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                            "Back"); // To close the dialog and go to home screen
                      },
                      child: Text(
                        negativeButtonText,
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.grey.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.2 * padding),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                            "My Profile"); // To close the dialog and go to the user's profile
                      },
                      child: Text(
                        positiveButtonText,
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.2 * padding),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: padding,
            right: padding,
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: avatarRadius,
              child: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 1.0 * avatarRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

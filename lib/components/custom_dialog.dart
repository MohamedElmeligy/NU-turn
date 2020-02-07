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
    double avatarRadius = 0.15 * MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 0.05 * MediaQuery.of(context).size.height,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop("Okay"); // To close the dialog
                        },
                        child: Text(
                          positiveButtonText,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.2 * padding),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            height: 2.0 * avatarRadius,
            child: Image.asset(
              "assets/happy.png",
              // height: avatarRadius,
            ),
          ),
        ],
      ),
    );
  }
}

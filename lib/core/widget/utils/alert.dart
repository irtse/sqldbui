import 'package:flutter/material.dart';

class AlertWidget extends StatefulWidget {
  Widget widget; 
  Color color = Colors.white;
  AlertWidget ({ super.key, required this.widget, this.color = Colors.white });
  @override AlertWidgetState createState() => AlertWidgetState();
}
class AlertWidgetState extends State<AlertWidget> {
  @override Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.color, // Dark background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3), // Rounded corners
      ),
      content: Padding(padding: EdgeInsets.all(20), 
        child: widget.widget,
      )
    );
  }
}
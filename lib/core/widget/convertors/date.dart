import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form.dart';

class DateWidget extends StatefulWidget {
  final FormWidgetState component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  dynamic value;
  final String label;
  final String type;
  DateWidget ({ Key? key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.type, required this.value, required this.label,
                      required this.component}): super(key: key);
  @override
  _DateState createState() => _DateState();
}
class _DateState extends State<DateWidget> {
  @override Widget build(BuildContext context) {
    var date = DateTime.now();
      DateTime dateValue = DateTime.now();
      if (widget.form[widget.name] != null) { 
        widget.value = widget.form[widget.name]; 
        dateValue = DateTime.parse(widget.value);
      } else { widget.form[widget.name]=date.toIso8601String(); }
      return DateTimeField(
        mode: widget.type == "time" ? DateTimeFieldPickerMode.time : DateTimeFieldPickerMode.date,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
            helperStyle: const TextStyle(height: -2),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
            hintStyle: const TextStyle(fontSize: 12, ),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.only(top: 1, left: 20.0, right: 20.0, bottom: 20),
            hintText: "enter your ${widget.label.toLowerCase()}",
            labelText: widget.label.toLowerCase(),
          ),
        value: dateValue,
        lastDate: DateTime(date.year + 1, date.month, date.day),
        onChanged: (DateTime? value) { 
          widget.component.widget.detectChange = true;
          setState(() {
            dateValue=value!; 
            widget.form[widget.name]=value.toIso8601String(); 
          });
        },
      );
  }
}
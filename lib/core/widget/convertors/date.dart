import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:sqldbui2/core/widget/form.dart';

class DateWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool require;
  final bool readOnly;
  dynamic value;
  final String label;
  final String type;
  DateWidget ({ Key? key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.type, required this.value, required this.label,
                      required this.component, this.require = false}): super(key: key);
  @override
  _DateState createState() => _DateState();
}
class _DateState extends State<DateWidget> {
  @override Widget build(BuildContext context) {
    var date = DateTime.now();
      DateTime? dateValue;
      if (widget.form[widget.name] != null) { 
        widget.value = widget.form[widget.name]; 
        dateValue = DateTime.parse(widget.value);
      }
      return DateTimeField(
        dateFormat: intl.DateFormat('y-M-dd'),
        mode: widget.type == "time" ? DateTimeFieldPickerMode.time : DateTimeFieldPickerMode.date,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_month, size: 20,),
            suffixIconColor: Theme.of(context).primaryColor,
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
            helperStyle: const TextStyle(height: -2),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
            hintStyle: const TextStyle(fontSize: 12, ),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.only(top: 1, left: 20.0, right: 20.0, bottom: 20),
            hintText: "enter ${widget.schemaName.replaceAll("_", " ").replaceAll("db", "")} ${widget.label.toLowerCase()}",
            labelText: "${widget.label.toLowerCase()}${widget.require ? '*' : ''}",
          ),
        value: dateValue,
        lastDate: DateTime(date.year + 10, date.month, date.day),
        onChanged: (DateTime? value) { 
          widget.component?.widget.detectChange = true;
          setState(() {
            dateValue=value!; 
            widget.form[widget.name]=value.toIso8601String(); 
          });
        },
      );
  }
}

class DateSaveTimeField extends DateTimeField {
  VoidCallback? onSaved;
  DateSaveTimeField({required DateTime? value, required DateTime? lastDate, required DateTimeFieldPickerMode mode, required intl.DateFormat dateFormat, required InputDecoration decoration, required TextStyle style, required void Function(DateTime?) onChanged})
      : super(value: value, lastDate: lastDate, mode: mode, dateFormat: dateFormat, decoration: decoration, style: style, onChanged: onChanged);
}
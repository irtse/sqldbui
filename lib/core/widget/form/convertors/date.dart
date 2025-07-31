import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
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
  final dynamic autofill;
  DateWidget ({ super.key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.type, required this.value, required this.label,
                      required this.component, this.require = false, required this.autofill});
  @override
  // ignore: library_private_types_in_public_api
  _DateState createState() => _DateState();
}
class _DateState extends State<DateWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
      DateTime? dateValue;
      var label = "${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}${widget.require ? '*' : ''}";
      try {
        label = await getOnFlow(label);
      } catch(e) {}
      try {
        TranslateConstants.selectDate = TranslateConstants.selectDate.toLowerCase();
      } catch(e) {}
      if (widget.form[widget.name] != null) { 
        widget.value = widget.form[widget.name]; 
      }
      if (widget.value != null) {
        dateValue = DateTime.parse(widget.value);
        widget.form[widget.name]=widget.value;
      } else if (widget.autofill != null) {
        dateValue = DateTime.parse("${widget.autofill}");
        widget.form[widget.name]=widget.autofill;
      }
      if (widget.readOnly) {
        return SizedBox(width: 400, height: 30, child: TextFormField(
          readOnly: true,
          initialValue: widget.value != null ? "${widget.value}" 
            : (widget.autofill != null ? "${widget.autofill}" : (widget.readOnly ? TranslateConstants.empty : null)),
          style: TextStyle(fontSize: 14, color: Colors.black),
         decoration: InputDecoration(
            filled: true,
            suffixIcon:  widget.type.contains("enum") ? Icon(Icons.format_list_numbered, color: Theme.of(context).secondaryHeaderColor) 
                        : Icon(Icons.calendar_month, color: Theme.of(context).primaryColor,),
            errorStyle: const TextStyle(height: -2),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor: widget.readOnly ? Theme.of(context).splashColor : (Colors.white),
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
            border: const OutlineInputBorder(),
            labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
            hintText: (await getOnFlow( TranslateConstants.selectDate)).toLowerCase(),
            labelText: label.toLowerCase(),
          ) ));
      }
      return DateTimeField(
        validator: (DateTime? value) {
          if (widget.require && value == null) { return ""; }
          return null;
        },
        initialValue: dateValue,
        format: intl.DateFormat('y-M-dd'),
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_month, size: 20,),
            suffixIconColor: widget.readOnly ? Colors.black : Theme.of(context).primaryColor,
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
            disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            helperStyle: const TextStyle(height: -2),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            errorStyle: const TextStyle(fontSize: 0),
            fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
            border: OutlineInputBorder(borderSide: BorderSide(color:Theme.of(context).splashColor, width: 1.0)),
            contentPadding: const EdgeInsets.only(top: 1, left: 20.0, right: 20.0, bottom: 20),
            hintText: (await getOnFlow(TranslateConstants.selectDate)).toLowerCase(),
            labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
            labelText: label.toLowerCase().toLowerCase(),
          ),
        onShowPicker: (context, currentValue) { return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: dateValue ?? currentValue,
              lastDate: DateTime(2100));
        },
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

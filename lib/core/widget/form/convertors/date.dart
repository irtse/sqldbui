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
      if (widget.form[widget.name] != null) { 
        widget.value = widget.form[widget.name]; 
      }
      if (widget.value != null) {
        dateValue = DateTime.parse(widget.value);
      } else if (widget.autofill != null) {
        dateValue = DateTime.parse("${widget.autofill}");
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
            hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
            border: const OutlineInputBorder(),
            labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
            contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
            hintText: ("${TranslateConstants.enter} ${await getOnFlow(widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase())}").toLowerCase(),
            labelText: (await getOnFlow("${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}${widget.require ? '*' : ''}")).toLowerCase(),
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
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
            helperStyle: const TextStyle(height: -2),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            errorStyle: const TextStyle(fontSize: 0),
            fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
            hintStyle: const TextStyle(fontSize: 12, ),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.only(top: 1, left: 20.0, right: 20.0, bottom: 20),
            hintText: ("${TranslateConstants.enter} ${await getOnFlow(widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase())}").toLowerCase(),
            labelText: (await getOnFlow("${widget.label.toLowerCase()}${widget.require ? '*' : ''}")).toLowerCase(),
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

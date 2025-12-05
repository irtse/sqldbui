import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

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
  dynamic autofill;
  DateWidget ({required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.type, required this.value, required this.label,
                      required this.component, this.require = false, required this.autofill}): super(key: GlobalKey<State<DateWidget>>());
  @override
  // ignore: library_private_types_in_public_api
  _DateState createState() => _DateState();
}
class _DateState extends State<DateWidget> {
  @override Widget build(BuildContext context) {
    if ((widget.component?.widget.view?.rules ?? []).where( (r) => r.trigger == widget.name).isNotEmpty) {
      for (var r in (widget.component?.widget.view?.rules ?? [])) {
        if (r.trigger == widget.name) {
          r.key = widget.key as GlobalKey<State<DateWidget>>;
        }
      }
    }
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
      try {  label = await getOnFlow(label);
      } catch(e) {}
      widget.value = widget.form[widget.name] ?? widget.value ?? widget.autofill; 
      if (widget.value != null) {
        dateValue = DateTime.parse(widget.value);
        saveChange(widget.component?.widget.view, widget.form, widget.name, widget.value);
      } else if (widget.autofill != null) {
        dateValue = DateTime.parse("${widget.autofill}");
        saveChange(widget.component?.widget.view, widget.form, widget.name, widget.autofill);
      }
      
      DateTime dateMin = DateTime(1900);
      DateTime dateMax = DateTime(2100);
      for (var r in (widget.component?.widget.view?.rules ?? [])) {
        if (r.trigger == widget.name) {
          for (var v in r.value.where( (e) => e != null )) {
            if (v.toString().toLowerCase().contains("now") || v.toString().toLowerCase().contains("current_date")) {
              var b = DateTime.now();
              if (r.min) {
                  if (dateMin.isBefore(b)) {
                    dateMin = b;
                  }
                }
                if (r.max) {
                  if (dateMax.isAfter(b)) {
                    dateMax = b;
                  }
                }
            } else {
              var s = v.toString().split("(").last.replaceAll("'", "").replaceAll(")", "");
              var val = widget.form[s] ?? v?.toString() ?? "";
              if (DateTime.tryParse(val) != null) {
                var b = DateTime.parse(val);
                if (r.min) {
                  if (dateMin.isBefore(b)) {
                    dateMin = b;
                  }
                }
                if (r.max) {
                  if (dateMax.isAfter(b)) {
                    dateMax = b;
                  }
                }
              }
            }
          }
        }
      }
      if (dateValue?.isBefore(dateMin) ?? false) {
        dateMin = dateValue!;
      }
      var v = widget.value != null ? "${widget.value}"
            : (widget.autofill != null ? "${widget.autofill}" : "");
      if (widget.readOnly) {
       var focusNode = FocusNode();

       GestureDetector( onLongPress:  () {
         FocusScope.of(context).requestFocus(focusNode);
         copyToClipboard(v, context);
       },  child : Tooltip( message:  widget.value != null ? "${widget.value}"
            : (widget.autofill != null ? "${widget.autofill}" : (widget.readOnly ? (await getOnFlow(TranslateConstants.empty)) : null)), child: SizedBox(width: 400, height: 30, 
            child: TextFormField( focusNode: focusNode,
          readOnly: true,
          initialValue: widget.value != null ? "${widget.value}" 
            : (widget.autofill != null ? "${widget.autofill}" : (
              widget.readOnly ? (await getOnFlow(TranslateConstants.empty)) : null)),
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
            labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
            hintText: (await getOnFlow(TranslateConstants.selectDate)).toLowerCase(),
            labelText: label.toLowerCase(),
          ) ))));
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
            labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
            labelText: label.toLowerCase(),
          ),
        onShowPicker: (context, currentValue) { return showDatePicker(
              context: context,
              firstDate: dateMin, // MIN OR MAX
              initialDate: dateValue ?? currentValue,
              lastDate: dateMax);
        },
        onChanged: (DateTime? value) { 
          setState(() {
            dateValue=value!; 
            saveChange(widget.component?.widget.view, widget.form, widget.name, value.toIso8601String());
          });
        },
      );
  }
}

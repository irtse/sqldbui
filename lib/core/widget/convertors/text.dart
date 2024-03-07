
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:sqldbui2/core/widget/form.dart';

class TextWidget extends StatefulWidget {
  final FormWidgetState component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String type;
  final String label;
  TextWidget ({ Key? key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.component}): super(key: key);
  @override
  _TextState createState() => _TextState();
}
class _TextState extends State<TextWidget> {
  @override Widget build(BuildContext context) {
    if (widget.form[widget.name] != null) { widget.value = widget.form[widget.name]; }
          if ((widget.type.contains("time") || widget.type.contains("date")) && widget.value != null) {
            widget.value = '${widget.value}'.substring(0,10);
          }
          return TextFormField(
              readOnly: widget.readOnly,
              initialValue: widget.value ?? "",
              maxLines: widget.type.contains("text") ? 100 : null,
              style: const TextStyle(fontSize: 14,),
              enabled: true,
              autocorrect: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                hintStyle: const TextStyle(fontSize: 12), // you need this
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
                contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
                suffixIcon: widget.type.contains("time") || widget.type.contains("date") ? const Icon(Icons.calendar_month) : const Icon(Icons.text_fields),
                hintText: "enter your ${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}",
                labelText: "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}",
                errorStyle: const TextStyle(fontSize: 0,),
              ),
              onChanged: (String? value) {
                widget.component.widget.detectChange = true;
                widget.form[widget.name]=value;
              },
              onSaved: (String? value) => widget.form[widget.name]=value,
              validator: (String? value) {
                var t = (value == null || value.isEmpty) && widget.require ? 'enter a proper value.' : null;
                return t;
              },
            );
  }
}

import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form.dart';

// ignore: must_be_immutable
class TextWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String type;
  final String label;
  bool isDark = false;
  TextWidget ({ Key? key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.component, this.isDark = false}): super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _TextState createState() => _TextState();
}
class _TextState extends State<TextWidget> {
  @override Widget build(BuildContext context) {
    if (widget.form[widget.name] != null) { widget.value = widget.form[widget.name]; }
          if ((widget.type.contains("time") || widget.type.contains("date")) && widget.value != null) {
            widget.value = '${widget.value}'.substring(0,10);
          }
          return TextFormField(
              obscureText: widget.type.contains("password") || widget.label.contains("password") ? true : false,
              readOnly: widget.readOnly,
              initialValue: widget.value ?? "",
              maxLines:  (widget.type.contains("text") && !widget.label.contains("password") ? 100 : 1),
              style: TextStyle( fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Theme.of(context).secondaryHeaderColor),
              enabled: true,
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.isDark ? Theme.of(context).splashColor : Colors.grey, width: 1.0)),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIconColor: Theme.of(context).primaryColor,
                hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: widget.readOnly ? Theme.of(context).splashColor : (widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
                contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, 
                  top: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0,
                  bottom: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0),
                suffixIcon: widget.type.contains("time") || widget.type.contains("date") ? const Icon(Icons.calendar_month, size: 20) : Icon(Icons.text_fields, color:  widget.isDark ? Theme.of(context).splashColor : Theme.of(context).primaryColor,),
                hintText: "enter ${widget.schemaName.replaceAll("_", " ").replaceAll("db", "")} ${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}...",
                labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
                labelText: "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}",
                errorStyle: const TextStyle(fontSize: 0,),
              ),
              onChanged: (String? value) {
                widget.component?.widget.detectChange = true;
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
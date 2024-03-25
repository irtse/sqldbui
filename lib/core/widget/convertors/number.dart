
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:sqldbui2/core/widget/form.dart';

class NumberWidget extends StatefulWidget {
  final FormWidgetState component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String type;
  final String label;
  NumberWidget ({ Key? key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.component}): super(key: key);
  @override
  _NumberState createState() => _NumberState();
}
class _NumberState extends State<NumberWidget> {
  @override Widget build(BuildContext context) {
    if (widget.form[widget.name] != null) { 
      widget.value = widget.form[widget.name]; 
    }
    func(String? value) {
      try {
        if (value == null) { widget.form[widget.name]=null;
        } else if (widget.type.contains("int")) { 
          widget.form[widget.name]=int.parse(value);
        } else { widget.form[widget.name]=double.parse(value); }
      } catch (e) { /* empty and proud to be */}
    }
    return SizedBox(width: 300, height: 30, child: TextFormField(
          readOnly: widget.readOnly,
          initialValue: widget.value != null ? "${widget.value}" : "", 
          style:  const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            hintStyle:const TextStyle(fontSize: 12, ),
            fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
            suffixIcon: widget.type.contains("money") ? const Icon(Icons.euro) : ( widget.value is int ? const Icon(Icons.onetwothree) : const Icon(Icons.link)),
            hintText: "enter ${widget.schemaName.replaceAll("_", " ").replaceAll("db", "")} ${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}",
            labelText: "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}",
            errorStyle: const TextStyle(fontSize: 0,),
          ),
          onSaved: func,
          onChanged: (String? value) {
            widget.component.widget.detectChange = true;
            try {
              if (value == null) { widget.form[widget.name]=null;
              } else if (widget.type.contains("int")) { 
                widget.form[widget.name]=int.parse(value);
              } else { widget.form[widget.name]=double.parse(value); }
            } catch (e) { /* empty and proud to be */}
          },
          keyboardType: TextInputType.numberWithOptions(
              signed: false,
              decimal: widget.type.contains("double") || widget.type.contains("float") || widget.type.contains("money"),
          ),
          validator: (String? value) {
            var err = false;
            if (widget.type.contains("int") && value != null) {
              try { double.parse(value); } catch (e) { err = true; }
            }
            if ((widget.type.contains("double") || widget.type.contains("float") || widget.type.contains("money")) && value != null) {
              try { double.parse(value); } catch (e) { err = true; }
            }
            return (value == null || value.isEmpty) && widget.require || err && widget.require ? 'enter a proper number.' : null;
          },
        ));
  }
}
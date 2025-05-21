
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class NumberWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String type;
  final String label;
  final dynamic autofill;
  NumberWidget ({ super.key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.component, this.autofill});
  @override
  // ignore: library_private_types_in_public_api
  _NumberState createState() => _NumberState();
}
class _NumberState extends State<NumberWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
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
          initialValue: widget.value != null ? "${widget.value}"
            : (widget.autofill != null ? "${widget.autofill}" : (widget.readOnly ? TranslateConstants.empty : null)), 
          style:  const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            suffixIconColor: Theme.of(context).primaryColor,
            hintStyle: const TextStyle(fontSize: 12, ),
            fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
            border: OutlineInputBorder(borderSide: BorderSide(color:Theme.of(context).splashColor, width: 1.0)),
            contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
            suffixIcon: widget.type.contains("money") ? const Icon(Icons.euro, color: Colors.black) : Icon(Icons.onetwothree, color: Theme.of(context).secondaryHeaderColor),
            hintText: TranslateConstants.writeNumber.toLowerCase(),
            labelStyle: TextStyle(color:Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
            labelText: (await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(),
            errorStyle: const TextStyle(fontSize: 0,),
          ),
          onSaved: func,
          onChanged: (String? value) {
            widget.component?.widget.detectChange = true;
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
            if ((widget.type.contains("double") || widget.type.contains("float") || widget.type.contains("decimal") || widget.type.contains("money")) && value != null) {
              try { double.parse(value); } catch (e) { err = true; }
            }
            return (value == null || value.isEmpty) && widget.require && !widget.readOnly || err && widget.require && !widget.readOnly ? 'enter a proper number.' : null;
          },
        ));
  }
}
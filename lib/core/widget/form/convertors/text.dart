
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/utils.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

// ignore: must_be_immutable
class TextWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  final bool translatable;
  dynamic value;
  final String type;
  final String label;
  final dynamic autofill;
  bool isDark = false;
  TextWidget ({ 
    required this.form, 
    required this.schemaName, 
    required this.name,
    required this.readOnly, 
    required this.require, 
    required this.type, 
    required this.component,
    required this.label,
    required this.translatable,
    this.value,
    this.autofill,
    this.isDark = false}): super(key: GlobalKey<State<TextWidget>>());
  @override
  // ignore: library_private_types_in_public_api
  _TextState createState() => _TextState();
}
class _TextState extends State<TextWidget> {
  @override Widget build(BuildContext context) {
    if ((widget.component?.widget.view?.rules ?? []).where( (r) => r.trigger == widget.name).isNotEmpty) {
      for (var r in (widget.component?.widget.view?.rules ?? [])) {
        if (r.trigger == widget.name) {
          r.key = widget.key as GlobalKey<State<TextWidget>>;
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
    var label = "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}";
    try {
      label = await getOnFlow(label);
    } catch (e) {}
    if (widget.form[widget.name] != null) { widget.value = widget.form[widget.name]; }
    if ((widget.type.contains("time") || widget.type.contains("date")) && widget.value != null) {
      widget.value = '${widget.value}'.substring(0, widget.value.length > 10 ? 10 : widget.value.length);
    }
    var val = widget.value  ?? widget.autofill;
    val = val?.replaceAll("''", "'");
    if (val != null) {
      saveChange(widget.component?.widget.view, widget.form, widget.name, val);
    }
    if (val == null || val == "") {
      val = widget.readOnly ? (await getOnFlow(TranslateConstants.empty)) : null;
    } else if (widget.translatable) {
      val = (await getOnFlow(val));
      if (val.toUpperCase() == val) {
        val = val.toUpperCase();
      } else {
        val = val.toLowerCase();
      }
    }
    try {
      TranslateConstants.writeValue = await getOnFlow(TranslateConstants.writeValue);
    } catch(e) {}
    
    return TextFormField(
      obscureText: widget.type.contains("password") || widget.label.contains("password") ? true : false,
      readOnly: widget.readOnly,
      initialValue: val,
      maxLines:  (widget.type.contains("text") && !widget.label.contains("password") ? 100 : 1),
      style: TextStyle( fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Theme.of(context).secondaryHeaderColor),
      enabled: true,
      autocorrect: true,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).splashColor, width: 1.0)),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
        border: OutlineInputBorder(borderSide: BorderSide(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).splashColor, width: 1.0)),
        isDense: true,
        suffixIconColor: Theme.of(context).primaryColor,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: widget.readOnly ? Theme.of(context).splashColor : (widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
        contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, 
          top: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0,
          bottom: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0),
        suffixIcon: widget.type.contains("time") || widget.type.contains("date") ? const Icon(Icons.calendar_month, size: 20) 
          : ( widget.type.contains("url") ? InkWell( 
          onTap: () async => showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "navigate to ${widget.value}", 
          validate: () {
            if ("${widget.value}".substring(0,7) == "http://") {
              launchUrl(widget.value, webOnlyWindowName:'_blank');
            } else {
              OpenFile.open("${widget.value}", type: getTypes("${widget.value}".split(".")[-1]));
            }
          })),
        child: Icon(Icons.link, size: 20)) : Icon(Icons.text_fields, color:  widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor)),
        hintText: TranslateConstants.writeValue.toLowerCase(),
        labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
        labelText: label.toLowerCase(),
        errorStyle: const TextStyle(fontSize: 0,),
      ),
      onChanged: (String? value) {
        widget.component?.widget.detectChange = true;
        saveChange(widget.component?.widget.view, widget.form, widget.name, value);
      },
      onSaved: (String? value) => saveChange(widget.component?.widget.view, widget.form, widget.name, value),
        validator: (String? value) {
          if ((value == null || value.isEmpty) && widget.require && !widget.readOnly) {
            return "";
          }
          for (var r in (widget.component?.widget.view?.rules ?? [])) {
            if (r.trigger == widget.name) {
              if (r.operator.toLowerCase().contains("in")) {
                if (r.operator.toLowerCase().contains("not") && r.value.contains(value)) {
                  return "";
                } else if (!r.value.contains(value)) {
                  return "";
                }
                return null;
              }
              for (var v in r.value.where( (e) => e != null )) {
                var s = v.toString().split("(").last.replaceAll("'", "").replaceAll(")", "");
                var val = cacheForm[widget.component?.widget.view?.name]?[s] ?? v?.toString() ?? "";
                if (r.operator.toLowerCase().contains("like")) {
                  if (r.operator.toLowerCase().contains("not")) {
                    if ((value?.contains(val) ?? true)) {
                      return "";
                    }
                  } else {
                    if (!(value?.contains(val) ?? false)) {
                      return "";
                    } 
                  }
                } else if (r.operator.contains("=")) {
                  if (r.operator.contains("!")) {
                    if (value != val) {
                      return "";
                    }
                  } else {
                    if (value == val) {
                      return "";
                    }
                  }
                }
              }
            }
          }
          return null;
        },
      );
  }
}
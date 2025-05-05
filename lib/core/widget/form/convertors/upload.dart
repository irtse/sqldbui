import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqldbui2/core/widget/form/form.dart';

// ignore: must_be_immutable
class UploadWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool require;
  final bool readOnly;
  dynamic value;
  final String? url;
  final String label;
  final String type;
  final dynamic autofill;
  UploadWidget ({ super.key, required this.form, required this.schemaName, required this.name, required this.url,
                      required this.readOnly, required this.type, required this.value, required this.label,
                      required this.component, this.require = false, required this.autofill });
  @override
  // ignore: library_private_types_in_public_api
  _UploadState createState() => _UploadState();
}
class _UploadState extends State<UploadWidget> {
  TextEditingController text = TextEditingController();
  PlatformFile? _selectedFile;

  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }

  Future<Widget> futureBuild(BuildContext context) async {
    if ("${widget.value}" == "") {
      widget.value = null;
    }
    if (widget.readOnly) {
      return SizedBox(width: 400, height: 30, child: TextFormField(
        readOnly: true,
        initialValue: widget.value != null ? await getOnFlow(widget.value) : (widget.readOnly ? TranslateConstants.empty : null),
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
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
          contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
          hintText: TranslateConstants.writePath.toLowerCase(),
          labelText: (await getOnFlow("${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}${widget.require ? '*' : ''}")).toLowerCase(),
        )
      ));
    }
    String? iv = widget.value ?? (widget.autofill != null ? (await getOnFlow("${widget.autofill}")) 
                                                               : (widget.readOnly ? TranslateConstants.empty : null));
    if (text.value.text != "") {
      iv = null;
    }
    return InkWell( 
      mouseCursor: SystemMouseCursors.click,
      onTap: () => widget.readOnly ? null : _pickFile(),
      child: TextFormField(
        controller: text,
        obscureText: widget.type.contains("password") || widget.label.contains("password") ? true : false,
        readOnly: true,
        initialValue: iv,
        maxLines: (widget.type.contains("text") && !widget.label.contains("password") ? 100 : 1),
        style: TextStyle( fontSize: 14, color: Theme.of(context).secondaryHeaderColor),
        enabled: false,
        autocorrect: true,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIconColor: Theme.of(context).primaryColor,
          hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: widget.readOnly ? Theme.of(context).splashColor :Colors.white,
          contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, 
            top: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0,
            bottom: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0),
          suffixIcon: widget.type.contains("time") || widget.type.contains("date") ? const Icon(Icons.calendar_month, size: 20) 
            : ( widget.type.contains("link") ? InkWell( 
          child: Icon(Icons.attach_file, size: 20)) : Icon(Icons.attach_file, color: Theme.of(context).secondaryHeaderColor)),
          hintText: TranslateConstants.writePath.toLowerCase(),
          labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
          labelText: (await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(),
          errorStyle: const TextStyle(fontSize: 0,),
        ),
        validator: (String? value) {
          var t = (value == null || value.isEmpty) && widget.require && !widget.readOnly ? "" : null;
          return t;
        },
      )
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        widget.value = _selectedFile?.name;
        text.value = TextEditingValue(text: widget.value);
        widget.form[widget.name]=<String,PlatformFile>{};
        widget.form[widget.name][widget.url]=_selectedFile;
        widget.component?.widget.detectChange = true;
      });
    }
  }
}

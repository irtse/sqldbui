import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:textfield_tags/textfield_tags.dart';
// import 'package:diacritic/diacritic.dart'; // remove accents
/*
String sanitizeFilename(String input) {
  // 1. Remove accents
  String noAccents = removeDiacritics(input);

  // 2. Replace spaces with underscores
  String noSpaces = noAccents.replaceAll(' ', '_');

  // 3. Remove unsafe characters
  String safe = noSpaces.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');

  // 4. Collapse multiple underscores
  safe = safe.replaceAll(RegExp(r'_+'), '_');
  return safe;
}*/

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
  UploadWidget ({ required this.form, required this.schemaName, required this.name, required this.url,
                  required this.readOnly, required this.type, required this.value, required this.label,
                  required this.component, this.require = false, required this.autofill }): super(key: GlobalKey<State<UploadWidget>>());
  @override
  // ignore: library_private_types_in_public_api
  _UploadState createState() => _UploadState();
}
class _UploadState extends State<UploadWidget> {
  bool error = false;
  PlatformFile? _selectedFile;
  TextEditingController text = TextEditingController();
  bool isNull = false;
  @override Widget build(BuildContext context) {
    if ((widget.component?.widget.view?.rules ?? []).where( (r) => r.trigger == widget.name).isNotEmpty) {
      for (var r in (widget.component?.widget.view?.rules ?? [])) {
        if (r.trigger == widget.name) {
          r.key = widget.key as GlobalKey<State<UploadWidget>>;
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
  var stringTagController = StringTagController();
  Future<Widget> futureBuild(BuildContext context) async {
    widget.value = widget.value ?? widget.autofill; 
    if (widget.form[widget.name] != null) {
      widget.value = "";
      for ( var k in ((widget.form[widget.name] as Map<String,List<PlatformFile>>)[widget.url] ?? [])) {
        widget.value = widget.type.contains("multiple") && widget.value.isNotEmpty ? "${widget.value},${k.name}" : k.name;
      }
    }
    var label = "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}";
    try {
      label = await getOnFlow(label);
    } catch (e) {}
    if ("${widget.value}" == "") {
      widget.value = null;
    }
    if (widget.readOnly) {
      if (widget.type.contains("multiple")) {
        List<Widget> rows = [];
        int index = 1;
        for (var vv in (widget.value?.toString().split(",") ?? [])) {
          rows.add(
            SizedBox(width: 400, height: 30, child: TextFormField(
              readOnly: true,
              initialValue: vv ?? (widget.readOnly ? (await getOnFlow(TranslateConstants.empty)) : null),
              style: TextStyle(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                suffixIcon: InkWell( 
                  onTap: () async {
                      String? newDirectory = (kIsWeb ? "/${vv.toString().split("/").last}" : await FilePicker.platform.saveFile(
                        fileName: vv.toString().split("/").last,
                        dialogTitle: await getOnFlow("select a folder where to download file")));
                      await APIService().getWithDownload("${APIConstants.downloadEndpost}/${vv.toString().split("/").last}", "", {}, "$newDirectory", kIsWeb, null);
                  },
                  child: Icon(Icons.attach_file, size: 20, color: Theme.of(context).primaryColor)),
                errorStyle: const TextStyle(height: -2),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                fillColor: widget.readOnly ? Theme.of(context).splashColor : (Colors.white),
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: error ? Colors.red : Theme.of(context).splashColor, width: 1.0)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                hintText: (await getOnFlow(TranslateConstants.writePath)).toLowerCase(),
                labelText: "${label.toLowerCase()} $index",
              )
            ))
          );
          index = index + 1;
        }
        return Wrap(children: rows);
      }
      return SizedBox(width: 400, height: 30, child: TextFormField(
        readOnly: true,
        initialValue: widget.value ?? (widget.readOnly ? (await getOnFlow(TranslateConstants.empty)) : null),
        style: TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          suffixIcon: InkWell( 
            onTap: () async {
              var vSub = widget.value.toString().split(",");
              for (var v in vSub ) {
                String? newDirectory = (kIsWeb ? "/${v.toString().split("/").last}" : await FilePicker.platform.saveFile(
                  fileName: v.toString().split("/").last,
                  dialogTitle: await getOnFlow("select a folder where to download file")));
                await APIService().getWithDownload("${APIConstants.downloadEndpost}/${v.toString().split("/").last}", "", {}, 
                      "$newDirectory", kIsWeb, null);
              }
            },
            child: Icon(Icons.attach_file, size: 20, color: Theme.of(context).primaryColor)),
          errorStyle: const TextStyle(height: -2),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          fillColor: widget.readOnly ? Theme.of(context).splashColor : (Colors.white),
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
          labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
          focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
          errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: error ? Colors.red : Theme.of(context).splashColor, width: 1.0)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
          contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
          hintText: (await getOnFlow(TranslateConstants.writePath)).toLowerCase(),
          labelText: label.toLowerCase(),
        )
      ));
    }
    String? iv = widget.value ?? (widget.autofill != null ? "${widget.autofill}" : (
      widget.readOnly ? (await getOnFlow(TranslateConstants.empty)) : null));
    if (isNull) {
      iv = "";
      isNull = false;
    }
    text = TextEditingController(text: iv);
    Widget w = Stack( children: [
       InkWell( 
            mouseCursor: SystemMouseCursors.click,
            onTap: () => widget.readOnly ? null : _pickFile(),
            child: TextFormField(
              obscureText: widget.type.contains("password") || widget.label.contains("password") ? true : false,
              readOnly: true,
              controller: text,
              maxLines: (widget.type.contains("text") && !widget.label.contains("password") ? 100 : 1),
              style: TextStyle( fontSize: 14, color: Theme.of(context).secondaryHeaderColor),
              enabled: false,
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              onChanged: (String value) {
                text.text = iv ?? "";
              },
              decoration: InputDecoration(
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: error ? Colors.red : Theme.of(context).splashColor, width: 1.0)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: error ? Colors.red : Theme.of(context).splashColor, width: 1.0)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: error ? Colors.red : Theme.of(context).splashColor, width: 1.0)),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: error ? Colors.red : Theme.of(context).splashColor, width: 1.0)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: error ? Colors.red : Theme.of(context).splashColor, width: 1.0)),
                border: OutlineInputBorder(borderSide:  BorderSide(color: error ? Colors.red : Theme.of(context).splashColor, width: 1.0)),
                isDense: true,
                suffixIconColor: Theme.of(context).primaryColor,
                hintStyle: TextStyle(fontSize: 12, color:Colors.grey),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: widget.readOnly ? Theme.of(context).splashColor :Colors.white,
                contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, 
                  top: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0,
                  bottom: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0),
                suffixIcon: Icon(Icons.attach_file, size: 20, color: Theme.of(context).secondaryHeaderColor),
                hintText: (await getOnFlow(TranslateConstants.writePath)).toLowerCase(),
                labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
                labelText: label.toLowerCase(),
                errorStyle: const TextStyle(fontSize: 0,),
              ),
              validator: (String? value) {
                var t = ((value ?? "") == "" || (value?.isEmpty ?? false)) && widget.require ? "" : null;
                setState(() {
                  error = ((value ?? "") == "" || (value?.isEmpty ?? false)) && widget.require;
                });
                return t;
              },
            )),
            if (widget.form[widget.name] != null)
              Positioned(right: 30, child: IconButton(
                onPressed: () {
                    isNull = true;
                    widget.value = '';
                    text.text = '';
                    Map<String,List<PlatformFile>> m = {};
                    saveChange(widget.component?.widget.view, widget.form, widget.name, m);
                   // PB FOR LINK ADD 
                },
                icon: Icon(Icons.close, size: 15),
              )),
          ]);
      if (widget.type.contains("multiple")) {
        return Column(children: [
          Wrap( children: widget.value == null ? [] : ("${widget.value}".split(",").map( 
            (e) => Container(
                margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(7))
                ),
                child: Row( 
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                  Text(e, style: TextStyle( color: Colors.white), overflow: TextOverflow.ellipsis ), 
                  InkWell( 
                    onTap: () => setState(() { 
                      try {
                      if (widget.value == null) {
                        return;
                      }
                      widget.value = "${widget.value}".replaceAll(e, "").replaceAll(",,", ","); 
                      if (widget.form[widget.name] == null) {
                        return;
                      }
                      var m = widget.form[widget.name] as Map<String,List<PlatformFile>>;
                      var newM = <String,List<PlatformFile>>{};
                      for (var f in m.keys) {
                        List<PlatformFile> files = [];
                        for (var vv in m[f]!) {
                          if (widget.value.contains(vv.name)) {
                            files.add(vv);
                          }
                        }
                        newM[f] = files;
                      } 
                      saveChange(widget.component?.widget.view, widget.form, widget.name, newM);
                      } catch(e,s) {
                        print(e);
                        print(s);
                      }
                    }),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10), 
                      child: Icon(Icons.close, size: 15, color: Colors.white)
                    )
                  )
                ])
            ))).toList()),
          w
        ]);
      }
      return w;
  }

  Future<void> _pickFile() async {
    List<String> extension = ['doc', 'docx', 'txt', 'rtf', 'odt', 'pdf', 
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'xls', 'xlsx', 'csv', 'ods'];
    /*if (widget.type.replaceAll("upload_multiple", "").isNotEmpty) {
      extension = widget.type.replaceAll("upload_multiple", "").split("_");
    } else if (widget.type.replaceAll("upload", "").isNotEmpty) {
      extension = widget.type.replaceAll("upload", "").split("_");
    }*/
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: kIsWeb,
      type: FileType.custom,
      allowedExtensions: extension,
    );
    if (result != null) {
      _selectedFile = result.files.first;      
      if (_selectedFile != null) {
        /*_selectedFile =  !widget.type.contains("multiple") && (widget.form["name"] ?? "") != "" ? PlatformFile(
          name:  sanitizeFilename("${widget.form["name"]}.${_selectedFile!.extension}"),
          size: _selectedFile!.size,
          bytes: _selectedFile!.bytes,
        ) : PlatformFile(
          name: sanitizeFilename(_selectedFile!.name),
          size: _selectedFile!.size,
          bytes: _selectedFile!.bytes,
        );*/
        if ("${widget.value ?? ""}" == "" ) {
          widget.value = _selectedFile?.name;
        } else {
          widget.value = widget.type.contains("multiple") && widget.value.isNotEmpty ? "${widget.value},${_selectedFile?.name}" : _selectedFile?.name;
        }
        if (widget.url != null && _selectedFile != null) {
          if (widget.form[widget.name] == null || widget.form[widget.name] is! Map) {
            saveChange(widget.component?.widget.view, widget.form, widget.name, <String,List<PlatformFile>>{});
          }
          var m = widget.form[widget.name] as Map<String,List<PlatformFile>>;
          if (m[widget.url ?? ""] == null || !widget.type.contains("multiple")) {
            m[widget.url ?? ""] = [];
          }
          m[widget.url ?? ""]?.add(_selectedFile!);
          saveChange(widget.component?.widget.view, widget.form, widget.name, m);
        }
        setState(() { });
      } 
    }
  }
}


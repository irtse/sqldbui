import 'dart:io';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/form/convertors/text.dart';
import 'package:sqldbui2/core/widget/form/convertors/dropdown.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sqldbui2/page/translate.dart';


// ignore: must_be_immutable
class MappingPopUpWidget extends StatefulWidget{
  bool isExport = true; 
  String format = "csv"; 
  List<String> importFormat = ["csv", "json", "xlsx"];
  Map<String, model.SchemaField>? forcedSchema;
  List<PlatformFile> files = [];
  MappingPopUpWidget ({ super.key, this.isExport = true, required this.format, this.forcedSchema });
  @override
  MappingPopUpState createState() => MappingPopUpState();
}

class MappingPopUpState extends State<MappingPopUpWidget> {
  bool isLoading = false;
  String directory = "/";
  bool isWeb = false;
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    var mapped = <String, dynamic>{};
          List<String> order = <String>[];
          for (var fieldName in currentView!.schema.keys) { 
            mapped[fieldName] = null; 
            order.add(fieldName);
    }
    var cache = <String,dynamic>{ };
    var newCacheEntry = <String,dynamic>{ };
    var formKey = GlobalKey<FormState>();
    List<Widget> items = <Widget>[];
    List<Widget> mapping = <Widget>[];
    isWeb = kIsWeb;
    if (isLoading) {
      items.add(Center( child: ValueListenableBuilder(
        valueListenable: APIService.downloadProgressNotifier, builder: (context, value, snapshot) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              const SizedBox( height: 32, ),
              CircularPercentIndicator( radius: 50.0, lineWidth: 10.0,
                percent: APIService.downloadProgressNotifier.value / 100,
                center: Text(
                  "${APIService.downloadProgressNotifier.value}%",
                  style: TextStyle( fontSize: 20.0, fontWeight: FontWeight.w600, color: Theme.of(context).highlightColor),
                ),
                backgroundColor: Theme.of(context).splashColor,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Theme.of(context).primaryColor,
              ),
            ],
          );
    })));
    } else {
      if (widget.isExport) {
        items.addAll([
        Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10), child: Divider(color: Theme.of(context).splashColor,)),
        Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10), 
          child: Form( key: formKey, 
          autovalidateMode: AutovalidateMode.always,
          child: Wrap( children : [
            Padding(
              padding: const EdgeInsets.only( bottom: 10), 
            child: TextWidget(
              form : cache, 
              schemaName: "", 
              name: "filename", 
              readOnly: false, 
              value: null, 
              label: "filename", 
              translatable: false,
              require: true, type: "varchar", 
              component: null, isDark: true)),
            DropDownWidget(
              form : cache, 
              schemaName: "", 
              schema: <String,model.SchemaField>{},
              name: "format", 
              readOnly: false, 
              value: widget.format, 
              label: "format", 
              require: true, 
              type: "enum__csv_json", 
              component: null, 
              mainUrl: null,
              url: null, 
              isDark: true, 
              path: "", 
              wrappers: null,
              translatable: false,
              autofill: null,
              empty: currentView?.isEmpty ?? false)
        ]))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Divider(color: Theme.of(context).splashColor,))]);
      } else {
        items.addAll([
          Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10), child: Divider(color: Theme.of(context).splashColor,)),
          Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10), 
            child: InkWell( 
              onTap: () async {
                var files = await FilePicker.platform.pickFiles(
                  initialDirectory: directory, 
                  type: FileType.custom,
                  allowedExtensions: widget.importFormat, 
                  allowMultiple: true
                );
                for (var file in files!.files) { widget.files.add(file); }
                setState(() {});
              },
              child: Stack( children: [Container(constraints: const BoxConstraints(minWidth: 200), 
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),
                  color: Theme.of(context).primaryColorLight,),
              height: 200, child: Center(child: Icon(Icons.upload_file, color: Theme.of(context).splashColor, size: 50,))),
            Positioned( left: 30, bottom: 10, child: Text(widget.files.isEmpty ? "no file upload..." : widget.files.map((e) => e.name).join(", "), style: TextStyle(color: Theme.of(context).splashColor),)),
          ]))),
          Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10), child: Divider(color: Theme.of(context).splashColor,)),
        ]);
      }
      var schema = widget.forcedSchema ?? currentView!.schema;
      for (var scheme in schema.keys) {
        var f = TextWidget(form : newCacheEntry, 
          schemaName: currentView!.schemaName, name: scheme, 
          readOnly: false, value: scheme, 
          label: "${schema[scheme]!.label} as label", 
          translatable: false,
          require: false, type: "varchar", 
          component: null, isDark: true);
        mapping.add(Padding(padding: const EdgeInsets.only(bottom: 10), 
                    child: Container( width: 300,
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(10),
                    ), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), child: f,))));
      }
    }
    Widget w = Padding( padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30), child: Column( children : [
          Padding( padding: const EdgeInsets.only(left: 20, right: 20, top: 10), 
          child: Row(children: [
            Padding( 
              padding: const EdgeInsets.only(right: 10, top: 5), 
              child: Icon(widget.isExport ? Icons.download : Icons.upload, 
                color: Theme.of(context).splashColor, 
                size: 30,)),
            Text((await getOnFlow("${widget.isExport ? "Export" : "Import" } data with custom mapping")).toLowerCase(),
              style: TextStyle(color: Theme.of(context).highlightColor, 
              fontSize: 20, 
              fontWeight: FontWeight.bold)),
            Padding( padding: const EdgeInsets.only(left: 20, top: 5), 
            child: Text( widget.isExport && !isWeb ? "${TranslateConstants.savedFolder.toLowerCase()} : $directory" : "${TranslateConstants.allowedFormat.toLowerCase()} : ${widget.importFormat.join(",")}",
              style: TextStyle(color: Theme.of(context).splashColor, fontSize: 12))), 
            widget.isExport && !isWeb ? Padding( padding: const EdgeInsets.only(left: 5, top: 5), 
            child: IconButton( icon: Icon(Icons.folder, color: Theme.of(context).splashColor, size: 20,), 
              onPressed: () async {
                String? newDirectory = await FilePicker.platform.getDirectoryPath();
                setState(() { directory = newDirectory ?? directory; });
              })) : Container(),
          ])),
        SizedBox( child: Wrap(alignment: WrapAlignment.center, children : [...items, Container( 
          constraints: BoxConstraints(maxHeight: currentHeigth / 3), 
          child: SingleChildScrollView(scrollDirection: Axis.vertical,
          child: Wrap(alignment: WrapAlignment.center, children: mapping)))])),
        Padding( padding: const EdgeInsets.only(top: 10), child: Row( mainAxisAlignment: MainAxisAlignment.end, children : isLoading ? [] : <Widget>[
              Padding( padding: const EdgeInsets.only(bottom: 10), 
              child: TextButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
                child: Padding( padding: const EdgeInsets.only(right: 10, left: 10), 
                child: Text(TranslateConstants.filterCancel.toUpperCase(), 
                  style: TextStyle(color: Theme.of(context).splashColor))), onPressed: () { Navigator.of(context).pop(); } )),
              Padding( padding: const EdgeInsets.only(right: 20, bottom: 10), 
              child: TextButton( style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge, backgroundColor: Theme.of(context).primaryColor),
                child: Padding( padding: const EdgeInsets.only(right: 10, left: 10), child: Text(widget.isExport ? "Export" : "Import", style: TextStyle(color: Theme.of(context).highlightColor))), 
                onPressed: () async { 
                  if (widget.isExport && formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    var path = currentView!.actionPath;
                    if (!globalGridKey.currentState!.widget.isSelected && selectedGrid.isNotEmpty) {
                      try {
                        var ids = selectedGrid.where( (e) => e.cells.isNotEmpty ).map( (e) => "${e.cells.first.value}" ).join(",");
                        path = path.replaceAll("rows=all", "rows=$ids");
                      } catch (e) { /* */ } 
                    } else if (globalGridKey.currentState!.widget.isSelected && unselectedGrid.isNotEmpty) {
                      path = "&filter_line=";
                      var params = "";
                      for (var row in unselectedGrid) {
                        if (row.cells.isNotEmpty) { 
                          if (params.isNotEmpty) { path += "|"; }
                          params += "id%3C%3E${row.cells.first.value},";
                        }
                      }
                      path += params;
                    }
                    if (globalGridKey.currentState!.widget.isSelected || selectedGrid.isNotEmpty) {
                      if (widget.isExport) { setState(() { isLoading = true; }); }
                      if (widget.forcedSchema != null) {
                        for (var key in newCacheEntry.keys) {
                          if (!widget.forcedSchema!.containsKey(key)) { newCacheEntry.remove(key); }
                        }
                      }
                      widget.isExport ? 
                        await APIService().getWithDownload(path, cache["format"], newCacheEntry, 
                                "$directory/${cache["filename"]}.${cache["format"]}", isWeb, context) : null; 
                      if (widget.isExport) { setState(() { isLoading = false; }); }
                    }
                  }
                  if (widget.files.isNotEmpty) {
                    for (var file in widget.files) {
                      if (file.path == null) { continue; }
                      await APIService().sendFile<model.View>(currentView!.actionPath, File(file.path!), context);
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, currentView, false); // TO REMOVE
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  }
                }))] )) ]));
    if (!isWeb) {
      (Platform.isIOS ? getApplicationDocumentsDirectory() : (Platform.isAndroid ? (getExternalStorageDirectory()) : (getDownloadsDirectory()))).then((value) {
        Future.delayed(const Duration(milliseconds: 500), () {
          var val = value != null && directory == "/" ? value.path : directory;
          if (directory != val) { setState(() { directory = val; });  }
        });
      });
    }
    return w;
  }
}
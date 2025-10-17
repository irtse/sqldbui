
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';

// ignore: must_be_immutable
class DatagridButtonWidget extends StatefulWidget {
  List<String> selectedGrid;
  Map<String, model.SchemaField> schema;
  String? columnName;
  dynamic value;
  String mode = "update";
  bool isNull = false;
  DatagridButtonWidget ({ 
    super.key,
    required this.schema,
    required this.selectedGrid,
    this.mode = "update",
    this.value,
    this.columnName,
    this.isNull = false,
  });
  @override
  DatagridButtonWidgetState createState() => DatagridButtonWidgetState();
}
class DatagridButtonWidgetState extends State<DatagridButtonWidget> {
  bool change = false;
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return change ? const Padding( padding: EdgeInsets.symmetric(horizontal: 10), 
      child: SpinKitCircle(color: Colors.white, size: 30.0 )) : IconButton(
        tooltip: (await getOnFlow("${widget.mode} multiple rows")),
        onPressed: () async {
        setState(() { change = true; });
        if (widget.mode == "update") {
          for (var i in widget.selectedGrid) {
            Map<String, dynamic> body = {};
            for (var lfile in cacheFilesChanges.values) {
                  for (var pathFile in lfile.keys) {
                    for (var file in lfile[pathFile] ?? []) {
                      await submitFile(pathFile.replaceAll("rows=all", "rows=$i"), file!, context);
                    }
                  }
                }
            for (var j in widget.schema.keys) {
              if (j != "id"  && detectChanges["$i:$j"] != null) {
                body[j] = cacheChanges["$i:$j"];
              }
            }
            if (body.isNotEmpty) {
              for (var path in (currentView?.multiPath ?? [])) {
                await APIService().put<model.View>(path.replaceAll("rows=all", "rows=$i"), body, null);
              }
              Future.delayed(Duration(seconds: 1), () {
                        globalMainViewKey.currentState?.setState(() {
                          navigate = true;
                        });
                      });
            }
          }
        } else if (widget.mode == "edit field" && !(selectedGrid.isEmpty && !allSelected)) {
                List<String> ids = [];
                if (!allSelected) {
                  for (var item in selectedGrid) { 
                    ids.add(item.toString()); 
                  }
                }
                Map<String, dynamic> body = {};
                for (var j in widget.schema.keys) {
                  if (j != "id"  && detectChanges[j] != null) {
                    body[j] = cacheChanges[j];
                  }
                }
                if (body.isNotEmpty) {
                  showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete element(s) <${ids.isEmpty ? "all" : ids.join(',')}>", 
                  validate: () async {
                      for (var lfile in cacheFilesChanges.values) {
                        for (var pathFile in lfile.keys) {
                          for (var file in lfile[pathFile] ?? []) {
                            await submitFile(pathFile.replaceAll("rows=all", "rows=${ids.isEmpty ? "all" : ids.join(",")}"), file!, context);
                          }
                        }
                      }
                      if (body.isNotEmpty) {
                        for (var path in (currentView?.multiPath ?? [])) {
                          await APIService().put(path.replaceAll("rows=all", "rows=${ids.isEmpty ? "all" : ids.join(",")}"), body, context);
                        }
                        Future.delayed(Duration(seconds: 1), () {
                          globalMainViewKey.currentState?.setState(() {
                            navigate = true;
                          });
                        });
                      }
                      
                  })); 
                }          
        } else if (widget.mode == "delete" && !(selectedGrid.isEmpty && !allSelected)) {
                List<String> ids = [];
                if (!allSelected) {
                  for (var item in selectedGrid) { 
                    ids.add(item.toString()); 
                  }
                }
                showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete element(s) <${ids.isEmpty ? "all" : ids.join(',')}>", validate: () async {
                  for (var path in (currentView?.multiPath ?? [])) {
                    await  APIService().delete(path.replaceAll("rows=all", "rows=${ids.isEmpty ? "all" : ids.join(",")}"), context);
                  }
                  Future.delayed(Duration(seconds: 3), () {
                    globalMainViewKey.currentState?.setState(() {
                      navigate = true;
                    });
                  });
                }));   
        }

        setState(() { change = false; });
      }, 
      icon: Icon(widget.mode == "delete" ? Icons.delete : ( widget.mode == "edit field" ? Icons.edit : Icons.save), color: Theme.of(context).highlightColor, size: 20));
  }
}
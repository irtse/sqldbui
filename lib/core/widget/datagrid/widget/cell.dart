
// ignore: must_be_immutable
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
// ignore: must_be_immutable
class GridCell {
  String? dataRef;
  String schemaID;
  double height = 100; 
  double width; 
  dynamic wasValue;
  String columnName; 
  dynamic value; 
  bool isNew = false;
  Color backgroundColor; 
  double borderWidth; 
  Color borderColor; 
  double fontSize; 
  String type; 
  bool isDraft= false;
  bool readOnly = false;
  bool isLink = false;
  String cellID;
  bool translatable = true;
  model.SchemaField? schemaField;
  GridCell({ 
    required this.dataRef,
    required this.schemaID,
    required this.schemaField,
    required this.translatable,
    required this.isDraft,
    required this.cellID,
    required this.columnName, 
    required this.wasValue,
    required this.value, 
    required this.width, 
    required this.isNew, 
    this.fontSize = 13, 
    this.type = "text",
    this.readOnly = false, 
    this.borderWidth = 1, 
    this.isLink = false,
    this.borderColor = Colors.grey, 
    this.backgroundColor = Colors.transparent});
}
// ignore: must_be_immutable
class GridCellWidget extends StatefulWidget implements ConvertorWidget {
  bool readOnly; 
  bool isLink = true;
  String cellID; 
  String schemaID;
  double maxheight;
  bool translatable = false;
  bool isNew = false;
  String? dataRef;

  GridCell cell;
  model.Shallowed? shal;
  model.SchemaField? schemaField;
  @override dynamic value;

  GridCellWidget ({ 
    super.key, 
    required this.dataRef,
    required this.isNew,
    required this.shal, 
    required this.cell,
    required this.value,
    required this.isLink,
    required this.cellID, 
    required this.readOnly, 
    required this.schemaID, 
    required this.maxheight, 
    required this.schemaField,
    required this.translatable,
  });

  @override GridCellWidgetState createState() => GridCellWidgetState();
}
class GridCellWidgetState extends State<GridCellWidget> {
  @override Widget build(BuildContext context) { 
    if (cacheChanges["${widget.cellID}:${widget.cell.columnName}"] != null) { 
      widget.cell.value = cacheChanges["${widget.cellID}:${widget.cell.columnName}"]; 
    }
    widget.value = widget.cell.value != null ? widget.cell.value.toString().replaceAll("true", "yes").replaceAll("false", "no") : "no info...";
    widget.value = widget.shal != null ? (widget.shal!.label ?? widget.shal!.name ?? "${widget.shal!.id}") : widget.value;
    if ( widget.shal != null && widget.value == "") {
      widget.value = widget.shal!.id;
    }
    var edit = modeIndex == 1 && !["id", "description", mathColName[viewID] ?? "total"].contains(widget.cell.columnName)
                && !widget.cell.readOnly && !widget.readOnly;
    if (edit && widget.shal != null) {
      widget.value = "${widget.shal!.id ?? widget.value}";
    }
    String url = currentView?.schema[widget.cell.columnName] == null || currentView!.schema[widget.cell.columnName]?.actionPath == "" ? 
      "" : "${currentView?.schema[widget.cell.columnName]!.actionPath}";
    var v = widget.value;
    if (widget.shal?.name != null) {
      widget.translatable = (widget.schemaField?.schema[widget.shal!.name]?.translatable ?? true) && widget.translatable;
    }
    Widget wid = Text( "$v".replaceAll(" (pending)", "").replaceAll(" (progressing)", "").replaceAll(" (completed)", "").replaceAll(" (dismiss)", "").replaceAll(" (refused)", ""), 
          textAlign: TextAlign.center, 
          style: TextStyle(
            fontSize: widget.cell.fontSize, 
            // ignore: use_build_context_synchronously
            color: (widget.schemaField?.type ?? "").contains("upload") && v !=  "no info..."  ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight)
          );
    if (widget.translatable || widget.cell.type.contains("bool") || v.contains("no info")) {
      wid = FutureBuilder(future: getOnFlow("$v"), builder: (a,b) {
        String t = "";
        if (b.data != null) {
          t = b.data!;
          if ("$v".toUpperCase() == "$v") {
            t = b.data!.toUpperCase();
          } else {
            t = b.data!.toLowerCase();
          }
          return Text( t, 
          textAlign: TextAlign.center, 
          style: TextStyle(
            fontSize: widget.cell.fontSize, 
            // ignore: use_build_context_synchronously
            color:(widget.schemaField?.type ?? "").contains("upload") && v !=  "no info..." ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight)
          );
        }
        return Text( "$v", 
          textAlign: TextAlign.center, 
          style: TextStyle(
            fontSize: widget.cell.fontSize, 
            // ignore: use_build_context_synchronously
            color: (widget.schemaField?.type ?? "").contains("upload") && v !=  "no info..."  ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight)
          );
      });      
    }
    return Column( mainAxisAlignment: MainAxisAlignment.center, children: [
      edit ? SizedBox(height: widget.maxheight - 20, 
        child: FutureBuilder( future: Convertor.filterFieldByType(
        // ignore: use_build_context_synchronously
        context, widget, widget.cell.type, widget.cell.columnName,  "", 
        this, false, true, url, url, "${widget.cellID}:${widget.cell.columnName}", currentView?.rules ?? []
      ), builder: (a,b) {
          if (b.data != null) {
            return Center( child: b.data! );
          }
          return Container();
        })) : 
      ListTile( 
        mouseCursor: modeIndex == 1 || !widget.isLink ? MouseCursor.defer : null, 
        enabled: !widget.cell.type.contains("enum") && !(currentView?.isEnum ?? false), 
        onTap: () {
          if (modeIndex == 1 || !widget.isLink || (currentView?.isEnum ?? false)) { return; }
          try {
            List<model.View> v = [];
            for (var cat in categories.values) { v = cat.where( (v) => "${v.id}" == viewID?.substring(1)).toList(); }
            if (isNew == widget.cellID) { isNew = null; }
            if (!notNew.containsKey(viewID)) { notNew[viewID] = [widget.cellID]; } else { 
              notNew[viewID]!.add(widget.cellID); 
            }
            if (v.isNotEmpty && widget.isNew) { v.first.news -= 1; }
          } catch (e) { /* */ }

          globalMenuKey.currentState!.setState(() {});
          if (widget.dataRef != null) {
            AppRouter.navigateTo(widget.dataRef!);
            Future.delayed(Duration(seconds: 1), () async {
              bool ok = false;
              for (var e in navigatorCtrls.items) {
                e.selected = e.value == "@${widget.schemaID}:${widget.cellID}";
                if (e.selected) {
                  ok = true;
                }
              }
              if (!ok) {
                navigatorCtrls.items.add(DropdownItem<String>( selected: true,
                value: "@${currentView!.id}${ currentView!.items.isNotEmpty ? ":${currentView!.items.first.values["id"]}" : "" }", 
                label: "${await getOnFlow(currentView!.label ?? currentView!.name.replaceAll("_", "").replaceAll("db", ""))} -> ${
                  await getOnFlow(currentView!.items.isNotEmpty ?currentView!.items.first.values["name"] ?? "data" : "")}".toLowerCase()));
              }
              navigatorCtrls.openDropdown("", "", true);
              navigatorCtrls.closeDropdown();
            });
          } else {
            AppRouter.navigateTo("@${widget.schemaID}:${widget.cellID}");
            Future.delayed(Duration(seconds: 1), () {
              bool ok = false;
              for (var e in navigatorCtrls.items) {
                e.selected = e.value == "@${widget.schemaID}:${widget.cellID}";
                if (e.selected) {
                  ok = true;
                }
              }
              if (!ok) {
                navigatorCtrls.items.add(DropdownItem<String>( selected: true,
                  value: "@${widget.schemaID}${widget.cellID}", 
                  label: "${(currentView!.label ?? currentView!.name).replaceAll("_", "").replaceAll("db", "")} -> ${ 
                    currentView!.items.isNotEmpty ?currentView!.items.first.values["name"] ?? "data" : ""}".toLowerCase()));
                navigatorCtrls.openDropdown("", "", true);
                navigatorCtrls.closeDropdown();
              }
            });
          } 
        }, 
        title: SizedBox(height: widget.maxheight - 20, 
        child: Center(child: (widget.schemaField?.type ?? "").contains("upload") && v !=  "no info..."  ? InkWell( 
            onTap: () async {
              String? newDirectory =  (kIsWeb ? "/${widget.value.toString().split("/").last}" : await FilePicker.platform.saveFile(
                fileName: widget.value.toString().split("/").last,
                dialogTitle: await getOnFlow("select a folder where to download file")));
              await APIService().getWithDownload("${APIConstants.downloadEndpost}/${widget.value.toString().split("/").last}", "", {}, 
                    "$newDirectory", kIsWeb, null);
            },  child: wid) : wid )))]);
  }
}


// ignore: must_be_immutable
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/page/translate.dart';
// ignore: must_be_immutable
class GridCell {
  double height = 100; 
  double width; 
  dynamic wasValue;
  String columnName; 
  dynamic value; 
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
    required this.schemaField,
    required this.translatable,
    required this.isDraft,
    required this.cellID,
    required this.columnName, 
    required this.wasValue,
    required this.value, 
    required this.width, 
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
  bool readOnly; bool isLink = true;
  String cellID; String schemaID;
  double maxheight;
  bool translatable = true;

  GridCell cell;
  model.Shallowed? shal;
  model.SchemaField? schemaField;
  @override dynamic value;

  GridCellWidget ({ 
    super.key, 
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
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    if (cacheChanges["${widget.cellID}:${widget.cell.columnName}"] != null) { 
      widget.cell.value = cacheChanges["${widget.cellID}:${widget.cell.columnName}"]; 
    }
    widget.value = widget.cell.value != null ? widget.cell.value.toString().replaceAll("true", "yes").replaceAll("false", "no") : "no info...";
    widget.value = widget.shal != null ? (widget.shal!.label ?? widget.shal!.name ?? "${widget.shal!.id}") : widget.value;
    var edit = (isEditMode[viewID] ?? false) && !["id", "description", mathColName[viewID] ?? "total"].contains(widget.cell.columnName)
                && !widget.cell.readOnly && !widget.readOnly;
    String url = currentView!.schema[widget.cell.columnName] == null || currentView!.schema[widget.cell.columnName]!.actionPath == "" ? 
      "" : "${currentView!.schema[widget.cell.columnName]!.actionPath}&shallow=enable";
    var v = widget.value;
    if (widget.shal?.name != null) {
      widget.translatable = (widget.schemaField?.schema[widget.shal!.name]?.translatable ?? true) && widget.translatable;
    }
    if (widget.translatable) {
      v = await getOnFlow(widget.value);
    }
    return Column( mainAxisAlignment: MainAxisAlignment.center, children: [
      edit ? await Convertor.filterFieldByType(
        context, widget, widget.cell.type, "", 
        this, false, true, url, 
        "${widget.cellID}:${widget.cell.columnName}") : 
      ListTile( 
        mouseCursor: (isEditMode[viewID] ?? false) || !widget.isLink ? MouseCursor.defer : null, 
        enabled: !widget.cell.type.contains("enum"), onTap: () {
          if (widget.cell.type.contains("enum") || (isEditMode[viewID] ?? false) || !widget.isLink) { return; }
          try {
            List<model.View> v = [];
            for (var cat in categories.values) { v = cat.where( (v) => "${v.id}" == viewID?.substring(1)).toList(); }
            if (isNew == widget.cellID) { isNew = null; }
            if (!notNew.containsKey(viewID)) { notNew[viewID] = [widget.cellID]; } else { notNew[viewID]!.add(widget.cellID); }
            if (v.isNotEmpty) { v.first.newIds.remove(widget.cellID); }
          } catch (e) { /* */ }
          globalMenuKey.currentState!.setState(() {});
          AppRouter.navigateTo("@${widget.schemaID}:${widget.cellID}");
        }, 
        title: SizedBox(height: widget.maxheight - 20, 
        child: Center(child: Text( translation ? v : widget.value, 
          textAlign: TextAlign.center, 
          style: TextStyle(
            fontSize: widget.cell.fontSize, 
            color: Theme.of(context).primaryColorLight)
          )
        )))]);
  }
}

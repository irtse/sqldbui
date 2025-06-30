
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/row.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';

// ignore: must_be_immutable
class SaveDatagridButtonWidget extends StatefulWidget {
  List<GridRowWidget> selectedGrid;
  SaveDatagridButtonWidget ({ 
    super.key,
    required this.selectedGrid,
  });
  @override
  SaveDatagridButtonWidgetState createState() => SaveDatagridButtonWidgetState();
}
class SaveDatagridButtonWidgetState extends State<SaveDatagridButtonWidget> {
  bool change = false;
  @override Widget build(BuildContext context) {
    return change ? const Padding( padding: EdgeInsets.symmetric(horizontal: 10), 
      child: SpinKitCircle(color: Colors.white, size: 30.0,)) : IconButton(onPressed: () async {
        setState(() { change = true; });
        for (var i in widget.selectedGrid) {
          if (i.cells.isNotEmpty) {
            Map<String, dynamic> body = {};
            for (var j in i.widgetCells) {
              if (j.cell.columnName != "id" 
              && detectChanges["${i.cellID}:${j.cell.columnName}"] != null 
              && detectChanges["${i.cellID}:${j.cell.columnName}"]!.currentState != null
              && detectChanges["${i.cellID}:${j.cell.columnName}"]!.currentState!.validate()) {
                body[j.cell.columnName] = cacheChanges["${i.cellID}:${j.cell.columnName}"];
              }
            }
            if (body.isNotEmpty && i.cells.isNotEmpty) {
              await APIService().put<model.View>(
                currentView!.actionPath.replaceAll("rows=all", "rows=${i.cellID}"), body, null);
            }
          }
        }
        setState(() { change = false; });
      }, 
      icon: Icon(Icons.save, color: Theme.of(context).highlightColor, size: 20));
  }
}
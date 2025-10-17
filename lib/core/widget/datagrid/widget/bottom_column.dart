
// ignore: must_be_immutable
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';

// ignore: must_be_immutable
class GridBottomColumnResultWidget extends StatefulWidget {
  bool isEditMode = false;
  String columnName;
  double borderWidth;
  Color borderColor;
  String value;
  String type;
  // ignore: use_super_parameters
  GridBottomColumnResultWidget ({
    required key,
    required this.type,
    required this.columnName,
    required this.value,
    this.isEditMode = false,
    this.borderWidth = 1,
    this.borderColor = Colors.grey,
  }):  super(key: key);
  @override
  GridBottomColumnResultWidgetState createState() => GridBottomColumnResultWidgetState();
}
class GridBottomColumnResultWidgetState extends State<GridBottomColumnResultWidget> {
  @override Widget build(BuildContext context) {
    bool isText = widget.columnName == "id";
    return isText || colFunction[viewID] == null || colFunction[viewID]![widget.columnName] == null ? Container( 
        decoration: BoxDecoration( color: Theme.of(context).primaryColorLight, 
          border: Border(right: BorderSide( width: widget.borderWidth, color: widget.borderColor))),
        alignment: Alignment.center,
        width: !widget.isEditMode ? 0 : (rects[viewID] != null && rects[viewID]![widget.columnName]!.width.isNaN ? 300 : rects[viewID]![widget.columnName]!.width), 
        height: widget.isEditMode ? 40 : 0, padding: const EdgeInsets.all(10),
        child: const Text("", style: TextStyle(fontSize: 15, color: Colors.white)))
      : FutureBuilder(future: APIService().raw(
        "${APIConstants.genericEndpost}${currentView!.schemaName}/${colFunction[viewID]![widget.columnName]}?rows=all&columns=${widget.columnName}", null, "get"), 
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) {
              widget.value = "${snapshot.data!.data![0].values["result"]}";
            }
            return Container( 
              decoration: BoxDecoration( color: Theme.of(context).primaryColorLight, 
                border: Border(right: BorderSide( width: widget.borderWidth, color: widget.borderColor))),
              alignment: Alignment.center,
              width: !widget.isEditMode ? 0 : (rects[viewID] != null && rects[viewID]![widget.columnName]!.width.isNaN ? 300 : rects[viewID]![widget.columnName]!.width), 
              height: widget.isEditMode ? 40 : 0, padding: const EdgeInsets.all(10),
              child: Text(widget.value, style: const TextStyle(fontSize: 15, color: Colors.white)));
          }
      );
  }
}
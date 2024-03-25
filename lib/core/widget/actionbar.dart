import 'dart:developer' as developer;
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/services/api_service.dart';

GlobalKey<ActionBarState> globalActionBar = GlobalKey<ActionBarState>();
class ActionBarWidget extends StatefulWidget {
  final MenuWidgetState menu;
  final model.View? view;
  final DataFormWidget? form;
  final DatagridWidget? grid;
  final GlobalKey<GridWidgetState>? gridKey;
  final GlobalKey<ViewWidgetState>? viewKey;
  const ActionBarWidget ({ Key? key, this.view, required this.menu, this.gridKey, this.viewKey, this.grid, this.form}): super(key: key);
  @override ActionBarState createState() => ActionBarState();
}
class ActionBarState extends State<ActionBarWidget> {
  Map<String, bool> states = {};
  void loading(String method) { setState(() { states[method]= true; });}
  void loaded(String method) { setState(() { states[method]= false; });}

  void refresh(int? viewID) {
    if (viewID != null) {
          currentView = null;
          homeKey.currentState!.widget.viewID="$viewID";
          homeKey.currentState!.widget.subViewID=null;
    }
    globalMenuKey.currentState!.setState(() { 
        firstAPI = true; 
        APIService.cache = {};
        states = {};
    });
  }

  @override Widget build(BuildContext context) {
      List<Widget> actions = <Widget>[
        Column(
          children: [IconButton(
            tooltip: "refresh page",
            style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
            icon: Icon( Icons.refresh, color: Theme.of(context).highlightColor, ),
            onPressed: () async { refresh(null); },
          )],
        )
      ];
      if (widget.gridKey != null) {
        if (isFilter()) {
          actions.add(
          Column(
            children: [IconButton(
                tooltip: "reset filter",
                style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                icon: Icon( Icons.filter_alt_off, color: Theme.of(context).highlightColor, size: 20 ), 
                onPressed: () async { 
                  homeKey.currentState!.setState(() { resetAllFilter(); });
                },
              ),],
          )
        );
      }
        

        /*actions.add(
          Column(
            children: [IconButton(
                tooltip: "download excel",
                style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                icon: Icon( Icons.download, color: Theme.of(context).highlightColor, ),
                onPressed: () async {
                    var state = widget.gridKey!.currentState;
                    if (state != null) {
                      final xls.Workbook workbook = state.exportToExcelWorkbook(
                        rows: globalGridWidgetKey.currentState!.widget.dataGridController.selectedRows);
                      final List<int> bytes = workbook.saveAsStream();
                      workbook.dispose();
                      await File('DataGrid.xlsx').writeAsBytes(bytes);
                    }   
                },
              ),],
          )
        );*/
        /* actions.add(
            IconButton( tooltip: "download pdf",
                style: ButtonStyle(  overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                icon: Icon( Icons.picture_as_pdf, color: Theme.of(context).highlightColor, ),
                onPressed: () async {
                  var state = widget.gridKey!.currentState;
                  if (state != null) {
                    PdfDocument document = state.exportToPdfDocument(
                      rows: globalGridWidgetKey.currentState!.widget.dataGridController.selectedRows);
                    final List<int> bytes = document.saveSync();
                    await File('DataGrid.xlsx').writeAsBytes(bytes);
                  }   
                },
              )
          );*/
      }
      if (widget.view != null && !widget.view!.readOnly) {
        for (var action in widget.view!.actions) {
          action = action as String;
          if (states.containsKey(action) && states[action]!) {
            actions.add( SizedBox(
              width: action == "post" ? 6 * 12 : (action == "put" ? 5 * 12 : 12),
              child: const SpinKitCircle(color: Colors.white, size: 25.0,)));
            continue;
          }
          if ( action.toLowerCase() == "post" && !widget.view!.isList ) {
            actions.add(Column(
              children: [Padding( padding: const EdgeInsets.only(top: 4, left: 2, right: 2), child: TextButton(
                    style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                    onPressed: ActionService.pressed(widget, false, widget.view!.schemaName,  
                                  widget.view!.actionPath, <String>[], widget.view!.schema, action, context), 
                    child: Text("SUBMIT", style: TextStyle(
                    fontSize: 12, color: Theme.of(context).highlightColor)))),],
            ));
          }
          if (action.toLowerCase() == "put" && !widget.view!.isList && widget.view!.items.isNotEmpty) {
            actions.add(Column(
              children: [Padding( padding: const EdgeInsets.only(top: 4, left: 2, right: 2), child: TextButton(
                    style: ButtonStyle(  overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                    onPressed: ActionService.pressed(widget, false, widget.view!.schemaName,  widget.view!.actionPath, 
                                      <String>["id"], widget.view!.schema, action, context), 
                    child: Text("SAVE", style: TextStyle( fontSize: 12, color: Theme.of(context).highlightColor)))),],
            )); 
          }
          if (action.toLowerCase() == "delete") {
            actions.add(Column(
              children: [IconButton(
                style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                tooltip: "delete${ widget.view!.isList ? ' selected rows' : ''}",
                icon: const Icon( Icons.restore_from_trash, color: Colors.white, ),
                onPressed: ActionService.pressed(widget, widget.view!.isList, widget.view!.schemaName, 
                                                 widget.view!.actionPath, <String>["id"],  widget.view!.schema, 
                                                 action, context) )],
            )); 
          }
        }
      }
      var row = <Widget>[];
      if (homeKey.currentState!.widget.subViewID != null) {
        row.add(Padding( padding: const EdgeInsets.only(left: 24.0), child: IconButton(
                tooltip: "back to list",
                style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                icon: Icon( Icons.arrow_back, color: Theme.of(context).highlightColor, ),
                onPressed: () {
                  widget.viewKey!.currentState!.setState(() {
                    currentView = beforeView; 
                    homeKey.currentState!.widget.subViewID=null;
                  });
                },
              )));
      }
      row.add(
        Padding( padding: const EdgeInsets.only(left: 30.0, right: 5.0),child: SizedBox(
                  width: (MediaQuery.of(context).size.width - 250) / (homeKey.currentState!.widget.subViewID != null ? 3.49 : 3),
                  child: Row( children: [Text(
                    widget.view == null ? (globalMenuKey.currentState!.loading ? "LOADING" : "HOME") : widget.view!.name.replaceAll("_", " ").replaceAll("db", "").toUpperCase(), 
                    style: TextStyle( color: Theme.of(context).highlightColor )),
                  Padding(padding: const EdgeInsets.only(left: 10), child: Icon(widget.view == null || !widget.view!.isList ? Icons.edit_document : Icons.list, 
                  color: Theme.of(context).splashColor, size: widget.view == null || !widget.view!.isList ? 20 : 25, )),
                  Text(widget.view == null || widget.view!.max == 0 ? "" : "   ${widget.view!.max} items founded",
                    style: TextStyle( fontSize: 11, color: Theme.of(context).splashColor )),]))),
      );
      if (widget.view != null) {
        if (widget.menu.loading) { Future.delayed(const Duration(milliseconds: 100), () { widget.menu.setState(() { widget.menu.loading = false; }); }); }
      }
      String path = "";
      if (homeKey.currentState!.widget.viewID != null) {
        path += "#${homeKey.currentState!.widget.viewID}";
        if (homeKey.currentState!.widget.subViewID != null) { path += ":${homeKey.currentState!.widget.subViewID}"; }
      }
      var controller = TextEditingController(text: path);
      return Row( children: [ 
            Container(
                color: Theme.of(context).selectedRowColor,
                height: 40,
                width: MediaQuery.of(context).size.width - 250,
                child: Row(children: row..addAll([ 
                  Stack( children: [ SizedBox (
                    width: (MediaQuery.of(context).size.width - 250 - 100) / 3,
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: TextFormField(
                        cursorHeight: 15,
                        style: TextStyle(height: 1, color: Theme.of(context).highlightColor, fontSize: 12),
                        controller: controller,
                        onSaved: (value) {
                          var split = controller.text.split('/');
                          if (split.length > 1) {
                            homeKey.currentState!.widget.viewID = split[1];
                            if (split.length > 2) { homeKey.currentState!.widget.subViewID = split[2]; }
                          }
                          homeKey.currentState!.setState(() {});
                        },
                        decoration: InputDecoration(
                        filled: true,
                        labelStyle: TextStyle(color: Theme.of(context).hintColor),
                        hintStyle: TextStyle(color: Theme.of(context).hintColor),
                        contentPadding: const EdgeInsets.all(1),
                        fillColor: Theme.of(context).secondaryHeaderColor,
                        iconColor: Theme.of(context).highlightColor,
                        prefixIcon: const Icon(Icons.account_tree),
                        hintText: 'actual url...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), 
                                                   borderSide: BorderSide(color: Theme.of(context).primaryColor))
                      )
                    ), 
                    ),
                  ),
                  Positioned(left: ((MediaQuery.of(context).size.width - 250 - 100) / 3) / 1.1, top: -5, child: IconButton(
                    tooltip: "go to data(s)",
                    style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                            return Colors.transparent;
                          }), ),
                    icon: Icon( Icons.send, color: Theme.of(context).splashColor, size: 20,),
                    onPressed: () {
                      AppRouter.navigateTo(controller.text);
                    },
                  ))
                ]),
                SizedBox ( // ACTIONS
                  width: (MediaQuery.of(context).size.width - 250) / 3.2,
                  child:Row ( mainAxisAlignment: MainAxisAlignment.end, children: actions, ),
                )
              ]))
            ),
        ],);
  }
}
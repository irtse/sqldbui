import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/utils.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';

GlobalKey<ActionBarState> globalActionBar = GlobalKey<ActionBarState>();
class ActionBarWidget extends StatefulWidget {
  final model.View? view;
  final DataFormWidget? form;
  final DatagridWidget? grid;
  final GlobalKey<GridWidgetState>? gridKey;
  const ActionBarWidget ({ super.key, this.view, this.gridKey, this.grid, this.form});
  @override ActionBarState createState() => ActionBarState();
}
class ActionBarState extends State<ActionBarWidget> {
  Widget getDescription(String content, double? size, Color color) {
    return Flexible( child: Text(content, overflow: TextOverflow.ellipsis, style: TextStyle( fontSize: size, color: color ) ));
  }

  Widget getIconOffset(String tooltip, IconData icon, double? size, Function() onPressed, bool isTransluscent) {
    return IconButton( 
      constraints: const BoxConstraints(),
      tooltip: tooltip,
      style: ButtonStyle( 
        overlayColor: WidgetStateProperty.resolveWith((states) => isTransluscent ? Colors.transparent : (
          states.contains(WidgetState.pressed) ? Colors.green : Theme.of(context).primaryColor))),
      icon: Icon( icon, color: isTransluscent ? Theme.of(context).splashColor : Theme.of(context).highlightColor, size: size ), 
      onPressed: () {  onPressed(); });
  }

  @override Widget build(BuildContext context) {
      List<Widget> actions = <Widget>[];
      if (viewID != null) {
        actions.add( getIconOffset("refresh page", Icons.refresh, null, () {
          globalOffset = 0;
          globalMenuKey.currentState?.refresh(true);
          globalMainViewKey.currentState?.refreshUrl(currentView?.linkPath != "" ? currentView?.linkPath
            : currentView?.actionPath.replaceAll("rows=all", "rows=${subViewID ?? viewID}"), subViewID, true);
        }, false));
      }
      if (widget.gridKey != null) {
        actions.add(
          getIconOffset("reset ui change", Icons.auto_fix_off, 20, () {
            globalOffset = 0;
            globalMainViewKey.currentState?.setState(() {rects.remove(viewID); });
          }, false)
        );
      }
      if (currentView != null && (MediaQuery.of(context).size.width - menuSize) > 650) {
        for (var short in currentView!.shortcuts.keys) {
          actions.add(
            Padding( 
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5), 
              child: OutlinedButton( 
                style: ButtonStyle( 
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) { return Colors.green; }
                    return Theme.of(context).primaryColor;
                  })
                ), 
                onPressed: () { AppRouter.navigateTo(currentView!.shortcuts[short]); }, 
                child: Text(short, overflow: TextOverflow.ellipsis, style: const TextStyle( color: Colors.white, fontSize: 12 ))
              )
            )
          );
        }
      }
      var row = <Widget>[];
      row.addAll([
        getDescription(widget.view == null ? (globalLoading ? "LOADING" : "HOME") : excludeDB(widget.view!.name),
          null, Theme.of(context).highlightColor),
        Padding(
          padding: const EdgeInsets.only(left: 10), 
          child: Icon(
            widget.view == null || !widget.view!.isList ? Icons.edit_document : Icons.list, 
            color: Theme.of(context).splashColor, 
            size: widget.view == null || !widget.view!.isList ? 20 : 25, 
          )
        ),
        getDescription(widget.view == null ? "" : "   ${widget.view!.max} items founded", 11, Theme.of(context).splashColor),
      ]);
      String path = "";
      if (viewID != null) { path += "$viewID${ subViewID != null ? ":$subViewID" : "" }"; }
      var controller = TextEditingController(text: path);
      if (widget.view != null && globalLoading) { 
        Future.delayed(const Duration(seconds: 1), () { globalLoaderMainViewKey.currentState?.setState(() { globalLoading = false; }); }); 
      }
      List<Widget> rows = [];
      if (MediaQuery.of(context).size.width > 700) {
        rows = [ 
          Flexible(flex: 1, child: Row( children: row,)),
          Flexible( 
            flex: 1, 
            child: Row( 
              children: [ 
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, top: 5, bottom: 5),
                      child: TextFormField(
                        cursorHeight: 15,
                        style: TextStyle(height: 1, color: Theme.of(context).highlightColor, fontSize: 12),
                        controller: controller,
                        decoration: InputDecoration( 
                          filled: true,
                          labelStyle: TextStyle(color: Theme.of(context).splashColor),
                          hintStyle: TextStyle(color: Theme.of(context).splashColor),
                          contentPadding: const EdgeInsets.all(1),
                          fillColor: Theme.of(context).secondaryHeaderColor,
                          iconColor: Theme.of(context).highlightColor,
                          prefixIcon: const Icon(Icons.account_tree),      
                          hintText: 'actual url...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide(color: Theme.of(context).primaryColor))
                        )
                      )
                    ),
                  ),
                  getIconOffset("go to data(s)", Icons.send, 20, () { AppRouter.navigateTo(controller.text); }, true),
              ]
            )
          ),
          Flexible( flex: 1, child: Row ( mainAxisAlignment: MainAxisAlignment.end, children: actions ))
        ];
      }
      return Container( 
        height: 40, 
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          boxShadow: [  BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: rows));
  }
}
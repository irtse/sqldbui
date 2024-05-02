import 'dart:developer' as developer;
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/utils/grid.dart';

GlobalKey<ActionBarState> globalActionBar = GlobalKey<ActionBarState>();
class ActionBarWidget extends StatefulWidget {
  final MenuWidgetState menu;
  final model.View? view;
  final DataFormWidget? form;
  final DatagridWidget? grid;
  final GlobalKey<GridWidgetState>? gridKey;
  const ActionBarWidget ({ Key? key, this.view, required this.menu, this.gridKey, this.grid, this.form}): super(key: key);
  @override ActionBarState createState() => ActionBarState();
}
class ActionBarState extends State<ActionBarWidget> {
  @override Widget build(BuildContext context) {
      List<Widget> actions = <Widget>[];
      if (viewID != null) {
        actions.add(Column(
            children: [IconButton( constraints: const BoxConstraints(),
              tooltip: "refresh page",
              style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) { return Colors.green; }
                          return Theme.of(context).primaryColor;
                        }), ),
              icon: Icon( Icons.refresh, color: Theme.of(context).highlightColor, ),
              onPressed: () {  
                globalOffset = 0;
                globalMainViewKey.currentState?.refreshUrl(currentView?.linkPath != "" ? currentView?.linkPath
                  : currentView?.actionPath.replaceAll("rows=all", "rows=${subViewID ?? viewID}"), subViewID, true); },
            )],
        ));
      }
      if (widget.gridKey != null) {
        if (isFilter()) {
          actions.add(
          Column(
            children: [IconButton( constraints: const BoxConstraints(),
                tooltip: "reset filter",
                style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                icon: Icon( Icons.filter_alt_off, color: Theme.of(context).highlightColor, size: 20 ), 
                onPressed: () async { 
                  globalOrder.remove(viewID);
                  globalFilter.remove(viewID);
                  globalNew = false;
                  globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                },
              ),],
          )
        );
      }
      actions.add(
          Column(
            children: [IconButton( constraints: const BoxConstraints(),
                tooltip: "reset ui change",
                style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                icon: Icon( Icons.auto_fix_off, color: Theme.of(context).highlightColor, size: 20 ), 
                onPressed: () { 
                  homeKey.currentState?.setState(() { 
                    globalOffset = 0; 
                    rects.remove(viewID);
                  });
                },
              ),]));
      }
      var row = <Widget>[];
      if (subViewID != null && AppRouter.routedSubID == null) {
        row.add(IconButton( 
                tooltip: "back to list", constraints: const BoxConstraints(),
                style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) { return Colors.green; }
                        return Theme.of(context).primaryColor;
                      }), ),
                icon: Icon( Icons.arrow_back, color: Theme.of(context).highlightColor, ),
                onPressed: () {
                  globalMainViewKey.currentState?.refresh(viewID, null, category, beforeView, true);
                },
              ));
      }
      row.addAll([Flexible(child: Text(overflow: TextOverflow.ellipsis,
                    widget.view == null ? (globalLoading ? "LOADING" : "HOME") : widget.view!.name.replaceAll("_", " ").replaceAll("db", "").toUpperCase(), 
                    style: TextStyle( color: Theme.of(context).highlightColor ))),
                  Padding(padding: const EdgeInsets.only(left: 10), child: Icon(widget.view == null || !widget.view!.isList ? Icons.edit_document : Icons.list, 
                  color: Theme.of(context).splashColor, size: widget.view == null || !widget.view!.isList ? 20 : 25, )),
                  Flexible(child: Text(widget.view == null || widget.view!.max == 0 ? "" : "   ${widget.view!.max} items founded",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle( fontSize: 11, color: Theme.of(context).splashColor ))),],);
      String path = "";
      if (viewID != null) { path += "#$viewID${ subViewID != null ? ":$subViewID" : "" }"; }
      var controller = TextEditingController(text: path);
      if (widget.view != null) {
        if (globalLoading) { Future.delayed(const Duration(seconds: 1), () { globalLoaderMainViewKey.currentState?.setState(() { globalLoading = false; }); }); }
      }
      List<Widget> rows = [];
      if (MediaQuery.of(context).size.width > 700) {
        rows = [ Flexible(flex: 1, child: Row( children: row,)),
                 Flexible( flex: 1, child: Row( children: [ Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, top: 5, bottom: 5),
                      child: TextFormField(
                        cursorHeight: 15,
                        style: TextStyle(height: 1, color: Theme.of(context).highlightColor, fontSize: 12),
                        controller: controller,
                        onSaved: (value) {
                          var split = controller.text.split('/');
                          if (split.length > 1) {
                            viewID = split[1];
                            if (split.length > 2) { subViewID = split[2]; }
                          }
                          globalMainViewKey.currentState?.refresh(
                            split.length > 1 ? split[1] : null, 
                            split.length > 2 ? split[1] : null, 
                            null, null, true);
                        },
                        decoration: InputDecoration(
                        filled: true,
                        labelStyle: TextStyle(color: Theme.of(context).splashColor),
                        hintStyle: TextStyle(color: Theme.of(context).splashColor),
                        contentPadding: const EdgeInsets.all(1),
                        fillColor: Theme.of(context).secondaryHeaderColor,
                        iconColor: Theme.of(context).highlightColor,
                        prefixIcon: const Icon(Icons.account_tree),      
                        hintText: 'actual url...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), 
                                                   borderSide: BorderSide(color: Theme.of(context).primaryColor))
                    ))),
                  ),
                  IconButton( constraints: const BoxConstraints(),
                    tooltip: "go to data(s)",
                    style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) { return Colors.transparent; }), ),
                    icon: Icon( Icons.send, color: Theme.of(context).splashColor, size: 20,),
                    onPressed: () { AppRouter.navigateTo(controller.text); },
                  )]
                )),
                Flexible( flex: 1, child: Row ( mainAxisAlignment: MainAxisAlignment.end, children: actions ))];
      }
      return Container( height: 40, padding: const EdgeInsets.symmetric(horizontal: 30),
        width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5),
                      spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ]),
        child: Row(mainAxisSize: MainAxisSize.min, children: rows));
  }
}
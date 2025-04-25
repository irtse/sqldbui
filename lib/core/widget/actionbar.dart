import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
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
import 'package:sqldbui2/page/translate.dart';

bool translation = true;
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
    return FutureBuilder(future: futureBuild(context), builder: (b, a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async{
      List<Widget> actions = <Widget>[];
      if (viewID != null && currentView!.isList) {
        actions.add( getIconOffset(!translation ? TranslateConstants.translationOFF.toLowerCase() : TranslateConstants.translationON.toLowerCase(), 
        !translation ? Icons.translate : Icons.g_translate, null, () {
          translation = !translation;
          globalMainViewKey.currentState?.setState(() { });
        }, false));
      }
      if (widget.gridKey != null) {
        actions.add( getIconOffset(TranslateConstants.resetUI.toLowerCase(), Icons.auto_fix_off, 20, () {
            globalOffset = 0;
            globalMainViewKey.currentState?.setState(() {rects.remove(viewID); });
          }, false)
        );
      }
      if (currentView != null && (currentWidth - menuSize) > 650) {
        if (currentView!.shortcuts.keys.length == 1) {
          var t = await getOnFlow(currentView!.shortcuts.keys.first);
          actions.add(
            InkWell( 
                onTap: () { AppRouter.navigateTo(currentView!.shortcuts[currentView!.shortcuts.keys.first]); }, 
                child: Container(
                  margin:  const EdgeInsets.only(top: 5, bottom: 5, left: 5),
                  padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 20), 
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(30))),
                  width: (currentWidth / 8) > 200 ? 200 : currentWidth / 8,
                  child: Center( 
                    child: Text(t.toLowerCase(), overflow: TextOverflow.ellipsis, 
                      style: const TextStyle( color: Colors.white, fontSize: 12 )))
              )
            )
          );
        } else if (currentView!.shortcuts.isNotEmpty) {
          List<Widget> items = [];
          double maxWidth = 0;
          for (var short in currentView!.shortcuts.keys) {
            var t = (await getOnFlow(short)).toLowerCase();
            if ((t.length * 12) > maxWidth) {
              maxWidth = t.length * 12;
            }
            items.add(
              InkWell( 
                onTap: () { 
                  AppRouter.navigateTo(currentView!.shortcuts[currentView!.shortcuts.keys.first]); 
                  Navigator.pop(context);
                },
                child: 
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(
                        color: currentView!.shortcuts.keys.last == short ? Colors.transparent : Colors.grey.shade200
                      ))
                    ),
                    padding: EdgeInsets.all(10),
                    width: maxWidth,
                    child: Center( child: Row( children: [ 
                      Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.arrow_right, color: Colors.grey)),
                      Text(t) 
                    ]))
                )
              )
            );
          }
          actions.add(
            PopupButtonWidget(
              tooltip: 'shortcuts',
              width: maxWidth,
              icon: Icons.menu,
              color: Colors.white,
              widget: Column(children: items),
            )
          );
        }
      }
      var row = <Widget>[];
      row.addAll([
        getDescription(
          (widget.view == null ? (
            globalLoading ? TranslateConstants.loading : TranslateConstants.home) 
          : await getOnFlow(excludeDB(widget.view!.name))).toLowerCase(),  
          null, Theme.of(context).highlightColor),
        Padding(
          padding: const EdgeInsets.only(left: 10), 
          child: Icon(
            widget.view == null || !widget.view!.isList ? Icons.edit_document : Icons.list, 
            color: Theme.of(context).splashColor, 
            size: widget.view == null || !widget.view!.isList ? 20 : 25, 
          )
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10), 
          child:getDescription(widget.view == null || !widget.view!.isList ? "" : "${widget.view!.max} ${TranslateConstants.found.toLowerCase()}", 
            11, Theme.of(context).splashColor),
        )
      ]);
      String path = "";
      if (viewID != null) { path += "$viewID${ subViewID != null ? ":$subViewID" : "" }"; }
      var controller = TextEditingController(text: path);
      if (widget.view != null && globalLoading) { 
        Future.delayed(const Duration(seconds: 1), () { globalLoaderMainViewKey.currentState?.setState(() { globalLoading = false; }); }); 
      }
      List<Widget> rows = [];
      if (currentWidth > 700) {
        rows = [ 
          Flexible(child: Row( children: row,)),
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
                          hintText: TranslateConstants.url.toLowerCase(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide(color: Theme.of(context).primaryColor))
                        )
                      )
                    ),
                  ),
                  getIconOffset(TranslateConstants.goto.toLowerCase(), Icons.send, 20, () { AppRouter.navigateTo(controller.text); }, true),
              ]
            )
          ),
          Flexible( flex: 1, child: Row ( mainAxisAlignment: MainAxisAlignment.end, children: actions ))
        ];
      }
      return Container( 
        height: 40, 
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          boxShadow: [  BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: rows));
  }
}
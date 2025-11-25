import 'package:sqldbui2/core/widget/datagrid/buttons/datagrid_button.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/dialog/link_box.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/dialog/trigger_box.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
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
import 'package:sqldbui2/page/page.dart';
import 'package:sqldbui2/page/translate.dart';

MultiSelectController<String> navigatorCtrls = MultiSelectController<String>();
bool translation = true;
GlobalKey<ActionBarState> globalActionBar = GlobalKey<ActionBarState>();
class ActionBarWidget extends StatefulWidget {
  model.View? view;
  final DataFormWidget? form;
  final DatagridWidget? grid;
  final GlobalKey<GridWidgetState>? gridKey;
  ActionBarWidget ({ super.key, required this.view, this.gridKey, this.grid, this.form});
  @override ActionBarState createState() => ActionBarState();
}
class ActionBarState extends State<ActionBarWidget> {
  Future<Widget> getDescription(String content, double? size, Color color) async {
    return Flexible( child: Text((await getOnFlow(content)), overflow: TextOverflow.ellipsis, style: TextStyle( fontSize: size, color: color ) ));
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

  List<model.Trigger> getTriggers(GlobalKey<FormWidgetState> form) {
    var triggers = form.currentState?.widget.view?.triggers.where( (e) => e.mode == "mail").toList() ?? [];
    form.currentState?.widget.wrappersGlobalKey.forEach( (f) {
      triggers.addAll(getTriggers(f));
    });
    return triggers;
  }
  Future<Widget> futureBuild(BuildContext context) async{
    try {
      List<Widget> actions = <Widget>[];
      if (viewID != null && widget.view != null) {
        if (widget.view!.isList) {
          if (allSelected || selectedGrid.isNotEmpty) {
            if (modeIndex == 1) {
              actions.add(DatagridButtonWidget(selectedGrid: selectedGrid, schema: widget.view?.schema ?? {}, mode: "update"));
            } else if (modeIndex == 2) {
              actions.add(DatagridButtonWidget(selectedGrid: selectedGrid, schema: widget.view?.schema ?? {}, mode: "delete"));
            } else {        
              actions.addAll([
                PopupButtonWidget(
                  tooltip: (currentView!.isList ? TranslateConstants.rowsListExport : TranslateConstants.rowsExport).toLowerCase(),
                  icon: Icons.file_download,
                  widget: MappingPopUpWidget(isExport: true, format: "csv")
                )
              ]);
            }
            if (currentView != null && currentView!.isList && currentView!.actions.contains("post") && (currentView?.schemaNew.isNotEmpty ?? false)) {
              actions.add(
                getIconOffset((await getOnFlow("new document")).toLowerCase(), 
                  Icons.new_label, 20, () async {
                    var label = await getOnFlow("create new document");
                    String desc = "";
                    if (currentView!.multiPath.length > 1) {
                      desc = await getOnFlow("BEWARE ! it can be another type than one wished, it's a top level type <${currentView!.schemaName.replaceAll("_", " ").replaceAll("db", "")}>");
                    }
                    cacheForm = {};
                    oneToManiesForm = {};
                    oneToManiesStateForm = {};
                    showDialog(
                      // ignore: use_build_context_synchronously
                      context: context, 
                      barrierDismissible: true,
                      builder: (builder) {
                        var newView = model.View(
                          actions: currentView!.actions,
                          category: currentView!.category,
                          isEmpty: true,
                          items: [model.Item(values: { "description": desc })],
                          schema: currentView!.schemaNew,
                          schemaID: currentView!.schemaID,
                          schemaName: currentView!.schemaName,
                          rules: currentView!.rules,
                          name: label.toLowerCase(),
                          order: currentView!.order,
                        );
                        return Center(
                        child: Material(
                          color: Colors.transparent,
                          elevation: 12,
                          borderRadius: BorderRadius.circular(16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: currentWidth - 100, 
                              maxHeight: currentHeigth - 100, 
                              minWidth: 300,
                              minHeight: 200,
                            ),
                            child:Center( child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    width: currentWidth - 100,
                                    height: currentHeigth - 100,
                                    child: DataFormWidget(view: newView, onlyDraft: true, noSub: true, subForm: false, key: mainForm, width: currentWidth - 100)
                           ))
                        ) ));
                      }
                    );
                  }, false)
              );
            }
            if (currentView != null && currentView!.isList && currentView!.actions.contains("import")) {
              actions.add(
                PopupButtonWidget(
                  tooltip: TranslateConstants.rowsImport,
                  icon: Icons.upload,
                  widget: MappingPopUpWidget(isExport: true, format: "csv")
                )
              );
            }
          }
        } else if (currentView?.items.isNotEmpty ?? false) { 
          if (mainForm.currentState != null && !currentView!.readOnly) {
            if (currentView!.actions.contains("put") && !currentView!.isEmpty) {
              var triggers = getTriggers(mainForm);
              if (triggers.isNotEmpty) {
                actions.add(getIconOffset((await getOnFlow(TranslateConstants.sendMail)).toLowerCase(), 
                  Icons.mail, 20, () {
                    showDialog(
                      context: context, 
                      barrierDismissible: false,
                      builder: (builder) => TriggerBoxWidget(
                            triggers: triggers, isCached: false)
                    );
                  }, false));
              }
            }
          }
        }
      if (!(currentView?.isEmpty ?? false) && !widget.view!.isList && (currentView?.items.isNotEmpty ?? false)) {
          actions.add(Padding( padding: EdgeInsets.only(left: 20),
                child: LinkBoxWidget(
                  isDelete: true,
                  color: Colors.white,
                  path: "@${currentView?.schemaID}:${currentView?.id}",
                  sharing: currentView?.items.first.sharing,
                )));
          actions.add(Padding( padding: EdgeInsets.only(right: 10),
                child: LinkBoxWidget(
                  isDelete: false,
                  color: Colors.white,
                  path: "@${currentView?.schemaID}:${currentView?.id}",
                  sharing: currentView?.items.first.sharing,
                )));
        }
      }
      if (widget.view != null && (currentWidth - menuSize) > 650) {
        if (widget.view!.shortcuts.keys.length == 1) {
          var t = await getOnFlow(widget.view!.shortcuts.keys.first);
          actions.add(
            InkWell( 
                onTap: () { AppRouter.navigateTo(widget.view!.shortcuts[widget.view!.shortcuts.keys.first]); }, 
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
        } else if (widget.view!.shortcuts.isNotEmpty) {
          List<Widget> items = [];
          double maxWidth = 0;
          for (var short in widget.view!.shortcuts.keys) {
            var t = (await getOnFlow(short)).toLowerCase();
            if ((t.length * 12) > maxWidth) {
              maxWidth = t.length * 12;
            }
            items.add(
              InkWell( 
                onTap: () { 
                  AppRouter.navigateTo(widget.view!.shortcuts[widget.view!.shortcuts.keys.first]); 
                  Navigator.pop(context);
                },
                child: 
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(
                        color: widget.view!.shortcuts.keys.last == short ? Colors.transparent : Colors.grey.shade200
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
      try {
        row.add(await getDescription(
          (widget.view == null ? (globalLoading ? TranslateConstants.loading : TranslateConstants.home)
          : (widget.view!.label ?? widget.view!.name)).toLowerCase(),  
          // ignore: use_build_context_synchronously
          null, Theme.of(context).highlightColor));
      } catch(e) {
        row.add(await getDescription(
          (widget.view == null ? (  globalLoading ? TranslateConstants.loading : TranslateConstants.home) 
          : (widget.view!.name != "" ? excludeDB(widget.view!.name)  : "")).toLowerCase(),  
          // ignore: use_build_context_synchronously
          null, Theme.of(context).highlightColor));
      }
      row.add(Padding(
          padding: const EdgeInsets.only(left: 10), 
          child: Icon(
            widget.view == null || !(widget.view?.isList ?? false)  ? Icons.edit_document : Icons.list, 
            // ignore: use_build_context_synchronously
            color: Theme.of(context).splashColor, 
            size: widget.view == null || !(widget.view?.isList ?? false) ? 20 : 25, 
          )
        ));
      if (widget.view != null && (widget.view?.isList ?? false)) {
        row.add(
          Padding(
            padding: const EdgeInsets.only(left: 10), 
            child: Text("${ !allSelected ? "${selectedGrid.length}/" : ""}${widget.view == null ? "0" : widget.view?.max} ${(await getOnFlow(TranslateConstants.found)).toLowerCase()}", 
            overflow: TextOverflow.ellipsis, style: TextStyle( fontSize: 11, color: Theme.of(context).splashColor ) )
          )
        );
      }
      String path = "";
      if (viewID != null) { path += "$viewID${ subViewID != null ? ":$subViewID" : "" }"; }
      var controller = TextEditingController(text: path);
      List<Widget> rows = [];
      if (currentWidth > 700) {
        List<DropdownItem<String>> items = [];
        for (var v in pageViews) {
          var i = items.where( (e) => e.value == "${v.id}");
          if (i.isEmpty) {
            items.add(DropdownItem<String>(selected: viewID?.replaceAll("#", "") == "${v.id}" && (subViewID ?? "") == "",
              value: "#${v.id}", label: (await getOnFlow(v.label ?? v.name)).toLowerCase()));
          } else {
            i.first.selected = viewID?.replaceAll("#", "") == "${v.id}" && (subViewID ?? "") == "";
          }
        }
        if (currentView != null && (subViewID ?? "") != "") {
            items.add(DropdownItem<String>( selected: true,
              value: "@${currentView!.id}${ currentView!.items.isNotEmpty ? ":${currentView!.items.first.values["id"]}" : "" }", 
              label: "${(await getOnFlow(currentView!.label ?? currentView!.name)).replaceAll("_", "").replaceAll("db", "")} -> ${ 
                currentView!.items.isNotEmpty ? await getOnFlow(currentView!.items.first.values["name"] ?? "data") : ""}".toLowerCase()));
        }
        var dp = MultiDropdown<String>(
        controller: navigatorCtrls,
        enabled: true,
        singleSelect: true,
        items: items,
        searchEnabled: true,
        style: TextStyle(color: Colors.grey.shade200),
        chipDecoration: ChipDecoration(
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
        ),                             // ignore: use_build_context_synchronously
        fieldDecoration: FieldDecoration(
                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                          padding: const EdgeInsets.all(1),
                          backgroundColor: Theme.of(context).secondaryHeaderColor,
                          labelStyle: TextStyle(fontSize: 0),
                          hintText: await getOnFlow(TranslateConstants.url.toLowerCase()),
                          hintStyle: TextStyle(color: Theme.of(context).splashColor, fontSize: 15),
                          prefixIcon: Icon(Icons.account_tree, size: 18,  color: Theme.of(context).splashColor),
                          showClearIcon: false,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), 
                            // ignore: use_build_context_synchronously
                            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), 
                            // ignore: use_build_context_synchronously
                            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        ),
        searchDecoration: SearchFieldDecoration(
                          hintText: "       ${(await getOnFlow(TranslateConstants.search)).toLowerCase()}",
                          border : const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder : const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(5)))
        ),
        dropdownDecoration: DropdownDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          marginTop: 2,
                          maxHeight: 400,
                          header: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "       ${(await getOnFlow(TranslateConstants.selectValue)).toLowerCase()}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        dropdownItemDecoration: DropdownItemDecoration(
                          backgroundColor: Theme.of(context).highlightColor,
                          selectedIcon:
                              const Icon(Icons.check_box, color: Colors.green),
                          disabledIcon:
                              Icon(Icons.lock, color: Colors.grey.shade300),
                        ),
                        validator: (value) {
                          if ((value == null || value.isEmpty)) {
                            return '';
                          }
                          return null;
                        },
                        onSelectionChange: (values) {
                          if (values.isNotEmpty) {
                            AppRouter.navigateTo(values[0]);
                          }
                        },
        );
        rows = [ 
          Flexible(child: Row( children: row)),
          Flexible( 
            flex: 1, 
            child: Row( 
              children: [ 
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, top: 5, bottom: 5),
                      child: dp, /* TextFormField(
                        cursorHeight: 15,
                        // ignore: use_build_context_synchronously
                        style: TextStyle(height: 1, color: Theme.of(context).highlightColor, fontSize: 12),
                        controller: controller,
                        decoration: InputDecoration( 
                          filled: true,
                          // ignore: use_build_context_synchronously
                          labelStyle: TextStyle(color: Theme.of(context).splashColor),
                          // ignore: use_build_context_synchronously
                          hintStyle: TextStyle(color: Theme.of(context).splashColor),
                          contentPadding: const EdgeInsets.all(1),
                          // ignore: use_build_context_synchronously
                          fillColor: Theme.of(context).secondaryHeaderColor,
                          // ignore: use_build_context_synchronously
                          iconColor: Theme.of(context).highlightColor,
                          prefixIcon: const Icon(Icons.account_tree),      
                          hintText:  await getOnFlow(TranslateConstants.url.toLowerCase()),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), 
                            // ignore: use_build_context_synchronously
                            borderSide: BorderSide(color: Theme.of(context).primaryColor))
                        )
                      ) */
                    ), 
                  ),
                  getIconOffset( await getOnFlow(TranslateConstants.goto.toLowerCase()), 
                  Icons.send, 20, () { AppRouter.navigateTo(controller.text); }, true),
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
          // ignore: use_build_context_synchronously
          color: Theme.of(context).secondaryHeaderColor,
          boxShadow: [  BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: rows)); 
    } catch(e,s) {
      print(e);
      print(s);
      return Container();
    }     
  }
}
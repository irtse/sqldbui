import 'dart:math';

import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'dart:developer' as developer;

import 'package:sqldbui2/page/page.dart';
bool isMenu = true;
double menuSize = 250;
bool done = true;
Map<String, List<model.View>> categories = <String, List<model.View>>{};
GlobalKey<MenuWidgetState> globalMenuKey = GlobalKey<MenuWidgetState>();
class MenuWidget extends StatefulWidget{
  const MenuWidget ({ Key? key}): super(key: key);
  @override MenuWidgetState createState() => MenuWidgetState();
}
bool globalLoading = true;
class MenuWidgetState extends State<MenuWidget> {
  TextEditingController controller = TextEditingController();
  Map<String, bool> initiallyExpanded = {};
  @override Widget build(BuildContext context) {
    var additionnalContent = <Widget>[];
    var id = homeKey.currentState!.widget.viewID;
    if (views != null && views!.isNotEmpty) { 
      model.View? view;
      for (var v in views!) {
        if ('${v.id}' == id) { view = v; break; }
      }
      if (view == null && views != null && views!.isNotEmpty) { view = views![0]; }
      if (view != null) {
        if (APIService.cache.containsKey(view.linkPath) && !firstAPI) { globalLoading = false; }
        if (firstAPI) { globalOffset = 0; }
        if (homeKey.currentState!.widget.subViewID == null || AppRouter.routedSubID != null) {
          additionnalContent.add(FutureBuilder<APIResponse<model.View>>(
          future: view.isList ? APIService().getWithOffset<model.View>("${view.linkPath}${AppRouter.routedSubID != null ? "&id=%25${AppRouter.routedSubID}%" : ""}", firstAPI || AppRouter.routedSubID != null, context)
          : APIService().get<model.View>(view.linkPath, firstAPI, context), // a previously-obtained Future<String> or null
          builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
              if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) { 
                currentView = snap.data!.data![0];
                if (homeKey.currentState!.widget.subViewID != null || AppRouter.routedSubID != null) {
                  var subID = AppRouter.routedSubID ?? homeKey.currentState!.widget.subViewID!;
                  model.Item? item;
                  for (var v2 in currentView!.items) {
                    if (v2.values['id'] == subID) { item = v2; break; }
                  }
                  if (item != null && item.linkPath != "") {
                    homeKey.currentState!.widget.subViewID = subID;
                    // AppRouter.routedSubID = null;
                    return FutureBuilder<APIResponse<model.View>>(
                      future: APIService().get<model.View>(item.linkPath, firstAPI, null), // a previously-obtained Future<String> or null
                      builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> sn) {
                      if (sn.hasData && sn.data!.data != null && sn.data!.data!.isNotEmpty) { currentView=sn.data!.data![0]; }
                      return ViewWidget(key: currentView != null ? globalViewKey : null, menu: this,);
                    });
                  }
                }   
              }
              if (homeKey.currentState!.widget.viewID == null) {
                homeKey.currentState!.widget.viewID = view!.id.toString();
                homeKey.currentState!.widget.subViewID = null;
              }
              if (currentView != null) { currentCat = currentView!.category; }
              return ViewWidget(key: currentView != null ? globalViewKey : null, menu: this);
          }));
        } else { additionnalContent.add(ViewWidget(key: globalViewKey, menu: this)); }
      }
    }
    var eldestCat = categories;
    categories = <String, List<model.View>>{};
    if (views != null) {
      for (var view in views!) {
        if (controller.text != "" && !view.name.toLowerCase().contains(controller.text.toLowerCase())) { continue; }
        var cat = view.category == "" ? "general" : view.category;
        if (!categories.containsKey(cat)) {  categories[cat] = <model.View>[]; }
        if (eldestCat.containsKey(cat)) {
          for (var v in eldestCat[cat]!) {
            if (v.id == view.id || v.name == view.name) { 
              if (view.newIds.length < v.newIds.length - 1 && view.items.isNotEmpty) { 
                view.newIds = v.newIds; 
              }
              break; 
            }
          }
        }
        categories[cat]!.add(view);
      }
    }
    List<Widget> comps = <Widget>[Container(
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          border: const Border(bottom: BorderSide(color: Colors.black, width: 0.5))
        ),
        child: Padding( padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10), child : Container(height: 30, width: 230, child:TextFormField(
                        cursorHeight: 15,
                        style: TextStyle(height: 1, color: Theme.of(context).highlightColor, fontSize: 11),
                        controller: controller,
                        onChanged: (value) => setState(() { }),
                        decoration: InputDecoration(
                        filled: true,
                        labelStyle: TextStyle(color: Theme.of(context).highlightColor),
                        hintStyle: TextStyle(color: Theme.of(context).splashColor),
                        contentPadding: const EdgeInsets.all(2),
                        fillColor: Theme.of(context).selectedRowColor,
                        iconColor: Theme.of(context).highlightColor,
                        prefixIcon: Icon(Icons.filter_alt, size: 20, color: Theme.of(context).splashColor,),
                        hintText: 'filter menu...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), 
                                                   borderSide: BorderSide(color: Theme.of(context).primaryColor))
                      )
        ),
      )))];
      var first = true;
      for (var cat in categories.keys) {
        var count = 0;
        if (categories[cat]!.isNotEmpty) {
          if (!initiallyExpanded.containsKey(cat)) { initiallyExpanded[cat] = first; }
          first = false;
          for (var catIndex in categories[cat]!) { count += catIndex.newIds.length; }
          List<Widget> badgeCat = count > 0 && !initiallyExpanded[cat]! ? [Positioned(left: 180, top: 13, child: Container(
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                      color: Theme.of(context).primaryColor),
            child: Padding(padding: const EdgeInsets.all(5), child: Text("$count", 
              style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),))
          ))] : [];
          comps.add(Container(
          width: menuSize,
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            border: Border(bottom: BorderSide(color: Colors.black, width: 0.4))
          ),
          margin: const EdgeInsets.only(bottom: 0.3),
          child: Stack( children: [ ExpansionTile(
            shape: const ContinuousRectangleBorder(side: BorderSide(color: Colors.transparent)),
            onExpansionChanged: (value) => setState(() {
              initiallyExpanded[cat] = value;
            }),
            initiallyExpanded: initiallyExpanded[cat]!,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            title: Row( children: [Padding(padding: const EdgeInsets.only(right: 10),
                                           child: Icon(Icons.bookmark, color: Theme.of(context).splashColor,),), 
              Text(cat.toUpperCase(), style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 11,),) ]), 
            iconColor: isMenu ? Theme.of(context).highlightColor : Colors.transparent, 
            collapsedIconColor: isMenu ? Theme.of(context).highlightColor : Colors.transparent,
            children: [ Container(
                width: menuSize,
                height: categories[cat]!.length * 40,
                color: Theme.of(context).secondaryHeaderColor,
                child: ListView.builder(
                  itemBuilder: (builder, index) {
                      if (index == 0 && homeKey.currentState!.widget.viewID == null && homeKey.currentState!.widget.subViewID == null) { 
                        homeKey.currentState!.widget.viewID = '${categories[cat]![index].id}';
                        if (homeKey.currentState!.widget.subViewID != null && currentView != null) {
                          homeKey.currentState!.widget.subViewID = "${currentView!.id}";
                        }
                      }
                      if (categories[cat] == null) { return null; }
                      var category = categories[cat]!;
                      if (category.length <= index) { return null; }
                      var catIndex = category[index];
                      List<Widget> badge = catIndex.newIds.isNotEmpty ? [Positioned(left: 220, top: 8, child: Container(
                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                    color: Theme.of(context).primaryColor),
                          child: Padding(
                            padding: const EdgeInsets.all(5), child: Text("${catIndex.newIds.length}", 
                            style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),))
                        ))] : [];
                      return Stack( alignment: Alignment.topRight,
                        children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.black, width: index == 0 ? .5 : .25), bottom: BorderSide(color: Colors.black, width: .25)),
                            color: "${catIndex.id}" == homeKey.currentState!.widget.viewID ? Theme.of(context).selectedRowColor : Colors.transparent,
                          ),
                          child:  Container(
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 10)),
                            color: "${catIndex.id}" == homeKey.currentState!.widget.viewID ? Theme.of(context).selectedRowColor : Colors.transparent,
                          ), child: Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                          selected: "${catIndex.id}" == homeKey.currentState!.widget.viewID,
                          onTap: () async { refresh(catIndex.id, cat, false); },
                          tileColor: Theme.of(context).secondaryHeaderColor,
                          iconColor: Theme.of(context).splashColor,
                          title: Text(catIndex.name, style: const TextStyle(fontSize: 13.0,)),
                          visualDensity: const VisualDensity(vertical: -4), // to compact
                          textColor: Colors.white,
                          selectedColor: Colors.white,
                          hoverColor: Theme.of(context).selectedRowColor,
                          leading: catIndex.isList ? const Icon(Icons.list) : const Icon(Icons.edit_document),
                      )))), ...badge] ); 
                  },
                ),
              )
          ],)]..addAll(badgeCat),
        )));
      }
    }
    firstAPI = false;
    List<Widget> content = [];
    if (globalLoading) {
      content.add(Stack(children: additionnalContent..add(
                    Container( width: MediaQuery.of(context).size.width - menuSize, height: MediaQuery.of(context).size.height - 40,
                              color: Theme.of(context).secondaryHeaderColor.withOpacity(0.5),
                              child: const SpinKitCircle(color: Colors.white, size: 100.0,))
                    ),));
    } else { content = additionnalContent; }
    if ((homeKey.currentState!.widget.viewID == null || homeKey.currentState!.widget.viewID == "") && done) {
      done = false;
    }
    menuSize = isMenu ? 250 : 0;
    content = [ 
      FutureBuilder<void>(future: Future.delayed(const Duration(seconds: 2)), 
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Container( color: Theme.of(context).secondaryHeaderColor,
          width: menuSize, height: MediaQuery.of(context).size.height - 40, child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: comps ),),); }), ...content];
    if (!isMenu) { return Row(crossAxisAlignment: CrossAxisAlignment.start, children: content); }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: content);
  }
  void refresh(int id, String? cat, bool forceFirstAPI) {
    setState(() {
      AppRouter.routedSubID = null;
      globalLoading =  globalFilter.containsKey(id) && globalFilter[id]!.isNotEmpty || globalOrder.containsKey(id) && globalFilter[id]!.isNotEmpty ;
      firstAPI =  forceFirstAPI || globalFilter.containsKey(id) && globalFilter[id]!.isNotEmpty || globalOrder.containsKey(id) && globalFilter[id]!.isNotEmpty ;
      currentView = null;
      currentCat = cat;
      globalOffset = 0;
      homeKey.currentState!.widget.category=cat;
      homeKey.currentState!.widget.subViewID=null;
      homeKey.currentState!.widget.viewID=id.toString();
    });
  }
}
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

Map<String, List<model.View>> categories = <String, List<model.View>>{};
GlobalKey<MenuWidgetState> globalMenuKey = GlobalKey<MenuWidgetState>();
class MenuWidget extends StatefulWidget{
  final List<model.View>? views;
  const MenuWidget ({ Key? key, this.views}): super(key: key);
  @override MenuWidgetState createState() => MenuWidgetState();
}
bool globalLoading = true;
class MenuWidgetState extends State<MenuWidget> {
  TextEditingController controller = TextEditingController();
  Map<String, bool> initiallyExpanded = {};
  @override Widget build(BuildContext context) {
    var additionnalContent = <Widget>[];
    var id = homeKey.currentState!.widget.viewID;
    if (widget.views != null && widget.views!.isNotEmpty) { 
      model.View? view;
      for (var v in widget.views!) {
        if ('${v.id}' == id) { view = v; break; }
      }
      if (view == null && widget.views != null && widget.views!.isNotEmpty) { view = widget.views![0]; }
      if (view != null) {
        if (APIService.cache.containsKey(view.linkPath) && !firstAPI) { globalLoading = false; }
        if (firstAPI) { globalOffset = 0; }
        if (homeKey.currentState!.widget.subViewID == null || AppRouter.routedSubID != null) {
          developer.log('LOG URL ${view.linkPath}${AppRouter.routedSubID != null ? "&id=${AppRouter.routedSubID}" : ""}', name: 'my.app.category');
          additionnalContent.add(FutureBuilder<APIResponse<model.View>>(
          future: view.isList ? APIService().getWithOffset<model.View>("${view.linkPath}${AppRouter.routedSubID != null ? "&id=%25${AppRouter.routedSubID}%" : ""}", firstAPI || AppRouter.routedSubID != null, context)
          : APIService().get<model.View>(view.linkPath, firstAPI, context), // a previously-obtained Future<String> or null
          builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
              if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) { 
                currentView = snap.data!.data![0];
                developer.log('LOG SUB ${AppRouter.routedSubID }', name: 'my.app.category');
                if (homeKey.currentState!.widget.subViewID != null || AppRouter.routedSubID != null) {
                  var subID = AppRouter.routedSubID ?? homeKey.currentState!.widget.subViewID!;
                  model.Item? item;
                  for (var v2 in currentView!.items) {
                     developer.log('LOG SUB ${AppRouter.routedSubID } ${v2.values}', name: 'my.app.category');
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
                homeKey.currentState!.widget.viewID = currentView != null ? "${currentView!.id}" : "";
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
    if (widget.views != null) {
      for (var view in widget.views!) {
        if (controller.text != "" && !view.name.toLowerCase().contains(controller.text.toLowerCase())) { continue; }
        var cat = view.category == "" ? "general" : view.category;
        if (!categories.containsKey(cat)) {  categories[cat] = <model.View>[]; }
        if (eldestCat.containsKey(cat)) {
          for (var v in eldestCat[cat]!) {
            if (v.id == view.id || v.name == view.name) { 
              if (view.newIds.length < v.newIds.length -1) { view.newIds = v.newIds; }
              break; 
            }
          }
        }
        categories[cat]!.add(view);
      }
    }
    List<Widget> comps = <Widget>[Container(
        color: Theme.of(context).selectedRowColor,
        child: Padding( padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10), child : Container(height: 30, width: 230, child:TextFormField(
                        cursorHeight: 15,
                        style: TextStyle(height: 1, color: Theme.of(context).highlightColor, fontSize: 12),
                        controller: controller,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                        filled: true,
                        labelStyle: TextStyle(color: Theme.of(context).highlightColor),
                        hintStyle: TextStyle(color: Theme.of(context).splashColor),
                        contentPadding: const EdgeInsets.all(1),
                        fillColor: Theme.of(context).secondaryHeaderColor,
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
        if (categories[cat]!.isNotEmpty) {
          var count = 0;
          if (!initiallyExpanded.containsKey(cat)) { initiallyExpanded[cat] = first; }
          first = false;
          for (var catIndex in categories[cat]!) { count += catIndex.newIds.length; }
          List<Widget> badgeCat = count > 0 && !initiallyExpanded[cat]! ? [Positioned(left: 180, top: 13, child: Container(
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                      color: Theme.of(context).secondaryHeaderColor),
            child: Padding(padding: const EdgeInsets.all(5), child: Text("$count", 
              style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),))
          ))] : [];
          comps.add(Container(
          width: 250,
          color: Theme.of(context).primaryColor,
          margin: const EdgeInsets.only(bottom: 0.3),
          child: Stack( children: [ ExpansionTile(
            onExpansionChanged: (value) => setState(() {
              initiallyExpanded[cat] = value;
            }),
            initiallyExpanded: initiallyExpanded[cat]!,
            backgroundColor: Theme.of(context).primaryColor,
            title: Row( children: [Padding(padding: const EdgeInsets.only(right: 10),
                                           child: Icon(Icons.bookmark, color: Theme.of(context).splashColor,),), 
              Text(cat.toUpperCase(), style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 11,),) ]), 
            iconColor: Theme.of(context).highlightColor, 
            collapsedIconColor: Theme.of(context).highlightColor,
            children: [ Container(
                width: 250,
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
                      return Material( child: Stack( children: [ListTile(
                        selected: "${catIndex.id}" == homeKey.currentState!.widget.viewID,
                        onTap: () async { refresh(catIndex.id, cat); },
                        tileColor: Theme.of(context).secondaryHeaderColor,
                        iconColor: Colors.white,
                        title: Padding( padding: const EdgeInsets.only(left: 10, right: 10), child: Text(catIndex.name, style: const TextStyle(fontSize: 13.0,))),
                        visualDensity: const VisualDensity(vertical: -4), // to compact
                        textColor: Colors.white,
                        hoverColor: Theme.of(context).selectedRowColor,
                        leading: catIndex.isList ? const Icon(Icons.list) : const Icon(Icons.edit_document),
                      )]..addAll(badge) )); 
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
                    Container(width: MediaQuery.of(context).size.width - 250, height: MediaQuery.of(context).size.height - 40,
                              color: Theme.of(context).secondaryHeaderColor.withOpacity(0.5),
                              child: const SpinKitCircle(color: Colors.white, size: 100.0,))
                    ),));
    } else { content = additionnalContent; }
    return Row(children: [ 
      Container( color: Theme.of(context).secondaryHeaderColor,
      height: MediaQuery.of(context).size.height - 40, child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: comps
      ),),)
    ]..addAll(content));
  }
  void refresh(int id, String? cat) {
    setState(() {
      AppRouter.routedSubID = null;
      globalLoading =  globalFilter.containsKey(id) && globalFilter[id]!.isNotEmpty || globalOrder.containsKey(id) && globalFilter[id]!.isNotEmpty ;
      firstAPI =  globalFilter.containsKey(id) && globalFilter[id]!.isNotEmpty || globalOrder.containsKey(id) && globalFilter[id]!.isNotEmpty ;
      currentView = null;
      currentCat = cat;
      globalOffset = 0;
      homeKey.currentState!.widget.category=cat;
      homeKey.currentState!.widget.subViewID=null;
      homeKey.currentState!.widget.viewID=id.toString();
    });
  }
}
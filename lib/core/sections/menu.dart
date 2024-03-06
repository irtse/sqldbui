import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'dart:developer' as developer;

import 'package:sqldbui2/main.dart';

GlobalKey<MenuWidgetState> globalMenuKey = GlobalKey<MenuWidgetState>();
class MenuWidget extends StatefulWidget{
  final List<model.View>? views;
  const MenuWidget ({ Key? key, this.views}): super(key: key);
  @override MenuWidgetState createState() => MenuWidgetState();
}
class MenuWidgetState extends State<MenuWidget> {
  bool loading = true;
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
        if (APIService.cache.containsKey(view.linkPath) && !firstAPI) { loading = false; }
        additionnalContent.add(FutureBuilder<APIResponse<model.View>>(
        future: APIService().get<model.View>(view.linkPath, firstAPI, context), // a previously-obtained Future<String> or null
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
            if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) { 
              currentView = snap.data!.data![0];
              if (homeKey.currentState!.widget.subViewID != null ) {
                var subID = homeKey.currentState!.widget.subViewID!;
                model.Item? item;
                for (var v2 in currentView!.items) {
                  if (v2.values['id'] == subID) { item = v2; break; }
                }
                if (item != null && item.linkPath != "") {
                  return FutureBuilder<APIResponse<model.View>>(
                    future: APIService().get<model.View>(item.linkPath, firstAPI, null), // a previously-obtained Future<String> or null
                    builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> sn) {
                    if (sn.hasData && sn.data!.data != null && sn.data!.data!.isNotEmpty) {
                       currentView=sn.data!.data![0];
                    }
                    if (loading) { Future.delayed(const Duration(seconds: 1), () { setState(() { loading = false; }); }); }
                    return ViewWidget(key: currentView != null ? globalViewKey : null);
                  });
                }
              }   
            }
            if (loading) { Future.delayed(const Duration(seconds: 1), () { setState(() { loading = false; }); }); }
            return ViewWidget(key: currentView != null ? globalViewKey : null);
        }));
      }
    }
    Map<String, List<model.View>> categories = <String, List<model.View>>{};
    if (widget.views != null) {
      for (var view in widget.views!) {
        var cat = view.category == "" ? "general" : view.category;
        if (!categories.containsKey(cat)) {  categories[cat] = <model.View>[]; }
        categories[cat]!.add(view);
      }
    }
    List<Widget> comps = <Widget>[Container(height: 40, width: 250, 
      margin: const EdgeInsets.only(bottom: 0.3), color:Theme.of(context).primaryColor, 
        child: Center(child: Text("VIEWS", style: TextStyle(color: Theme.of(context).splashColor)))),];
    for (var cat in categories.keys) {
      if (categories[cat]!.isNotEmpty) {
        comps.add(Container(
          width: 250,
          color: Theme.of(context).primaryColor,
          margin: const EdgeInsets.only(bottom: 0.3),
          child: ExpansionTile(
            initiallyExpanded: true,
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
                      if (index == 0 && homeKey.currentState!.widget.viewID == null) { 
                        homeKey.currentState!.widget.viewID = '${categories[cat]![index].id}';
                        if (homeKey.currentState!.widget.subViewID != null && currentView != null) {
                          homeKey.currentState!.widget.subViewID = "${currentView!.id}";
                        }
                      }
                      if (categories[cat] == null) { return null; }
                      var category = categories[cat]!;
                      if (category.length <= index) { return null; }
                      var catIndex = category[index];
                      return Material( child: ListTile(
                        selected: "${catIndex.id}" == homeKey.currentState!.widget.viewID,
                        onTap: () async {
                          setState(() {
                            loading = true;
                            currentView = null;
                            homeKey.currentState!.widget.subViewID=null;
                            homeKey.currentState!.widget.viewID='${catIndex.id}';
                          });
                        },
                        tileColor: Theme.of(context).secondaryHeaderColor,
                        iconColor: Colors.white,
                        title: Padding( padding: const EdgeInsets.only(left: 10, right: 10), child: Text(catIndex.name, style: const TextStyle(fontSize: 13.0,))),
                        visualDensity: const VisualDensity(vertical: -4), // to compact
                        textColor: Colors.white,
                        hoverColor: Theme.of(context).selectedRowColor,
                        leading: catIndex.isList ? const Icon(Icons.list) : const Icon(Icons.edit_document),
                      )); 
                  },
                ),
              )
          ],),
          ));
      }
    }
    firstAPI = false;
    List<Widget> content = [];
    if (loading) {
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
}
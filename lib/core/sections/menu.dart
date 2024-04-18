import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/view.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:sqldbui2/main.dart';

bool isMenu = true;
double menuSize = 250;
bool cantRefresh = false;
Map<String, List<model.View>> categories = <String, List<model.View>>{};
GlobalKey<MenuWidgetState> globalMenuKey = GlobalKey<MenuWidgetState>();
// ignore: must_be_immutable
class MenuWidget extends StatefulWidget{
  List<model.View>? views;
  String? url;
  MenuWidget ({ Key? key, required this.views}): super(key: key);
  @override MenuWidgetState createState() => MenuWidgetState();
}
bool globalLoading = true;
class MenuWidgetState extends State<MenuWidget> {
  TextEditingController controller = TextEditingController();
  Map<String, bool> initiallyExpanded = {};
  @override Widget build(BuildContext context) {
    var additionnalContent = <Widget>[];
    try {
      additionnalContent.add(MainViewWidget(key: globalMainViewKey, menu: this, url: widget.url,
        views: widget.views, view: widget.views?.firstWhere((v) => '${v.id}' == viewID  && viewID != "")));
    } catch (e) { additionnalContent.add(MainViewWidget(views: widget.views, menu: this, view: null, url: widget.url)); }
    var eldestCat = categories;
    categories = <String, List<model.View>>{};
    if (widget.views != null) {
      for (var view in widget.views!) {
        if (controller.text != "" && !view.name.toLowerCase().contains(controller.text.toLowerCase())) { continue; }
        var cat = view.category == "" ? "general" : view.category;
        if (!categories.containsKey(cat)) {  categories[cat] = <model.View>[]; }
        if (eldestCat.containsKey(cat)) {
          try { 
            view.newIds = eldestCat[cat]!.firstWhere((v) => view.id == v.id && view.newIds.length < v.newIds.length - 1 && view.items.isNotEmpty).newIds;
          } catch(e) { /* */ }     
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
      for (var cat in categories.keys) {
        var count = 0;
        initiallyExpanded[cat] = category == cat;
        if (categories[cat]!.isNotEmpty) {
          for (var catIndex in categories[cat]!) { count += catIndex.newIds.length; }
          List<Widget> badgeCat = count > 0 && !initiallyExpanded[cat]! ? [Positioned(left: 180, top: 13, child: Container(
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                      color: Theme.of(context).primaryColor),
            child: Padding(padding: const EdgeInsets.all(5), child: Text("$count", overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),)
          )))] : [];
          comps.add(Container(
          width: menuSize,
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            border: const Border(bottom: BorderSide(color: Colors.black, width: 0.4)) ),
          margin: const EdgeInsets.only(bottom: 0.3),
          child: Stack( children: [ ExpansionTile(
            shape: const ContinuousRectangleBorder(side: BorderSide(color: Colors.transparent)),
            initiallyExpanded: initiallyExpanded[cat]!,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            title: Row( children: [Padding(padding: const EdgeInsets.only(right: 10),
                                           child: Icon(Icons.bookmark, color: Theme.of(context).splashColor,),), 
              Flexible( child: Text(cat.toUpperCase(), overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 11))) ]), 
            iconColor: isMenu ? Theme.of(context).highlightColor : Colors.transparent, 
            collapsedIconColor: isMenu ? Theme.of(context).highlightColor : Colors.transparent,
            children: [ Container(width: menuSize, height: categories[cat]!.length * 40, color: Theme.of(context).secondaryHeaderColor,
              child: ListView.builder(itemBuilder: (builder, index) {
                if (categories[cat] == null || categories[cat]!.length <= index) { return null; }
                var catIndex = categories[cat]![index];
                List<Widget> badge = catIndex.newIds.isNotEmpty ? [Positioned(left: 220, top: 8, child: Container(
                  decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).primaryColor),
                  child: Padding(padding: const EdgeInsets.all(5), child: Text("${catIndex.newIds.length}", 
                    overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),))))] : [];
                  return Stack( alignment: Alignment.topRight, children: [
                    Container(decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black, width: index == 0 ? .5 : .25), bottom: BorderSide(color: Colors.black, width: .25)),
                        color: "${catIndex.id}" == viewID ? Theme.of(context).selectedRowColor : Colors.transparent ),
                      child:  Container(decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 10)),
                        color: "${catIndex.id}" == viewID ? Theme.of(context).selectedRowColor : Colors.transparent ), 
                      child: Material(type: MaterialType.transparency,
                        child: ListTile(
                          selected: "${catIndex.id}" == viewID,
                          onTap: () async { refreshView("${catIndex.id}", cat, false, false, false); },
                          tileColor: Theme.of(context).secondaryHeaderColor,
                          iconColor: Theme.of(context).splashColor,
                          title: Text(catIndex.name, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.0,)),
                          visualDensity: const VisualDensity(vertical: -4), // to compact
                          textColor: Colors.white,
                          selectedColor: Colors.white,
                          hoverColor: Theme.of(context).selectedRowColor,
                          leading: catIndex.isList ? const Icon(Icons.list) : const Icon(Icons.edit_document),
                      )))), ...badge] ); 
                  }))],), ...badgeCat])));
      }
    }
    firstAPI = false;
    List<Widget> content = [];
    menuSize = isMenu ? (MediaQuery.of(context).size.width < 250 ? 202 : 250) : 0;
    content = [ 
      FutureBuilder<void>(future: Future.delayed(const Duration(seconds: 2)), 
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Container( padding: const EdgeInsets.only(bottom: 80),
          color: Theme.of(context).secondaryHeaderColor,
          width: menuSize, height: MediaQuery.of(context).size.height - 40 > 0 ? MediaQuery.of(context).size.height - 40 : 0, child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: comps ),),); }), ...additionnalContent];
    if (!isMenu) { return Row(crossAxisAlignment: CrossAxisAlignment.start, children: content); }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: content);
  }
  void refresh() {
      if (widget.views == null) {
          APIService().get<model.View>(APIConstants.mainEndpost, true, null).then((value) {
          if (value.data != null) { widget.views = value.data; }
          for (var view in widget.views!) {
            if (view.id.toString() == viewID && subViewID != null) {
              try { view.newIds.remove(subViewID); } catch(e) { /* */ }     
            }
          }
          setState(() {}); 
        });
      } else {
        for (var view in widget.views!) {
          if (view.id.toString() == viewID && subViewID != null) {
            try { view.newIds.remove(subViewID); } catch(e) { /* */ }     
          }
        }
        setState(() {}); 
      }
  }
  void refreshUrl(String? path, String? id) {
    globalLoading = true;
    subViewID = id;
    widget.url = path;
    rects.remove(viewID);
    refresh();
  }
  void refreshView(String? id, String? cat, bool isFirst, bool nullable, bool full) {
    AppRouter.routedSubID = null;
    globalLoading = globalFilter.containsKey(id) && globalFilter[id]!.isNotEmpty || globalOrder.containsKey(id) && globalFilter[id]!.isNotEmpty ;
    firstAPI =  isFirst || globalFilter.containsKey(id) && globalFilter[id]!.isNotEmpty || globalOrder.containsKey(id) && globalFilter[id]!.isNotEmpty ;
    globalOffset = 0;
    category=cat;
    subViewID=null;
    viewID=id.toString();
    widget.url = null;
    if (nullable) { Future.delayed(const Duration(microseconds: 500), () => currentView = null);  }
    full ? refresh() : setState(() {});
  }
}
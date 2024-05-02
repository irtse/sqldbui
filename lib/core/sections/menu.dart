import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/utils/grid.dart';
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
  bool isFavorite = false;
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
        if (controller.text != "" && !view.name.toLowerCase().contains(controller.text.toLowerCase())
        || (isFavorite && !view.isFavorize)) { continue; }
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
    List<Widget> comps = [];
    List<Widget> header = <Widget>[Container(
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          border: const Border(bottom: BorderSide(color: Colors.black, width: 0.5))
        ),
        child: Padding( padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10), child : Container(height: 30, width: 230, child:TextFormField(
                        cursorHeight: 15,
                        style: TextStyle(height: 1, color: Theme.of(context).highlightColor, fontSize: 11),
                        controller: controller,
                        onChanged: (value) => viewID == "" || viewID == null ? homeKey.currentState?.setState(() {}) : setState(() { }),
                        decoration: InputDecoration(
                        filled: true,
                        labelStyle: TextStyle(color: Theme.of(context).highlightColor),
                        hintStyle: TextStyle(color: Theme.of(context).splashColor),
                        contentPadding: const EdgeInsets.all(2),
                        fillColor: Theme.of(context).primaryColorLight,
                        iconColor: Theme.of(context).highlightColor,
                        prefixIcon: Icon(Icons.filter_alt, size: 20, color: Theme.of(context).splashColor,),
                        hintText: 'filter menu...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), 
                                                   borderSide: BorderSide(color: Theme.of(context).primaryColor))
                      )
        ),
      ))), Row(children: [
        InkWell( onTap: () { setState(() {isFavorite = false; });}, child: Container(
          decoration: BoxDecoration(
            color: isFavorite ? Theme.of(context).secondaryHeaderColor : Theme.of(context).primaryColor,
            border: const Border(bottom: BorderSide(color: Colors.black, width: 0.4), right: BorderSide(color: Colors.black, width: 0.4)) ),
          alignment: Alignment.center, height: 40, width: menuSize > 0 ? menuSize / 2 : 0, child: Icon(Icons.all_inbox, color: Theme.of(context).highlightColor,))),
        InkWell( onTap: () { setState(() { isFavorite = true; });}, child: Container(decoration: BoxDecoration(
            color: isFavorite ? Theme.of(context).primaryColor : Theme.of(context).secondaryHeaderColor,
            border: const Border(bottom: BorderSide(color: Colors.black, width: 0.4))),
          alignment: Alignment.center, height: 40, width: menuSize > 0 ? menuSize / 2 : 0, child: Icon(Icons.favorite_border, color: Theme.of(context).highlightColor))),],)
      ];
      for (var cat in categories.keys) {
        var count = 0;
        initiallyExpanded[cat] = category == cat;
        if (categories[cat]!.isNotEmpty) {
          for (var catIndex in categories[cat]!) { count += catIndex.newIds.length; }
          List<Widget> badgeCat = count > 0 && !initiallyExpanded[cat]! ? [Positioned(left: 170, top: 13, child: Container(
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(7)), color: Theme.of(context).primaryColor),
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
            title: Row( children: [Padding(padding: const EdgeInsets.only(right: 10), child: Icon(Icons.bookmark, color: Theme.of(context).splashColor,),), 
              Flexible( child: Padding( padding: EdgeInsets.only(right: "$count".isNotEmpty ? (("$count".length + 1) * 7) : 0), child: Text(cat.toUpperCase(), overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 11)))) ]), 
            iconColor: isMenu ? Theme.of(context).highlightColor : Colors.transparent, 
            collapsedIconColor: isMenu ? Theme.of(context).highlightColor : Colors.transparent,
            children: [ Container(width: menuSize, height: categories[cat]!.length * 40, color: Theme.of(context).secondaryHeaderColor,
              child: ListView.builder(itemBuilder: (builder, index) {
                if (categories[cat] == null || categories[cat]!.length <= index) { return null; }
                var catIndex = categories[cat]![index];
                List<Widget> badge = catIndex.newIds.isNotEmpty ? [Positioned(left: 220 - ("${catIndex.newIds.length}".length * 7), top: 8, child: Container(
                  decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(7)),
                    color: Theme.of(context).primaryColor),
                  child: Padding(padding: const EdgeInsets.all(5), child: Text("${catIndex.newIds.length}", 
                    overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),))))] : [];
                  return Stack( alignment: Alignment.topRight, children: [
                    Container(decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black, width: index == 0 ? .5 : .25), bottom: BorderSide(color: Colors.black, width: .25)),
                        color: "${catIndex.id}" == viewID ? Theme.of(context).primaryColorLight : Colors.transparent ),
                      child:  Container(decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 10)),
                        color: "${catIndex.id}" == viewID ? Theme.of(context).primaryColorLight : Colors.transparent ), 
                      child: Material(type: MaterialType.transparency,
                        child: ListTile(
                          selected: "${catIndex.id}" == viewID,
                          onTap: () async { refreshView("${catIndex.id}", cat, false, false, false); },
                          tileColor: Theme.of(context).secondaryHeaderColor,
                          iconColor: Theme.of(context).splashColor,
                          title: Text(catIndex.label ?? catIndex.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.0,)),
                          visualDensity: const VisualDensity(vertical: -4), // to compact
                          textColor: Colors.white,
                          selectedColor: Colors.white,
                          hoverColor: Theme.of(context).primaryColorLight,
                          trailing: Padding( padding: EdgeInsets.only(right: catIndex.newIds.isNotEmpty ? (("${catIndex.newIds.length}".length + 1) * 10) : 0), 
                            child: InkWell( onTap: () {
                              catIndex.isFavorize = !catIndex.isFavorize;
                              var urlPath = catIndex.favorizePath;
                              if (!catIndex.isFavorize) {
                                for (var k in catIndex.favorizeBody.keys) { urlPath += "&$k=${catIndex.favorizeBody[k]}"; }
                              }
                              setState(() {});
                              APIService().call(urlPath, catIndex.isFavorize ? "post" : "delete", catIndex.favorizeBody, true, null);
                            }, child: Icon( catIndex.isFavorize ? Icons.favorite : Icons.favorite_border, size: 14))),
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
        return  Column(
          children : [ ...header,
            Container( padding: const EdgeInsets.only(bottom: 80),
          color: Theme.of(context).secondaryHeaderColor,
          width: menuSize, height: MediaQuery.of(context).size.height - 121 > 0 ? MediaQuery.of(context).size.height - 121 : 0, child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: comps ),),)] ); }), ...additionnalContent];
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
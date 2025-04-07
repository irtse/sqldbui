import 'package:sqldbui2/core/sections/menu/menu_expansion_tile.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/sections/menu/menu_header.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/page/page.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/page/translate.dart';

bool isMenu = true;
double menuSize = 250;
Map<String, List<model.View>> categories = <String, List<model.View>>{};
GlobalKey<MenuWidgetState> globalMenuKey = GlobalKey<MenuWidgetState>();
// ignore: must_be_immutable
class MenuWidget extends StatefulWidget{
  List<model.View>? views;
  String? url;
  MenuWidget ({ super.key, required this.views});
  @override MenuWidgetState createState() => MenuWidgetState();
}
bool globalLoading = true;
class MenuWidgetState extends State<MenuWidget> {
  Map<String, bool> initiallyExpanded = {};
  TextEditingController controller = TextEditingController();

  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    var eldestCat = categories;
    List<model.View> views = [];
    for (var view in widget.views!) {
      var label = await getOnFlow(view.label ?? view.name);
      if (!((!label.toLowerCase().contains(MenuConstants.value?.toLowerCase() ?? "")) 
      || (MenuConstants.isFavorite && !view.isFavorize))) {
        views.add(view);
      }
    }
    categories = <String, List<model.View>>{};
    for (var view in views) {
      var cat = view.category == "" ? "general" : view.category;
      if (!categories.containsKey(cat)) {  categories[cat] = <model.View>[]; }
      if (eldestCat.containsKey(cat)) {
        try { 
          view.newIds = eldestCat[cat]!.firstWhere((v) => view.id == v.id && view.items.isNotEmpty).newIds.where(
                              (element) => notNew[viewID] == null || !notNew[viewID]!.contains(element)).toList();
        } catch(e) { /* */ }     
      }
      categories[cat]!.add(view);
    }
    List<Widget> comps = [];
    for (var cat in categories.keys) {
      var count = 0;
      initiallyExpanded[cat] = widget.views != null ? widget.views!.where(
        (element) => viewID != null && viewID!.isNotEmpty && "${element.id}" == viewID!.substring(1)).isNotEmpty : false;
      if (!categories[cat]!.isNotEmpty) { continue; }
      for (var catIndex in categories[cat]!) { 
        count += catIndex.newIds.length; 
      }
      List<Widget> badgeCat = count > 0 && !initiallyExpanded[cat]! ? [
        Positioned(left: 190 - ("$count".length * 8), top: 13, 
          child: Container(
              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(7)), color: Theme.of(context).primaryColor),
              child: Padding(
                padding: const EdgeInsets.all(5), 
                child: Text("$count", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ))
            )
          )
        )] : [];
      comps.add(Container(
        width: noMenu ? 300 : menuSize,
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          border: const Border(bottom: BorderSide(color: Colors.black, width: 0.4)) 
        ),
        margin: const EdgeInsets.only(bottom: 0.3),
        child: Stack( children: [
          MenuExpansionTileWidget(
            count: count,
            category: cat, 
            isExpanded: initiallyExpanded[cat]!, 
            refreshView: refreshView), 
          ...badgeCat
        ])
      ));
    }
    comps.add(SizedBox(height: 10,));
    firstAPI = false;
    noReload = false;
    var height = noMenu ? MediaQuery.of(context).size.height - 81 : MediaQuery.of(context).size.height - 162;
    return Column( children : [ 
      MenuHeaderWidget(controller: controller), 
      SizedBox( height: height > 0 ? height : 0,
        child: SingleChildScrollView( 
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: comps )
        )
      )
    ]);
  }
  void refresh(bool getView) {
      filterRowsWidget = []; functionMathRowsWidget = [];
      selectedGrid = []; unselectedGrid = [];
      detectChanges = {};
      cacheChanges = {};
      if (widget.views == null || getView || firstAPI) {
        APIService().get<model.View>(APIConstants.mainEndpost, true, null).then((value) {
          if (value.data != null) { widget.views = value.data; }
          for (var view in widget.views!) {
            if (view.id.toString() == viewID?.substring(1) && subViewID != null) {
              try { view.newIds.remove(subViewID); } catch(e) { /* */ }     
            }
          }
          setState(() {}); 
        });
        globalMainViewKey.currentState?.setState(() {}); 
      } else {
        for (var view in widget.views!) {
          if (viewID != null && view.id.toString() == viewID?.substring(1) && subViewID != null) {
            try { view.newIds.remove(subViewID); } catch(e) { /* */ }     
          }
        }
        globalMainViewKey.currentState?.setState(() {}); 
        setState(() {});
      }
  }
  
  void refreshView(String? id, String? cat, bool isFirst, bool nullable, bool full) {
    if (id != null && !globalFilter.containsKey(id)) { 
      globalNew[id] = "all";
      globalFilter[id] = Filters(); 
      globalOrder[id] = <String, String>{};
    }
    cacheChanges = {};
    detectChanges = {};
    selectedGrid = []; 
    unselectedGrid = [];
    firstAPI = isFirst;
    globalOffset = 0;
    viewID=id;
    subViewID=null;
    widget.url = null;
    currentView = null;
    filterRowsWidget = []; functionMathRowsWidget = [];
    if(full) { refresh(true); }
    AppRouter.setRouteCookie("${viewID ?? ""}${subViewID != null ? ":$subViewID" : ""}", context);
    globalLoading = globalFilter.containsKey(id) && globalFilter[id]!.size() > 0 
      || globalOrder.containsKey(id) && globalFilter[id]!.size() > 0 ;
    globalMainViewKey.currentState?.refresh(viewID, null, currentView, true);
  }
}
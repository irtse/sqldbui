import 'package:sqldbui2/core/sections/homeview.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';
import 'dart:developer' as developer;

model.View? beforeView;
model.View? currentView;
String? currentCat;
GlobalKey<MainViewWidgetState> globalMainViewKey = GlobalKey<MainViewWidgetState>();
GlobalKey<LoaderViewWidgetState> globalLoaderMainViewKey = GlobalKey<LoaderViewWidgetState>();
// ignore: must_be_immutable
class MainViewWidget extends StatefulWidget{
  List<model.View>? views;
  MenuWidgetState menu;
  model.View? view;
  String? url;
  MainViewWidget ({ Key? key, required this.menu, required this.view, this.views, this.url}): super(key: key);
  @override MainViewWidgetState createState() => MainViewWidgetState();
}
class MainViewWidgetState extends State<MainViewWidget> {
  @override Widget build(BuildContext context) {
    var view = widget.view; 
    if (view != null || widget.url != null) {
      if (APIService.cache.containsKey(view?.linkPath) && !firstAPI && widget.url == null) { globalLoading = false; }
      if (firstAPI) { globalOffset = 0; }
      if ((currentView == null || currentView != null && currentView!.id.toString() != viewID 
      || AppRouter.routedSubID != null) || firstAPI || widget.url != null) {
        developer.log("View changed", name: "MainViewWidget");
        return FutureBuilder<APIResponse<model.View>>(
          future: widget.url == null && view!.isList  ? APIService().getWithOffset<model.View>("${view.linkPath}${AppRouter.routedSubID != null ? "&id=%25${AppRouter.routedSubID}%" : ""}", firstAPI || AppRouter.routedSubID != null, context)
          : APIService().get<model.View>(widget.url ?? view!.linkPath, firstAPI || widget.url != null, context), // a previously-obtained Future<String> or null
          builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
            if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) { 
              currentView = snap.data!.data![0]; 
              try { 
                var v = widget.views?.firstWhere((element) => "${element.id}" == viewID);
                if (v != null) { currentView?.readOnly = v.readOnly;  }
              } catch(e) { /* */ }
            }
            if ((subViewID != null || AppRouter.routedSubID != null) 
            && currentView != null && widget.url == null) {
              var subID = AppRouter.routedSubID ?? subViewID;
              try {
                model.Item item = currentView!.items.firstWhere((v) => v.values['id'] == subID);
                if (item.linkPath != "") { 
                  developer.log("THERE View changed", name: "MainViewWidget");
                  Future.delayed( const Duration(seconds: 1), () => refreshUrl(item.linkPath, subID));  
                } 
              } catch (e) { developer.log("View not found $e", name: "MainViewWidget"); }
            }
            return ViewWidget(menu: widget.menu, view: currentView, views: widget.views);
        });
      } 
    }
    if (currentView == null) { 
      viewID=null;
      subViewID=null;
      category=null;
    }
    return ViewWidget(menu: widget.menu, view: currentView, views: widget.views); 
  }
  void refreshUrl(String? path, String? id) {
    subViewID = id;
    globalLoading = true;
    setState(() { widget.url = path;});
  }
  void refresh(String? id, String? subID, String? cat, model.View? view, bool forceFirstAPI) {
    setState(() {
      widget.url = null;
      globalOffset = 0;
      currentView = view;
      AppRouter.routedSubID = null;
      category=cat;
      viewID=id;
      subViewID=subID;
      globalLoading = true; // globalFilter.containsKey(id) && globalFilter[id]!.isNotEmpty || globalOrder.containsKey(id) && globalFilter[id]!.isNotEmpty ;
      firstAPI =  forceFirstAPI || globalFilter.containsKey(id) && globalFilter[id]!.isNotEmpty || globalOrder.containsKey(id) && globalFilter[id]!.isNotEmpty ;
    });
  }
}
// ignore: must_be_immutable
class ViewWidget extends StatefulWidget{
  List<model.View>? views;
  MenuWidgetState menu;
  model.View? view;
  ViewWidget ({ Key? key, required this.menu, required this.view, required this.views }): super(key: key);
  @override ViewWidgetState createState() => ViewWidgetState();
}
class ViewWidgetState extends State<ViewWidget> {
  @override Widget build(BuildContext context) {
    return Container(child: _build(context));
  }
  Widget _build(BuildContext context) {
    List<Widget> comps = <Widget>[];
    if (MediaQuery.of(context).size.width < 660 ) {
      return Stack( children: [ 
          Container(
            margin: const EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
            height: MediaQuery.of(context).size.height - 95 > 0 ? MediaQuery.of(context).size.height - 95 : 0, 
                decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius:  const BorderRadius.only(bottomLeft: Radius.circular(7),)),
                child: null),
          ActionBarWidget(key: globalActionBar, menu: widget.menu, view: widget.view), ...comps]);
    }
    comps.add(LoaderMainViewWidget(key: globalLoaderMainViewKey));
    if (widget.view != null) {
      if (widget.view!.isList == true && subViewID == null) { 
        DatagridWidget w = DatagridWidget(key: globalGridWidgetKey, view: widget.view,);
        return Stack( children: [ 
          Container(margin: const EdgeInsets.only(top: 40), child: w),
          ActionBarWidget(key: globalActionBar, menu: widget.menu, view: widget.view, grid: w, gridKey: globalGridKey), ...comps]);
      } else { 
        DataFormWidget w =  DataFormWidget(key: mainForm, view: widget.view);
        return Stack( children: [ 
          Container(margin: const EdgeInsets.only(top: 25), child: w),
          ActionBarWidget(key: globalActionBar, menu: widget.menu, view: widget.view,  form: w ),  ...comps
        ] ); }
    }
    if (viewID != null) { 
      return Stack( children: [ 
          Container(
            margin: const EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
            height: MediaQuery.of(context).size.height - 95 > 0 ? MediaQuery.of(context).size.height - 95 : 0, 
                decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius:  const BorderRadius.only(bottomLeft: Radius.circular(7),)),
                child: null),
          ActionBarWidget(key: globalActionBar, menu: widget.menu, view: widget.view), ...comps]);
    }
    globalLoading = false;
    return Stack( children: [ const HomeViewWidget(), 
      ActionBarWidget(key: globalActionBar, menu: widget.menu, view: widget.view, ), ], );
  }
}

class LoaderMainViewWidget extends StatefulWidget{
  const LoaderMainViewWidget ({ Key? key,}): super(key: key);
  @override LoaderViewWidgetState createState() => LoaderViewWidgetState();
}
class LoaderViewWidgetState extends State<LoaderMainViewWidget> {
  @override Widget build(BuildContext context) {
    return globalLoading ? Container( width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
                   height: MediaQuery.of(context).size.height - 40 > 0 ? MediaQuery.of(context).size.height - 40 : 0,
                   color: Theme.of(context).secondaryHeaderColor.withOpacity(0.5),
                   child: const SpinKitCircle(color: Colors.white, size: 100.0,)) : Container();
  }
}
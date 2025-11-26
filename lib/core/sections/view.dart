import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/dialog/trigger_box.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/services/trigger_cache.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/homeview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';
import 'dart:async';

bool navigate = true;
model.View? currentView;
String? currentCat;
GlobalKey<MainViewWidgetState> globalMainViewKey = GlobalKey<MainViewWidgetState>();
// ignore: must_be_immutable
class MainViewWidget extends StatefulWidget{
  List<model.View>? views;
  String? url;
  MainViewWidget ({ super.key, this.views });
  @override MainViewWidgetState createState() => MainViewWidgetState();
}
class MainViewWidgetState extends State<MainViewWidget> {
  @override Widget build(BuildContext context) {
    if ((viewID ?? "").contains(TranslateConstants.dashboard.toLowerCase()) || (viewID ?? "").contains("dashboard")) {
      return ViewWidget(
        view: currentView, 
        views: widget.views
      );
    }
    model.View? view; 
    try { 
      view = currentView ?? widget.views?.firstWhere((v) => '${v.id}' == viewID?.substring(1) && (viewID != null && !viewID!.contains("@"))); 
    } catch (e) { 
      if ((viewID == null || viewID == "") && (widget.views?.length ?? 0 ) > 0) { 
        view = widget.views?.first;
        viewID = "#${view!.id}";
        subViewID = null; 
        AppRouter.setRouteCookie(viewID!, context);
      }
    }
    

    bool isList = (view != null && view.isList) || subViewID == null || (viewID != null && viewID!.contains("#"));
    var defaultPath = viewID != null ? "${APIConstants.genericEndpost}${subViewID != null ? viewID!.substring(1) : "dbview"}?rows=${subViewID != null ? "$subViewID" : viewID!.substring(1)}" : "";
    return FutureBuilder<APIResponse<model.View>>(
      future: isList ? APIService().getWithOffset<model.View>(widget.url ?? (view != null && view.linkPath != "" ? view.linkPath : defaultPath), navigate, context) : 
        APIService().get<model.View>(widget.url ?? (view != null && view.linkPath != "" ? view.linkPath : defaultPath),  navigate || widget.url != null, context), // a previously-obtained Future<String> or null
      builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
            Future.delayed(Duration(seconds: 2), () => navigate = false);
            currentView = null;
            if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) { 
              currentView = snap.data!.data![0];               
              currentView!.isList = isList && !currentView!.isEmpty;
              if (snap.data!.data!.isEmpty ) {
                currentView?.max = currentView?.items.length ?? 0;
              }
              try { 
                var v = widget.views?.firstWhere((element) => "${element.id}" == viewID?.substring(1));
                if (v != null) { currentView?.readOnly = v.readOnly;  }
              } catch(e) { /* */ }
            } 
            Future.delayed(const Duration(seconds:5), () { firstAPI = false; });
            widget.url = null;
            selectedGrid = [];
            unselectedGrid = [];
            return ViewWidget( 
              view: viewID?.contains("${currentView?.id ?? 00000}") ?? false ? currentView : null, 
              views: widget.views
            );
        });
  }
  void refresh(String? id, String? subID, model.View? view, bool forceFirstAPI) {
    setState(() {
      widget.url = null;
      globalOffset = 0;
      currentView = view;
      viewID=id;
      subViewID=subID;
      globalLoading = true;
      firstAPI =  forceFirstAPI || globalFilter.containsKey(id) && globalFilter[id]!.size() > 0 || globalOrder.containsKey(id) && globalFilter[id]!.size() > 0 ;
    });
  }
}

bool isTriggerOpen = false;
// ignore: must_be_immutable
class ViewWidget extends StatefulWidget{
  List<model.View>? views;
  model.View? view;
  ViewWidget ({ super.key, required this.view, required this.views });
  @override ViewWidgetState createState() => ViewWidgetState();
}
class ViewWidgetState extends State<ViewWidget> {
  @override Widget build(BuildContext context) { return FutureBuilder(future: _build(context), builder: (a, s) {
    if (s.data != null) {
      return s.data!;
    }
    return Container();
  });  }
  Future<Widget> _build(BuildContext context) async {
    if ((viewID ?? "").contains(TranslateConstants.dashboard.toLowerCase()) || (viewID ?? "").contains("dashboard")) {
      return HomeViewWidget();
    }
    if (TriggerCacheService.getTriggers().isNotEmpty && !isTriggerOpen && !(widget.view?.items.first.isDraft ?? true)) {
      isTriggerOpen = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        var triggers = TriggerCacheService.getTriggers();
        showDialog(context: context, barrierDismissible: false,
        builder: (builder) => TriggerBoxWidget(triggers: triggers, isCached: true,));
      });
    }
    if (widget.view?.items.first.isDraft ?? true) {
      TriggerCacheService.triggers = [];
    }
    List<Widget> comps = <Widget>[];
    if (widget.view != null) {
      if (widget.view!.isList && subViewID == null) { 
        DatagridWidget w = DatagridWidget(key: globalGridWidgetKey, view: widget.view);
        return Stack( children: [ 
          Container(margin: const EdgeInsets.only(top: 40), child: w),
          ActionBarWidget(key: globalActionBar, view: widget.view, grid: w, gridKey: globalGridKey), ...comps]);
      } else if (widget.view!.items.isNotEmpty) { 
        DataFormWidget w =  DataFormWidget(key: mainForm, view: widget.view);
        return Stack( children: [ 
          Container(margin: const EdgeInsets.only(top: 25), child: w),
          ActionBarWidget(key: globalActionBar, view: widget.view, form: w ), ...comps] ); 
      } else {
        Stack( children: [...comps] );
      }
    }
    List<Widget> childs = [];
    if (viewID == null) {
      return Stack(children: [ 
        HomeViewWidget(), 
        ActionBarWidget(key: globalActionBar, view: widget.view ) 
      ]);
    }
    if (!firstLoad) {
      childs = [
        Icon(Icons.error, color: Colors.white, size: 100.0,),
        Padding(padding: EdgeInsets.all(10),
                child: Text((await getOnFlow(TranslateConstants.lost)).toLowerCase(), 
                style: TextStyle(color: Colors.white, fontSize: 20.0)),)
      ];
    }
    return Stack( children: [ 
      Container(margin: const EdgeInsets.only(top: 40),
        width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0, 
        height: currentHeigth - 65 > 0 ? currentHeigth - 65 : 0, 
        decoration: BoxDecoration(color: Theme.of(context).splashColor),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children : childs))),
      ActionBarWidget(key: globalActionBar, view: widget.view), ...comps]); 
  }
}
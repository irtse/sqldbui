import 'dart:async';

import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/sections/homeview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';
import 'dart:developer' as developer;

model.View? currentView;
String? currentCat;
GlobalKey<MainViewWidgetState> globalMainViewKey = GlobalKey<MainViewWidgetState>();
GlobalKey<LoaderViewWidgetState> globalLoaderMainViewKey = GlobalKey<LoaderViewWidgetState>();
// ignore: must_be_immutable
class MainViewWidget extends StatefulWidget{
  List<model.View>? views;
  String? url;
  MainViewWidget ({ Key? key, this.views }): super(key: key);
  @override MainViewWidgetState createState() => MainViewWidgetState();
}
class MainViewWidgetState extends State<MainViewWidget> {
  @override Widget build(BuildContext context) {
    model.View? view; 
    try { view = currentView ?? widget.views?.firstWhere((v) => '${v.id}' == viewID?.substring(1) && (viewID != null && !viewID!.contains("@"))); } catch (e) { /* */ }
    if (viewID == null) { return ViewWidget(view: currentView, views: widget.views); }
    bool isList = (view != null && view.isList) || subViewID == null || (viewID != null && viewID!.contains("#"));
    bool reForge = view != null || widget.url != null || (viewID != null && viewID!.contains("@"));
    print("HEY $isList $reForge ${viewID} ${subViewID}");
    if (isList || reForge) {
        print("WIDGET : ${widget.url} ${viewID} ${subViewID}");
        var defaultPath = viewID != null ? "${APIConstants.genericEndpost}${viewID!.substring(1)}?rows=${subViewID != null ? "$subViewID" : "all"}" : "";
        return FutureBuilder<APIResponse<model.View>>(
          future: isList ? APIService().getWithOffset<model.View>(widget.url ?? (view != null ? view.linkPath : defaultPath), firstAPI, context) : 
          APIService().get<model.View>(widget.url ?? (view != null ? view.linkPath : defaultPath),  firstAPI || widget.url != null, context), // a previously-obtained Future<String> or null
          builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
            if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) { 
              currentView = snap.data!.data![0];  
              currentView!.isList = isList && !currentView!.isEmpty;
              if (snap.data!.data!.length > 1 && currentView!.isList) {
                for (var view in snap.data!.data!.sublist(1)) { 
                  for (var item in view.items) { 
                    if (currentView!.items.where((element) => element.values['id'] == item.values['id']).isEmpty) { currentView!.items.add(item); }
                  }
                }
              }
              try { 
                var v = widget.views?.firstWhere((element) => "${element.id}" == viewID?.substring(1));
                if (v != null) { currentView?.readOnly = v.readOnly;  }
              } catch(e) { /* */ }
            } else { currentView = null; }
            Future.delayed(const Duration(seconds:5), () => firstAPI = false);
            widget.url = null;
            return ViewWidget(view: currentView, views: widget.views);
        });
    } 
    if (currentView == null) {   
      viewID=null;
      subViewID=null;
      category=null;
      AppRouter.setRouteCookie("", context);
    }
    return ViewWidget(view: currentView, views: widget.views); 
  }
  void refreshUrl(String? path, String? id, bool load) {
    subViewID = id;
    globalLoading = load;
    firstAPI = true;
    setState(() { widget.url = path;});
    AppRouter.setRouteCookie("${viewID ?? ""}${subViewID != null ? ":$subViewID" : ""}", context);
  }
  void refresh(String? id, String? subID, String? cat, model.View? view, bool forceFirstAPI) {
    setState(() {
      widget.url = null;
      globalOffset = 0;
      currentView = view;
      category=cat;
      viewID=id;
      subViewID=subID;
      globalLoading = true;
      firstAPI =  forceFirstAPI || globalFilter.containsKey(id) && globalFilter[id]!.size() > 0 || globalOrder.containsKey(id) && globalFilter[id]!.size() > 0 ;
    });
  }
}
// ignore: must_be_immutable
class ViewWidget extends StatefulWidget{
  List<model.View>? views;
  model.View? view;
  ViewWidget ({ Key? key, required this.view, required this.views }): super(key: key);
  @override ViewWidgetState createState() => ViewWidgetState();
}
class ViewWidgetState extends State<ViewWidget> {
  @override Widget build(BuildContext context) { return Container(child: _build(context));  }
  Widget _build(BuildContext context) {
    List<Widget> comps = <Widget>[];
    Future.delayed(const Duration(seconds: 2), () => globalLoading = false);
    if (MediaQuery.of(context).size.width < 600 ) {
      return Stack( children: [ 
          Container( margin: const EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
            height: MediaQuery.of(context).size.height - 65 > 0 ? MediaQuery.of(context).size.height - 65 : 0, 
                decoration: BoxDecoration( color: Theme.of(context).highlightColor),
                child: null),
          ActionBarWidget(key: globalActionBar, view: widget.view), ...comps]);
    }
    comps.add(LoaderMainViewWidget(key: globalLoaderMainViewKey));
    if (widget.view != null) {
      if (widget.view!.isList && subViewID == null) { 
        DatagridWidget w = DatagridWidget(key: globalGridWidgetKey, view: widget.view,);
        return Stack( children: [ 
          Container(margin: const EdgeInsets.only(top: 40), child: w),
          ActionBarWidget(key: globalActionBar, view: widget.view, grid: w, gridKey: globalGridKey), ...comps]);
      } else { 
        DataFormWidget w =  DataFormWidget(key: mainForm, view: widget.view);
        return Stack( children: [ 
          Container(margin: const EdgeInsets.only(top: 25), child: w),
          ActionBarWidget(key: globalActionBar, view: widget.view,  form: w ),  ...comps] ); }
    }
    if (viewID != null) { 
      return Stack( children: [ 
          Container(
            margin: const EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
            height: MediaQuery.of(context).size.height - 65 > 0 ? MediaQuery.of(context).size.height - 65 : 0, 
                decoration: BoxDecoration(color: globalLoading ? Colors.white : Theme.of(context).primaryColor),
                child: globalLoading ? null : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children : [
                  Icon(Icons.error, color: Colors.white, size: 100.0,),
                  Padding(padding: EdgeInsets.all(10), child: Text("Seems pretty lost... go on another page please :)", style: TextStyle(color: Colors.white, fontSize: 20.0)),)
                ]))),
          ActionBarWidget(key: globalActionBar, view: widget.view), ...comps]);
    }
    return Stack( children: [ HomeViewWidget(key: globalHomeViewKey), ActionBarWidget(key: globalActionBar, view: widget.view, ), ], );
  }
}

class LoaderMainViewWidget extends StatefulWidget{
  const LoaderMainViewWidget ({ Key? key,}): super(key: key);
  @override LoaderViewWidgetState createState() => LoaderViewWidgetState();
}
class LoaderViewWidgetState extends State<LoaderMainViewWidget> {
  @override Widget build(BuildContext context) {
    return globalLoading ? Container( width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
                   height: MediaQuery.of(context).size.height > 0 ? MediaQuery.of(context).size.height - 40 : 0,
                   color: Theme.of(context).secondaryHeaderColor.withOpacity(0.5),
                   child: const SpinKitCircle(color: Colors.white, size: 100.0,)) : Container();
  }
}
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/utils/loading_overlay.dart';
import 'package:sqldbui2/core/widget/dialog/trigger_box.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/services/trigger_cache.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/homeview.dart';
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
// Untyped on purpose: only used to reach `setState()` on the private State
// below from grid.dart, without exposing that private type across files.
GlobalKey<State> globalMainLoaderKey = GlobalKey<State>();
// Fully decoupled from the content it sits on top of: a plain sibling in
// MainViewWidgetState's Stack, not a wrapper around it. Re-checks
// `gridInitialLoading` (grid.dart) on its own rebuild and renders either the
// overlay or nothing (a zero-size SizedBox) accordingly. Clearing the flag
// only ever needs to touch this one small widget via its GlobalKey — never
// MainViewWidgetState, whose FutureBuilder would refetch on every rebuild.
class _MainLoaderWidget extends StatefulWidget {
  const _MainLoaderWidget({super.key});
  @override State<_MainLoaderWidget> createState() => _MainLoaderWidgetState();
}
class _MainLoaderWidgetState extends State<_MainLoaderWidget> {
  @override Widget build(BuildContext context) {
    if (gridInitialLoading) {
      return const LoadingOverlayWidget(topMargin: 40);
    }
    return const SizedBox();
  }
}
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
      view = currentView ?? widget.views?.firstWhere((v) {
        return '${v.id}' == viewID?.substring(1) && (viewID != null && !viewID!.contains("@"));
      }); 
            

    } catch (e) { 
      if ((viewID == null || viewID == "") && (widget.views?.length ?? 0 ) > 0) { 
        view = widget.views?.first;
        viewID = "#${view!.id}";
        subViewID = null; 
        AppRouter.setRouteCookie(viewID!, context);
      }
    }
    if (view != null) {
      currentView = view;
    }

    bool isList = (view != null && view.isList) || subViewID == null || (viewID != null && viewID!.contains("#"));
    var defaultPath = viewID != null ? "${APIConstants.genericEndpost}${subViewID != null ? viewID!.substring(1) : "dbview"}?rows=${subViewID != null ? "$subViewID" : viewID!.substring(1)}" : "";
    globalOffset = 0;
    return FutureBuilder<APIResponse<model.View>>(
      future: isList ? APIService().getWithOffset<model.View>(widget.url ?? (view != null && view.linkPath != "" ? view.linkPath : defaultPath), navigate, context) : 
        APIService().get<model.View>(widget.url ?? (view != null && view.linkPath != "" ? view.linkPath : defaultPath),  navigate || widget.url != null, context), // a previously-obtained Future<String> or null
      builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
            
            Future.delayed(Duration(seconds: 2), () {
              navigate = false;
            });

            currentView = null;
            if (snap.data?.data != null && snap.data!.data!.isNotEmpty) { 
              currentView = snap.data!.data![0];               
              currentView!.isList = isList && !currentView!.isEmpty;
              if (snap.data!.data!.isEmpty) {
                currentView?.max = currentView?.items.length ?? 0;
              }
              try { 
                var v = widget.views?.firstWhere((element) => "${element.id}" == viewID?.substring(1));
                if (v != null) { currentView?.readOnly = v.readOnly;  }
              } catch(e) { /* */ }  
            }
            if (snap.connectionState == ConnectionState.waiting) {
              setMainViewReloading(true);
            } else {
              setMainViewReloading(false);
            }
            Future.delayed(const Duration(seconds:5), () { 
              firstAPI = false; 
            });
            widget.url = null;
            selectedGrid = [];
            unselectedGrid = [];
            // Don't alter what gets returned here (view resolution/rebuild is
            // correct now) — just lay a loading mask on top of it while this
            // fetch is in flight, since a page change tears the whole
            // ViewWidget subtree down to a blank placeholder and GridWidget's
            // own overlay has nothing left to render on top of during that
            // window. This is the "principal" overlay: it always wins over
            // GridWidget's own nested one (see gridReloading in grid.dart,
            // which deliberately ignores this same reload source).
            // Exact match, not `.contains` — viewID "#12" would otherwise
            // spuriously match a stale currentView of id "1", letting the
            // previous view's (mismatched) columns render while the new
            // view's data is still in flight.
            bool viewMatches = currentView != null && viewID != null && "${currentView!.id}" == viewID!.substring(1);
            var v = ViewWidget(
              view: viewMatches ? currentView : null,
              views: widget.views
            );
            if (snap.connectionState == ConnectionState.waiting) {
              setGridInitialLoading(true);
            } else {
              // A grid is expected to mount fresh under `v` and run its own
              // first (usually near-instant) local load — hold the loader
              // until it clears the flag itself, instead of dropping it now
              // and flashing its own differently-styled loader for a frame.
              bool willMountGrid = (currentView?.isList ?? false) && subViewID == null;
              if (!willMountGrid) {
                setGridInitialLoading(false);
              }
            }
            // `_MainLoaderWidget` is a plain sibling of `v`, not a wrapper
            // around it, so toggling the loader (via globalMainLoaderKey,
            // from grid.dart) only ever rebuilds that one small widget —
            // never `v`, and never MainViewWidgetState itself. Rebuilding
            // MainViewWidgetState would recreate the FutureBuilder's
            // `future:` (it's built inline above, not memoized) and fire a
            // brand new fetch — which would hit `ConnectionState.waiting`
            // again, re-arm this same flag, and loop forever.
            return Stack(children: [v, _MainLoaderWidget(key: globalMainLoaderKey)]);
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
  @override Widget build(BuildContext context) { 
    if ((viewID ?? "").contains(TranslateConstants.dashboard.toLowerCase()) || (viewID ?? "").contains("dashboard")) {
      return HomeViewWidget();
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
    return Stack( children: [ 
      Container(
        margin: const EdgeInsets.only(top: 40),
        width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0, 
        height: currentHeigth - 65 > 0 ? currentHeigth - 65 : 0, 
        decoration: BoxDecoration(color: Colors.grey.shade300),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children : []))),
      ActionBarWidget(key: globalActionBar, view: widget.view), ...comps]); 
  }
}
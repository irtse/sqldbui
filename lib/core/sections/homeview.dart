import 'dart:async';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqldbui2/model/view.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/sections/menu/redirect_button.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' if (kIsWeb) '' as html;

// ignore: must_be_immutable
GlobalKey<HomeViewWidgetState> globalHomeViewKey = GlobalKey<HomeViewWidgetState>();
class HomeViewWidget extends StatefulWidget{
  HomeViewWidget(): super(key: globalHomeViewKey);
  @override HomeViewWidgetState createState() => HomeViewWidgetState();
}
class HomeViewWidgetState extends State<HomeViewWidget> {
  String currentUrl = "";
  final Completer<WebViewController> _controller =  Completer<WebViewController>();
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
     GlobalKey<html.HtmlWidgetState> htmlKey = GlobalKey<html.HtmlWidgetState>();
    List<Widget> comps = [];
    List<Widget> views = [];
    Widget? web;
    if (kIsWeb) {
      web= FutureBuilder(future: APIService().get<model.View>(
        "${APIConstants.genericEndpost}/dbdashboard?rows=all&is_selected=true", false, context), 
        builder: (s,a){
          if (a.data?.data != null && a.data!.data!.isNotEmpty 
          && a.data!.data![0].items.isNotEmpty && (a.data?.data?[0].items[0].values["url"] ?? "") != "") {
            var v = a.data!.data![0].items[0];
            return html.HtmlWidget( 
              key: htmlKey,
              '''
                <iframe src="${ v.values["url"]! }"</iframe>
              ''',
            );
          }
          return SizedBox(
            width: currentWidth - menuSize,
            height: currentHeigth - 120,
            child: Wrap( alignment: WrapAlignment.center, children: [
              Container(
                height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 60,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 40,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 40,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 60,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: currentWidth - menuSize - 80,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
            ]),
          );
        }); 
    } else {
      web = FutureBuilder(future: APIService().get<model.View>(
        "${APIConstants.genericEndpost}/dbdashboard?rows=all&is_selected=true", false, context), 
        builder: (s,a){
          if (a.data?.data != null && a.data!.data!.isNotEmpty 
          && a.data!.data![0].items.isNotEmpty && (a.data?.data?[0].items[0].values["url"] ?? "") != "") {
            var v = a.data!.data![0].items[0];
            return WebView(
              initialUrl: v.values["url"]!,
              onPageStarted: (v) {
                currentUrl = v;
              },
              onPageFinished: (v) {
                currentUrl = v;
              },
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              javascriptMode: JavascriptMode.unrestricted,
            );
          }
          return SizedBox(
            width: currentWidth - menuSize,
            height: currentHeigth - 120,
            child: Wrap( alignment: WrapAlignment.center, children: [
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 60,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 40,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 40,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 60,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: currentWidth - menuSize - 80,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
            ]),
          );
        });
    }
    for (var cat in categories.keys) {
      comps.add(Padding( padding: const EdgeInsets.symmetric(horizontal: 50), child: Column(children: [
        Row(children: [  Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.bookmark, color: Theme.of(context).splashColor, size: 25)),
          Padding( padding: const EdgeInsets.only(right: 20),
          child: FutureBuilder(future: getOnFlow("${cat[0].toUpperCase()}${cat.substring(1).toLowerCase()}"), builder: (a,s) { 
            if (s.data != null) {
              return Text(s.data!,
                style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 20) );
            }
            return Container();
          })),
          Expanded( child: Divider(color: Theme.of(context).splashColor))]),
        Padding(padding: const EdgeInsets.all(10), child: Wrap(alignment: WrapAlignment.center, children: views,))
      ],)));
    }
    var goto = await getOnFlow(TranslateConstants.goto);
    var dash = await getOnFlow(TranslateConstants.dashboard);

    return FutureBuilder<APIResponse<Shallowed>>(future:APIService().get<Shallowed>(
      "${APIConstants.genericEndpost}/dbview?rows=all&shallow=enable&shortcut_on_main=true", false, context), 
    builder: (a,s) {
      views = [];
      List<Shallowed> dd = [];
      if (s.data?.data != null) {
        for (var d in s.data!.data!) {
          if (dd.where( (e) => (e.label ?? e.name ?? "") == (d.label ?? d.name ?? "")).isEmpty) {
            dd.add(d);
          } 
        } 
      }
      if (dd.length > 4) {
        List<PopupMenuItem<String>> item = [];
        for (var d in dd) {
          item.add(PopupMenuItem(value: "${d.id}", child: FutureBuilder(future: getOnFlow(d.label ?? d.name ?? ""), builder: (a,s) {
            if (s.data != null) {
              return Text(s.data!);
            }
            return Text(d.label ?? d.name ?? "");
          }))); 
        }
        views.add(PopupMenuButton<String>(
            iconColor:  Colors.white,
            color: Colors.white,
            shape: const ContinuousRectangleBorder(side: BorderSide(color: Colors.transparent)),
            onSelected: (value) {
              cacheForm = {};
              consentCache = {};
              oneToManiesForm = {};
              oneToManiesStateForm = {};
              globalMenuKey.currentState?.refreshView("#$value", "", false, false, false);
            },
            itemBuilder: (BuildContext context) { return item; }
          )
        );
      } else {
        for (var d in dd) {
          views.add(RedirectButtonWidget(id: "${d.id}", name: d.label ?? d.name ?? "", category: ""));
        }
      }
      return Stack( children: [
          Container(
            margin: EdgeInsets.only(top: 80),
            width: currentWidth - menuSize,
            color: Colors.grey.shade300,
            height: currentHeigth - 120,
            child: web
          ),
          Positioned(
          child: Column( children: [
            Container( 
              height: 40, 
              padding: const EdgeInsets.symmetric(horizontal: 30),
              width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                boxShadow: [  BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible( child: Text(dash.toUpperCase(), 
                  overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).highlightColor) ) ),
                  Padding(padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.home, color: Colors.grey.shade200, size: 18)
                ),
              ])),
            Container(
                  width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0, 
                  decoration: BoxDecoration( 
                    boxShadow: [  BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
                    color: Theme.of(context).primaryColor),
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [ 
                    Tooltip( message: "$goto $dash", child:  InkWell( 
                      onTap: () {
                        cacheForm = {};
                        consentCache = {};
                        oneToManiesForm = {};
                        oneToManiesStateForm = {};
                        subMenuIndex = 0;
                        globalMainViewKey.currentState?.setState(() { viewID = null; });
                        Future.delayed(Duration(milliseconds: 50), () {
                          globalMainViewKey.currentState?.setState(() {
                            currentView = null;
                            viewID = "dashboard";
                            subViewID = null;
                            globalMenuKey.currentState?.setState(() { });
                          });
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration( border: Border(right: BorderSide(color: Theme.of(context).splashColor))),
                        child: Icon(Icons.dashboard, color: Colors.white)
                    ))), ...views]))
          ),
      ]))
      ]);
    }); 
  }  
}
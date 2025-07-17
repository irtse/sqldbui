import 'package:flutter/foundation.dart';
import 'package:sqldbui2/core/sections/head_menu.dart';
import 'package:sqldbui2/core/sections/notifications.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/utils/dialog_button.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:sqldbui2/core/widget/utils/fork/tranformablebox.dart' as fork;
import 'package:sqldbui2/page/translate.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';


bool noMenu = false;
final _authProvider = AuthService(); 
List<model.View> pageViews = [];
/// Flutter code sample for [FutureBuilder].
// ignore: must_be_immutable
class PageWidget extends StatefulWidget {
  PageWidget({super.key});
  @override
  State<PageWidget> createState() => PageWidgetState();
}
bool filterMenuMain = true;
class PageWidgetState extends State<PageWidget> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    noMenu = currentWidth - menuSize < 600;
    menuSize = isMenu && !noMenu ? (250 <= currentWidth ? (
              menuSize == 0 ? 250 : (menuSize <= (currentWidth / 2) ? menuSize : (currentWidth / 2))) : currentWidth) : 0;
    return Scaffold(
      key: scaffoldKey,
      drawer: buildDrawer(),
      endDrawer: Drawer(
        width: currentWidth / 3,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0))),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: const NotificationDrawerWidget()
      ),
      appBar: AppBar(
        elevation: 3,
        leading: noMenu ? Builder(
          builder: (context) {
            return Tooltip( message: TranslateConstants.menu.toLowerCase(), child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white,),
              onPressed: () { Scaffold.of(context).openDrawer(); }));
          },
        ) : null,
        automaticallyImplyLeading: false,
        shadowColor: Theme.of(context).secondaryHeaderColor,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: HeadMenuWidget(),         
        toolbarHeight: 40,
        actions: <Widget>[
          Stack( children: [
            Tooltip(
             message: (await getOnFlow(TranslateConstants.notifications)).toLowerCase(),
             child: IconButton(icon: const Icon(Icons.notifications, color: Colors.white, size: 25,),
             onPressed: () { 
              scaffoldKey.currentState!.openEndDrawer();
              // if (AuthService.user!.notifications.isNotEmpty) { scaffoldKey.currentState!.openEndDrawer(); }
             })),
             NotificationWidget(key: appBarKey),
          ]),
          Padding(padding: EdgeInsets.only(left: 0, right: 0), 
            child: IconButton(
              icon: Icon( Icons.info_outline, color: Colors.white ), 
                tooltip: (await getOnFlow(TranslateConstants.tutorial)).toLowerCase(),
                onPressed: () => kIsWeb ? html.window.open("${const String.fromEnvironment('HOST', defaultValue: 'http://capitalisation.irt-aese.local')}/assets/pdf/tutorial.pdf", '_blank')
                : launchUrl(Uri( path: "${const String.fromEnvironment('HOST', defaultValue: 'http://capitalisation.irt-aese.local')}/assets/pdf/tutorial.pdf"), mode: LaunchMode.externalApplication) // Opens in new tab), 
            )
          ),
          //DialogButtonWidget(icon: Icons.info_outline, widget: TutorialPopUpWidget(), tooltip: (await getOnFlow(TranslateConstants.tutorial)).toLowerCase(), left: 12.5),
          DialogButtonWidget( left: 12.5, right: 50,
            icon: Icons.logout_outlined,
            widget: ConfirmBoxWidget(purpose: "disconnect your account", validate: () { _authProvider.logOut(context); }), 
            tooltip: (await getOnFlow(TranslateConstants.logout)).toLowerCase()),
        ],
      ),
      body: Stack( 
        alignment: Alignment.topCenter,
        children: [  buildView(), buildMenu() ],
      ),
      backgroundColor: Theme.of(context).secondaryHeaderColor);
  }

  
  Widget? buildDrawer() {
    return noMenu ? Drawer(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0))),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: FutureBuilder<APIResponse<model.View>>(
          future: APIService().get<model.View>(APIConstants.mainEndpost, filterMenuMain, null), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.View>> snapshot) {
          filterMenuMain = false;
          if (snapshot.hasData && snapshot.data!.data != null) { 
            pageViews = snapshot.data!.data!;
          }
          return MenuWidget(key: globalMenuKey, views: pageViews);
        })) : null;
  }
  Widget buildMenu() {
    return noMenu ? Container() : AnimatedPositioned(
        duration: const Duration(milliseconds: 200), 
        left: isMenu ? 80 : -10, 
        bottom: -8,
        child: CircleAvatar(
          radius: 30, 
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          child: IconButton( 
            iconSize: 30, 
            color: Theme.of(context).splashColor,
            icon: Icon(isMenu ? Icons.close :  Icons.menu), 
        onPressed: () { 
          rects.remove(viewID);
          setState(() { isMenu = !isMenu;  });
        })
      )
    );
  }
  Widget buildView() {
    return pageViews.isNotEmpty ? buildPage(pageViews) :
      FutureBuilder<APIResponse<model.View>>(
        future: APIService().get<model.View>(APIConstants.mainEndpost, filterMenuMain, null), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<APIResponse<model.View>> snapshot) {
          var c = <Widget>[];
          if (snapshot.hasData && snapshot.data!.data != null) { 
            pageViews = snapshot.data!.data!;
            return buildPage(pageViews);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: c);
        }
      );
  }
  Widget buildPage(List<model.View> views) {
    Rect rect = Rect.fromCenter( 
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: menuSize, 
      height: currentHeigth - 40 > 0 ? currentHeigth - 40 : 0
    );
    List<Widget> c = !isMenu || noMenu ? [] : <Widget>[
      fork.TransformableBox(
        rect: rect, constraints: BoxConstraints(
          maxWidth: 250 <= (currentWidth / 2) ? (currentWidth / 2) 
            : currentWidth,
          minWidth: 250 <= currentWidth ? 250 : currentWidth),
        flip: null,
        draggable: false,
        handleTapSize: 1, 
        handleTapLeftSize: 0, 
        allowFlippingWhileResizing: false, 
        handleAlignment: HandleAlignment.inside,
        resizeModeResolver: () => ResizeMode.freeform,
        visibleHandles: const {HandlePosition.right},
        enabledHandles: const {HandlePosition.right},
        clampingRect: Offset.zero & MediaQuery.sizeOf(context),
        onChanged: (result, event) { setState(() { menuSize = result.rect.width; }); },
        contentBuilder: (context, rect, flip) { return Container(
          color: Theme.of(context).secondaryHeaderColor, 
          width: menuSize, 
          child: MenuWidget(key: globalMenuKey, views: views)); } 
    )];
    try { c.add(MainViewWidget(key: globalMainViewKey, views: views));  } catch (e) { /* */ }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: c);
  }
}
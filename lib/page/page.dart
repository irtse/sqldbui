import 'package:sqldbui2/core/sections/notifications.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/dialog/tutorial.dart';
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

bool noMenu = false;
final _authProvider = AuthService();          
/// Flutter code sample for [FutureBuilder].
// ignore: must_be_immutable
class PageWidget extends StatefulWidget {
  List<model.View> views = [];
  PageWidget({super.key});
  @override
  State<PageWidget> createState() => PageWidgetState();
}

class PageWidgetState extends State<PageWidget> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override Widget build(BuildContext context) {
    noMenu = MediaQuery.of(context).size.width - menuSize < 600;
    menuSize = isMenu && !noMenu ? (250 <= MediaQuery.of(context).size.width ? (
                menuSize == 0 ? 250 : (menuSize <= (MediaQuery.of(context).size.width / 2) ? menuSize : (MediaQuery.of(context).size.width / 2))) : MediaQuery.of(context).size.width) : 0;
    return Scaffold(
      key: scaffoldKey,
      drawer: buildDrawer(),
      endDrawer: const NotificationDrawerWidget(),
      appBar: AppBar(
        elevation: 3,
        leading: noMenu ? Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white,),
              onPressed: () { Scaffold.of(context).openDrawer(); });
          },
        ) : null,
        automaticallyImplyLeading: false,
        shadowColor: Theme.of(context).secondaryHeaderColor,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Padding(padding: EdgeInsets.only(left: noMenu ? 0 : 50, right: 50), 
          child: SizedBox(child: Row(children: [
            MediaQuery.of(context).size.width > 400 ? RouterWidget(key: routerKey) : Container(),
            InkWell( onTap: () { clear(); },  
              child: Image(image: const AssetImage('assets/images/logo.png'), width: MediaQuery.of(context).size.width > 600 ? 60 : 0,)),
            InkWell( onTap: () { clear(); }, 
              child:Container(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width > 600 ? 30 : 0), 
                child: MediaQuery.of(context).size.width > 1000 ? Text("SOFTWARE NAME", overflow: TextOverflow.ellipsis,
                 style: TextStyle( color: Theme.of(context).highlightColor)) : null)),
            Padding(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width > 600 ?  50 : 0, 
                right: MediaQuery.of(context).size.width > 600 ?  10 : 0), 
              child: MediaQuery.of(context).size.width > 600 ? Icon(Icons.verified_user, color: Theme.of(context).splashColor) : null),
            Flexible(child: Container(padding: const EdgeInsets.only(left: 0, right: 0), 
                  child: MediaQuery.of(context).size.width > 600 ? Text("${AuthService.user != null ? "${AuthService.user!.name} - " : "unknown" }${AuthService.user != null ? AuthService.user!.email : ""}",
                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Theme.of(context).splashColor)) : null)),
          ],)
        )),         
        toolbarHeight: 40,
        actions: <Widget>[
          Stack( children: [
             IconButton(icon: const Icon(Icons.notifications, color: Colors.white, size: 25,),
             onPressed: () { 
              if (AuthService.user!.notifications.isNotEmpty) { scaffoldKey.currentState!.openEndDrawer(); }
             }),
             NotificationWidget(key: appBarKey),
          ],),
          DialogButtonWidget(icon: Icons.info_outline, widget: TutorialPopUpWidget(), tooltip: "tutorial", left: 12.5),
          DialogButtonWidget( left: 12.5, right: 50,
            icon: Icons.logout_outlined,
            widget: ConfirmBoxWidget(purpose: "disconnect your account", validate: () { _authProvider.logOut(context); }), 
            tooltip: "logout"),
        ],
      ),
      body: Stack( 
        alignment: Alignment.topCenter,
        children: [  buildView(), buildMenu() ],
      ),
      backgroundColor: Theme.of(context).secondaryHeaderColor);
  }

  void clear() {
    setState(() {
      currentView = null;
      viewID = null;
      subViewID = null;
    });
  }
  Widget? buildDrawer() {
    return noMenu ? Drawer(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0))),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: FutureBuilder<APIResponse<model.View>>(
          future: APIService().get<model.View>(APIConstants.mainEndpost, false, null), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.View>> snapshot) {
          if (snapshot.hasData && snapshot.data!.data != null) { 
            widget.views = snapshot.data!.data!;
          }
          return MenuWidget(key: globalMenuKey, views: widget.views);
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
    return widget.views.isNotEmpty ? buildPage(widget.views) :
      FutureBuilder<APIResponse<model.View>>(
        future: APIService().get<model.View>(APIConstants.mainEndpost, false, null), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<APIResponse<model.View>> snapshot) {
          var c = <Widget>[];
          if (snapshot.hasData && snapshot.data!.data != null) { 
            widget.views = snapshot.data!.data!;
            return buildPage(widget.views);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: c);
        }
      );
  }
  Widget buildPage(List<model.View> views) {
    Rect rect = Rect.fromCenter( 
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: menuSize, 
      height: MediaQuery.of(context).size.height - 40 > 0 ? MediaQuery.of(context).size.height - 40 : 0
    );
    List<Widget> c = !isMenu || noMenu ? [] : <Widget>[
      fork.TransformableBox(
        rect: rect, constraints: BoxConstraints(
          maxWidth: 250 <= (MediaQuery.of(context).size.width / 2) ? (MediaQuery.of(context).size.width / 2) 
            : MediaQuery.of(context).size.width,
          minWidth: 250 <= MediaQuery.of(context).size.width ? 250 : MediaQuery.of(context).size.width),
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/page/login.dart';
import 'package:sqldbui2/page/page.dart';

final ThemeData myTheme = ThemeData(
  secondaryHeaderColor: const Color.fromRGBO(40, 42, 54, 1),
  selectedRowColor: const Color.fromRGBO(68, 71, 90, 1),
  highlightColor: const Color.fromRGBO(248, 248, 242 , 1),
  shadowColor: const Color.fromRGBO(98, 114, 164  , 1),
);

void main() {
  runApp(const MyApp());
}
final _authProvider = AuthService();          
final _appRouter = AppRouter();   

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: myTheme,
      routerConfig: GoRouter(routes: _appRouter.routes),
    );
  }
}
GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
class HomeScreen extends StatefulWidget {
  String? viewID;
  String? subViewID;
  String? category;
  HomeScreen({ Key? key, this.viewID, this.subViewID }): super(key: homeKey);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  State<HomeScreen> createState() => HomeScreenState();
}
class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    AuthService();
    if (!AuthService.isLoggedIn) { return const LoginScreen(); }
    APIService.cache = {};
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shadowColor: Theme.of(context).secondaryHeaderColor,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Padding(padding: const EdgeInsets.only(left: 50, right: 50), 
          child: SizedBox(child: Row(children: [
            const Image(image: AssetImage('assets/images/logo.png'), width: 60,),
            Padding(padding: const EdgeInsets.only(left: 30), 
              child: Text("SOFTWARE NAME", 
                style: TextStyle( color: Theme.of(context).highlightColor,),)),
                Padding(padding: const EdgeInsets.only(left: 50, right: 10), 
                child: Icon(Icons.verified_user, color: Theme.of(context).splashColor),),
                Padding(padding: const EdgeInsets.only(left: 0, right: 50), 
                  child: Text("${AuthService.user != null ? AuthService.user!.name : "unknown"} - ${AuthService.user != null ? AuthService.user!.email : ""}",
                    style: TextStyle(fontSize: 13, color: Theme.of(context).splashColor)),
                  ),
              ],)
        )),         
        toolbarHeight: 40,
        actions: <Widget>[
          Stack( children: [
            PopupMenuButton(
              color: Colors.white,
              icon: const Icon(Icons.notifications, color: Colors.white, size: 25,),
              onSelected: (value) { },
              itemBuilder: (BuildContext bc) {
                List<Widget> rows = [];
                for ( var notif in AuthService.user!.notifications ) {
                  rows.add(Padding( padding: const EdgeInsets.all(10), child: Stack( children: [ Column(children: [
                      SizedBox( width: 235, child: TextButton( 
                        onPressed: () { AppRouter.navigateTo(notif.ref); }, child:  Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                        children: [const Icon(Icons.message), Padding( padding: const EdgeInsets.only(left: 10), child: Text(notif.name, style: TextStyle(color: Theme.of(context).primaryColor)),),
                        Padding( padding: const EdgeInsets.only(left: 10), child: Text(notif.ref, style: TextStyle(color: Theme.of(context).splashColor)),)],))),
                      SizedBox( width: 200, child: Row(children: [Text(notif.description.toLowerCase())],)),
                      Container( margin: const EdgeInsets.only(top: 10), height: 1, width: 236, color: Theme.of(context).splashColor)
                    ]), Positioned(top: -5, left: 190, child: IconButton(focusColor: Colors.transparent, hoverColor: Colors.transparent, icon: const Icon(Icons.close, size: 20,), onPressed: () {},) ) ]) ));
                }
                return [
                  PopupMenuItem(enabled: false, child: StatefulBuilder( builder: (BuildContext context, StateSetter setState) {
                    return Container( 
                    width: 300, constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView( child:  Row(children:  rows ),)
                  ); }))
                ]; 
            }),
            NotificationWidget(key: appBarKey,),
          ],),
          
          Padding(padding: const EdgeInsets.only(left: 25, right: 50), 
                  child: IconButton(icon: const Icon( Icons.logout_outlined, color: Colors.white, ), tooltip: "logout",
                                    onPressed: () async { await _authProvider.logOut(context); }, )
          )
        ],
      ),
      body: PageWidget(key: globalPageKey),
    );
  }
}

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({ Key? key }): super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  NotificationWidgetState createState() => NotificationWidgetState();
}
GlobalKey<NotificationWidgetState> appBarKey = GlobalKey<NotificationWidgetState>();
class NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    
    return Positioned( left: 10, child: Container(
              height: 20,
              alignment: Alignment.bottomRight,
              child: Container(
                width: 15,
                height: 20,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffc32c37),
                    border: Border.all(color: Colors.white, width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(
                    child: Text(
                      AuthService.user!.notifications.length > 9 ? "+" : AuthService.user!.notifications.length.toString(),
                      style: const TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
              )),
            );
  }
}
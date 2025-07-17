import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqldbui2/page/page.dart';
import 'package:sqldbui2/page/login.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:desktop_window/desktop_window.dart' if (kIsWeb) '';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_linux_webview/flutter_linux_webview.dart';

final ThemeData myTheme = ThemeData(
  secondaryHeaderColor: const Color.fromRGBO(40, 42, 54, 1),
  primaryColorLight: const Color.fromRGBO(68, 71, 90, 1),
  highlightColor: const Color.fromRGBO(248, 248, 242 , 1),
  shadowColor: const Color.fromRGBO(98, 114, 164  , 1),
);

void main() async { 
    // ensureInitialized() is required if the plugin is initialized before runApp()
  WidgetsFlutterBinding.ensureInitialized();
  // Run `LinuxWebViewPlugin.initialize()` first before creating a WebView.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
    LinuxWebViewPlugin.initialize(options: <String, String?>{
      'user-agent': 'UA String',
      'remote-debugging-port': '8888',
      'autoplay-policy': 'no-user-gesture-required',
    });

    // Configure [WebView] to use the [LinuxWebView].
    WebView.platform = LinuxWebView();
  }
  setUpTranslate();
  runApp(const MyApp()); 
}
final _appRouter = AppRouter();   

double currentWidth = -1;
double currentHeigth = -1;

bool resize = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (currentWidth < 0) {
      currentWidth = MediaQuery.of(context).size.width;
    }
    if (currentHeigth < 0) {
      currentHeigth = MediaQuery.of(context).size.height;
    }
    if (MediaQuery.of(context).size.width != currentWidth) {
      resize = true;
      currentWidth = MediaQuery.of(context).size.width;
    }
    if (MediaQuery.of(context).size.height != currentHeigth) {
        resize = true;
        currentHeigth = MediaQuery.of(context).size.height;
    }
    if (resize) {
      Future.delayed(Duration(seconds: 2), () => resize == false );
    }
    TranslateConstants.lang = const String.fromEnvironment("LANG", defaultValue: "fr");
    return MaterialApp.router(
      title: 'OPPS',
      theme: myTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'), // Add other locales as needed
      ],
      routerConfig: GoRouter(routes: _appRouter.routes),
    );
  }
}
String? viewID;
String? subViewID;
GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  bool fromUrl = false;
  HomeScreen({ Key? key, this.fromUrl = false }): super(key: homeKey);
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

bool noReload = false;
double homeWidth = 0;
bool firstLoad = true;
class HomeScreenState extends State<HomeScreen> {
  late Future<void> loadAsync;

  void refresh(String? id, String? subID, bool isHome) {
    viewID = id;
    subViewID = subID;
    currentView = null;
    clearFilter();
    notNew = {};
    setState(() {});
    if (isHome) { AppRouter.setRouteCookie("", context); }
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    AuthService();
    isTriggerOpen = false;
    if (homeWidth == 0) { homeWidth = MediaQuery.of(context).size.width; 
    } else if (homeWidth != MediaQuery.of(context).size.width) { 
      homeWidth = MediaQuery.of(context).size.width; 
      noReload = true;
    } else {
      noReload = false;
    }
    if (!AuthService.isLoggedIn) { return const LoginScreen(); }
    globalFilter = <String, Filters>{};
    rects = {};
    AppRouter.getRouteCookie().then((value) {
      if (value != null && value != "") {
        var splitted = value.split(":");
        viewID = splitted.isNotEmpty && splitted[0] != "" ? splitted[0] : null;
        subViewID = splitted.length > 1 && splitted[1] != "" ? splitted[1] : null;
        var f = Filters();
        f.isEmpty = true;
        if (viewID != null) { 
          if (globalNew[viewID] == null) { globalNew[viewID] = "all"; }
          if (globalFilter[viewID] == null) {
            globalFilter[viewID] = f; 
          }
          if (globalOrder[viewID] == null) {
            globalOrder[viewID] = {}; 
          }
        } 
      }
      // ignore: use_build_context_synchronously
      AppRouter.setRouteCookie("${viewID ?? ""}${subViewID != null ? ":$subViewID" : ""}", context);
      globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
    });
    if (!kIsWeb) { DesktopWindow.setMinWindowSize(const Size(800, 600)); }
    return PageWidget();
  }
}
class NotificationWidget extends StatefulWidget {
  const NotificationWidget({ super.key });
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
      height: 20, alignment: Alignment.bottomRight,
      child: Container( width: 15, height: 20,
        decoration: BoxDecoration( shape: BoxShape.circle,
          color: const Color(0xffc32c37),
          border: Border.all(color: Colors.white, width: 1)),
        child: Center( child: Text( overflow: TextOverflow.ellipsis,
            AuthService.user!.notifications.length > 9 ? "+" : AuthService.user!.notifications.length.toString(),
            style: const TextStyle(fontSize: 9, color: Colors.white),
    )))));
  }
}
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;

// ignore: must_be_immutable
GlobalKey<HomeViewWidgetState> globalHomeViewKey = GlobalKey<HomeViewWidgetState>();
class HomeViewWidget extends StatefulWidget{
  const HomeViewWidget ({ Key? key}): super(key: key);
  @override HomeViewWidgetState createState() => HomeViewWidgetState();
}
class HomeViewWidgetState extends State<HomeViewWidget> {
  @override Widget build(BuildContext context) {
    List<Widget> comps = [];
    List<Widget> views = [];
    for (var cat in categories.keys) {
      for (var view in categories[cat]!) {
        views.add(
          InkWell( onTap: () { globalMenuKey.currentState?.refreshView("${view.id}", cat, false, false, false); },
              child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5),
                      spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ],
              borderRadius: const BorderRadius.all(Radius.circular(7)),),
            child: Container( width: 300, child: Column(children: [
                Container(margin: const EdgeInsets.only(top: 10), child: const ClipRRect(
                  borderRadius:  BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                  child: Image( image: AssetImage('assets/images/default.png'), height: 150, width: 280, fit: BoxFit.cover, ),
                )),
                Padding(padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10), child: ListTile(
                  title: Text( view.name[0].toUpperCase() + view.name.substring(1).toLowerCase(), overflow: TextOverflow.ellipsis,
                  style:  TextStyle( color: Theme.of(context).primaryColor, fontSize: 17), ),
                  trailing: const Text("go to view", style: TextStyle(fontSize: 9, color: Colors.grey) ),
                  subtitle: view.description == "" ? null : Text(view.description[0].toUpperCase() + view.description.substring(1).toLowerCase(), style: const TextStyle( fontSize: 10), ),
                )),
          ],)) )));
      }
      comps.add(Padding( padding: const EdgeInsets.symmetric(horizontal: 50), child: Column(children: [
        Row(children: [  Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.bookmark, color: Theme.of(context).splashColor, size: 25)),
          Padding( padding: const EdgeInsets.only(right: 20),
          child: Text(cat[0].toUpperCase() + cat.substring(1).toLowerCase(),
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 20))),
            Expanded( child: Divider(color: Theme.of(context).splashColor,))],),
        Padding(padding: const EdgeInsets.all(10), child: Wrap(alignment: WrapAlignment.center, children: views,))
      ],)));
    }
    return Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.only(top: 30, right: 30, left: 30),
            width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
            height: MediaQuery.of(context).size.height - 80 > 0 ? MediaQuery.of(context).size.height - 80 : 0, 
                decoration: BoxDecoration( color: Colors.grey[200]),
                child: SingleChildScrollView(child: Wrap(alignment: WrapAlignment.center, children:views)));
  }
}
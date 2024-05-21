import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

var slide1 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: const AssetImage('assets/images/slide1.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text("How to create a data ?", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              const Flexible( child: Text(overflow: TextOverflow.ellipsis, "you need to access <submit page> from home page, \"MENU -> GENERAL -> SUBMIT DATAS\", or from any shortcut on pages.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> then you will access to a formulary selector, that will show the data formulary depending the selected one.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> fill, at least, all required fields and then you only have to submit ! if any workflow is engaged, it will triggered on submition.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));

var slide2 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: AssetImage('assets/images/slide2.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text("How to access my assigned activities ?", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              const Flexible( child: Text(overflow: TextOverflow.ellipsis, "you need to access <assigned activity page> from home page, \"MENU -> ACTIVITY -> ASSIGNED ACTIVITY\". notifications will allows you a quick access to your unread activities.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> assigned activities concerns all your action to realise in the purpose of a current workflow, on closure, workflow will go to next activity (activity for you or another actor).", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> an activity can be stated as <pending,progressing,dismiss,completed>. completion will close it as successful. dismiss will close it as failed. when closed an activity can't be reopenned without superadmin action.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));

var slide3 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: const AssetImage('assets/images/slide3.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text("How to access my requests ?", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              const Flexible( child: Text(overflow: TextOverflow.ellipsis, "you need to access <validated/unvalidated request page> from home page, \"MENU -> ACTIVITY -> VALIDATED/UNVALIDATED REQUEST\".", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> requests concerns all your request or your hierarchical subordinate. you can monitor where your requests are stated. notification will warn you on closure", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> an request can be stated as <pending,progressing,dismiss,completed>. completion will close it as successful. dismiss will close it as rejected. when closed an activity can't be reopenned without superadmin action.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));

var slide4 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: AssetImage('assets/images/slide4.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text("How to filter by columns in a view list ? [ALPHA]", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              const Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> filter showed column by tapping on the <gear> icon to open a popup panel to choose columns. filter can be saved. [ALPHA] only register state on session.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> filter on column by hovering column label and tapping <filter> icon to open a popup panel to filter by value column. filter multiple columns is allowed as 'and' connector. [ALPHA] only register state on session && does not adapt by column types only text considers.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> filter on full table by using top bar <filter> icon. [ALPHA] actually not working, only visually sets up.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));
  
  var slide5 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: AssetImage('assets/images/slide5.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text("How to access a datas ?", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              const Flexible( child: Text(overflow: TextOverflow.ellipsis, "datas are ordered in thematized views accessible in the side menu. menu give access to datas list views.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> tap on a line of a list to acces its formulary. a form gives you state allowed depending your rights and actions available such as <save, delete>.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> [ACCESS] enter in top search bar in the middle of the screen, app path to the form. (can also be use to access a list view)", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));

    var slide6 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: AssetImage('assets/images/slide6.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text("How to track progress of a workflow ?", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              const Flexible( child: Text(overflow: TextOverflow.ellipsis, "workflows are attached to a request. some request does not have a workflow to integrate data.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> only request, task shows workflow completion, on top of their forms. it consists of a simple bar declining steps with a list of parrallel subtask depending on step.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        const Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> grey color define not reached step, vivid color step is done or currently doing, icons in subtask will give you its current state (done or doing). task can show you a optionnal hub under main workflow, by this you can choose wich are the next step to launch.", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));

class TutorialPopUpWidget extends StatefulWidget {
  const TutorialPopUpWidget ({ Key? key,}): super(key: key);
  @override
  TutorialPopUpState createState() => TutorialPopUpState();
}
class TutorialPopUpState extends State<TutorialPopUpWidget> {
  @override Widget build(BuildContext context) {
    List<Widget> list = [slide1(context), slide2(context), slide3(context), slide4(context), slide5(context), slide6(context)];
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).secondaryHeaderColor, iconTheme: IconThemeData(color: Theme.of(context).splashColor),
        title: const Text('TUTORIAL - HOW TO START', style: TextStyle(color: Colors.white),)),
      body: Container( width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height, color: Theme.of(context).primaryColorLight,
          child: Center( child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
        items: list,
      ))),
    );
  }
}
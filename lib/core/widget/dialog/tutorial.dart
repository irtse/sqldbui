import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sqldbui2/page/translate.dart';

var slide1 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: const AssetImage('assets/images/slide1.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text(TranslateConstants.howToCreate, 
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needAccess, style: const TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: const EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule1, style: const TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: const EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule2, style: const TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));

var slide2 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: const AssetImage('assets/images/slide2.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text(TranslateConstants.howToAssign, 
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule3, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: const EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, 
                TranslateConstants.needRule4, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: const EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, 
                TranslateConstants.needRule5, style: TextStyle(color: Colors.grey, fontSize: 12)))
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
            children: [ Flexible( child: Text(TranslateConstants.howToReq, 
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              const Flexible( child: Text(overflow: TextOverflow.ellipsis, "you need to access <validated/unvalidated request page> from home page, \"MENU -> ACTIVITY -> VALIDATED/UNVALIDATED REQUEST\".", style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, 
              TranslateConstants.needRule6, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, 
                TranslateConstants.needRule7, style: TextStyle(color: Colors.grey, fontSize: 12)))
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
            children: [ Flexible( child: Text(TranslateConstants.howToFilter, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, 
                TranslateConstants.needRule8, style: TextStyle(color: Colors.grey, fontSize: 12)))
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
            children: [ Flexible( child: Text(TranslateConstants.howToProgress, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
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
        title: Text(TranslateConstants.howToTutorial.toUpperCase(), style: TextStyle(color: Colors.white),)),
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
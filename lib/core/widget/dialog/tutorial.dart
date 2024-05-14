import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TutorialPopUpWidget extends StatefulWidget {
  TutorialPopUpWidget ({ Key? key,}): super(key: key);
  @override
  TutorialPopUpState createState() => TutorialPopUpState();
}
class TutorialPopUpState extends State<TutorialPopUpWidget> {
  @override Widget build(BuildContext context) {
    List<Widget> list = [Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: EdgeInsets.only(top: 180), child: Image( image: AssetImage('assets/images/slide1.png'), height: MediaQuery.of(context).size.height - 260, width: MediaQuery.of(context).size.width - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text("How to create/submit a data ?", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "you need to access <submit page> from home page, \"MENU -> GENERAL -> SUBMIT DATAS\", or from any shortcut on pages.", style: const 
              TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: const EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, "-> then you will access to a formulary selector, that will show the data formulary depending the selected one.", style: const 
              TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: const EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, " -> fill, at least, all required fields and then you only have to submit ! if any workflow is engaged, it will triggered on submition.", style: const 
              TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ])),];
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).secondaryHeaderColor, 
        title: const Text('TUTORIAL - HOW TO START', style: TextStyle(color: Colors.white),)),
      body: Container( height: MediaQuery.of(context).size.height, color: Theme.of(context).primaryColorLight,
          child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
        items: list,
      )),
    );
  }
}
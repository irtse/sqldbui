import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:pdfx/pdfx.dart';

var slide1 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: const AssetImage('assets/images/slide1.png'), height: currentHeigth - 260, width: currentWidth - 200, fit: BoxFit.cover, )),
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
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: const AssetImage('assets/images/slide2.png'), height: currentHeigth - 260, width: currentWidth - 200, fit: BoxFit.cover, )),
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
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: const AssetImage('assets/images/slide3.png'), height: currentHeigth - 260, width: currentWidth - 200, fit: BoxFit.cover, )),
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
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: AssetImage('assets/images/slide4.png'), height: currentHeigth - 260, width: currentWidth - 200, fit: BoxFit.cover, )),
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
        Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule9, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule10, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));
  
  var slide5 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: AssetImage('assets/images/slide5.png'), height: currentHeigth - 260, width: currentWidth - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text(TranslateConstants.howToAccess, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.howToOrder, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule11, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule12, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));

    var slide6 = (BuildContext context) => Container( decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]), child: Stack(children: [ 
      Container( margin: const EdgeInsets.only(top: 180), child: Image( image: AssetImage('assets/images/slide6.png'), height: currentHeigth - 260, width: currentWidth - 200, fit: BoxFit.cover, )),
      Container( height: 180, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ]),
         child: Column( children: [
        Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
            children: [ Flexible( child: Text(TranslateConstants.howToProgress, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30))) ])),
        Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
            children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.howToWorkflow, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule13, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
        Padding( padding: EdgeInsets.only(left: 80), child: Row( 
            children: [ 
              Flexible( child: Text(overflow: TextOverflow.ellipsis, TranslateConstants.needRule14, style: TextStyle(color: Colors.grey, fontSize: 12)))
        ])),
      ] ))
    ]));

class TutorialPopUpWidget extends StatefulWidget {
  const TutorialPopUpWidget ({ super.key,});
  @override
  TutorialPopUpState createState() => TutorialPopUpState();
}
class TutorialPopUpState extends State<TutorialPopUpWidget> {
  late final PdfControllerPinch _pdfController;
  int _pages = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/pdf/tutorial.pdf'),
    );

    _pdfController.pageListenable.addListener(() {
      setState(() {
        _currentPage = _pdfController.pageListenable.value;
      });
    });

    _loadPageCount();
  }

  Future<void> _loadPageCount() async {
    final doc = await PdfDocument.openAsset('assets/pdf/tutorial.pdf');
    setState(() {
      _pages = doc.pagesCount;
    });
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pdfController.jumpToPage(page);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).secondaryHeaderColor, iconTheme: IconThemeData(color: Theme.of(context).splashColor),
        title: Text("${TranslateConstants.howToTutorial.toUpperCase()} ($_currentPage/$_pages)", style: TextStyle(color: Colors.white),)),
      body: Row(
        children: [
          // Navigation panel
          Container(
            width: 80,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: _pages,
              itemBuilder: (context, index) {
                final pageNum = index + 1;
                return ListTile(
                  dense: true,
                  title: Text('$pageNum',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            _currentPage == pageNum ? FontWeight.bold : null,
                        color: _currentPage == pageNum
                            ? Colors.blue
                            : Colors.black,
                      )),
                  onTap: () => _goToPage(pageNum),
                );
              },
            ),
          ),
          // PDF view
          Expanded(
            child: PdfViewPinch(
              controller: _pdfController,
              scrollDirection: Axis.vertical,
            ),
          ),
        ],
      ),
    );
  }
}


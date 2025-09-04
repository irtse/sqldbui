import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:pdfx/pdfx.dart';

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
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).secondaryHeaderColor, iconTheme: IconThemeData(color: Theme.of(context).splashColor),
        title: Text("${(await getOnFlow(TranslateConstants.howToTutorial)).toUpperCase()} ($_currentPage/$_pages)", style: TextStyle(color: Colors.white),)),
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


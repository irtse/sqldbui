import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class TranslateConstants {
  static String inserImage = "insert image from desktop";
  static String errorRequire = "you must fill in the required fields *";
  static String searchInfoMake = "make a search to find others.";
  static String searchInfo = "items were found, they may be partially displayed.";
  static String addNewEntry = "add new entry";
  static String search = "search";
  static String noDashboard = "no dashboard found";
  static String global = "menu of the data";
  static String lang = "fr";
  static String synthesis = "tasks synthesis";
  
  static String empty = "not specified";
  static String all = "all";
  static String update = "update";
  static String favorites = "favorites";
  static String dashboard = "dashboard";
  static String back = "backspace";
  static String forward = "forward";

  static String disconnect = "disconnect your account";
  static String logout = "logout";
  static String tutorial = "tutorial";
  static String notifications = "notifications";
  static String menu = "menu";

  static String step = "step";

  static String filterPlaceholder = "select a filter...";
  static String filterLabel = "filters";

  static String sendMail = "send back mails";
  static String filterTitle = "LIST COLUMNS";
  static String filterApply = "APPLY";
  static String filterCancel = "CANCEL";
  static String filterSave = "SAVE";
  static String submit = "SUBMIT";
  static String draft = "DRAFT";
  static String publish = "PUBLISH";
  static String delete = "DELETE";
  static String filterViewPlaceholder = "filter view columns";

  static String filterMenu = "search in menu...";

  static String filterNew = "new filter line";
  static String filterRM = "remove filter line";
  static String filterApplyT = "apply filter";
  static String filterResetT = "reset filter";
  static String filterSaveT = "save filter";
  static String filterDeleteT = "delete filter";
  static String filterHide = "hide filter panel";
  static String filterShow = "show filter panel";

  static String home = "home page";
  static String loading = "LOADING";
  static String found = "lines";
  static String url = "actual url...";
  static String goto = "go to";

  static String translationON = "translation of grid is active";
  static String translationOFF = "translation of grid inactive";

  static String resetUI = "reset ui";

  static String exportMathList = "export selected rows with math operation...";
  static String exportMath= "export with math operation...";
  static String mathPlaceholder = "enter result column name...";
  static String mathValuePlaceholder = "please enter a result column value...";
  static String mathError = "column name already exists in the schema... can't choose this name";
  static String total = "total";
  static String edit = "edition";
  static String math = "math";

  static String rowsListDelete = "delete selected rows";
  static String rowsDelete = "delete data";
  static String rowsListExport = "export selected rows";
  static String rowsExport = "export data";
  static String rowsImport = "upload datas file";

  static String sortASC = "ASCENDING SORTING";
  static String sortDesc = "DESCENDING SORTING";
  static String value = "value";
  static String valueFilterPlaceholder = "value to filter...";
  static String valuePlaceholder = "please select a value..";
  static String like = "similar to";
  static String notLike = "not similar to";

  static String unshare = "cancel data sharing";
  static String share = "share data";

  static String undelegate = "cancel data delegation";
  static String delegate = "delegate data";

  static String pathToCopy = "navigation path for the browser :";
  static String shareToUser = "share to a user :";
  static String userShared = "user already shared :";

  static String delegateToUser = "delegate to a user :";
  static String userDelegated = "user already delegated :";

  static String successCopy = "successfully copied to clipboard";

  static String and = "and";
  static String or = "or";

  static String colFilter = "select a column to filter...";
  static String colErrFilter = "please select a column to filter...";

  static String colNullFilter = "select a null value...";
  static String colNullErrFilter = "please select a null value...";
  
  static String dismiss = "dismiss";
  static String validate = "validate";
  static String refused = "refused";

    static String send = "send";

  static String yes = "yes";
  static String no = "no";
  static String colDirFilter = "select a direction to filter...";
  static String placeHolderValue = "select value...";
  static String funcColErr = "no column function";
  static String colCompFilter = "please select a comparator to filter...";
  static String emptyData = "EMPTY DATA";
  static String newT = "NEW";
  static String draftT = "DRAFT";
  static String lost = "Seems pretty lost... go on another page please :)";
  static String sure = "Do we confirm?";
  static String undoAction = "You will not able to undo this action.";
  static String noWorkflow = "no workflow related !";
  static String nextOpt = "optional next steps:";

  static String howToCreate = "How to create a data ?";
  static String howToAssign = "How to access my assigned activities ?";
  static String howToReq = "How to access my requests ?";
  static String howToFilter = "How to filter by columns in a view list ? [ALPHA]";
  static String howToProgress = "How to track progress of a workflow ?";
  static String needAccess = "you need to access <submit page> from home page, \"MENU -> GENERAL -> SUBMIT DATAS\", or from any shortcut on pages.";
  static String needRule1 = "-> then you will access to a formulary selector, that will show the data formulary depending the selected one.";
  static String needRule2 = "-> fill, at least, all required fields and then you only have to submit ! if any workflow is engaged, it will triggered on submition.";
  static String needRule3 = "you need to access <assigned activity page> from home page, \"MENU -> ACTIVITY -> ASSIGNED ACTIVITY\". notifications will allows you a quick access to your unread activities.";
  static String needRule4 = "-> assigned activities concerns all your action to realise in the purpose of a current workflow, on closure, workflow will go to next activity (activity for you or another actor).";
  static String needRule5 = "-> an activity can be stated as <pending,progressing,dismiss,completed>. completion will close it as successful. dismiss will close it as failed. when closed an activity can't be reopenned without superadmin action.";
  static String needRule6 = "-> requests concerns all your request or your hierarchical subordinate. you can monitor where your requests are stated. notification will warn you on closure";
  static String needRule7 = "-> an request can be stated as <pending,progressing,dismiss,completed>. completion will close it as successful. dismiss will close it as rejected. when closed an activity can't be reopenned without superadmin action.";
  static String needRule8 = "-> filter showed column by tapping on the <gear> icon to open a popup panel to choose columns. filter can be saved. [ALPHA] only register state on session.";
  static String needRule9 = "-> filter on column by hovering column label and tapping <filter> icon to open a popup panel to filter by value column. filter multiple columns is allowed as 'and' connector. [ALPHA] only register state on session && does not adapt by column types only text considers.";
  static String needRule10 = "-> filter on full table by using top bar <filter> icon. [ALPHA] actually not working, only visually sets up.";
  static String needRule11 = "-> tap on a line of a list to acces its formulary. a form gives you state allowed depending your rights and actions available such as <save, delete>.";
  static String needRule12 = "-> [ACCESS] enter in top search bar in the middle of the screen, app path to the form. (can also be use to access a list view)";
  static String needRule13 = "-> only request, task shows workflow completion, on top of their forms. it consists of a simple bar declining steps with a list of parrallel subtask depending on step.";
  static String needRule14 = "-> grey color define not reached step, vivid color step is done or currently doing, icons in subtask will give you its current state (done or doing). task can show you a optionnal hub under main workflow, by this you can choose wich are the next step to launch.";

  static String showMenu = "open menu";
  static String showFilter = "show filter";

  static String savedFolder = "saved to folder";
  static String allowedFormat = "allowed format";
  static String howToAccess = "How to access a datas ?";
  static String howToTutorial = "TUTORIAL";
  static String howToOrder = "datas are ordered in thematized views accessible in the side menu. menu give access to datas list views.";
  static String howToWorkflow = "workflows are attached to a request. some request does not have a workflow to integrate data.";
  static String select = "select : ";
  static String selectDate = "select a date";
  static String selectValue = "select a value";
  static String writeValue = "write a value";
  static String writeNumber = "write a number";
  static String writePath = "write a path";

  static String commentary = "write your commentary";
  static String enterProper = "enter a proper value.";
  static String dataFormulary = "fill data formulary";
  static String formulary = "form";

  static String data = "the data";
  static String comments = "comments";
  static String history = "historical";
  static String formularyMenu = "submenu";
  static Map<String, String> onFlowTrad = {};
}

Future<String> getOnFlow(String value) async {
  if (value == "type") {
    return "type";
  }
  if (!TranslateConstants.onFlowTrad.containsKey(value)) {
    var translator = GoogleTranslator();
    var trans = await translator.translate(value, to: TranslateConstants.lang);
    TranslateConstants.onFlowTrad[value] = trans.text;
    if (TranslateConstants.onFlowTrad[value]!.contains("affiche")) {
      TranslateConstants.onFlowTrad[value] = TranslateConstants.onFlowTrad[value]!.replaceAll("l'affiche", "un poster"); // to AD HOC
      TranslateConstants.onFlowTrad[value] = TranslateConstants.onFlowTrad[value]!.replaceAll("affiche", "poster"); // to AD HOC
    }
  }
  return TranslateConstants.onFlowTrad[value]!;
}

getTranslateCookie() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var translation = prefs.getString("translation") != "" ? prefs.getString("translation") : null;
    if (translation != null) {
      for (var t in translation.split(";")) {
        var s = t.split("=");
        TranslateConstants.onFlowTrad[s[0]] = s[1];
      }
    }
  }

removeTranslateCookie() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("translation");
}

setTranslateCookie() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> arr = [];
  for (var key in  TranslateConstants.onFlowTrad.keys) {
    arr.add("$key=${TranslateConstants.onFlowTrad[key]}");
  }
  prefs.setString("translation", arr.join(";"));
}

translate( String addTranslation) async {
  if (TranslateConstants.onFlowTrad[addTranslation] == null) {
    return;
  }
  GoogleTranslator().translate(addTranslation, to: TranslateConstants.lang).then( (e) {
    TranslateConstants.onFlowTrad[addTranslation] = e.text.toLowerCase();
    setTranslateCookie();
  });
}

Future<void> setUpTranslate() async {
  getTranslateCookie(); 
  translate(TranslateConstants.home);
  translate(TranslateConstants.searchInfoMake);
  translate(TranslateConstants.searchInfo);
  translate(TranslateConstants.history);

  translate(TranslateConstants.filterTitle);
  translate(TranslateConstants.filterApply);
  translate(TranslateConstants.filterCancel);
  translate(TranslateConstants.filterSave);

  translate(TranslateConstants.filterViewPlaceholder);
  
  translate(TranslateConstants.filterRM);
  translate(TranslateConstants.filterNew);
  translate(TranslateConstants.filterApplyT);
  translate(TranslateConstants.filterResetT);
  translate(TranslateConstants.filterSaveT);
  translate(TranslateConstants.filterDeleteT);
  translate(TranslateConstants.filterHide);
  translate(TranslateConstants.filterShow);

  translate(TranslateConstants.addNewEntry);
  translate(TranslateConstants.search);

  translate(TranslateConstants.noDashboard);
  translate(TranslateConstants.formulary);
  translate(TranslateConstants.formularyMenu);
  translate(TranslateConstants.commentary);
  translate(TranslateConstants.global);

  translate(TranslateConstants.selectDate);
  translate(TranslateConstants.writeValue);
  translate(TranslateConstants.writeNumber);
  translate(TranslateConstants.writePath);
  translate(TranslateConstants.errorRequire);

  translate(TranslateConstants.sendMail);
  translate(TranslateConstants.data);
  translate(TranslateConstants.comments);
 
  translate(TranslateConstants.update);
  translate(TranslateConstants.send);
  translate(TranslateConstants.draftT);
  translate(TranslateConstants.dataFormulary);

  translate(TranslateConstants.enterProper);
  translate(TranslateConstants.selectValue);
  translate(TranslateConstants.select);
  translate(TranslateConstants.synthesis);

  translate(TranslateConstants.draft);
  translate(TranslateConstants.publish);
  translate(TranslateConstants.empty);
  translate(TranslateConstants.userShared);
  translate(TranslateConstants.shareToUser);

  translate(TranslateConstants.userDelegated);
  translate(TranslateConstants.delegateToUser);


  translate(TranslateConstants.savedFolder);
  translate(TranslateConstants.allowedFormat);

  translate(TranslateConstants.step);

  translate(TranslateConstants.showMenu);
  translate(TranslateConstants.showFilter);


  translate(TranslateConstants.refused);
  translate(TranslateConstants.dismiss);
  translate(TranslateConstants.validate);
  translate(TranslateConstants.inserImage);

  translate(TranslateConstants.sure);

  translate(TranslateConstants.all);
  translate(TranslateConstants.favorites);
  translate(TranslateConstants.dashboard);
  translate(TranslateConstants.back);
  translate(TranslateConstants.forward);

  translate(TranslateConstants.filterMenu);

  translate(TranslateConstants.disconnect);
  translate(TranslateConstants.logout);
  translate(TranslateConstants.tutorial);
  translate(TranslateConstants.notifications);
  translate(TranslateConstants.menu);

  translate(TranslateConstants.filterPlaceholder);
  translate(TranslateConstants.filterLabel);

  translate(TranslateConstants.loading);
  translate(TranslateConstants.found);
  translate(TranslateConstants.url);
  translate(TranslateConstants.goto);

  translate(TranslateConstants.resetUI);
  translate(TranslateConstants.translationON);
  translate(TranslateConstants.translationOFF);


  translate(TranslateConstants.exportMathList);
  translate(TranslateConstants.exportMath);
  translate(TranslateConstants.mathPlaceholder);
  translate(TranslateConstants.mathValuePlaceholder);
  translate(TranslateConstants.mathError);
  translate(TranslateConstants.total);
  translate(TranslateConstants.edit);
  translate(TranslateConstants.math);

  translate(TranslateConstants.rowsDelete);
  translate(TranslateConstants.rowsListDelete);
  translate(TranslateConstants.rowsExport);
  translate(TranslateConstants.rowsListExport);
  translate(TranslateConstants.rowsImport);

  translate(TranslateConstants.sortASC);
  translate(TranslateConstants.sortDesc);
  translate(TranslateConstants.value);
  translate(TranslateConstants.valueFilterPlaceholder);
  translate(TranslateConstants.like);
  translate(TranslateConstants.notLike);
  
  translate(TranslateConstants.undelegate);
  translate(TranslateConstants.delegate);

  translate(TranslateConstants.unshare);

  translate(TranslateConstants.share);
  translate(TranslateConstants.pathToCopy);
  translate(TranslateConstants.successCopy);

  translate(TranslateConstants.and);
  translate(TranslateConstants.or);

  translate(TranslateConstants.colFilter);
  translate(TranslateConstants.colErrFilter);

  translate(TranslateConstants.colNullFilter);
  translate(TranslateConstants.colCompFilter);

  translate(TranslateConstants.colNullFilter);
  translate(TranslateConstants.colNullErrFilter);
  translate(TranslateConstants.submit);
  translate(TranslateConstants.delete);

  translate(TranslateConstants.yes);
  translate(TranslateConstants.no);
  translate(TranslateConstants.funcColErr);
  translate(TranslateConstants.placeHolderValue);
  translate(TranslateConstants.emptyData);
  translate(TranslateConstants.newT);
  translate(TranslateConstants.lost);
  translate(TranslateConstants.undoAction);
  translate(TranslateConstants.noWorkflow);
  translate(TranslateConstants.nextOpt);

  translate(TranslateConstants.howToCreate);
  translate(TranslateConstants.howToAssign);
  translate(TranslateConstants.howToReq);
  translate(TranslateConstants.howToTutorial);
  translate(TranslateConstants.howToFilter);
  translate(TranslateConstants.howToProgress);
  translate(TranslateConstants.howToAccess);
  translate(TranslateConstants.howToOrder);
  translate(TranslateConstants.howToWorkflow);
  
  
  translate(TranslateConstants.needAccess);
  translate(TranslateConstants.needRule1);
  translate(TranslateConstants.needRule2);
  translate(TranslateConstants.needRule3);
  translate(TranslateConstants.needRule4);
  translate(TranslateConstants.needRule5);
  translate(TranslateConstants.needRule6);
  translate(TranslateConstants.needRule7);
  translate(TranslateConstants.needRule8);
  translate(TranslateConstants.needRule9);
  translate(TranslateConstants.needRule10);
  translate(TranslateConstants.needRule11);
  translate(TranslateConstants.needRule12);
  translate(TranslateConstants.needRule13);
  translate(TranslateConstants.needRule14);
}


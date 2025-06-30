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

  static String filterNew = "new filter";
  static String filterApplyT = "apply filter";
  static String filterResetT = "reset filter";
  static String filterSaveT = "save filter";
  static String filterDeleteT = "delete filter";
  static String filterHide = "hide filter panel";
  static String filterShow = "show filter panel";

  static String home = "home page";
  static String loading = "LOADING";
  static String found = "items found";
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

  static String sortASC = "SORT ASCENDING";
  static String sortDesc = "SORT DESCENDING";
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

  static String showMenu = "show menu";
  static String showFilter = "show filter";

  static String savedFolder = "saved to folder";
  static String allowedFormat = "allowed format";
  static String howToAccess = "How to access a datas ?";
  static String howToTutorial = "TUTORIAL - HOW TO START";
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
      TranslateConstants.onFlowTrad[value] = TranslateConstants.onFlowTrad[value]!.replaceAll("affiche", "poster"); // to AD HOC
    }
  }
  return TranslateConstants.onFlowTrad[value]!;
}

Future<void> setUpTranslate() async {
  var translator = GoogleTranslator();

  translator.translate(TranslateConstants.home, to: TranslateConstants.lang).then( (e) => TranslateConstants.home = e.text.toLowerCase());
  translator.translate(TranslateConstants.searchInfoMake, to: TranslateConstants.lang).then( (e) => TranslateConstants.searchInfoMake = e.text.toLowerCase());
  translator.translate(TranslateConstants.searchInfo, to: TranslateConstants.lang).then( (e) => TranslateConstants.searchInfo = e.text.toLowerCase());

  translator.translate(TranslateConstants.filterTitle, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterTitle = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterApply, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterApply = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterCancel, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterCancel = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterSave, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterSave = e.text.toLowerCase());

  translator.translate(TranslateConstants.filterViewPlaceholder, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterViewPlaceholder = e.text.toLowerCase());

  translator.translate(TranslateConstants.filterNew, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterNew = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterApplyT, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterApplyT = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterResetT, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterResetT = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterSaveT, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterSaveT = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterDeleteT, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterDeleteT = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterHide, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterHide = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterShow, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterShow = e.text.toLowerCase());

  translator.translate(TranslateConstants.addNewEntry, to: TranslateConstants.lang).then( (e) => TranslateConstants.addNewEntry = e.text.toLowerCase());
  translator.translate(TranslateConstants.search, to: TranslateConstants.lang).then( (e) => TranslateConstants.search = e.text.toLowerCase());

  translator.translate(TranslateConstants.noDashboard, to: TranslateConstants.lang).then( (e) => TranslateConstants.noDashboard = e.text.toLowerCase());
  translator.translate(TranslateConstants.formulary, to: TranslateConstants.lang).then( (e) => TranslateConstants.formulary = e.text.toLowerCase());
  translator.translate(TranslateConstants.formularyMenu, to: TranslateConstants.lang).then( (e) => TranslateConstants.formularyMenu = e.text.toLowerCase());
  translator.translate(TranslateConstants.commentary, to: TranslateConstants.lang).then( (e) => TranslateConstants.commentary = e.text.toLowerCase());
  translator.translate(TranslateConstants.global, to: TranslateConstants.lang).then( (e) => TranslateConstants.global = e.text.toLowerCase());

  translator.translate(TranslateConstants.selectDate, to: TranslateConstants.lang).then( (e) => TranslateConstants.selectDate = e.text.toLowerCase());
  translator.translate(TranslateConstants.writeValue, to: TranslateConstants.lang).then( (e) => TranslateConstants.writeValue = e.text.toLowerCase());
  translator.translate(TranslateConstants.writeNumber, to: TranslateConstants.lang).then( (e) => TranslateConstants.writeNumber = e.text.toLowerCase());
  translator.translate(TranslateConstants.writePath, to: TranslateConstants.lang).then( (e) => TranslateConstants.writePath = e.text.toLowerCase());
  translator.translate(TranslateConstants.errorRequire, to: TranslateConstants.lang).then( (e) => TranslateConstants.errorRequire = e.text.toLowerCase());

  translator.translate(TranslateConstants.sendMail, to: TranslateConstants.lang).then( (e) => TranslateConstants.sendMail = e.text.toLowerCase());
  translator.translate(TranslateConstants.data, to: TranslateConstants.lang).then( (e) => TranslateConstants.data = e.text.toLowerCase());
  translator.translate(TranslateConstants.comments, to: TranslateConstants.lang).then( (e) => TranslateConstants.comments = e.text.toLowerCase());
 
  translator.translate(TranslateConstants.update, to: TranslateConstants.lang).then( (e) => TranslateConstants.update = e.text.toLowerCase());
  translator.translate(TranslateConstants.send, to: TranslateConstants.lang).then( (e) => TranslateConstants.send = e.text.toLowerCase());
  translator.translate(TranslateConstants.draftT, to: TranslateConstants.lang).then( (e) => TranslateConstants.draftT = e.text.toLowerCase());
  translator.translate(TranslateConstants.dataFormulary, to: TranslateConstants.lang).then( (e) => TranslateConstants.dataFormulary = e.text.toLowerCase());

  translator.translate(TranslateConstants.enterProper, to: TranslateConstants.lang).then( (e) => TranslateConstants.enterProper = e.text.toLowerCase());
  translator.translate(TranslateConstants.selectValue, to: TranslateConstants.lang).then( (e) => TranslateConstants.selectValue = e.text.toLowerCase());
  translator.translate(TranslateConstants.select, to: TranslateConstants.lang).then( (e) => TranslateConstants.select = e.text.toLowerCase());
  translator.translate(TranslateConstants.synthesis, to: TranslateConstants.lang).then( (e) => TranslateConstants.synthesis = e.text.toLowerCase());

  translator.translate(TranslateConstants.draft, to: TranslateConstants.lang).then( (e) => TranslateConstants.draft = e.text.toLowerCase());
  translator.translate(TranslateConstants.publish, to: TranslateConstants.lang).then( (e) => TranslateConstants.publish = e.text.toLowerCase());
  translator.translate(TranslateConstants.empty, to: TranslateConstants.lang).then( (e) => TranslateConstants.empty = e.text.toLowerCase());
  translator.translate(TranslateConstants.userShared, to: TranslateConstants.lang).then( (e) => TranslateConstants.userShared = e.text.toLowerCase());
  translator.translate(TranslateConstants.shareToUser, to: TranslateConstants.lang).then( (e) => TranslateConstants.shareToUser = e.text.toLowerCase());

  translator.translate(TranslateConstants.userDelegated, to: TranslateConstants.lang).then( (e) => TranslateConstants.userDelegated = e.text.toLowerCase());
  translator.translate(TranslateConstants.delegateToUser, to: TranslateConstants.lang).then( (e) => TranslateConstants.delegateToUser = e.text.toLowerCase());


  translator.translate(TranslateConstants.savedFolder, to: TranslateConstants.lang).then( (e) => TranslateConstants.savedFolder = e.text.toLowerCase());
  translator.translate(TranslateConstants.allowedFormat, to: TranslateConstants.lang).then( (e) => TranslateConstants.allowedFormat = e.text.toLowerCase());

  translator.translate(TranslateConstants.step, to: TranslateConstants.lang).then( (e) => TranslateConstants.step = e.text.toLowerCase());

  translator.translate(TranslateConstants.showMenu, to: TranslateConstants.lang).then( (e) => TranslateConstants.showMenu = e.text.toLowerCase());
  translator.translate(TranslateConstants.showFilter, to: TranslateConstants.lang).then( (e) => TranslateConstants.showFilter = e.text.toLowerCase());


  translator.translate(TranslateConstants.refused, to: TranslateConstants.lang).then( (e) => TranslateConstants.refused = e.text.toLowerCase());
  translator.translate(TranslateConstants.dismiss, to: TranslateConstants.lang).then( (e) => TranslateConstants.dismiss = e.text.toLowerCase());
  translator.translate(TranslateConstants.validate, to: TranslateConstants.lang).then( (e) => TranslateConstants.validate = e.text.toLowerCase());
  translator.translate(TranslateConstants.inserImage, to: TranslateConstants.lang).then( (e) => TranslateConstants.inserImage = e.text.toLowerCase());

  translator.translate(TranslateConstants.sure, to: TranslateConstants.lang).then( (e) => TranslateConstants.sure = e.text.toLowerCase());

  translator.translate(TranslateConstants.all, to: TranslateConstants.lang).then( (e) => TranslateConstants.all = e.text.toLowerCase());
  translator.translate(TranslateConstants.favorites, to: TranslateConstants.lang).then( (e) => TranslateConstants.favorites = e.text.toLowerCase());
  translator.translate(TranslateConstants.dashboard, to: TranslateConstants.lang).then( (e) => TranslateConstants.dashboard = e.text.toLowerCase());
  translator.translate(TranslateConstants.back, to: TranslateConstants.lang).then( (e) => TranslateConstants.back = e.text.toLowerCase());
  translator.translate(TranslateConstants.forward, to: TranslateConstants.lang).then( (e) => TranslateConstants.forward = e.text.toLowerCase());

  translator.translate(TranslateConstants.filterMenu, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterMenu = e.text.toLowerCase());

  translator.translate(TranslateConstants.disconnect, to: TranslateConstants.lang).then( (e) => TranslateConstants.disconnect = e.text.toLowerCase());
  translator.translate(TranslateConstants.logout, to: TranslateConstants.lang).then( (e) => TranslateConstants.logout = e.text.toLowerCase());
  translator.translate(TranslateConstants.tutorial, to: TranslateConstants.lang).then( (e) => TranslateConstants.tutorial = e.text.toLowerCase());
  translator.translate(TranslateConstants.notifications, to: TranslateConstants.lang).then( (e) => TranslateConstants.notifications = e.text.toLowerCase());
  translator.translate(TranslateConstants.menu, to: TranslateConstants.lang).then( (e) => TranslateConstants.menu = e.text.toLowerCase());

  translator.translate(TranslateConstants.filterPlaceholder, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterPlaceholder = e.text.toLowerCase());
  translator.translate(TranslateConstants.filterLabel, to: TranslateConstants.lang).then( (e) => TranslateConstants.filterLabel = e.text.toLowerCase());

  translator.translate(TranslateConstants.loading, to: TranslateConstants.lang).then( (e) => TranslateConstants.loading = e.text.toLowerCase());
  translator.translate(TranslateConstants.found, to: TranslateConstants.lang).then( (e) => TranslateConstants.found = e.text.toLowerCase());
  translator.translate(TranslateConstants.url, to: TranslateConstants.lang).then( (e) => TranslateConstants.url = e.text.toLowerCase());
  translator.translate(TranslateConstants.goto, to: TranslateConstants.lang).then( (e) => TranslateConstants.goto = e.text.toLowerCase());

  translator.translate(TranslateConstants.resetUI, to: TranslateConstants.lang).then( (e) => TranslateConstants.resetUI = e.text.toLowerCase());
  translator.translate(TranslateConstants.translationON, to: TranslateConstants.lang).then( (e) => TranslateConstants.translationON = e.text.toLowerCase());
  translator.translate(TranslateConstants.translationOFF, to: TranslateConstants.lang).then( (e) => TranslateConstants.translationOFF = e.text.toLowerCase());


  translator.translate(TranslateConstants.exportMathList, to: TranslateConstants.lang).then( (e) => TranslateConstants.exportMathList = e.text.toLowerCase());
  translator.translate(TranslateConstants.exportMath, to: TranslateConstants.lang).then( (e) => TranslateConstants.exportMathList = e.text.toLowerCase());
  translator.translate(TranslateConstants.mathPlaceholder, to: TranslateConstants.lang).then( (e) => TranslateConstants.mathPlaceholder = e.text.toLowerCase());
  translator.translate(TranslateConstants.mathValuePlaceholder, to: TranslateConstants.lang).then( (e) => TranslateConstants.mathValuePlaceholder = e.text.toLowerCase());
  translator.translate(TranslateConstants.mathError, to: TranslateConstants.lang).then( (e) => TranslateConstants.mathError = e.text.toLowerCase());
  translator.translate(TranslateConstants.total, to: TranslateConstants.lang).then( (e) => TranslateConstants.total = e.text.toLowerCase());
  translator.translate(TranslateConstants.edit, to: TranslateConstants.lang).then( (e) => TranslateConstants.edit = e.text.toLowerCase());
  translator.translate(TranslateConstants.math, to: TranslateConstants.lang).then( (e) => TranslateConstants.math = e.text.toLowerCase());

  translator.translate(TranslateConstants.rowsDelete, to: TranslateConstants.lang).then( (e) => TranslateConstants.rowsDelete = e.text.toLowerCase());
  translator.translate(TranslateConstants.rowsListDelete, to: TranslateConstants.lang).then( (e) => TranslateConstants.rowsListDelete = e.text.toLowerCase());
  translator.translate(TranslateConstants.rowsExport, to: TranslateConstants.lang).then( (e) => TranslateConstants.rowsExport = e.text.toLowerCase());
  translator.translate(TranslateConstants.rowsListExport, to: TranslateConstants.lang).then( (e) => TranslateConstants.rowsListExport = e.text.toLowerCase());
  translator.translate(TranslateConstants.rowsImport, to: TranslateConstants.lang).then( (e) => TranslateConstants.rowsImport = e.text.toLowerCase());

  translator.translate(TranslateConstants.sortASC, to: TranslateConstants.lang).then( (e) => TranslateConstants.sortASC = e.text.toLowerCase());
  translator.translate(TranslateConstants.sortDesc, to: TranslateConstants.lang).then( (e) => TranslateConstants.sortDesc = e.text.toLowerCase());
  translator.translate(TranslateConstants.value, to: TranslateConstants.lang).then( (e) => TranslateConstants.value = e.text.toLowerCase());
  translator.translate(TranslateConstants.valueFilterPlaceholder, to: TranslateConstants.lang).then( (e) => TranslateConstants.valueFilterPlaceholder = e.text.toLowerCase());
  translator.translate(TranslateConstants.like, to: TranslateConstants.lang).then( (e) => TranslateConstants.like = e.text.toLowerCase());
  translator.translate(TranslateConstants.notLike, to: TranslateConstants.lang).then( (e) => TranslateConstants.notLike = e.text.toLowerCase());
  
  translator.translate(TranslateConstants.undelegate, to: TranslateConstants.lang).then( (e) => TranslateConstants.undelegate = e.text.toLowerCase());
  translator.translate(TranslateConstants.delegate, to: TranslateConstants.lang).then( (e) => TranslateConstants.delegate = e.text.toLowerCase());

  translator.translate(TranslateConstants.unshare, to: TranslateConstants.lang).then( (e) => TranslateConstants.unshare = e.text.toLowerCase());

  translator.translate(TranslateConstants.share, to: TranslateConstants.lang).then( (e) => TranslateConstants.share = e.text.toLowerCase());
  translator.translate(TranslateConstants.pathToCopy, to: TranslateConstants.lang).then( (e) => TranslateConstants.pathToCopy = e.text.toLowerCase());
  translator.translate(TranslateConstants.successCopy, to: TranslateConstants.lang).then( (e) => TranslateConstants.successCopy = e.text.toLowerCase());

  translator.translate(TranslateConstants.and, to: TranslateConstants.lang).then( (e) => TranslateConstants.and = e.text.toLowerCase());
  translator.translate(TranslateConstants.or, to: TranslateConstants.lang).then( (e) => TranslateConstants.or = e.text.toLowerCase());

  translator.translate(TranslateConstants.colFilter, to: TranslateConstants.lang).then( (e) => TranslateConstants.colFilter = e.text.toLowerCase());
  translator.translate(TranslateConstants.colErrFilter, to: TranslateConstants.lang).then( (e) => TranslateConstants.colErrFilter = e.text.toLowerCase());

  translator.translate(TranslateConstants.colNullFilter, to: TranslateConstants.lang).then( (e) => TranslateConstants.colDirFilter = e.text.toLowerCase());
  translator.translate(TranslateConstants.colCompFilter, to: TranslateConstants.lang).then( (e) => TranslateConstants.colCompFilter = e.text.toLowerCase());

  translator.translate(TranslateConstants.colNullFilter, to: TranslateConstants.lang).then( (e) => TranslateConstants.colNullFilter = e.text.toLowerCase());
  translator.translate(TranslateConstants.colNullErrFilter, to: TranslateConstants.lang).then( (e) => TranslateConstants.colNullErrFilter = e.text.toLowerCase());
  translator.translate(TranslateConstants.submit, to: TranslateConstants.lang).then( (e) => TranslateConstants.submit = e.text.toLowerCase());
  translator.translate(TranslateConstants.delete, to: TranslateConstants.lang).then( (e) => TranslateConstants.delete = e.text.toLowerCase());

  translator.translate(TranslateConstants.yes, to: TranslateConstants.lang).then( (e) => TranslateConstants.yes = e.text.toLowerCase());
  translator.translate(TranslateConstants.no, to: TranslateConstants.lang).then( (e) => TranslateConstants.no = e.text.toLowerCase());
  translator.translate(TranslateConstants.funcColErr, to: TranslateConstants.lang).then( (e) => TranslateConstants.funcColErr = e.text.toLowerCase());
  translator.translate(TranslateConstants.placeHolderValue, to: TranslateConstants.lang).then( (e) => TranslateConstants.placeHolderValue = e.text.toLowerCase());
  translator.translate(TranslateConstants.emptyData, to: TranslateConstants.lang).then( (e) => TranslateConstants.emptyData = e.text.toLowerCase());
  translator.translate(TranslateConstants.newT, to: TranslateConstants.lang).then( (e) => TranslateConstants.newT = e.text.toLowerCase());
  translator.translate(TranslateConstants.lost, to: TranslateConstants.lang).then( (e) => TranslateConstants.lost = e.text.toLowerCase());
  translator.translate(TranslateConstants.undoAction, to: TranslateConstants.lang).then( (e) => TranslateConstants.undoAction = e.text.toLowerCase());
  translator.translate(TranslateConstants.noWorkflow, to: TranslateConstants.lang).then( (e) => TranslateConstants.noWorkflow = e.text.toLowerCase());
  translator.translate(TranslateConstants.nextOpt, to: TranslateConstants.lang).then( (e) => TranslateConstants.nextOpt = e.text.toLowerCase());

  translator.translate(TranslateConstants.howToCreate, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToCreate = e.text.toLowerCase());
  translator.translate(TranslateConstants.howToAssign, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToAssign = e.text.toLowerCase());
  translator.translate(TranslateConstants.howToReq, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToReq = e.text.toLowerCase());
  translator.translate(TranslateConstants.howToTutorial, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToTutorial = e.text.toLowerCase());
  translator.translate(TranslateConstants.howToFilter, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToFilter = e.text.toLowerCase());
  translator.translate(TranslateConstants.howToProgress, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToProgress = e.text.toLowerCase());
  translator.translate(TranslateConstants.howToAccess, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToAccess = e.text.toLowerCase());
  translator.translate(TranslateConstants.howToOrder, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToOrder = e.text.toLowerCase());
  translator.translate(TranslateConstants.howToWorkflow, to: TranslateConstants.lang).then( (e) => TranslateConstants.howToWorkflow = e.text.toLowerCase());
  
  
  translator.translate(TranslateConstants.needAccess, to: TranslateConstants.lang).then( (e) => TranslateConstants.needAccess = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule1, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule1 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule2, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule2 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule3, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule3 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule4, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule4 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule5, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule5 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule6, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule6 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule7, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule7 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule8, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule8 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule9, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule9 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule10, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule10 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule11, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule11 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule12, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule12 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule13, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule13 = e.text.toLowerCase());
  translator.translate(TranslateConstants.needRule14, to: TranslateConstants.lang).then( (e) => TranslateConstants.needRule14 = e.text.toLowerCase());
}

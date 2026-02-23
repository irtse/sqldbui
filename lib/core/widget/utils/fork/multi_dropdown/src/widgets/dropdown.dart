part of '../multi_dropdown.dart';

/// Dropdown widget for the multiselect dropdown.
///
class _Dropdown<T> extends StatelessWidget {
  /// Creates a dropdown widget.
  const _Dropdown({
    required this.label,
    required this.decoration,
    required this.width,
    required this.searchEnabled,
    required this.dropdownItemDecoration,
    required this.searchDecoration,
    required this.maxSelections,
    required this.items,
    required this.onItemTap,
    this.changeFunction,
    this.addFunction,
    Key? key,
    this.max = 0,
    this.onSearchChange,
    this.itemBuilder,
    this.itemSeparator,
    this.singleSelect = false,
    this.gk,
  }) : super(key: key);
  final GlobalKey<OptionsListState>? gk;
  final void Function(String)? changeFunction;
  final void Function(String)? addFunction;
  /// The decoration of the dropdown.
  final DropdownDecoration decoration;
  final int max;
  /// Whether the search field is enabled.
  final bool searchEnabled;

  /// The width of the dropdown.
  final double width;
  final String label;

  /// The decoration of the dropdown items.
  final DropdownItemDecoration dropdownItemDecoration;

  /// Dropdown item builder, if not provided, the default ListTile will be used.
  final DropdownItemBuilder<T>? itemBuilder;

  /// The separator between the dropdown items.
  final Widget? itemSeparator;

  /// The decoration of the search field.
  final SearchFieldDecoration searchDecoration;

  /// The maximum number of selections allowed.
  final int maxSelections;

  /// The list of dropdown items.
  final List<DropdownItem<T>> items;

  /// The callback when an item is tapped.
  final ValueChanged<DropdownItem<T>> onItemTap;

  /// The callback when the search field value changes.
  final ValueChanged<List<String>>? onSearchChange;
  /// Whether the selection is single.
  final bool singleSelect;

  int get _selectedCount => items.where((element) => element.selected).length;

  static const Map<ShortcutActivator, Intent> _webShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowDown):
        DirectionalFocusIntent(TraversalDirection.down),
    SingleActivator(LogicalKeyboardKey.arrowUp):
        DirectionalFocusIntent(TraversalDirection.up),
  };

  @override Widget build(BuildContext context) {  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    final theme = Theme.of(context);

    final child = Material(
      elevation: decoration.elevation,
      borderRadius: decoration.borderRadius,
      clipBehavior: Clip.antiAlias,
      color: decoration.backgroundColor,
      surfaceTintColor: decoration.backgroundColor,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: decoration.borderRadius,
            color: decoration.backgroundColor,
            backgroundBlendMode: BlendMode.dstATop,
          ),
          constraints: BoxConstraints(
            maxWidth: width,
            maxHeight: decoration.maxHeight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (searchEnabled)
                if (max > 20) 
                  Column(children: [
                    Center(child: Padding(padding: EdgeInsets.only(bottom: 5, top: 15, left: 10, right: 10),
                      child: Text("$max ${(await getOnFlow(TranslateConstants.searchInfo)).toLowerCase()}", 
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    )),
                    Center(child: Padding(padding: EdgeInsets.only(bottom: 5),
                      child: Text((await getOnFlow(TranslateConstants.searchInfoMake)), style: TextStyle(color: Colors.grey)),
                    )),
                  ]),
                SearchField(
                  label: label,
                  function: addFunction,
                  decoration: searchDecoration,
                  changeFunction: changeFunction,
                  onChanged: _onSearchChange,
                ),
              if (decoration.header != null)
                Flexible(child: decoration.header!),
              OptionsList( key: gk, buildOption: _buildOption, items: items, theme: theme, itemSeparator: itemSeparator,),
              if (items.isEmpty && searchEnabled)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No items found',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              if (decoration.footer != null)
                Flexible(child: decoration.footer!),
            ],
          ),
        ),
      ),
    );

    if (kIsWeb || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return Shortcuts(shortcuts: _webShortcuts, child: child);
    }

    return child;
  }

  Widget _buildOption(int index, ThemeData theme) {
    final option = items[index];

    if (itemBuilder != null) {
      return itemBuilder!(option, index, () => onItemTap(option));
    }

    final disabledColor = dropdownItemDecoration.disabledBackgroundColor ??
        dropdownItemDecoration.backgroundColor?.withAlpha(100);

    final tileColor = option.disabled
        ? disabledColor
        : option.selected
            ? dropdownItemDecoration.selectedBackgroundColor
            : dropdownItemDecoration.backgroundColor;

    final trailing = option.disabled
        ? dropdownItemDecoration.disabledIcon
        : option.selected
            ? dropdownItemDecoration.selectedIcon
            : null;

    return Ink(
      child: ListTile(
        title: Text(option.label),
        trailing: trailing,
        dense: true,
        enabled: !option.disabled,
        selected: option.selected,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        focusColor: dropdownItemDecoration.backgroundColor?.withAlpha(100),
        selectedColor: dropdownItemDecoration.selectedTextColor ??
            theme.colorScheme.onSurface,
        textColor:
            dropdownItemDecoration.textColor ?? theme.colorScheme.onSurface,
        tileColor: tileColor ?? Colors.transparent,
        selectedTileColor: dropdownItemDecoration.selectedBackgroundColor ??
            Colors.grey.shade200,
        onTap: () {
          if (option.disabled || (option.selected && singleSelect)) return;
          if (singleSelect && !option.selected  || (!_reachedMaxSelection(option))) {
            onItemTap(option);
            return;
          }
        },
      ),
    );
  }

  void _onSearchChange(List<String> value) => onSearchChange?.call(value);

  bool _reachedMaxSelection(DropdownItem<dynamic> option) {
    return !option.selected &&
        maxSelections > 0 &&
        _selectedCount >= maxSelections;
  }
}
Map<String,TextEditingController> searchCtrl = {};
Map<String, List<String>> search = {};
Map<String, List<String>> alreadySearch = {};

class OptionsList<T>  extends StatefulWidget {
  List<DropdownItem<T>> items;
  Widget Function(int, ThemeData) buildOption;
  ThemeData theme;
  Widget? itemSeparator;

  OptionsList({super.key, required this.items, required this.buildOption, required this.theme, required this.itemSeparator});

  @override
  State<OptionsList> createState() => OptionsListState();
}

class OptionsListState extends State<OptionsList> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
                child: ListView.separated(
                  separatorBuilder: (_, __) =>
                      widget.itemSeparator ?? const SizedBox.shrink(),
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (_, int index) => widget.buildOption(index, widget.theme),
                ),
              );
  }
}

// ignore: must_be_immutable
class SearchField extends StatefulWidget {
   SearchField({
    required this.decoration,
    required this.onChanged,
    required this.changeFunction,
    required this.label,
    this.function,
  });

  final String label;
  final SearchFieldDecoration decoration;
  final ValueChanged<List<String>> onChanged;
  final void Function(String)? function;
  final void Function(String)? changeFunction;




  @override SearchFieldState createState() => SearchFieldState();
}
class SearchFieldState extends State<SearchField> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
                    searchCtrl[widget.label]?.selection = TextSelection.collapsed(
                      offset: searchCtrl[widget.label]?.text.length ?? 0,
                    );
                  }); 
    });
  }
  @override Widget build(BuildContext context) {
  Future.delayed(Duration(milliseconds: 500), (){
    widget.onChanged(search[widget.label] ?? []);
  });
  
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    if (searchCtrl[widget.label] == null) {
      searchCtrl[widget.label] =TextEditingController();
    }
    if ((searchCtrl[widget.label]?.text ?? "") != "" && (searchCtrl[widget.label]?.text ?? "") != search[widget.label]?.join(" ") ) {
      Future.delayed(Duration(microseconds: 100), () {
        search[widget.label]=(searchCtrl[widget.label]?.text ?? "").split(" ");
        widget.onChanged(search[widget.label]!);
      });
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap( 
      alignment: WrapAlignment.center, 
      children: [ TextField(
        autofocus: true,
        controller: searchCtrl[widget.label]!,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.decoration.hintText,
          border: widget.decoration.border,
          focusedBorder: widget.decoration.focusedBorder,
          suffixIcon: widget.decoration.searchIcon,
        ),
        onChanged: (String v) {
          search[widget.label] = ((searchCtrl[widget.label]?.text ?? "").trim()).split(" ");
          if (widget.changeFunction != null) {
            Future.delayed(Duration(milliseconds: 500), () {
              if (searchCtrl[widget.label]?.text == v) {
                widget.changeFunction!(searchCtrl[widget.label]?.text ?? "");
                widget.onChanged(search[widget.label] ??  []);
              } 
            });
          }
        },
      ), widget.function == null ? Container() : Padding(padding: EdgeInsets.only(top: 10), 
      child: InkWell( 
        onTap: () {
          if ((searchCtrl[widget.label]?.text ?? "") != "") {
            widget.function!(searchCtrl[widget.label]?.text ?? "");
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration( 
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Theme.of(context).primaryColor,
          ),
          padding: EdgeInsets.all(10), width: (currentWidth - menuSize) / 2, 
          child: Text((await getOnFlow(TranslateConstants.addNewEntry)).toLowerCase(), 
            style: TextStyle(color: Colors.white))))) ])
    );
  }
}

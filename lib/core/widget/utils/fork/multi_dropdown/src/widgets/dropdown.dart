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
  }) : super(key: key);
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

  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
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
                _SearchField(
                  label: label,
                  function: addFunction,
                  decoration: searchDecoration,
                  changeFunction: changeFunction,
                  onChanged: _onSearchChange,
                ),
              if (decoration.header != null)
                Flexible(child: decoration.header!),
              Flexible(
                child: ListView.separated(
                  separatorBuilder: (_, __) =>
                      itemSeparator ?? const SizedBox.shrink(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, int index) => _buildOption(index, theme),
                ),
              ),
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

// ignore: must_be_immutable
class _SearchField extends StatelessWidget {
   _SearchField({
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

  @override
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    if (searchCtrl[label] == null) {
      searchCtrl[label] =TextEditingController();
    }
    if ((searchCtrl[label]?.text ?? "") != "" ) {
      Future.delayed(Duration(seconds: 1), () {
        if (search[label] == null) {
          search[label]=[];
        }
        search[label]!.add(searchCtrl[label]?.text ?? "");
        onChanged(search[label]!);
      });
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap( 
      alignment: WrapAlignment.center, 
      children: [ TextField(
        autofocus: true,
        controller: searchCtrl[label]!,
        decoration: InputDecoration(
          isDense: true,
          hintText: decoration.hintText,
          border: decoration.border,
          focusedBorder: decoration.focusedBorder,
          suffixIcon: decoration.searchIcon,
        ),
        onChanged: (String v) {
          search[label] = (searchCtrl[label]?.text ?? "").split(" ");
          if (changeFunction != null) {
            Future.delayed(Duration(seconds: 1), () {
              if (searchCtrl[label]?.text == v) {
                changeFunction!(searchCtrl[label]?.text ?? "");
                onChanged(search[label] ??  []);
              } 
            });
          }
        },
      ), function == null ? Container() : Padding(padding: EdgeInsets.only(top: 10), 
      child: InkWell( 
        onTap: () {
          if ((searchCtrl[label]?.text ?? "") != "") {
            function!(searchCtrl[label]?.text ?? "");
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

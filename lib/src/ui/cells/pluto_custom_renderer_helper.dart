import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/helper/platform_helper.dart';

/// Hücre editleme durumunu izleyen enum
enum _CellEditingStatus {
  init,
  changed,
  updated;

  bool get isNotChanged => this != _CellEditingStatus.changed;
  bool get isChanged => this == _CellEditingStatus.changed;
  bool get isUpdated => this == _CellEditingStatus.updated;
}

/// PlutoGrid hücre renderer'ı için genel bir yardımcı sınıf.
/// Bu sınıf, herhangi bir özel widget'ı (TextFormField, DropdownSearch, vb.)
/// PlutoGrid'in hücre düzenleme sistemiyle entegre etmek için kullanılabilir.
class PlutoCustomRendererHelper {
  final PlutoGridStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;
  final PlutoRow row;

  // Özel değer değişikliği callback'i
  final Function(dynamic value)? onValueChanged;

  // Klavye olayları için özel kontrol callback'i
  final bool Function(PlutoKeyManagerEvent)? onKeyPressed;

  late final FocusNode _cellFocus;
  late final TextEditingController _textController;
  final PlutoDebounceByHashCode _debounce = PlutoDebounceByHashCode();

  dynamic _initialCellValue;
  late _CellEditingStatus _cellEditingStatus;

  PlutoCustomRendererHelper({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    this.onValueChanged,
    this.onKeyPressed,
  }) {
    _initialize();
  }

  FocusNode get cellFocus => _cellFocus;

  TextEditingController get textController => _textController;

  // Hücre değerinin formatlı halini döndürür
  String get formattedValue =>
      column.formattedValueForDisplayInEditing(cell.value);

  void _initialize() {
    _cellFocus = FocusNode(onKeyEvent: _handleOnKey);

    _textController = TextEditingController();
    stateManager.setTextEditingController(_textController);

    _textController.text = formattedValue;
    _initialCellValue = _textController.text;
    _cellEditingStatus = _CellEditingStatus.init;
  }

  // Hücreyi odaklamak için
  void requestFocus() {
    if (stateManager.keepFocus) {
      _cellFocus.requestFocus();
    }
  }

  // Hücre değerini değiştirmek için
  void changeValue(dynamic newValue, {bool notify = true}) {
    stateManager.changeCellValue(
      cell,
      newValue,
      notify: notify,
    );

    if (onValueChanged != null) {
      onValueChanged!(newValue);
    }

    _cellEditingStatus = _CellEditingStatus.updated;
  }

  // Değeri metin olarak değiştirmek için
  void changeTextValue(String text, {bool notify = true}) {
    _textController.text = text;
    changeValue(text, notify: notify);
  }

  // Metin değişikliğini işlemek için
  void handleOnChanged(String value) {
    changeValue(value);
  }

  // Düzenleme tamamlandığında
  void handleOnComplete() {
    final old = _textController.text;
    changeValue(old);

    PlatformHelper.onMobile(() {
      stateManager.setKeepFocus(false);
    });
  }

  // Metin alanına tıklandığında
  void handleOnTap() {
    stateManager.setKeepFocus(true);
  }

  // Orijinal değere dönmek için
  void restoreValue() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text = _initialCellValue.toString();

    stateManager.changeCellValue(
      stateManager.currentCell!,
      _initialCellValue,
      notify: false,
    );
  }

  // Klavye olaylarını işlemek için
  KeyEventResult _handleOnKey(FocusNode node, KeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    // Özel tuş kontrolleri varsa
    if (onKeyPressed != null && onKeyPressed!(keyManager)) {
      return KeyEventResult.handled;
    }

    bool moveHorizontal = _canMoveHorizontal(keyManager);

    final skip = !(keyManager.isVertical ||
        moveHorizontal ||
        keyManager.isEsc ||
        keyManager.isTab ||
        keyManager.isF3 ||
        keyManager.isEnter);

    if (skip) {
      return stateManager.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    if (_debounce.isDebounced(
      hashCode: _textController.text.hashCode,
      ignore: !kIsWeb,
    )) {
      return KeyEventResult.handled;
    }

    if (keyManager.isEnter) {
      handleOnComplete();
      return KeyEventResult.ignored;
    }

    if (keyManager.isEsc) {
      restoreValue();
    }

    stateManager.keyManager!.subject.add(keyManager);
    return KeyEventResult.handled;
  }

  bool _canMoveHorizontal(PlutoKeyManagerEvent keyManager) {
    if (!keyManager.isHorizontal) {
      return false;
    }

    if (column.readOnly == true) {
      return true;
    }

    final selection = _textController.selection;

    if (selection.baseOffset != selection.extentOffset) {
      return false;
    }

    if (selection.baseOffset == 0 && keyManager.isLeft) {
      return true;
    }

    final textLength = _textController.text.length;

    if (selection.baseOffset == textLength && keyManager.isRight) {
      return true;
    }

    return false;
  }

  // Kaynakları temizlemek için
  void dispose() {
    if (_cellEditingStatus.isChanged) {
      changeValue(_textController.text);
    }

    if (!stateManager.isEditing ||
        stateManager.currentColumn?.enableEditingMode != true) {
      stateManager.setTextEditingController(null);
    }

    _debounce.dispose();
    _textController.dispose();
    _cellFocus.dispose();
  }
}

/// Özel bir widget için renderer oluşturmak için yardımcı fonksiyon.
/// widgetBuilder: Özel widget'ı oluşturmak için kullanılacak fonksiyon.
PlutoColumnRenderer createCustomRenderer({
  required Widget Function(
    BuildContext context,
    PlutoCustomRendererHelper helper,
  ) widgetBuilder,
  Function(dynamic value)? onValueChanged,
  bool Function(PlutoKeyManagerEvent)? onKeyPressed,
}) {
  return (PlutoColumnRendererContext rendererContext) {
    return _CustomRendererWidget(
      stateManager: rendererContext.stateManager,
      cell: rendererContext.cell,
      column: rendererContext.column,
      row: rendererContext.row,
      widgetBuilder: widgetBuilder,
      onValueChanged: onValueChanged,
      onKeyPressed: onKeyPressed,
    );
  };
}

class _CustomRendererWidget extends StatefulWidget {
  final PlutoGridStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;
  final PlutoRow row;
  final Widget Function(
    BuildContext context,
    PlutoCustomRendererHelper helper,
  ) widgetBuilder;
  final Function(dynamic value)? onValueChanged;
  final bool Function(PlutoKeyManagerEvent)? onKeyPressed;

  const _CustomRendererWidget({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    required this.widgetBuilder,
    this.onValueChanged,
    this.onKeyPressed,
  });

  @override
  _CustomRendererWidgetState createState() => _CustomRendererWidgetState();
}

class _CustomRendererWidgetState extends State<_CustomRendererWidget> {
  late PlutoCustomRendererHelper _helper;

  @override
  void initState() {
    super.initState();
    _helper = PlutoCustomRendererHelper(
      stateManager: widget.stateManager,
      cell: widget.cell,
      column: widget.column,
      row: widget.row,
      onValueChanged: widget.onValueChanged,
      onKeyPressed: widget.onKeyPressed,
    );
  }

  @override
  void dispose() {
    _helper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _helper.requestFocus();
    return widget.widgetBuilder(context, _helper);
  }
}

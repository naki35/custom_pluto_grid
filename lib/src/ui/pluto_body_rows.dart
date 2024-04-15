import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/platform_helper.dart';
import 'ui.dart';

class PlutoBodyRows extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoBodyRows(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoBodyRowsState createState() => PlutoBodyRowsState();
}

class PlutoBodyRowsState extends PlutoStateWithChange<PlutoBodyRows> {
  List<PlutoColumn> _columns = [];

  List<PlutoRow> _rows = [];

  late final ScrollController _verticalScroll;

  late final ScrollController _horizontalScroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _horizontalScroll = stateManager.scroll.horizontal!.addAndGet();

    stateManager.scroll.setBodyRowsHorizontal(_horizontalScroll);

    _verticalScroll = stateManager.scroll.vertical!.addAndGet();

    stateManager.scroll.setBodyRowsVertical(_verticalScroll);

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();

    _horizontalScroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    forceUpdate();

    _columns = _getColumns();

    _rows = stateManager.refRows;
  }

  List<PlutoColumn> _getColumns() {
    return stateManager.showFrozenColumn == true
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  @override
  Widget build(BuildContext context) {
    final scrollbarConfig = stateManager.configuration.scrollbar;
    var groupedMap = groupBy(
      stateManager.rows,
      (PlutoRow custom) => custom.cells[stateManager.rowGroupBy]?.value,
    );

    return PlutoScrollbar(
      verticalController:
          scrollbarConfig.draggableScrollbar ? _verticalScroll : null,
      horizontalController:
          scrollbarConfig.draggableScrollbar ? _horizontalScroll : null,
      isAlwaysShown: scrollbarConfig.isAlwaysShown,
      onlyDraggingThumb: scrollbarConfig.onlyDraggingThumb,
      enableHover: PlatformHelper.isDesktop,
      thickness: scrollbarConfig.scrollbarThickness,
      thicknessWhileDragging: scrollbarConfig.scrollbarThicknessWhileDragging,
      hoverWidth: scrollbarConfig.hoverWidth,
      mainAxisMargin: scrollbarConfig.mainAxisMargin,
      crossAxisMargin: scrollbarConfig.crossAxisMargin,
      scrollBarColor: scrollbarConfig.scrollBarColor,
      scrollBarTrackColor: scrollbarConfig.scrollBarTrackColor,
      radius: scrollbarConfig.scrollbarRadius,
      radiusWhileDragging: scrollbarConfig.scrollbarRadiusWhileDragging,
      child: SingleChildScrollView(
        controller: _horizontalScroll,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: CustomSingleChildLayout(
          delegate: ListResizeDelegate(stateManager, _columns),
          child: groupedMap.length == 1
              ? ListView.builder(
                  controller: _verticalScroll,
                  scrollDirection: Axis.vertical,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _rows.length,
                  itemExtent: stateManager.rowTotalHeight,
                  addRepaintBoundaries: false,
                  itemBuilder: (ctx, i) {
                    return PlutoBaseRow(
                      key: ValueKey('body_row_${_rows[i].key}'),
                      rowIdx: i,
                      row: _rows[i],
                      columns: _columns,
                      stateManager: stateManager,
                      visibilityLayout: true,
                    );
                  },
                )
              : SingleChildScrollView(
                  controller: _verticalScroll,
                  child: Column(
                    children: groupedMap.entries.map((e) {
                      return ExpansionTile(
                        title: Text(
                          e.key.toString(),
                          style:
                              stateManager.configuration.style.columnTextStyle,
                        ),
                        initiallyExpanded: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        collapsedIconColor:
                            stateManager.configuration.style.disabledIconColor,
                        iconColor: stateManager.configuration.style.iconColor,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const ClampingScrollPhysics(),
                            itemCount: e.value.length,
                            itemExtent: stateManager.rowTotalHeight,
                            addRepaintBoundaries: false,
                            itemBuilder: (ctx, i) {
                              return PlutoBaseRow(
                                key: ValueKey('body_row_${e.value[i].key}'),
                                rowIdx: i,
                                row: e.value[i],
                                columns: _columns,
                                stateManager: stateManager,
                                visibilityLayout: true,
                              );
                            },
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ),
    );
  }
}

class ListResizeDelegate extends SingleChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumn> columns;

  ListResizeDelegate(this.stateManager, this.columns)
      : super(relayout: stateManager.resizingChangeNotifier);

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  double _getWidth() {
    return columns.fold(
      0,
      (previousValue, element) => previousValue + element.width,
    );
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth()).biggest;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return const Offset(0, 0);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth());
  }
}

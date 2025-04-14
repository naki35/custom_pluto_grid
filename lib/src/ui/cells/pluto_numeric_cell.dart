import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'text_cell.dart';

class PlutoNumericCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoNumericCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoNumericCellState createState() => PlutoNumericCellState();
}

class PlutoNumericCellState extends State<PlutoNumericCell>
    with TextCellState<PlutoNumericCell> {
  @override
  late final TextInputType keyboardType;

  @override
  late final List<TextInputFormatter>? inputFormatters;

  @override
  void initState() {
    super.initState();

    inputFormatters = [
      FilteringTextInputFormatter.digitsOnly,
    ];

    keyboardType = TextInputType.number;
  }
}

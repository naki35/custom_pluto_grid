import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'text_cell.dart';

class PlutoPhoneCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoPhoneCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoPhoneCellState createState() => PlutoPhoneCellState();
}

class PlutoPhoneCellState extends State<PlutoPhoneCell>
    with TextCellState<PlutoPhoneCell> {
  @override
  late final TextInputType keyboardType;

  @override
  late final List<TextInputFormatter>? inputFormatters;

  @override
  void initState() {
    super.initState();

    inputFormatters = [
      PhoneNumberInputFormatter(),
    ];

    keyboardType = TextInputType.phone;
  }
}

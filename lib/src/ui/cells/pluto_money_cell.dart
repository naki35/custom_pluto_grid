import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart'
    as currency_formatter;

import 'text_cell.dart';

class PlutoMoneyCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoMoneyCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoMoneyCellState createState() => PlutoMoneyCellState();
}

class PlutoMoneyCellState extends State<PlutoMoneyCell>
    with TextCellState<PlutoMoneyCell> {
  @override
  late final TextInputType keyboardType;

  @override
  late final List<TextInputFormatter>? inputFormatters;

  @override
  void initState() {
    super.initState();

    inputFormatters = [
      currency_formatter.CurrencyTextInputFormatter.currency(
        locale: 'tr',
        symbol: '',
      ),
    ];

    keyboardType = TextInputType.number;
  }
}

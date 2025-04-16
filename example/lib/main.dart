import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/cells/pluto_custom_renderer_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlutoGrid Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlutoGridExamplePage(),
    );
  }
}

/// PlutoGrid Example
//
/// For more examples, go to the demo web link on the github below.
class PlutoGridExamplePage extends StatefulWidget {
  const PlutoGridExamplePage({Key? key}) : super(key: key);

  @override
  State<PlutoGridExamplePage> createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'Id',
      field: 'id',
      type: PlutoColumnType.text(),
    ),
    // TextFormField için özel renderer kullanımı
    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.text(),
      renderer: createCustomRenderer(
        widgetBuilder: (context, helper) {
          return TextFormField(
            focusNode: helper.cellFocus,
            controller: helper.textController,
            onChanged: helper.handleOnChanged,
            onEditingComplete: helper.handleOnComplete,
            onTap: helper.handleOnTap,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            style: helper.stateManager.configuration.style.cellTextStyle,
          );
        },
      ),
    ),
    // Dropdown için özel renderer kullanımı
    PlutoColumn(
      title: 'Role',
      field: 'role',
      type: PlutoColumnType.text(),
      renderer: createCustomRenderer(
        widgetBuilder: (context, helper) {
          final roles = ['Admin', 'User', 'Guest', 'Manager'];
          String currentValue = helper.cell.value.toString();

          // Boş değer ya da geçersiz değer kontrolü
          if (currentValue.isEmpty || !roles.contains(currentValue)) {
            currentValue = roles.first;
            // Varsayılan değeri ayarla
            Future.microtask(() => helper.changeValue(currentValue));
          }

          return DropdownButton<String>(
            value: currentValue,
            isExpanded: true,
            focusNode: helper.cellFocus,
            underline: Container(height: 0),
            onTap: helper.handleOnTap,
            onChanged: (newValue) {
              if (newValue != null) {
                helper.changeValue(newValue);
              }
            },
            items: roles.map((role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(
                  role,
                  style: helper.stateManager.configuration.style.cellTextStyle,
                ),
              );
            }).toList(),
          );
        },
      ),
    ),
    PlutoColumn(
      title: 'Age',
      field: 'age',
      type: PlutoColumnType.numeric(),
    ),
    PlutoColumn(
      title: 'Joined',
      field: 'joined',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: 'Working time',
      field: 'working_time',
      type: PlutoColumnType.time(),
    ),
    PlutoColumn(
      title: 'Salary',
      field: 'salary',
      type: PlutoColumnType.currency(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          formatAsCurrency: true,
          type: PlutoAggregateColumnType.sum,
          format: '#,###',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'Sum',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ' : '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
  ];

  final List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user1'),
        'name': PlutoCell(value: 'John'),
        'role': PlutoCell(value: 'Admin'),
        'age': PlutoCell(value: 20),
        'joined': PlutoCell(value: '2021-01-01'),
        'working_time': PlutoCell(value: '09:00'),
        'salary': PlutoCell(value: 3000),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user2'),
        'name': PlutoCell(value: 'Lisa'),
        'role': PlutoCell(value: 'User'),
        'age': PlutoCell(value: 25),
        'joined': PlutoCell(value: '2021-02-01'),
        'working_time': PlutoCell(value: '10:00'),
        'salary': PlutoCell(value: 4000),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user3'),
        'name': PlutoCell(value: 'Michael'),
        'role': PlutoCell(value: 'Manager'),
        'age': PlutoCell(value: 30),
        'joined': PlutoCell(value: '2021-03-01'),
        'working_time': PlutoCell(value: '08:00'),
        'salary': PlutoCell(value: 5000),
      },
    ),
  ];

  // Column groups if needed
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
    PlutoColumnGroup(title: 'User information', fields: ['name', 'role']),
    PlutoColumnGroup(title: 'Status', children: [
      PlutoColumnGroup(
          title: 'Details', fields: ['age', 'joined', 'working_time']),
    ]),
  ];

  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    stateManager.clearCurrentCell();
                  },
                  child: Text('Clear Focus'),
                ),
                TextButton(
                  onPressed: () {
                    // Yeni bir satır ekleme
                    stateManager.appendRows([
                      PlutoRow(
                        cells: {
                          'id': PlutoCell(value: 'user${rows.length + 1}'),
                          'name': PlutoCell(value: ''),
                          'role': PlutoCell(value: ''),
                          'age': PlutoCell(value: 0),
                          'joined': PlutoCell(value: ''),
                          'working_time': PlutoCell(value: ''),
                          'salary': PlutoCell(value: 0),
                        },
                      ),
                    ]);
                  },
                  child: Text('Add Row'),
                ),
              ],
            ),
            Expanded(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                // columnGroups: columnGroups,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager.setShowColumnFilter(true);
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  print(event);
                },
                onColumnResized: (PlutoGridOnColumnResizedEvent event) {
                  print(event.width);
                },
                mode: PlutoGridMode.normal,
                configuration: PlutoGridConfiguration(
                  columnSize: const PlutoGridColumnSizeConfig(
                    autoSizeMode: PlutoAutoSizeMode.equal,
                    restoreAutoSizeAfterMoveColumn: false,
                  ),
                  localeText:
                      const PlutoGridLocaleText.turkish(filterContains: ''),
                  scrollbar: const PlutoGridScrollbarConfig(
                    isAlwaysShown: true,
                    scrollbarThickness: 10,
                  ),
                  columnFilter: PlutoGridColumnFilterConfig(
                    debounceMilliseconds: 300,
                  ),
                  enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveDown,
                  style: PlutoGridStyleConfig(
                    oddRowColor: Colors.white,
                    evenRowColor: const Color(0xfff8fafc),
                    activatedColor: const Color(0xffb2e7da),
                    gridBorderColor: Colors.transparent,
                    gridBackgroundColor: const Color(0xffefefef),
                    cellColorInEditState: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

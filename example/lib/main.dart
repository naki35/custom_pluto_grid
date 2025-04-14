import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
      type: PlutoColumnType.money(),
    ),
    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.phone(),
    ),
    PlutoColumn(
      title: 'Age',
      field: 'age',
      type: PlutoColumnType.numeric(),
    ),
    PlutoColumn(
      title: 'Role',
      field: 'role',
      type: PlutoColumnType.decimal(),
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
      title: 'salary',
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
        'id': PlutoCell(value: ''),
        'name': PlutoCell(value: ''),
        'age': PlutoCell(value: 20),
        'role': PlutoCell(value: ''),
        'joined': PlutoCell(value: '2021-01-01'),
        'working_time': PlutoCell(value: '09:00'),
        'salary': PlutoCell(value: 300),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: ''),
        'name': PlutoCell(value: ''),
        'age': PlutoCell(value: 25),
        'role': PlutoCell(value: ''),
        'joined': PlutoCell(value: '2021-02-01'),
        'working_time': PlutoCell(value: '10:00'),
        'salary': PlutoCell(value: 400),
      },
    ),
    // PlutoRow(
    //   cells: {
    //     'id': PlutoCell(value: 'user3'),
    //     'name': PlutoCell(value: 'şimşekçiğelörın'),
    //     'age': PlutoCell(value: 40),
    //     'role': PlutoCell(value: 'Owner'),
    //     'joined': PlutoCell(value: '2021-03-01'),
    //     'working_time': PlutoCell(value: '11:00'),
    //     'salary': PlutoCell(value: 700),
    //   },
    // ),
    // PlutoRow(
    //   cells: {
    //     'id': PlutoCell(value: 'user4'),
    //     'name': PlutoCell(value: 'ŞİMŞEKÇİĞELÖRIN'),
    //     'age': PlutoCell(value: 40),
    //     'role': PlutoCell(value: 'Owner'),
    //     'joined': PlutoCell(value: '2021-03-01'),
    //     'working_time': PlutoCell(value: '11:00'),
    //     'salary': PlutoCell(value: 700),
    //   },
    // ),
  ];

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
    PlutoColumnGroup(title: 'User information', fields: ['name', 'age']),
    PlutoColumnGroup(title: 'Status', children: [
      PlutoColumnGroup(title: 'A', fields: ['role'], expandedColumn: true),
      PlutoColumnGroup(title: 'Etc.', fields: ['joined', 'working_time']),
    ]),
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                stateManager.clearCurrentCell();
              },
              child: Text('Focus'),
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
                onSearch: (value, setPage) {
                  //wait 1 second
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
                  enterKeyAction: PlutoGridEnterKeyAction.none,
                  style: PlutoGridStyleConfig(
                    oddRowColor: Colors.white,
                    evenRowColor: const Color(0xfff8fafc),
                    activatedColor: const Color(0xffb2e7da),
                    gridBorderColor: Colors.transparent,
                    gridBackgroundColor: const Color(0xffefefef),
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

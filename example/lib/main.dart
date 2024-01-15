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
      type: PlutoColumnType.text(),
      formatter: (value) {
        if (value == "1") {
          return "Gelen Evrak";
        } else if (value == "2") {
          return "Giden Evrak";
        } else if (value == "3" || value == "5" || value == "6") {
          return "Kurum İçi Evrak";
        } else if (value == "4") {
          return "Arşiv Evrakı";
        } else {
          return value;
        }
      },
      formatterFields: {
        'Seçiniz': "0",
        'Gelen Evrak': "1",
        'Giden Evrak': "2",
        'Kurum İçi Evrak': "3",
        'Arşiv Evrakı': "4",
      },
    ),
    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Age',
      field: 'age',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'Role',
      field: 'role',
      type: PlutoColumnType.select(<String>[
        'Programmer',
        'Designer',
        'Owner',
      ]),
    ),
    PlutoColumn(
      title: 'Joined',
      field: 'joined',
      type: PlutoColumnType.date(format: 'dd.MM.yyyy'),
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
        'id': PlutoCell(value: '1'),
        'name': PlutoCell(value: 'Mike'),
        'age': PlutoCell(value: 20),
        'role': PlutoCell(value: 'Programmer'),
        'joined': PlutoCell(value: '2023-12-01'),
        'working_time': PlutoCell(value: '09:00'),
        'salary': PlutoCell(value: 300),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: '2'),
        'name': PlutoCell(value: 'Jack'),
        'age': PlutoCell(value: 25),
        'role': PlutoCell(value: 'Designer'),
        'joined': PlutoCell(value: '2023-12-02'),
        'working_time': PlutoCell(value: '10:00'),
        'salary': PlutoCell(value: 400),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: '2'),
        'name': PlutoCell(value: 'Suzi'),
        'age': PlutoCell(value: 40),
        'role': PlutoCell(value: 'Owner'),
        'joined': PlutoCell(value: '2023-12-02'),
        'working_time': PlutoCell(value: '11:00'),
        'salary': PlutoCell(value: 700),
      },
    ),
  ];

  final List<PlutoRow> rows2 = [
    PlutoRow(
      cells: {
        'id': PlutoCell(value: '1'),
        'name': PlutoCell(value: 'DENEME'),
        'age': PlutoCell(value: 20),
        'role': PlutoCell(value: '3g3f32f233f22f'),
        'joined': PlutoCell(value: '2023-12-01'),
        'working_time': PlutoCell(value: '09:00'),
        'salary': PlutoCell(value: 300),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: '2'),
        'name': PlutoCell(value: 'TEST3'),
        'age': PlutoCell(value: 25),
        'role': PlutoCell(value: 'dfvfdvdfvfd'),
        'joined': PlutoCell(value: '2023-12-02'),
        'working_time': PlutoCell(value: '10:00'),
        'salary': PlutoCell(value: 400),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: '2'),
        'name': PlutoCell(value: 'TESTTT'),
        'age': PlutoCell(value: 40),
        'role': PlutoCell(value: 'DGSDGDSGGDSGDS'),
        'joined': PlutoCell(value: '2023-12-02'),
        'working_time': PlutoCell(value: '11:00'),
        'salary': PlutoCell(value: 700),
      },
    ),
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
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager.setAutoEditing(true);
            stateManager.setShowColumnFilter(true);
          },
          onColumnsMoved: (event) {
            print(event.oldIdx);
            print(event.idx);
          },
          onColumnHide: (event) {
            print(event.isHidden);
            print(event.column);
          },
          createFooter: (PlutoGridStateManager stateManager) {
            return ElevatedButton(
              onPressed: () {
                print(stateManager.refRows[0].cells['name']!.value);
              },
              child: const Text("Click me"),
            );
          },
          onSearch: (List<PlutoRow> value, bool? setPage) {
            List<PlutoRow> filteredList = filterData(rows2, value);
          },
          configuration: const PlutoGridConfiguration(
            localeText: PlutoGridLocaleText.turkish(),
          ),
        ),
      ),
    );
  }

  List<PlutoRow> filterData(
    List<PlutoRow> dataList,
    List<PlutoRow> filterList,
  ) {
    List<PlutoRow> filteredList = [];

    //Set<String> usedColumns = {};
    //print(filterList);
    for (var dataRow in dataList) {
      bool isMatch = true;

      for (var filterRow in filterList.reversed.toList()) {
        String columnName = filterRow.cells['column']?.value ?? '';

        // if (usedColumns.contains(columnName)) {
        //   continue;
        // }

        dynamic filterValue = filterRow.cells['value']?.value;
        print(filterValue);
        if (filterRow.cells['type']?.value == const PlutoFilterTypeContains() &&
            !dataRow.cells[columnName]!.value
                .toString()
                .toLowerCase()
                .contains(filterValue.toString().toLowerCase())) {
          isMatch = false;
          break;
        }

        if (filterRow.cells['type']?.value != const PlutoFilterTypeContains() &&
            dataRow.cells[columnName]?.value.toLowerCase() !=
                filterValue.toLowerCase()) {
          isMatch = false;
          break;
        }

        //usedColumns.add(columnName);
      }

      //usedColumns.clear();

      if (isMatch) {
        filteredList.add(dataRow);
      }
    }

    return filteredList;
  }
}

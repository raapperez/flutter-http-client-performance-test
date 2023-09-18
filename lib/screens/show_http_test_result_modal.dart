import 'package:flutter/material.dart';

import '../models/http_test_group.dart';

class ShowHttpTestResultModal extends StatelessWidget {
  final List<HttpTestGroup> testGroups;

  const ShowHttpTestResultModal({super.key, required this.testGroups});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.separated(
          itemCount: testGroups.length,
          itemBuilder: (context, idx) => _HttpTestGroupView(testGroup: testGroups[idx]),
          separatorBuilder: (_, idx) => const SizedBox(height: 8),
        ),
      ),
    );
  }
}

class _HttpTestGroupView extends StatefulWidget {
  final HttpTestGroup testGroup;

  const _HttpTestGroupView({required this.testGroup});

  @override
  State<_HttpTestGroupView> createState() => __HttpTestGroupViewState();
}

class __HttpTestGroupViewState extends State<_HttpTestGroupView> {
  late final _HttpTestGroupDTS _source;
  late final int _rowsPerPage;

  late final List<DataColumn> _clientDataColumns;

  @override
  void initState() {
    _source = _HttpTestGroupDTS(widget.testGroup);
    if (_source.rowCount < 10) {
      _rowsPerPage = _source.rowCount;
    } else {
      _rowsPerPage = 10;
    }
    _clientDataColumns = widget.testGroup.results.map((result) {
      return DataColumn(label: Text(result.clientName));
    }).toList();
    super.initState();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.testGroup.testName, textAlign: TextAlign.center),
          PaginatedDataTable(
            columns: [
              const DataColumn(label: Text('Iteration')),
              ..._clientDataColumns,
            ],
            rowsPerPage: _rowsPerPage,
            dataRowMinHeight: 30,
            dataRowMaxHeight: 30,
            source: _source,
          ),
        ],
      ),
    );
  }
}

class _HttpTestGroupDTS extends DataTableSource {
  final HttpTestGroup testGroup;

  _HttpTestGroupDTS(this.testGroup);

  @override
  DataRow getRow(int index) {
    final clientIterationsResults =
        testGroup.results.map((result) => DataCell(Text(result.iterations[index].toString()))).toList();
    return DataRow.byIndex(
      index: index,
      cells: [DataCell(Text('${index + 1}')), ...clientIterationsResults],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => testGroup.results.first.iterations.length;

  @override
  int get selectedRowCount => 0;
}

import 'dart:html' as html;
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:face_attendance_dashboard/app_router.dart';
import 'package:face_attendance_dashboard/constants/dimens.dart';
import 'package:face_attendance_dashboard/generated/l10n.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_button_theme.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_data_table_theme.dart';
import 'package:face_attendance_dashboard/views/widgets/card_elements.dart';
import 'package:face_attendance_dashboard/views/widgets/portal_master_layout/portal_master_layout.dart';

import '../../utils/app_focus_helper.dart';

class CrudScreen extends StatefulWidget {
  const CrudScreen({super.key});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();
  final _searchController = TextEditingController();

  final _dataTableHorizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> fetchItems({String searchQuery = ''}) async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Student').get();
    final items = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id; // Store document ID in the data map
      return data;
    }).toList();

    if (searchQuery.isNotEmpty) {
      return items.where((item) {
        return item.values.any((value) {
          return value.toString().toLowerCase().contains(searchQuery.toLowerCase());
        });
      }).toList();
    }

    return items;
  }

  void onDetailButtonPressed(Map<String, dynamic> data) {
    final documentId = data['docId']; // Retrieve the stored document ID
    GoRouter.of(context).go('${RouteUri.crudDetail}?id=$documentId');
  }

  void _doDelete(Map<String, dynamic> data) async {
    AppFocusHelper.instance.requestUnfocus();

    final lang = Lang.of(context);
    final documentId = data['docId']; // Use the stored 'docId' for deletion

    if (documentId == null) {
      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'Document ID not found',
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {},
      );
      dialog.show();
      return;
    }

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: lang.confirmDeleteRecord,
      width: kDialogWidth,
      btnOkText: lang.yes,
      btnOkOnPress: () async {
        try {
          await FirebaseFirestore.instance.collection('Student').doc(documentId).delete();
          final d = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: lang.recordDeletedSuccessfully,
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () => setState(() {}), // Refresh the list after deletion
          );
          d.show();
        } catch (e) {
          final d = AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: 'Error',
            desc: e.toString(),
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () {},
          );
          d.show();
        }
      },
      btnCancelText: lang.cancel,
      btnCancelOnPress: () {},
    );

    dialog.show();
  }

  Future<void> _exportToCSV() async {
    List<Map<String, dynamic>> items = await fetchItems();
    List<List<dynamic>> rows = [];

    // Add header row
    rows.add([
      'ID',
      'Khmer Name',
      'English Name',
      'Birth of Date',
      'Address',
      'Department',
    ]);

    // Add data rows
    for (var item in items) {
      rows.add([
        item['id'],
        item['khmerName'],
        '${item['firstName']} ${item['lastName']}', // Combine first name and last name
        item['birthDate'],
        item['address'],
        item['department'],
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Add BOM to the CSV string
    const bom = '\u{FEFF}';
    csv = bom + csv;

    // Create a Blob from the CSV string and trigger a download
    final blob = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'students.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _importFromCSV() async {
    final input = html.FileUploadInputElement()..accept = '.csv';
    input.click();
    input.onChange.listen((event) async {
      final file = input.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsText(file);
        reader.onLoadEnd.listen((event) async {
          final csvString = reader.result as String;
          List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

          if (rows.isNotEmpty) {
            final header = rows.first;
            final dataRows = rows.skip(1);

            for (var row in dataRows) {
              final data = {
                'id': row[0],
                'khmerName': row[1],
                'firstName': row[2].split(' ')[0], // Assuming first name is the first word
                'lastName': row[2].split(' ')[1], // Assuming last name is the second word
                'birthDate': row[3],
                'address': row[4],
                'department': row[5],
              };

              try {
                await FirebaseFirestore.instance.collection('Student').add(data);
              } catch (e) {
                final d = AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  title: 'Error',
                  desc: e.toString(),
                  width: kDialogWidth,
                  btnOkText: 'OK',
                  btnOkOnPress: () {},
                );
                d.show();
                return;
              }
            }

            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: 'Import Successful',
              desc: 'Data imported successfully.',
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () => setState(() {}),
            );
            dialog.show();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dataTableHorizontalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appDataTableTheme = themeData.extension<AppDataTableTheme>()!;

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            'Students',
            style: themeData.textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardHeader(
                    title: 'Students',
                  ),
                  CardBody(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                          child: FormBuilder(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                direction: Axis.horizontal,
                                spacing: kDefaultPadding,
                                runSpacing: kDefaultPadding,
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: SizedBox(
                                      width: 300.0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                        child: FormBuilderTextField(
                                          name: 'search',
                                          controller: _searchController,
                                          decoration: InputDecoration(
                                            labelText: lang.search,
                                            hintText: lang.search,
                                            border: const OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: kDefaultPadding),
                                    child: SizedBox(
                                      height: 40.0,
                                      child: ElevatedButton(
                                        style: themeData.extension<AppButtonTheme>()!.infoElevated,
                                        onPressed: () => setState(() {}),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                              child: Icon(
                                                Icons.search,
                                                size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                              ),
                                            ),
                                            Text(lang.search),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding),
                                        child: SizedBox(
                                          height: 40.0,
                                          child: ElevatedButton(
                                            style: themeData.extension<AppButtonTheme>()!.infoElevated,
                                            onPressed: _exportToCSV,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.file_download,
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                const Text('Export'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding),
                                        child: SizedBox(
                                          height: 40.0,
                                          child: ElevatedButton(
                                            style: themeData.extension<AppButtonTheme>()!.infoElevated,
                                            onPressed: _importFromCSV,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.file_upload,
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                const Text('Import'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40.0,
                                        child: ElevatedButton(
                                          style: themeData.extension<AppButtonTheme>()!.successElevated,
                                          onPressed: () => GoRouter.of(context).go(RouteUri.crudDetail),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                child: Icon(
                                                  Icons.add,
                                                  size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                ),
                                              ),
                                              Text(lang.crudNew),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double dataTableWidth = max(kScreenWidthMd, constraints.maxWidth);

                              return Scrollbar(
                                controller: _dataTableHorizontalScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _dataTableHorizontalScrollController,
                                  child: SizedBox(
                                    width: dataTableWidth,
                                    child: FutureBuilder<List<Map<String, dynamic>>>(
                                      future: fetchItems(searchQuery: _searchController.text),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(child: Text('Error: ${snapshot.error}'));
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Center(child: Text('No data available'));
                                        } else {
                                          final items = snapshot.data!;
                                          return Theme(
                                            data: themeData.copyWith(
                                              cardTheme: appDataTableTheme.cardTheme,
                                              dataTableTheme: appDataTableTheme.dataTableThemeData,
                                            ),
                                            child: DataTable(
                                              showCheckboxColumn: false,
                                              showBottomBorder: true,
                                              columns: const [
                                                DataColumn(label: Text('No.'), numeric: true),
                                                DataColumn(label: Text('ID'), numeric: true),
                                                DataColumn(label: Text('KhmerName')),
                                                DataColumn(label: Text('EnglishName')),
                                                DataColumn(label: Text('BirthDate')),
                                                DataColumn(label: Text('Address')),
                                                DataColumn(label: Text('Department')),
                                                DataColumn(label: Text('Action')),
                                              ],
                                              rows: List.generate(items.length, (index) {
                                                final item = items[index];
                                                final englishName = '${item['firstName'] ?? 'N/A'} ${item['lastName'] ?? 'N/A'}';
                                                return DataRow.byIndex(
                                                  index: index,
                                                  cells: [
                                                    DataCell(Text('#${index + 1}')),
                                                    DataCell(Text('${item['id'] ?? 'N/A'}')),
                                                    DataCell(Text(item['khmerName'] ?? 'N/A')),
                                                    DataCell(Text(englishName)),
                                                    DataCell(Text(item['birthDate'] ?? 'N/A')),
                                                    DataCell(Text(item['address'] ?? 'N/A')),
                                                    DataCell(Text(item['department'] ?? 'N/A')),
                                                    DataCell(Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: kDefaultPadding),
                                                          child: OutlinedButton(
                                                            onPressed: () => onDetailButtonPressed(item),
                                                            style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                                                            child: Text(Lang.of(context).crudDetail),
                                                          ),
                                                        ),
                                                        OutlinedButton(
                                                          onPressed: () => _doDelete(item),
                                                          style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
                                                          child: Text(Lang.of(context).crudDelete),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                );
                                              }),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

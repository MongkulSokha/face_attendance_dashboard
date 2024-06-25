import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_data_table_theme.dart';
import 'package:face_attendance_dashboard/constants/dimens.dart';
import 'package:face_attendance_dashboard/views/widgets/card_elements.dart';
import 'package:face_attendance_dashboard/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:flutter_picker/flutter_picker.dart';  // Import the flutter_picker package
import '../../app_router.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _dataTableHorizontalScrollController = ScrollController();
  final _dataTableVerticalScrollController = ScrollController();
  DateTime selectedMonth = DateTime.now();
  bool showDayList = true;  // State variable to track the current view

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceRecords() async {
    final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    final querySnapshot = await FirebaseFirestore.instance.collection('Student').get();

    List<Map<String, dynamic>> records = [];

    for (var doc in querySnapshot.docs) {
      final studentId = doc.id;
      final studentData = doc.data();
      final firstName = studentData['firstName'] ?? 'N/A';
      final lastName = studentData['lastName'] ?? 'N/A';
      final fullName = '$firstName $lastName';

      final attendanceSnapshot = await FirebaseFirestore.instance
          .collection('Student')
          .doc(studentId)
          .collection('Record')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      for (var attendanceDoc in attendanceSnapshot.docs) {
        final data = attendanceDoc.data();
        data['studentId'] = studentId;
        data['fullName'] = fullName;
        records.add(data);
      }
    }

    return records;
  }

  void switchMonth(int increment) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + increment, 1);
    });
  }

  Future<void> exportToCSV(List<Map<String, dynamic>> records, bool isDayList) async {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final daysInMonth = List<int>.generate(DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day, (i) => i + 1);

    List<List<dynamic>> csvData;

    if (isDayList) {
      csvData = [
        ['No.', 'Student', ...daysInMonth.map((day) => day.toString())]
      ];

      final Map<String, Map<String, String>> studentAttendance = {};

      for (var item in records) {
        final date = dateFormat.format((item['date'] as Timestamp).toDate());
        final checkIn = item['checkIn'];
        final checkOut = item['checkOut'];
        final status = (checkIn != null && checkOut != null) ? '1' : 'A';
        final fullName = item['fullName'];

        if (!studentAttendance.containsKey(fullName)) {
          studentAttendance[fullName] = {};
        }

        studentAttendance[fullName]![date] = status;
      }

      final today = DateTime.now();

      int index = 1;
      studentAttendance.forEach((fullName, attendanceData) {
        List<dynamic> row = [index++, fullName];
        for (int day in daysInMonth) {
          final date = DateTime(selectedMonth.year, selectedMonth.month, day);
          if (date.isAfter(today)) {
            row.add('');
          } else {
            final dateString = dateFormat.format(date);
            row.add(attendanceData[dateString] ?? ' ');
          }
        }
        csvData.add(row);
      });
    } else {
      csvData = [
        ['No.', 'Student', 'Date', 'Check-In', 'Check-Out']
      ];

      int index = 1;
      for (var item in records) {
        final date = dateFormat.format((item['date'] as Timestamp).toDate());
        final checkIn = item['checkIn'] ?? 'N/A';
        final checkOut = item['checkOut'] ?? 'N/A';
        final fullName = item['fullName'];

        csvData.add([
          index++,
          fullName,
          date,
          checkIn,
          checkOut,
        ]);
      }
    }

    String csv = const ListToCsvConverter().convert(csvData);

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "attendance_${DateFormat('yyyy_MM').format(selectedMonth)}.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> selectMonth(BuildContext context) async {
    Picker(
      adapter: DateTimePickerAdapter(
        type: PickerDateTimeType.kYM,
        isNumberMonth: true,
        yearBegin: 2000,
        yearEnd: 2100,
        value: selectedMonth,
      ),
      title: const Text("Select Month and Year"),
      onConfirm: (Picker picker, List<int> value) {
        setState(() {
          selectedMonth = (picker.adapter as DateTimePickerAdapter).value!;
        });
      },
    ).showModal(context);
  }

  @override
  void dispose() {
    _dataTableHorizontalScrollController.dispose();
    _dataTableVerticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appDataTableTheme = themeData.extension<AppDataTableTheme>()!;
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final DateTime today = DateTime.now();

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () => switchMonth(-1),
              ),
              InkWell(
                onTap: () => selectMonth(context),
                child: Text(
                  DateFormat('MMMM yyyy').format(selectedMonth),
                  style: themeData.textTheme.headlineMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () => switchMonth(1),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showDayList = !showDayList;
                  });
                },
                child: Text(showDayList ? 'Show Detailed List' : 'Show Day List'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardHeader(
                    title: 'Attendance Records',
                  ),
                  CardBody(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const double dataTableWidth = 60;

                              final daysInMonth = List<int>.generate(DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day, (i) => i + 1);

                              return Scrollbar(
                                controller: _dataTableHorizontalScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _dataTableHorizontalScrollController,
                                  child: Scrollbar(
                                    controller: _dataTableVerticalScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      controller: _dataTableVerticalScrollController,
                                      child: SizedBox(
                                        width: showDayList ? dataTableWidth + (daysInMonth.length * 75) : 800, // Adjust width for each day column
                                        child: FutureBuilder<List<Map<String, dynamic>>>(
                                          future: fetchAttendanceRecords(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(child: Text('Error: ${snapshot.error}'));
                                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                              return const Center(child: Text('No data available'));
                                            } else {
                                              final items = snapshot.data!;
                                              final Map<String, Map<String, String>> studentAttendance = {};

                                              for (var item in items) {
                                                final date = dateFormat.format((item['date'] as Timestamp).toDate());
                                                final checkIn = item['checkIn'];
                                                final checkOut = item['checkOut'];
                                                final status = (checkIn != null && checkOut != null) ? '1' : 'A';
                                                final fullName = item['fullName'];

                                                if (!studentAttendance.containsKey(fullName)) {
                                                  studentAttendance[fullName] = {};
                                                }

                                                studentAttendance[fullName]![date] = status;
                                              }

                                              return Theme(
                                                data: themeData.copyWith(
                                                  cardTheme: appDataTableTheme.cardTheme,
                                                  dataTableTheme: appDataTableTheme.dataTableThemeData,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () => exportToCSV(items, showDayList),
                                                      child: const Text('Export to CSV'),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    DataTable(
                                                      showCheckboxColumn: false,
                                                      showBottomBorder: true,
                                                      columns: showDayList
                                                          ? [
                                                        const DataColumn(label: Text('No.'), numeric: true),
                                                        const DataColumn(label: Text('Student')),
                                                        ...daysInMonth.map((day) => DataColumn(label: Text('$day'))).toList(),
                                                      ]
                                                          : [
                                                        const DataColumn(label: Text('No.'), numeric: true),
                                                        const DataColumn(label: Text('Student')),
                                                        const DataColumn(label: Text('Date')),
                                                        const DataColumn(label: Text('Check-In')),
                                                        const DataColumn(label: Text('Check-Out')),
                                                      ],
                                                      rows: showDayList
                                                          ? List.generate(studentAttendance.keys.length, (index) {
                                                        final studentName = studentAttendance.keys.elementAt(index);
                                                        final attendanceData = studentAttendance[studentName]!;

                                                        return DataRow.byIndex(
                                                          index: index,
                                                          cells: [
                                                            DataCell(Text('#${index + 1}')),
                                                            DataCell(Text(studentName)),
                                                            ...daysInMonth.map((day) {
                                                              final date = DateTime(selectedMonth.year, selectedMonth.month, day);
                                                              if (date.isAfter(today)) {
                                                                return const DataCell(Text(''));
                                                              } else {
                                                                final dateString = dateFormat.format(date);
                                                                return DataCell(Text(attendanceData[dateString] ?? ''));
                                                              }
                                                            }).toList(),
                                                          ],
                                                        );
                                                      })
                                                          : List.generate(items.length, (index) {
                                                        final item = items[index];
                                                        final date = dateFormat.format((item['date'] as Timestamp).toDate());
                                                        final checkIn = item['checkIn'] ?? 'N/A';
                                                        final checkOut = item['checkOut'] ?? 'N/A';
                                                        final fullName = item['fullName'];

                                                        return DataRow.byIndex(
                                                          index: index,
                                                          cells: [
                                                            DataCell(Text('#${index + 1}')),
                                                            DataCell(Text(fullName)),
                                                            DataCell(Text(date)),
                                                            DataCell(Text(checkIn)),
                                                            DataCell(Text(checkOut)),
                                                          ],
                                                        );
                                                      }),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
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

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:face_attendance_dashboard/constants/dimens.dart';
import 'package:face_attendance_dashboard/generated/l10n.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_button_theme.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_color_scheme.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_data_table_theme.dart';
import 'package:face_attendance_dashboard/views/widgets/card_elements.dart';
import 'package:face_attendance_dashboard/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../app_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dataTableHorizontalScrollController = ScrollController();

  @override
  void dispose() {
    _dataTableHorizontalScrollController.dispose();

    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Student').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<int> fetchNewOrdersCount() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Student').get();
    return querySnapshot.size;
  }

  Future<int> fetchMayorsCount() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('faculty')
        .doc('Engineering')
        .collection('Department')
        .get();
    return querySnapshot.size;
  }

  Future<int> fetchSubjectsCount() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('faculty')
        .doc('Engineering')
        .collection('Department')
        .doc('Information Technology Engineering')
        .collection('subjects')
        .get();
    return querySnapshot.size;
  }

  Future<int> fetchNewUsersCount() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('faculty').get();
    return querySnapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appColorScheme = Theme.of(context).extension<AppColorScheme>()!;
    final appDataTableTheme = Theme.of(context).extension<AppDataTableTheme>()!;
    final size = MediaQuery.of(context).size;

    final summaryCardCrossAxisCount = (size.width >= kScreenWidthLg ? 4 : 2);

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.dashboard,
            style: themeData.textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final summaryCardWidth = ((constraints.maxWidth -
                        (kDefaultPadding * (summaryCardCrossAxisCount - 1))) /
                    summaryCardCrossAxisCount);

                return Wrap(
                  direction: Axis.horizontal,
                  spacing: kDefaultPadding,
                  runSpacing: kDefaultPadding,
                  children: [
                    FutureBuilder<int>(
                      future: fetchNewOrdersCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            width: summaryCardWidth,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return SummaryCard(
                            title: lang.newOrders(2),
                            value: 'Error',
                            icon: Icons.people,
                            backgroundColor: appColorScheme.info,
                            textColor: themeData.colorScheme.onPrimary,
                            iconColor: Colors.black12,
                            width: summaryCardWidth,
                          );
                        } else {
                          return SummaryCard(
                            title: lang.newOrders(2),
                            value: '${snapshot.data}',
                            icon: Icons.people,
                            backgroundColor: appColorScheme.info,
                            textColor: themeData.colorScheme.onPrimary,
                            iconColor: Colors.black12,
                            width: summaryCardWidth,
                          );
                        }
                      },
                    ),
                    FutureBuilder<int>(
                      future: fetchMayorsCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            width: summaryCardWidth,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return SummaryCard(
                            title: lang.mayors,
                            value: 'Error',
                            icon: Icons.school,
                            backgroundColor: appColorScheme.success,
                            textColor: themeData.colorScheme.onPrimary,
                            iconColor: Colors.black12,
                            width: summaryCardWidth,
                          );
                        } else {
                          return SummaryCard(
                            title: lang.mayors,
                            value: '${snapshot.data}',
                            icon: Icons.school,
                            backgroundColor: appColorScheme.success,
                            textColor: themeData.colorScheme.onPrimary,
                            iconColor: Colors.black12,
                            width: summaryCardWidth,
                          );
                        }
                      },
                    ),
                    FutureBuilder<int>(
                      future: fetchSubjectsCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            width: summaryCardWidth,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return SummaryCard(
                            title: lang.subject(2),
                            value: 'Error',
                            icon: Icons.book,
                            backgroundColor: appColorScheme.error,
                            textColor: themeData.colorScheme.onPrimary,
                            iconColor: Colors.black12,
                            width: summaryCardWidth,
                          );
                        } else {
                          return SummaryCard(
                            title: lang.subject(2),
                            value: '${snapshot.data}',
                            icon: Icons.book,
                            backgroundColor: appColorScheme.error,
                            textColor: themeData.colorScheme.onPrimary,
                            iconColor: Colors.black12,
                            width: summaryCardWidth,
                          );
                        }
                      },
                    ),
                    FutureBuilder<int>(
                      future: fetchNewUsersCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            width: summaryCardWidth,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return SummaryCard(
                            title: lang.newUsers(2),
                            value: 'Error',
                            icon: FontAwesomeIcons.building,
                            backgroundColor: appColorScheme.warning,
                            textColor: appColorScheme.buttonTextBlack,
                            iconColor: Colors.black12,
                            width: summaryCardWidth,
                          );
                        } else {
                          return SummaryCard(
                            title: lang.newUsers(2),
                            value: '${snapshot.data}',
                            icon: FontAwesomeIcons.building,
                            backgroundColor: appColorScheme.warning,
                            textColor: appColorScheme.buttonTextBlack,
                            iconColor: Colors.black12,
                            width: summaryCardWidth,
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHeader(
                    title: lang.students(2),
                    showDivider: false,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double dataTableWidth =
                            max(kScreenWidthMd, constraints.maxWidth);

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
                                future: fetchItems(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('No data available'));
                                  } else {
                                    final items = snapshot.data!;
                                    return Theme(
                                      data: themeData.copyWith(
                                        cardTheme: appDataTableTheme.cardTheme,
                                        dataTableTheme: appDataTableTheme
                                            .dataTableThemeData,
                                      ),
                                      child: DataTable(
                                        showCheckboxColumn: false,
                                        showBottomBorder: true,
                                        columns: const [
                                          DataColumn(label: Text('No.'), numeric: true),
                                          DataColumn(label: Text('ID'), numeric: true),
                                          DataColumn(label: Text('Khmer Name')),
                                          DataColumn(label: Text('English Name')),
                                          DataColumn(label: Text('BirthDate')),
                                          DataColumn(label: Text('Address')),
                                          DataColumn(label: Text('Department')),
                                        ],
                                        rows: List.generate(items.length,
                                            (index) {
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
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: SizedBox(
                        height: 40.0,
                        width: 120.0,
                        child: ElevatedButton(
                          onPressed: () =>
                              GoRouter.of(context).go(RouteUri.crud),
                          style: themeData
                              .extension<AppButtonTheme>()!
                              .infoElevated,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: kDefaultPadding * 0.5),
                                child: Icon(
                                  Icons.visibility_rounded,
                                  size: (themeData
                                          .textTheme.labelLarge!.fontSize! +
                                      4.0),
                                ),
                              ),
                              const Text('View All'),
                            ],
                          ),
                        ),
                      ),
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

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double width;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 120.0,
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: kDefaultPadding * 0.5,
              right: kDefaultPadding * 0.5,
              child: Icon(
                icon,
                size: 80.0,
                color: iconColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                    child: Text(
                      value,
                      style: textTheme.headlineMedium!.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: textTheme.labelLarge!.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

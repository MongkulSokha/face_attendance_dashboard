import 'package:flutter/material.dart';
import 'package:face_attendance_dashboard/app_router.dart';
import 'package:face_attendance_dashboard/generated/l10n.dart';
import 'package:face_attendance_dashboard/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:face_attendance_dashboard/views/widgets/portal_master_layout/sidebar.dart';

final sidebarMenuConfigs = [
  SidebarMenuConfig(
    uri: RouteUri.dashboard,
    icon: Icons.dashboard_rounded,
    title: (context) => Lang.of(context).dashboard,
  ),
  SidebarMenuConfig(
    uri: RouteUri.crud,
    icon: Icons.circle_outlined,
    title: (context) => 'CRUD',
  ),
  SidebarMenuConfig(
    uri: RouteUri.form,
    icon: Icons.edit_note_rounded,
    title: (context) => Lang.of(context).forms(1),
  ),
  SidebarMenuConfig(
    uri: '',
    icon: Icons.interests_rounded,
    title: (context) => Lang.of(context).uiElements(2),
    children: [
      SidebarChildMenuConfig(
        uri: RouteUri.generalUi,
        icon: Icons.circle_outlined,
        title: (context) => Lang.of(context).generalUi,
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.colors,
        icon: Icons.circle_outlined,
        title: (context) => Lang.of(context).colors(2),
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.text,
        icon: Icons.circle_outlined,
        title: (context) => Lang.of(context).text,
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.buttons,
        icon: Icons.circle_outlined,
        title: (context) => Lang.of(context).buttons(2),
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.dialogs,
        icon: Icons.circle_outlined,
        title: (context) => Lang.of(context).dialogs(2),
      ),
    ],
  ),
  SidebarMenuConfig(
    uri: RouteUri.iframe,
    icon: Icons.laptop_windows_rounded,
    title: (context) => Lang.of(context).iframeDemo,
  ),
];

const localeMenuConfigs = [
  LocaleMenuConfig(
    languageCode: 'en',
    name: 'English',
  ),
  LocaleMenuConfig(
    languageCode: 'zh',
    scriptCode: 'Hans',
    name: '中文 (简体)',
  ),
  LocaleMenuConfig(
    languageCode: 'zh',
    scriptCode: 'Hant',
    name: '中文 (繁體)',
  ),
];

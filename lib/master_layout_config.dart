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
    icon: Icons.people,
    title: (context) => 'Student',
  ),
  SidebarMenuConfig(
    uri: RouteUri.register,
    icon: Icons.app_registration,
    title: (context) => 'Register Account',
  ),
];

const localeMenuConfigs = [
  LocaleMenuConfig(
    languageCode: 'en',
    name: 'English',
  ),
  LocaleMenuConfig(
    languageCode: 'km',
    name: 'ខ្មែរ',
  ),
];

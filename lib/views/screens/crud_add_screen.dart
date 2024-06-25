import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:face_attendance_dashboard/app_router.dart';
import 'package:face_attendance_dashboard/constants/dimens.dart';
import 'package:face_attendance_dashboard/generated/l10n.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_button_theme.dart';
import 'package:face_attendance_dashboard/utils/app_focus_helper.dart';
import 'package:face_attendance_dashboard/views/widgets/card_elements.dart';
import 'package:face_attendance_dashboard/views/widgets/portal_master_layout/portal_master_layout.dart';

class CrudAddScreen extends StatefulWidget {
  final String id;

  const CrudAddScreen({
    super.key,
    required this.id,
  });

  @override
  State<CrudAddScreen> createState() => _CrudAddScreenState();
}

class _CrudAddScreenState extends State<CrudAddScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _id = "";
  String _firstName = "";
  String _lastName = "";
  String _khmerName = "";
  String _studentId = "";
  String _birthDate = "";
  String _address = "";
  String _department = "";
  String _profilePicLink = "";
  bool _canEdit = true;
  String _password = "";

  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<bool>? _future;

  List<String> _departmentList = [];

  Future<bool> _getDataAsync() async {
    if (widget.id.isNotEmpty) {
      _departmentList = await fetchDepartment();

      final doc = await FirebaseFirestore.instance.collection('Student').doc(widget.id).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _id = widget.id;
            _firstName = data['firstName'] ?? '';
            _lastName = data['lastName'] ?? '';
            _khmerName = data['khmerName'] ?? '';
            _studentId = data['id'] ?? '';
            _birthDate = data['birthDate'] ?? '';
            _address = data['address'] ?? '';
            _department = data['department'] ?? '';
            _profilePicLink = data['profilePicLink'] ?? '';
            _canEdit = data['canEdit'] ?? true;
            _password = data['password'] ?? '';
          });
        }
      }
    }
    return true;
  }

  Future<List<String>> fetchDepartment() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('department')
        .get();
    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _doSubmit(BuildContext context) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final lang = Lang.of(context);

      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        title: lang.confirmSubmitRecord,
        width: kDialogWidth,
        btnOkText: lang.yes,
        btnOkOnPress: () async {
          try {
            final data = {
              'firstName': _firstName,
              'lastName': _lastName,
              'khmerName': _khmerName,
              'id': _studentId,
              'birthDate': _birthDate,
              'address': _address,
              'department': _department,
              'profilePicLink': _profilePicLink,
              'canEdit': _canEdit,
              'password': _password,
            };

            if (_id.isEmpty) {
              await FirebaseFirestore.instance.collection('Student').add(data);
            } else {
              await FirebaseFirestore.instance.collection('Student').doc(_id).update(data);
            }

            final d = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: lang.recordSubmittedSuccessfully,
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () => GoRouter.of(context).go(RouteUri.crud),
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
  }

  void _doDelete(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    final lang = Lang.of(context);

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: lang.confirmDeleteRecord,
      width: kDialogWidth,
      btnOkText: lang.yes,
      btnOkOnPress: () async {
        try {
          await FirebaseFirestore.instance.collection('Student').doc(_id).delete();
          final d = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: lang.recordDeletedSuccessfully,
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () => GoRouter.of(context).go(RouteUri.crud),
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

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    final pageTitle = 'Student - ${widget.id.isEmpty ? lang.crudNew : lang.crudDetail}';

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.crud,
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            pageTitle,
            style: themeData.textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHeader(
                    title: pageTitle,
                  ),
                  CardBody(
                    child: FutureBuilder<bool>(
                      initialData: null,
                      future: (_future ??= _getDataAsync()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          if (snapshot.hasData && snapshot.data!) {
                            return _content(context);
                          }
                        } else if (snapshot.hasData && snapshot.data!) {
                          return _content(context);
                        }

                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                          child: SizedBox(
                            height: 40.0,
                            width: 40.0,
                            child: CircularProgressIndicator(
                              backgroundColor: themeData.scaffoldBackgroundColor,
                            ),
                          ),
                        );
                      },
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

  Widget _content(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'studentId',
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'Student ID',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _studentId,
              onSaved: (value) => _studentId = value ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'khmerName',
              decoration: const InputDecoration(
                labelText: 'Khmer Name',
                hintText: 'Khmer Name',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _khmerName,
              onSaved: (value) => _khmerName = value ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'firstName',
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'First Name',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _firstName,
              onSaved: (value) => _firstName = value ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'lastName',
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Last Name',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _lastName,
              onSaved: (value) => _lastName = value ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'birthDate',
              decoration: const InputDecoration(
                labelText: 'Birth Date',
                hintText: 'Birth Date',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _birthDate,
              onSaved: (value) => _birthDate = value ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'address',
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Address',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _address,
              onSaved: (value) => _address = value ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'department',
              decoration: const InputDecoration(
                labelText: 'Department',
                hintText: 'Department',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _department,
              onSaved: (value) => _department = value ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'password',
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Password',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _password,
              obscureText: true,
              onSaved: (value) => _password = value ?? '',
            ),
          ),
          Row(
            children: [
              const Text("Can Edit"),
              Switch(
                value: _canEdit,
                onChanged: (value) => setState(() {
                  _canEdit = value;
                }),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40.0,
                child: ElevatedButton(
                  style: themeData.extension<AppButtonTheme>()!.secondaryElevated,
                  onPressed: () => GoRouter.of(context).go(RouteUri.crud),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                        child: Icon(
                          Icons.arrow_circle_left_outlined,
                          size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                        ),
                      ),
                      Text(lang.crudBack),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Visibility(
                visible: widget.id.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(right: kDefaultPadding),
                  child: SizedBox(
                    height: 40.0,
                    child: ElevatedButton(
                      style: themeData.extension<AppButtonTheme>()!.errorElevated,
                      onPressed: () => _doDelete(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                            child: Icon(
                              Icons.delete_rounded,
                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                            ),
                          ),
                          Text(lang.crudDelete),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40.0,
                child: ElevatedButton(
                  style: themeData.extension<AppButtonTheme>()!.successElevated,
                  onPressed: () => _doSubmit(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                        ),
                      ),
                      Text(lang.submit),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

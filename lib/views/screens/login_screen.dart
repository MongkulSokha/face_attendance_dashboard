import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:face_attendance_dashboard/app_router.dart';
import 'package:face_attendance_dashboard/constants/dimens.dart';
import 'package:face_attendance_dashboard/generated/l10n.dart';
import 'package:face_attendance_dashboard/providers/user_data_provider.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_button_theme.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_color_scheme.dart';
import 'package:face_attendance_dashboard/utils/app_focus_helper.dart';
import 'package:face_attendance_dashboard/views/widgets/public_master_layout/public_master_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  var _isFormLoading = false;

  Future<void> _doLoginAsync({
    required UserDataProvider userDataProvider,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      // Validation passed.
      _formKey.currentState!.save();

      setState(() => _isFormLoading = true);

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _formData.email,
          password: _formData.password,
        );

        // Set user data in provider
        await userDataProvider.setUserDataAsync(
          username: userCredential.user?.email ?? 'User',
          userProfileImageUrl: 'https://picsum.photos/id/1005/300/300',
        );

        onSuccess.call();
      } on FirebaseAuthException catch (e) {
        onError.call(e.message ?? 'Login failed');
      } catch (e) {
        onError.call('An unknown error occurred');
      } finally {
        setState(() => _isFormLoading = false);
      }
    }
  }

  void _onLoginSuccess(BuildContext context) {
    GoRouter.of(context).go(RouteUri.home);
  }

  void _onLoginError(BuildContext context, String message) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      desc: message,
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    );

    dialog.show();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PublicMasterLayout(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.only(top: kDefaultPadding * 5.0),
            constraints: const BoxConstraints(maxWidth: 400.0),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: kDefaultPadding),
                      child: Image.asset(
                        'assets/icons/icon.jpg',
                        height: 80.0,
                      ),
                    ),
                    Text(
                      lang.appTitle,
                      style: themeData.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                      child: Text(
                        lang.adminPortalLogin,
                        style: themeData.textTheme.titleMedium,
                      ),
                    ),
                    FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                            child: FormBuilderTextField(
                              name: 'email',
                              decoration: InputDecoration(
                                labelText: lang.email,
                                hintText: lang.email,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              enableSuggestions: false,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.email(),
                              ]),
                              onSaved: (value) => (_formData.email = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              name: 'password',
                              decoration: InputDecoration(
                                labelText: lang.password,
                                hintText: lang.password,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              enableSuggestions: false,
                              obscureText: true,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) => (_formData.password = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding),
                            child: SizedBox(
                              height: 40.0,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: themeData.extension<AppButtonTheme>()!.primaryElevated,
                                onPressed: (_isFormLoading
                                    ? null
                                    : () => _doLoginAsync(
                                  userDataProvider: context.read<UserDataProvider>(),
                                  onSuccess: () => _onLoginSuccess(context),
                                  onError: (message) => _onLoginError(context, message),
                                )),
                                child: Text(lang.login),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                            width: double.infinity,
                            child: TextButton(
                              style: themeData.extension<AppButtonTheme>()!.secondaryText,
                              onPressed: () => GoRouter.of(context).go(RouteUri.register),
                              child: RichText(
                                text: TextSpan(
                                  text: '${lang.dontHaveAnAccount} ',
                                  style: TextStyle(
                                    color: themeData.colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: lang.registerNow,
                                      style: TextStyle(
                                        color: themeData.extension<AppColorScheme>()!.hyperlink,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormData {
  String email = '';
  String password = '';
}

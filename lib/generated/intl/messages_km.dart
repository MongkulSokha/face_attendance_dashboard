// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a km locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'km';

  static String m0(count) =>
      "${Intl.plural(count, one: 'ប៊ូតុង', other: 'ប៊ូតុង')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'ពណ៌', other: 'ពណ៌')}";

  static String m2(count) =>
      "${Intl.plural(count, one: 'ប្រអប់សន្ទនា', other: 'ប្រអប់សន្ទនា')}";

  static String m3(value) =>
      "តម្លៃវាលនេះត្រូវតែស្មើនឹង ${value}។";

  static String m4(count) =>
      "${Intl.plural(count, one: 'ផ្នែកបន្ថែម', other: 'ផ្នែកបន្ថែម')}";

  static String m5(count) =>
      "${Intl.plural(count, one: 'បែបបទ', other: 'បែបបទ')}";

  static String m6(max) =>
      "តម្លៃត្រូវតែតិចជាង ឬស្មើ ${max}";

  static String m7(maxLength) =>
      "តម្លៃត្រូវតែមានប្រវែងតិចជាង ឬស្មើ ${maxLength}";

  static String m8(min) =>
      "តម្លៃត្រូវតែធំជាង ឬស្មើ ${min}.";

  static String m9(minLength) =>
      "តម្លៃត្រូវតែមានប្រវែងធំជាង ឬស្មើ ${minLength}";

  static String m10(count) =>
      "${Intl.plural(count, one: 'ការបញ្ជាទិញថ្មី', other: 'ការបញ្ជាទិញថ្មី')}";

  static String m11(count) =>
      "${Intl.plural(count, one: 'អ្នកប្រើថ្មី', other: 'អ្នកប្រើថ្មី')}";

  static String m12(value) =>
      "តម្លៃវាលនេះមិនត្រូវស្មើនឹង ${value}។";

  static String m13(count) =>
      "${Intl.plural(count, one: 'ទំព័រ', other: 'ទំព័រ')}";

  static String m14(count) =>
      "${Intl.plural(count, one: 'បញ្ហាកំពុងរង់ចាំ', other: 'បញ្ហាកំពុងរង់ចាំ')}";

  static String m15(count) =>
      "${Intl.plural(count, one: 'ការបញ្ជាទិញថ្មីៗ', other: 'ការបញ្ជាទិញថ្មីៗ')}";

  static String m16(count) =>
      "${Intl.plural(count, one: 'ធាតុ UI', other: 'ធាតុ UI')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "account": MessageLookupByLibrary.simpleMessage("គណនី"),
    "adminPortalLogin":
    MessageLookupByLibrary.simpleMessage("ចូលទៅបន្ទប់គ្រប់គ្រង"),
    "appTitle": MessageLookupByLibrary.simpleMessage("អ្នកគ្រប់គ្រងវេបសាយ"),
    "backToLogin":
    MessageLookupByLibrary.simpleMessage("ត្រលប់ទៅចូលប្រើ"),
    "buttonEmphasis":
    MessageLookupByLibrary.simpleMessage("សំដែងប៊ូតុង"),
    "buttons": m0,
    "cancel": MessageLookupByLibrary.simpleMessage("បោះបង់"),
    "closeNavigationMenu":
    MessageLookupByLibrary.simpleMessage("បិទម៉ឺនុយរុករក"),
    "colorPalette":
    MessageLookupByLibrary.simpleMessage("បញ្ជីពណ៌"),
    "colorScheme":
    MessageLookupByLibrary.simpleMessage("គ្រោងពណ៌"),
    "colors": m1,
    "confirmDeleteRecord":
    MessageLookupByLibrary.simpleMessage("បញ្ជាក់លុបកំណត់ត្រានេះ?"),
    "confirmSubmitRecord":
    MessageLookupByLibrary.simpleMessage("បញ្ជាក់ដាក់ស្នើកំណត់ត្រានេះ?"),
    "copy": MessageLookupByLibrary.simpleMessage("ចម្លង"),
    "creditCardErrorText": MessageLookupByLibrary.simpleMessage(
        "វាលនេះត្រូវការលេខកាតឥណទានត្រឹមត្រូវ។"),
    "crudBack": MessageLookupByLibrary.simpleMessage("ត្រលប់"),
    "crudDelete": MessageLookupByLibrary.simpleMessage("លុប"),
    "crudDetail": MessageLookupByLibrary.simpleMessage("លម្អិត"),
    "crudNew": MessageLookupByLibrary.simpleMessage("ថ្មី"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("ផ្ទៃខ្មៅ"),
    "dashboard": MessageLookupByLibrary.simpleMessage("ផ្ទាំងគ្រប់គ្រង"),
    "dateStringErrorText": MessageLookupByLibrary.simpleMessage(
        "វាលនេះត្រូវការខ្សែអក្សរថ្ងៃខែត្រឹមត្រូវ។"),
    "dialogs": m2,
    "dontHaveAnAccount":
    MessageLookupByLibrary.simpleMessage("មិនមានគណនី?"),
    "email": MessageLookupByLibrary.simpleMessage("អ៊ីមែល"),
    "emailErrorText": MessageLookupByLibrary.simpleMessage(
        "វាលនេះត្រូវការអាសយដ្ឋានអ៊ីមែលត្រឹមត្រូវ។"),
    "equalErrorText": m3,
    "error404": MessageLookupByLibrary.simpleMessage("កំហុស 404"),
    "error404Message": MessageLookupByLibrary.simpleMessage(
        "សូមអភ័យទោស ទំព័រដែលអ្នកកំពុងស្វែងរកត្រូវបានយកចេញ ឬមិនមាន។"),
    "error404Title": MessageLookupByLibrary.simpleMessage("រកមិនឃើញទំព័រ"),
    "example": MessageLookupByLibrary.simpleMessage("ឧទាហរណ៍"),
    "extensions": m4,
    "forms": m5,
    "generalUi": MessageLookupByLibrary.simpleMessage("UI ទូទៅ"),
    "hi": MessageLookupByLibrary.simpleMessage("សួស្តី"),
    "homePage": MessageLookupByLibrary.simpleMessage("ទំព័រដើម"),
    "iframeDemo": MessageLookupByLibrary.simpleMessage("សាកល្បង IFrame"),
    "integerErrorText": MessageLookupByLibrary.simpleMessage(
        "វាលនេះត្រូវការលេខគត់ត្រឹមត្រូវ។"),
    "ipErrorText": MessageLookupByLibrary.simpleMessage(
        "វាលនេះត្រូវការលេខ IP ត្រឹមត្រូវ។"),
    "language": MessageLookupByLibrary.simpleMessage("ភាសា"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("ផ្ទៃស"),
    "login": MessageLookupByLibrary.simpleMessage("ចូលប្រើ"),
    "loginNow": MessageLookupByLibrary.simpleMessage("ចូលឥឡូវនេះ!"),
    "logout": MessageLookupByLibrary.simpleMessage("ចេញ"),
    "loremIpsum": MessageLookupByLibrary.simpleMessage(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit"),
    "matchErrorText": MessageLookupByLibrary.simpleMessage(
        "តម្លៃមិនត្រូវនឹងលំនាំ។"),
    "maxErrorText": m6,
    "maxLengthErrorText": m7,
    "minErrorText": m8,
    "minLengthErrorText": m9,
    "myProfile": MessageLookupByLibrary.simpleMessage("ពត៌មានផ្ទាល់ខ្លួន"),
    "newOrders": m10,
    "newUsers": m11,
    "notEqualErrorText": m12,
    "numericErrorText":
    MessageLookupByLibrary.simpleMessage("តម្លៃត្រូវតែជាលេខ។"),
    "openInNewTab":
    MessageLookupByLibrary.simpleMessage("បើកក្នុងផ្ទាំងថ្មី"),
    "pages": m13,
    "password": MessageLookupByLibrary.simpleMessage("ពាក្យសម្ងាត់"),
    "passwordHelperText":
    MessageLookupByLibrary.simpleMessage("* 6 - 18 តួអក្សរ"),
    "passwordNotMatch":
    MessageLookupByLibrary.simpleMessage("ពាក្យសម្ងាត់មិនត្រូវគ្នា។"),
    "pendingIssues": m14,
    "recentOrders": m15,
    "recordDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
        "បានលុបកំណត់ត្រាចេញដោយជោគជ័យ។"),
    "recordSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
        "បានរក្សាទុកកំណត់ត្រាចេញដោយជោគជ័យ។"),
    "recordSubmittedSuccessfully": MessageLookupByLibrary.simpleMessage(
        "បានដាក់ស្នើកំណត់ត្រាចេញដោយជោគជ័យ។"),
    "register": MessageLookupByLibrary.simpleMessage("ចុះឈ្មោះ"),
    "registerANewAccount":
    MessageLookupByLibrary.simpleMessage("ចុះឈ្មោះគណនីថ្មី"),
    "registerNow": MessageLookupByLibrary.simpleMessage("ចុះឈ្មោះឥឡូវនេះ!"),
    "requiredErrorText":
    MessageLookupByLibrary.simpleMessage("វាលនេះមិនអាចទទេបាន។"),
    "retypePassword":
    MessageLookupByLibrary.simpleMessage("វាយបញ្ចូលពាក្យសម្ងាត់ម្តងទៀត"),
    "save": MessageLookupByLibrary.simpleMessage("រក្សាទុក"),
    "search": MessageLookupByLibrary.simpleMessage("ស្វែងរក"),
    "submit": MessageLookupByLibrary.simpleMessage("ដាក់ស្នើ"),
    "text": MessageLookupByLibrary.simpleMessage("អត្ថបទ"),
    "textEmphasis":
    MessageLookupByLibrary.simpleMessage("សំដែងអត្ថបទ"),
    "textTheme": MessageLookupByLibrary.simpleMessage("ស្បៀងអត្ថបទ"),
    "todaySales": MessageLookupByLibrary.simpleMessage("ការលក់ថ្ងៃនេះ"),
    "typography": MessageLookupByLibrary.simpleMessage("វាយអក្សរ"),
    "uiElements": m16,
    "urlErrorText": MessageLookupByLibrary.simpleMessage(
        "វាលនេះត្រូវការអាសយដ្ឋាន URL ត្រឹមត្រូវ។"),
    "username": MessageLookupByLibrary.simpleMessage("ឈ្មោះអ្នកប្រើ"),
    "yes": MessageLookupByLibrary.simpleMessage("បាទ/ចាស")
  };
}

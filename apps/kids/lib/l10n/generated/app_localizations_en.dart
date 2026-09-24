// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get leaveFamilyTitle => 'Leave family?';

  @override
  String get leaveFamilyMessage =>
      'The link with the family will be removed. Your local tasks will be kept.';

  @override
  String get cancel => 'Cancel';

  @override
  String get leave => 'Leave';

  @override
  String get linkFamilyTitle => 'Link family';

  @override
  String get scanQrCode => 'Scan the QR code';

  @override
  String get scanQrInstructions =>
      'Open Kinetic Link, go to Settings → Family → Link kids app, scan the QR code, then enter the WebDAV password.';

  @override
  String invalidQrCode(Object error) {
    return 'Invalid QR code: $error';
  }

  @override
  String get qrCodeFoundConfirm =>
      'QR code found. Link this device to the family?';

  @override
  String get account => 'Account';

  @override
  String get server => 'Server';

  @override
  String get enterWebDavPassword =>
      'Enter the WebDAV password from Kinetic Link. It is not in the QR code.';

  @override
  String get webDavPassword => 'WebDAV password';

  @override
  String get link => 'Link';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get sync => 'Sync';

  @override
  String get syncFailed => 'Sync failed — tap to retry';

  @override
  String get syncOk => 'Synced';

  @override
  String get leaveFamily => 'Leave family';

  @override
  String errorWithDetails(Object error) {
    return 'Error: $error';
  }

  @override
  String get allDone => 'All done!';

  @override
  String get noTasksRightNow => 'No tasks right now.';

  @override
  String get stillToDo => 'To do';

  @override
  String get waitingForLink => 'Waiting for Link';

  @override
  String get completed => 'Completed';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityLow => 'Low';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get overdue => 'Overdue';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String taskNotFound(Object error) {
    return 'Task not found: $error';
  }

  @override
  String get taskDetails => 'Task details';

  @override
  String get details => 'Details';

  @override
  String get dueDate => 'Due date';

  @override
  String get noDueDate => 'No due date';

  @override
  String get priority => 'Priority';

  @override
  String get category => 'Category';

  @override
  String get experience => 'Experience';

  @override
  String get notes => 'Notes';

  @override
  String get delete => 'Delete';

  @override
  String get categoryHousehold => 'Household';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryOther => 'Other';

  @override
  String get notificationChannelName => 'Tasks';

  @override
  String get notificationChannelDescription =>
      'Notifications for new tasks from Link.';

  @override
  String get newTaskNotificationTitle => 'New task';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get continueLabel => 'Continue';

  @override
  String get settings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get keepGoing => 'Keep going!';

  @override
  String goalProgress(int earned, int target) {
    return '$earned / $target XP';
  }

  @override
  String totalXp(int xp) {
    return '$xp XP';
  }

  @override
  String get confirmCompleteTitle => 'Are you done?';

  @override
  String get confirmCompleteBody =>
      'Are you sure you are finished? We will send a confirmation request to Link.';

  @override
  String get confirmCompleteAction => 'Yes, I\'m done';

  @override
  String get awaitingLinkConfirm => 'Waiting for Link to confirm';

  @override
  String get cleanUpCompleted => 'Clean up';
}

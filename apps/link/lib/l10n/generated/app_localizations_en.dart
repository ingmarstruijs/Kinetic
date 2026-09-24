// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navTasks => 'Tasks';

  @override
  String get navNotes => 'Notes';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonOk => 'OK';

  @override
  String get commonError => 'Error';

  @override
  String get commonImport => 'Import';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonUnknown => '(unknown)';

  @override
  String get themeLight => 'Default';

  @override
  String get themeCalm => 'Calm';

  @override
  String get themeNight => 'Night';

  @override
  String get themeLightDesc => 'Light blue';

  @override
  String get themeCalmDesc => 'Warm sand with terracotta accents';

  @override
  String get themeNightDesc => 'OLED black';

  @override
  String get themeChoose => 'Choose theme';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsSectionSync => 'Sync';

  @override
  String get settingsWebDavConfigure => 'Configure WebDAV';

  @override
  String get settingsWebDavConnected => 'Connected';

  @override
  String get settingsWebDavConnectHint =>
      'Connect to a Nextcloud or WebDAV server';

  @override
  String get settingsWebDavTurnOff => 'Turn off WebDAV sync';

  @override
  String get settingsWebDavTurnOffTitle => 'Turn off WebDAV sync?';

  @override
  String get settingsWebDavTurnOffBody =>
      'Sync with the server stops. You also lose family linking, shared notes, kids tasks, and multi-device sync. Your private tasks and notes stay on this device. The recovery phrase still unlocks your local vault.';

  @override
  String get settingsWebDavTurnOffConfirm => 'Turn off';

  @override
  String get settingsWebDavTurnedOff => 'WebDAV sync turned off.';

  @override
  String get settingsSectionFamily => 'Family';

  @override
  String get settingsFamilyMember => 'Family member';

  @override
  String get settingsFamilyMembers => 'Family members';

  @override
  String get settingsFamilyMemberLinked => 'Family member linked';

  @override
  String get settingsFamilyMemberLinkHint => 'Link with another family member';

  @override
  String get settingsKids => 'Kids';

  @override
  String get settingsKidsParticipation => 'Kids tasks on this device';

  @override
  String get settingsKidsParticipationSubtitle =>
      'When off, this device cannot see, create, assign, or verify kids tasks';

  @override
  String get settingsKidsLinkHint => 'Link the kids app';

  @override
  String settingsKidsEnrolledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kids linked',
      one: '1 kid linked',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionVault => 'Vault';

  @override
  String get settingsVerifyPhrase => 'Verify recovery phrase';

  @override
  String get settingsVerifyPhraseSubtitle =>
      'Check that you still know the 12 words. We will not show them.';

  @override
  String get settingsSectionBackup => 'Backup & Restore';

  @override
  String get settingsExportBackup => 'Export backup';

  @override
  String get settingsExportBackupSubtitle =>
      'Encrypted .kvault file. The recovery phrase is not included.';

  @override
  String get settingsImportBackup => 'Import backup';

  @override
  String get settingsImportBackupSubtitle => 'Replaces all data on this phone';

  @override
  String notifServiceFailed(String error) {
    return 'Notification service failed to start: $error';
  }

  @override
  String get notifDisabledBanner =>
      'Notifications are disabled. Turn them on in Settings to receive reminders.';

  @override
  String get notifExactAlarmBanner =>
      'Exact reminders are disabled. Allow \"Alarms & reminders\" for precise times.';

  @override
  String get familyKeyScanTitle => 'Scan family key';

  @override
  String get familyKeyScanHint => 'Point at the family member\'s QR code';

  @override
  String get familyKeyEnterPhrase => 'Enter phrase';

  @override
  String get familyKeyFound => 'Key found';

  @override
  String get familyKeyLinkMember => 'Family member';

  @override
  String get familyKeyServer => 'Server';

  @override
  String get familyKeyFingerprint => 'Fingerprint';

  @override
  String familyKeyServerMismatch(String scanned, String current) {
    return 'The server in the invite ($scanned) does not match your WebDAV server ($current). Family sync only works when everyone uses the same server — linking is blocked.';
  }

  @override
  String get familyKeyConfirmLinkMember =>
      'Is this the right family member? Check the username above.';

  @override
  String get familyKeyAlreadyPairedWarning =>
      'You already have a family key. Importing a new one will make data encrypted with the current key unreadable until you sync again.';

  @override
  String get familyKeyEnterTitle => 'Enter family key';

  @override
  String get familyKeyEnterSubtitle =>
      'Enter their 12 words. You will then see the fingerprint to verify.';

  @override
  String get familyKeySaved => 'Family key saved.';

  @override
  String familyKeySaveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String familyKeyInvalidQr(String error) {
    return 'Invalid QR code: $error';
  }

  @override
  String get familyKeyShareTitle => 'Share family key';

  @override
  String get familyKeyShareLegacyBody =>
      'Have the family member scan this QR code. This family key is from before the recovery phrase and has no 12 words.';

  @override
  String get familyKeyShareBody =>
      'Have the family member scan this QR code, or type the 12 words.';

  @override
  String get familyKeyShareNoPassword =>
      'The code does not include the WebDAV password. Check the fingerprint together.';

  @override
  String get familyKeyShareNoEntropy =>
      'No recovery-phrase data on this device. Create a new family key.';

  @override
  String familyKeyShareFingerprint(String fingerprint) {
    return 'Fingerprint  $fingerprint';
  }

  @override
  String get familyKeyLinkMemberScanned => 'Family member has scanned';

  @override
  String get familyKeyShared => 'Family key shared';

  @override
  String get vaultWelcomeTitle => 'Your vault';

  @override
  String get vaultWelcomeBody =>
      'Kinetic Link stores tasks and notes with a 12-word recovery phrase. Write that phrase on paper and keep it safe. We do not store the words on this device.';

  @override
  String get vaultNewVault => 'New vault';

  @override
  String get vaultRestoreVault => 'Restore vault';

  @override
  String get vaultCreateVault => 'Create vault';

  @override
  String get vaultRecoveryPhrase => 'Recovery phrase';

  @override
  String get vaultConfirm => 'Confirm';

  @override
  String get vaultWriteWords =>
      'Write these 12 words on paper and keep them safe. Without this phrase you cannot restore the vault on a new device.';

  @override
  String get vaultPhraseCopied => 'Recovery phrase copied';

  @override
  String get vaultIWroteThemDown => 'I wrote them down';

  @override
  String get vaultQuizPrompt =>
      'Fill in the requested words to confirm you saved the phrase.';

  @override
  String vaultWordN(int n) {
    return 'Word $n';
  }

  @override
  String get vaultBackToWords => 'Back to the words';

  @override
  String get vaultQuizMismatch => 'Not all words match. Try again.';

  @override
  String vaultCreateFailed(String error) {
    return 'Could not create the vault: $error';
  }

  @override
  String get vaultCouldNotReadFile => 'Could not read the file.';

  @override
  String get vaultRestoreTitle => 'Restore vault';

  @override
  String get vaultRestoreIntro =>
      'Choose how to restore the vault. The recovery phrase is the same in both cases.';

  @override
  String get vaultRestoreFromFile => 'From file';

  @override
  String get vaultRestoreFromWebDav => 'From WebDAV';

  @override
  String get vaultRestoreFromWebDavSubtitle =>
      'Server, credentials, and 12 words. No file needed.';

  @override
  String get vaultRestoreFileTitle => 'Restore from file';

  @override
  String get vaultRestoreFileBody =>
      'Enter your recovery phrase, then choose the .kvault file.';

  @override
  String get vaultChooseFileAndRestore => 'Choose file and restore';

  @override
  String get vaultNoVaultOnServer =>
      'No vault on this server. Create a new vault or choose a different server.';

  @override
  String get vaultPhraseMismatchServer =>
      'This recovery phrase does not match the vault on this server.';

  @override
  String get vaultRestoreWebDavTitle => 'Restore from WebDAV';

  @override
  String get vaultRestoreWebDavBody =>
      'Sign in to your server and enter the same 12 words used when creating the vault.';

  @override
  String get vaultServerUrl => 'Server URL';

  @override
  String get vaultUsername => 'Username';

  @override
  String get vaultPassword => 'Password';

  @override
  String get vaultUnlock => 'Unlock vault';

  @override
  String get vaultPhraseFieldLabel => 'Recovery phrase (12 words)';

  @override
  String get vaultMigrateTitle => 'New recovery phrase';

  @override
  String get vaultMigrateBody =>
      'Your current key is random (version 0.2) and cannot become 12 words. Tasks and notes on this device stay. We will create a new recovery phrase. On the next sync, personal files are re-encrypted. The family key stays the same — family members and kids do not need to re-link.';

  @override
  String get vaultMigrateActivate => 'Activate new recovery phrase';

  @override
  String get vaultMigrateHeadline =>
      'Write down these new 12 words. The old key will no longer work for WebDAV or a .kvault.';

  @override
  String get vaultRestoreFromFileSubtitle =>
      '12 words + encrypted .kvault file. No internet needed.';

  @override
  String get vaultBiometricsReason => 'Show the recovery phrase on this device';

  @override
  String get vaultNoScreenLockTitle => 'No screen lock';

  @override
  String get vaultNoScreenLockBody =>
      'This device has no Face ID, fingerprint, or PIN. Anyone with access to the app can see the words. Continue?';

  @override
  String get vaultShowAnyway => 'Show anyway';

  @override
  String get vaultRevealWarning =>
      'Write the words down again on paper if you lost your copy. Do not leave this screen open.';

  @override
  String get familyCreateTitle => 'Family key';

  @override
  String get familyCreateWriteWords =>
      'Write these 12 words down. They belong to the family key you share with family members. We do not store the words.';

  @override
  String familyCreateFailed(String error) {
    return 'Could not create the family key: $error';
  }

  @override
  String get commonVerify => 'Verify';

  @override
  String get commonLeave => 'Leave';

  @override
  String get relativeJustNow => 'just now';

  @override
  String relativeMinutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String relativeHoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String get relativeYesterday => 'yesterday';

  @override
  String relativeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get familyMemberVerifyTitle => 'Verify family key';

  @override
  String get familyMemberVerifyBody =>
      'Enter the 12 words. We will not show them; we only check that they match.';

  @override
  String get familyMemberVerifyOk => 'The family key matches.';

  @override
  String get familyMemberVerifyMismatch =>
      'This recovery phrase does not match this family key.';

  @override
  String get familyMemberRevealMissing =>
      'This family key is from before the recovery phrase (0.2) or arrived as a raw key. We cannot show the words. Create a new family key and have family members and kids re-link.';

  @override
  String get familyMemberUnlinkTitle => 'Leave family?';

  @override
  String get familyMemberUnlinkBody =>
      'All shared notes will be removed from this device. Your own tasks and private notes stay. Other family members keep their connection — only you leave the shared workspace.';

  @override
  String get familyMemberShareViaQr => 'Share family key via QR';

  @override
  String get familyMemberShareViaQrSubtitle =>
      'Have a family member scan the QR code to collaborate.';

  @override
  String get familyMemberScanKey => 'Scan family key';

  @override
  String get familyMemberScanKeySubtitle =>
      'Scan the QR or type their 12 words.';

  @override
  String get familyMemberReshareKey => 'Share family key again';

  @override
  String get familyMemberReshareKeySubtitle =>
      'Share the key with a new device of a family member.';

  @override
  String get familyMemberVerifyPhrase => 'Verify recovery phrase';

  @override
  String get familyMemberVerifyPhraseSubtitle =>
      'Check that you still know the 12 words of the family key.';

  @override
  String get familyMemberShowKey => 'Show family key';

  @override
  String get familyMemberShowKeySubtitle =>
      'Show the 12 words on this device (screen lock).';

  @override
  String get familyMemberUnlink => 'Leave family';

  @override
  String get familyMemberUnlinkSubtitle =>
      'Remove the family key and shared notes from this device.';

  @override
  String get familyMemberRemoveTooltip => 'Remove from family';

  @override
  String familyMemberRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String familyMemberRemoveBody(String name) {
    return '$name will be removed from this family\'s roster. Their app will disconnect on the next sync. The family key is not changed automatically — you can run the new-key wizard afterward so they cannot decrypt new shared data.';
  }

  @override
  String get familyMemberRemovedFromFamily =>
      'You were removed from the family on another device.';

  @override
  String get familyKeyRotationOfferTitle => 'Create a new family key?';

  @override
  String get familyKeyRotationOfferBody =>
      'Removing a member does not change the family key. To keep them from reading new shared notes and tasks, create a new key and share it with everyone who should stay.';

  @override
  String get familyKeyRotationOfferNow => 'Start wizard';

  @override
  String get familyKeyRotationOfferLater => 'Not now';

  @override
  String get familyKeyRotationTitle => 'New family key';

  @override
  String get familyKeyRotationIntroTitle => 'Rotate the family key';

  @override
  String get familyKeyRotationIntroBody =>
      'You will write down a new 12-word family key. Shared data on WebDAV is re-encrypted. Remaining family members and kids must scan a new QR to stay connected.';

  @override
  String get familyKeyRotationStart => 'Create new key';

  @override
  String get familyKeyRotationReencryptTitle => 'Re-encrypting shared data…';

  @override
  String get familyKeyRotationReencryptPreparing => 'Scanning shared folders…';

  @override
  String familyKeyRotationReencryptProgress(int done, int total) {
    return '$done of $total files';
  }

  @override
  String get familyKeyRotationShareLinkTitle => 'Share with family members';

  @override
  String get familyKeyRotationShareLinkBody =>
      'Each remaining Kinetic Link adult must scan this QR or use tap-to-link. Their old key will not open new shared data.';

  @override
  String get familyKeyRotationShareLinkButton => 'Show family QR';

  @override
  String get familyKeyRotationShareLinkSkip => 'Skip for now';

  @override
  String get familyKeyRotationShareKidsTitle => 'Re-enroll kids';

  @override
  String get familyKeyRotationShareKidsBody =>
      'Each child device needs a new enrollment QR with the updated family key.';

  @override
  String get familyKeyRotationDoneTitle => 'Family key updated';

  @override
  String get familyKeyRotationDoneBody =>
      'This device uses the new key. Make sure every remaining family member and kid has scanned the new QR when you are ready.';

  @override
  String get otherLinkMemberStatusPaired =>
      'Family member linked — family key present';

  @override
  String get otherLinkMemberStatusUnpaired =>
      'Family member not linked — scan or share the QR code to link';

  @override
  String familyMemberLastSeen(String when) {
    return 'Last seen $when';
  }

  @override
  String familyMemberLastSeenWarning(String when) {
    return 'Warning: last seen $when';
  }

  @override
  String familyMemberFingerprint(String fingerprint) {
    return 'Fingerprint $fingerprint';
  }

  @override
  String get kidsLinkApp => 'Link kids app';

  @override
  String get kidsLinkAppSubtitle => 'Have the kids app scan the QR code.';

  @override
  String get kidsEnrolledSection => 'ENROLLED KIDS';

  @override
  String get kidsNoneEnrolled => 'No kids linked yet.';

  @override
  String get kidsRemoveTooltip => 'Remove from family';

  @override
  String kidsRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String kidsRemoveBody(String name) {
    return '$name will be removed from the family list. The kids app will no longer receive family tasks unless linked again.';
  }

  @override
  String kidsEnrolledOn(String date) {
    return 'Linked on $date';
  }

  @override
  String kidsLastSeen(String when) {
    return 'Last seen $when';
  }

  @override
  String kidsLastSeenWarning(String when) {
    return 'Warning: last seen $when';
  }

  @override
  String get kidsEnrollTitle => 'Link kids app';

  @override
  String get kidsEnrollNameTitle => 'Child\'s name';

  @override
  String get kidsEnrollNameBody =>
      'Enter the name of the child you want to link.';

  @override
  String get kidsEnrollNameLabel => 'Child name';

  @override
  String get kidsEnrollContinueToQr => 'Continue to QR code';

  @override
  String kidsEnrollQrTitle(String name) {
    return 'QR code for $name';
  }

  @override
  String kidsEnrollQrBody(String name) {
    return 'Open the kids app on $name\'s device and scan this code.';
  }

  @override
  String get kidsEnrollWhatShared => 'What is shared?';

  @override
  String get kidsEnrollWhatSharedBody =>
      'This QR code contains the server, account, and family key — not the WebDAV password. Type that password once on the kids device. Only share the code with the kids app on a trusted device.';

  @override
  String get kidsEnrollWaitingDevice =>
      'Waiting for the kids device to connect…';

  @override
  String get kidsEnrollKeepWaiting => 'Done — keep waiting for device';

  @override
  String get kidsWaitingForDevice => 'Waiting for device';

  @override
  String get kidsMarkActive => 'Mark as linked';

  @override
  String get kidsDraftSection => 'WAITING TO LINK';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageDutch => 'Nederlands';

  @override
  String get settingsLanguageChoose => 'Choose language';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonSend => 'Send';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonCloseAction => 'Close';

  @override
  String get commonExporting => 'Exporting…';

  @override
  String get commonImporting => 'Importing…';

  @override
  String get commonNone => 'None';

  @override
  String get commonEveryone => 'Everyone';

  @override
  String get commonTitle => 'Title';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonContent => 'Content';

  @override
  String get commonLow => 'Low';

  @override
  String get commonMedium => 'Medium';

  @override
  String get commonHigh => 'High';

  @override
  String get commonPrivate => 'Private';

  @override
  String get commonShared => 'Shared';

  @override
  String get commonKids => 'Kids';

  @override
  String get commonFamilyMember => 'Family member';

  @override
  String get commonReminder => 'Reminder';

  @override
  String get commonTime => 'Time';

  @override
  String get commonCategory => 'Category';

  @override
  String get commonPriority => 'Priority';

  @override
  String get commonNoCategory => 'No category';

  @override
  String commonSaveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String commonDeleteError(String error) {
    return 'Error deleting: $error';
  }

  @override
  String relativeWeeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String get dateToday => 'Today';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateDaysOverdue(int count) {
    return '${count}d overdue';
  }

  @override
  String dateInDays(int count) {
    return 'In $count days';
  }

  @override
  String dateInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count hours',
      one: 'In 1 hour',
    );
    return '$_temp0';
  }

  @override
  String dateTonightTime(String time) {
    return 'Tonight $time';
  }

  @override
  String dateTodayTime(String time) {
    return 'Today $time';
  }

  @override
  String dateYesterdayTime(String time) {
    return 'Yesterday $time';
  }

  @override
  String dateTomorrowTime(String time) {
    return 'Tomorrow $time';
  }

  @override
  String get dateWeekdayMonday => 'Monday';

  @override
  String get dateWeekdayTuesday => 'Tuesday';

  @override
  String get dateWeekdayWednesday => 'Wednesday';

  @override
  String get dateWeekdayThursday => 'Thursday';

  @override
  String get dateWeekdayFriday => 'Friday';

  @override
  String get dateWeekdaySaturday => 'Saturday';

  @override
  String get dateWeekdaySunday => 'Sunday';

  @override
  String get dateWeekdayShortMonday => 'Mon';

  @override
  String get dateWeekdayShortTuesday => 'Tue';

  @override
  String get dateWeekdayShortWednesday => 'Wed';

  @override
  String get dateWeekdayShortThursday => 'Thu';

  @override
  String get dateWeekdayShortFriday => 'Fri';

  @override
  String get dateWeekdayShortSaturday => 'Sat';

  @override
  String get dateWeekdayShortSunday => 'Sun';

  @override
  String reminderWhyHabitTime(int count, String weekday) {
    return 'You did this task $count× on $weekday';
  }

  @override
  String reminderWhyHabitInterval(int median, int daysSince) {
    return 'About every $median days, last $daysSince days ago';
  }

  @override
  String reminderWhyKeyword(String keyword) {
    return 'Matches \"$keyword\" in the title';
  }

  @override
  String get reminderWhyCategorySchool =>
      'School tasks are usually planned in the morning';

  @override
  String get reminderWhyCategoryHousehold =>
      'Household tasks are often planned on weekends';

  @override
  String get reminderWhyCategoryHealth =>
      'Health tasks are often reminded in the morning';

  @override
  String get reminderWhyCategoryAdmin =>
      'Admin tasks are often planned during the day';

  @override
  String get reminderWhyDefaultMorning => 'Default morning reminder';

  @override
  String get reminderWhyEvening => 'Quick evening reminder';

  @override
  String get reminderWhyTomorrowEvening => 'Reminder tomorrow evening';

  @override
  String get reminderWhyQuick => 'Quick reminder';

  @override
  String get dateMonthJan => 'Jan';

  @override
  String get dateMonthFeb => 'Feb';

  @override
  String get dateMonthMar => 'Mar';

  @override
  String get dateMonthApr => 'Apr';

  @override
  String get dateMonthMay => 'May';

  @override
  String get dateMonthJun => 'Jun';

  @override
  String get dateMonthJul => 'Jul';

  @override
  String get dateMonthAug => 'Aug';

  @override
  String get dateMonthSep => 'Sep';

  @override
  String get dateMonthOct => 'Oct';

  @override
  String get dateMonthNov => 'Nov';

  @override
  String get dateMonthDec => 'Dec';

  @override
  String get connNotConnected => 'Not connected';

  @override
  String connNotConnectedSince(String when) {
    return 'Not connected since $when';
  }

  @override
  String get connUnknownNoSync => 'Connection unknown (no sync)';

  @override
  String connStale(String when) {
    return 'Connection stale ($when)';
  }

  @override
  String get connConnected => 'Connected';

  @override
  String connConnectedSince(String when) {
    return 'Connected ($when)';
  }

  @override
  String tasksAmbientLoadOpen(int count) {
    return '$count open';
  }

  @override
  String get tasksAmbientLoadUnknown => '—';

  @override
  String get notifChannelName => 'Task reminders';

  @override
  String get notifChannelDesc => 'Reminders for tasks and assignments';

  @override
  String get notifReminderTitle => 'Reminder';

  @override
  String get backupNoVault => 'No vault on this device.';

  @override
  String backupSaved(String path) {
    return 'Backup saved: $path';
  }

  @override
  String backupExportError(String error) {
    return 'Error exporting: $error';
  }

  @override
  String get backupVerifyTitle => 'Verify recovery phrase';

  @override
  String get backupVerifyBody =>
      'Enter your 12 words. We will not show the phrase; we only check that it matches.';

  @override
  String get backupVerifyOk => 'The recovery phrase matches.';

  @override
  String get backupVerifyMismatch =>
      'This recovery phrase does not belong to this vault.';

  @override
  String get backupRevealTitle => 'Recovery phrase';

  @override
  String get backupRevealMissing =>
      'We cannot show the words again on this device. Use your paper copy, or restore the vault with the 12 words.';

  @override
  String get backupImportTitle => 'Import backup';

  @override
  String get backupImportBody => 'Enter the 12 words for this .kvault file.';

  @override
  String get backupImportOtherVaultBody =>
      'This backup uses a different vault. Enter its 12 words.';

  @override
  String get backupImportOverwriteTitle => 'Replace all data?';

  @override
  String get backupImportOverwriteBody =>
      'This deletes everything on this phone and puts the backup in its place. Newer data on this device is lost.';

  @override
  String get backupImportOverwriteConfirm => 'Replace';

  @override
  String get backupImportWrongPhrase =>
      'Wrong recovery phrase for this backup.';

  @override
  String get backupCouldNotReadFile => 'Could not read the file.';

  @override
  String get backupRestored => 'Backup restored successfully.';

  @override
  String backupInvalidFile(String error) {
    return 'Invalid backup file: $error';
  }

  @override
  String backupImportError(String error) {
    return 'Error importing: $error';
  }

  @override
  String get backupRestoring => 'Restoring backup…';

  @override
  String get webdavSetupTitle => 'Set up WebDAV';

  @override
  String get webdavUrlRequired => 'Enter the server URL';

  @override
  String get webdavUsernameRequired => 'Enter the username';

  @override
  String get webdavPasswordRequired => 'Enter the password';

  @override
  String get webdavTestConnection => 'Test connection';

  @override
  String get webdavTestingConnection => 'Testing connection…';

  @override
  String get webdavConnectionOk => 'Connection succeeded';

  @override
  String get webdavErrorAuth => 'Wrong username or password.';

  @override
  String get webdavErrorNoWebDav =>
      'This server does not appear to support WebDAV. Check the URL (for Nextcloud often …/remote.php/dav).';

  @override
  String get webdavErrorTimeout =>
      'Connection timed out. Check the server URL and your network.';

  @override
  String get webdavErrorUnreachable =>
      'Could not reach the server. Check the URL and your network.';

  @override
  String get webdavTestFirst => 'Test the connection before saving.';

  @override
  String get webdavCreateVaultFirst => 'Create a vault before linking WebDAV.';

  @override
  String get webdavPhraseMismatchServer =>
      'This server already has a vault that does not match your recovery phrase.';

  @override
  String get webdavConfigSaved => 'WebDAV configuration saved.';

  @override
  String webdavSaveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String get webdavMigrationTitle => 'Existing data found';

  @override
  String get webdavMigrationIntro =>
      'The WebDAV server already has encrypted files:';

  @override
  String webdavMigrationTaskFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '  • $count task files',
      one: '  • 1 task file',
    );
    return '$_temp0';
  }

  @override
  String webdavMigrationNoteFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '  • $count note files',
      one: '  • 1 note file',
    );
    return '$_temp0';
  }

  @override
  String get webdavMigrationChoose =>
      'These files are encrypted with a vault. Choose how to continue:';

  @override
  String get webdavMigrationCleanOption =>
      '1. Clean install — remove the old files on the server and start fresh.';

  @override
  String get webdavMigrationImportOption =>
      '2. Import backup — replaces all data on this phone with a .kvault file.';

  @override
  String get webdavMigrationClean => 'Clean install';

  @override
  String get webdavMigrationImport => 'Import backup';

  @override
  String get webdavBackupRestoredSync =>
      'Backup restored. The app will now sync with the server.';

  @override
  String webdavRestoreError(String error) {
    return 'Error restoring backup: $error';
  }

  @override
  String webdavMigrationCheckFailed(String error) {
    return 'Migration check failed: $error';
  }

  @override
  String webdavFilesDeleted(int count) {
    return '$count files deleted.';
  }

  @override
  String webdavCleanupError(String error) {
    return 'Error cleaning up: $error';
  }

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksCompletedTooltip => 'Completed tasks';

  @override
  String get tasksSyncFailed => 'Sync failed, tap to retry.';

  @override
  String get tasksSyncing => 'Syncing';

  @override
  String get syncStatusTitle => 'Sync status';

  @override
  String get syncStatusIdle => 'Up to date';

  @override
  String get syncStatusSyncing => 'Syncing…';

  @override
  String get syncStatusError => 'Sync failed';

  @override
  String get syncStatusRetry => 'Retry sync';

  @override
  String get syncStatusNeverSynced => 'Not synced yet';

  @override
  String syncStatusLastSuccess(String when) {
    return 'Last success: $when';
  }

  @override
  String get syncErrorTimeout =>
      'Sync timed out. Check your connection and try again.';

  @override
  String get syncErrorAuth =>
      'WebDAV login failed. Check username and password.';

  @override
  String get syncErrorNetwork =>
      'Could not reach the server. Check your connection.';

  @override
  String get syncErrorGeneric =>
      'Sync failed. Try again or check WebDAV settings.';

  @override
  String get settingsSyncHealthIdle => 'Synced';

  @override
  String get settingsSyncHealthSyncing => 'Syncing…';

  @override
  String get settingsSyncHealthError => 'Sync error — tap for details';

  @override
  String get settingsSyncHealthNever => 'Not synced yet';

  @override
  String get settingsStartFamily => 'Start family';

  @override
  String get settingsStartFamilyHint =>
      'Guided setup: WebDAV, members, and kids';

  @override
  String get familySetupPromptTitle => 'Set up your family?';

  @override
  String get familySetupPromptBody =>
      'WebDAV sync is on, but you have not linked a family yet. Shared notes, kids tasks, and multi-device family sync need a family key.';

  @override
  String get familySetupPromptIgnore => 'Ignore';

  @override
  String familySetupPromptRemind(int days) {
    return 'Remind in $days days';
  }

  @override
  String get familySetupPromptStart => 'Start guide';

  @override
  String get webdavJoinFamilyTitle => 'Join family?';

  @override
  String get webdavJoinFamilyBody =>
      'Someone is already using Kinetic on this folder.';

  @override
  String webdavJoinFamilyMembersOne(String name) {
    return '$name is already here.';
  }

  @override
  String webdavJoinFamilyMembersMany(int count) {
    return 'Already here:';
  }

  @override
  String get webdavJoinFamilySharedOnly => 'Family data found.';

  @override
  String get webdavJoinFamilyLink => 'Link now';

  @override
  String get webdavJoinFamilyLater => 'Not now';

  @override
  String get webdavFamilyRestored => 'Family key restored from this server.';

  @override
  String get wizardTitle => 'Start family';

  @override
  String get wizardStepWebDav => 'Connect WebDAV';

  @override
  String get wizardStepFamily => 'Create or join family';

  @override
  String get wizardStepInvite => 'Invite a family member';

  @override
  String get wizardStepKids => 'Enroll a kid';

  @override
  String get wizardStepDone => 'You\'re set';

  @override
  String get wizardSkip => 'Skip';

  @override
  String get wizardNext => 'Continue';

  @override
  String get wizardDone => 'Done';

  @override
  String get wizardInviteHint =>
      'Share your family key with QR or hold phones close (tap to link).';

  @override
  String get wizardKidsPasswordHint =>
      'The child still needs the WebDAV password — it is not in the QR. Share it separately.';

  @override
  String get wizardFirstSuccessHint =>
      'Try a shared note or assign a kid task to see sync in action.';

  @override
  String get wizardOpenTasks => 'Go to tasks';

  @override
  String get bleShareTitle => 'Tap to share';

  @override
  String get bleJoinTitle => 'Tap to join';

  @override
  String get bleSearching => 'Looking for a nearby Kinetic phone…';

  @override
  String get bleAdvertising => 'Ready — hold the other phone close';

  @override
  String get bleConfirmTitle => 'Allow link?';

  @override
  String bleConfirmBody(String name) {
    return '$name wants to join your family.';
  }

  @override
  String get bleConfirmAllow => 'Allow';

  @override
  String get bleConfirmDeny => 'Deny';

  @override
  String get bleSuccess => 'Linked successfully';

  @override
  String get bleFailed => 'Could not link over Bluetooth. Try QR instead.';

  @override
  String get bleUnavailable => 'Bluetooth is unavailable. Use QR code instead.';

  @override
  String get bleTimeout => 'No nearby phone found. Move closer or use QR.';

  @override
  String get tasksForYou => 'For you';

  @override
  String tasksForFamilyMember(String name) {
    return 'For $name';
  }

  @override
  String tasksFromFamilyMember(String name) {
    return 'From $name';
  }

  @override
  String get tasksForFamily => 'For family';

  @override
  String get tasksFromFamily => 'From family';

  @override
  String get familyMemberGenericName => 'family member';

  @override
  String get tasksAccept => 'Accept';

  @override
  String tasksXpResetTitle(String name) {
    return 'Reset XP for $name?';
  }

  @override
  String get tasksXpResetBody =>
      'This resets the XP counter to 0. The assignments stay.';

  @override
  String get tasksXpResetAction => 'Reset';

  @override
  String tasksXpResetDone(String name) {
    return 'XP reset for $name';
  }

  @override
  String tasksXpResetError(String error) {
    return 'Error resetting: $error';
  }

  @override
  String get tasksLoadKidsError => 'Error loading kids assignments';

  @override
  String get tasksNoKidsAssignments => 'No assignments';

  @override
  String get tasksResetXp => 'Reset XP';

  @override
  String tasksDoneOn(int day, int month) {
    return 'Done on $day/$month';
  }

  @override
  String get tasksCompletedTitle => 'Completed tasks';

  @override
  String get tasksDeleteAll => 'Delete all';

  @override
  String get tasksDeleteCompletedTitle => 'Delete completed tasks';

  @override
  String get tasksDeleteCompletedBody =>
      'Are you sure you want to delete all completed tasks? This cannot be undone.';

  @override
  String get tasksAllDone => 'All done!';

  @override
  String get tasksNoOpenTasks => 'You have no open tasks';

  @override
  String get tasksNoPersonalOpen => 'No personal tasks open';

  @override
  String get tasksNoCompleted => 'No completed tasks';

  @override
  String get tasksNoCompletedHint => 'Completed tasks appear here';

  @override
  String get tasksAssignment => 'Assignment';

  @override
  String get taskDeleteTitle => 'Delete task?';

  @override
  String taskDeleteBody(String title) {
    return '\"$title\" will be permanently deleted. This cannot be undone.';
  }

  @override
  String get taskForwardTitle => 'Forward task';

  @override
  String get taskAssignmentCreated => 'Assignment created ✓';

  @override
  String get taskNoConnectedFamily => 'No connected family members or kids';

  @override
  String get taskStaleConnectionTitle => 'Connection stale';

  @override
  String taskStaleFamilyMemberBody(String status) {
    return 'This family member was last seen $status. Send anyway?';
  }

  @override
  String taskStaleKidBody(String name, String status) {
    return '$name was last seen $status. Send anyway?';
  }

  @override
  String get taskSendAnyway => 'Send anyway';

  @override
  String get familyMemberPickerTitle => 'Send to which family member?';

  @override
  String taskSendToFamilyMemberTitle(String name) {
    return 'Send to $name?';
  }

  @override
  String taskSendToFamilyMemberBody(String title, String name) {
    return '\"$title\" will be sent as a proposal to $name and removed from your list once they accept it.';
  }

  @override
  String taskSendToKidTitle(String name) {
    return 'Send to $name?';
  }

  @override
  String get taskSendToKidBody =>
      'The task disappears from your list once the child completes it.';

  @override
  String taskSendToKidLead(String title, String name) {
    return '\"$title\" will be sent as an assignment to $name.';
  }

  @override
  String get taskSendToEveryoneSubtitle => 'Visible to all enrolled kids';

  @override
  String get taskSendToEveryoneBody =>
      'Every enrolled child will see this assignment. It leaves your list once any child completes it.';

  @override
  String get taskXpReward => 'XP reward:';

  @override
  String get taskNameHint => 'Task name';

  @override
  String get taskAddTime => 'Add time';

  @override
  String get taskAddCategory => 'Add category';

  @override
  String get taskRepeat => 'Repeat';

  @override
  String get taskForward => 'Forward';

  @override
  String get taskAssignToLabel => 'Assign to';

  @override
  String get taskAssignToMe => 'Me';

  @override
  String get taskRecurrenceNone => 'No recurrence';

  @override
  String get taskRecurrenceDaily => 'Daily';

  @override
  String get taskRecurrenceWeekdays => 'Weekdays';

  @override
  String get taskRecurrenceWeekly => 'Weekly';

  @override
  String get taskRecurrenceBiweekly => 'Biweekly';

  @override
  String get taskRecurrenceMonthly => 'Monthly';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesTabPrivate => 'Private';

  @override
  String get notesTabShared => 'Shared';

  @override
  String get notesNewTooltip => 'New note';

  @override
  String get notesLoadError => 'Error loading notes';

  @override
  String get notesEmptyShared => 'No shared notes';

  @override
  String get notesEmptyPrivate => 'No private notes';

  @override
  String get notesEmpty => 'No notes';

  @override
  String get notesEmptySharedHint =>
      'Notes shared with family members appear here';

  @override
  String get notesEmptyPrivateHint => 'Your private notes appear here';

  @override
  String get notesEmptyHint => 'Private and shared notes appear here';

  @override
  String get notesSaved => 'Note saved';

  @override
  String get notesLastModified => 'Last modified';

  @override
  String get notesSharedBadge => 'Shared';

  @override
  String get notesTitleRequired => 'Title is required';

  @override
  String get notesDeleteTitle => 'Delete note?';

  @override
  String get notesDeleteBody =>
      'The note moves to the trash. You can restore it from there.';

  @override
  String get notesTrashTooltip => 'Deleted notes';

  @override
  String get notesTrashTitle => 'Deleted notes';

  @override
  String get notesNoTrash => 'No deleted notes';

  @override
  String get notesNoTrashHint => 'Deleted notes appear here';

  @override
  String get notesRestore => 'Restore';

  @override
  String get notesEmptyTrashTitle => 'Empty trash?';

  @override
  String get notesEmptyTrashBody =>
      'Deleted notes will be permanently removed. This cannot be undone.';

  @override
  String get notesSharedWithFamily => 'Shared with family';

  @override
  String get notesShareAllAdults => 'All family members';

  @override
  String get notesSharePickAdults => 'Choose who can see this note';

  @override
  String get notesShareAudienceHint => 'Shared with selected members';

  @override
  String notesSharedWithNames(String names) {
    return 'With $names';
  }

  @override
  String get notesHideContent => 'Require unlock';

  @override
  String get notesHideContentHint =>
      'Hides previews and asks for biometrics or PIN to open. The note body still syncs via WebDAV unless “Keep on this device only” is on.';

  @override
  String get notesLocalOnly => 'Keep on this device only';

  @override
  String get notesLocalOnlyHint =>
      'Title and body never upload to WebDAV. Cannot share with family.';

  @override
  String get notesLocalOnlyBadge => 'This device';

  @override
  String get notesLinkedTasks => 'Linked tasks';

  @override
  String get notesLinkTask => 'Link tasks';

  @override
  String get notesLinkTaskEmpty => 'No open tasks to link';

  @override
  String get notesFromTemplate => 'New from template';

  @override
  String get notesTemplateMeeting => 'Meeting notes';

  @override
  String get notesTemplateMeetingBody =>
      '## Attendees\n\n## Agenda\n- \n\n## Actions\n- ';

  @override
  String get notesTemplateShopping => 'Shopping list';

  @override
  String get notesTemplateShoppingBody => '- \n- \n- ';

  @override
  String get notesTemplateJournal => 'Journal';

  @override
  String get notesTemplateJournalBody => '## Today\n\n## Grateful for\n- ';

  @override
  String get taskLinkedNotes => 'Linked notes';

  @override
  String get notesUnlockReason => 'Unlock this note';

  @override
  String get notesUnlockFailed => 'Could not unlock the note';

  @override
  String get notesHideNeedsDeviceLock =>
      'Turn on a screen lock on this device to require unlock';

  @override
  String get notesBodyHint => 'Write a note…';

  @override
  String get notesMdBold => 'Bold';

  @override
  String get notesMdItalic => 'Italic';

  @override
  String get notesMdHeading => 'Heading';

  @override
  String get notesMdBullet => 'Bullet list';

  @override
  String get notesMdCheckbox => 'Checkbox';

  @override
  String get notesMdLink => 'Link';

  @override
  String get notesUnsavedTitle => 'Unsaved changes';

  @override
  String get notesUnsavedBody => 'Do you want to save your changes?';

  @override
  String get notesDiscard => 'Discard';

  @override
  String get notesLockedBadge => 'Locked';

  @override
  String get suggestWebDavRequired => 'Link WebDAV first to send a suggestion.';

  @override
  String suggestFamilyMemberSeesTitle(String name) {
    return 'What $name sees';
  }

  @override
  String get suggestFamilyMemberSeesGeneric =>
      'Intentionally generic — no private titles or notes.';

  @override
  String get suggestFamilyMemberSeesFull =>
      'The title and any notes from this suggestion will be included.';

  @override
  String get suggestSend => 'Send';

  @override
  String suggestSent(String name) {
    return 'Suggestion sent to $name';
  }

  @override
  String get suggestReasonHabit => 'Habit';

  @override
  String get suggestReasonFamilyMember => 'Family complement';

  @override
  String get suggestReasonSeasonal => 'Seasonal';

  @override
  String get suggestReasonLoadBalance => 'Load balance';

  @override
  String get suggestReasonStale => 'Open task';

  @override
  String get suggestReasonCalendar => 'Calendar';

  @override
  String get suggestReasonCategorize => 'Category';

  @override
  String suggestCategorizeTitle(int count, String category) {
    return 'Set category $category on $count tasks?';
  }

  @override
  String suggestCategorizeExplanation(int count) {
    return 'These open tasks have no category yet. Accept only sets the label.';
  }

  @override
  String get suggestLoadBalanceTitleHousehold =>
      'Can you pick up something around the house this week?';

  @override
  String get suggestLoadBalanceTitleHealth =>
      'Can you pick up something around care or health this week?';

  @override
  String get suggestLoadBalanceTitleAdmin =>
      'Can you pick up something in admin this week?';

  @override
  String get suggestLoadBalanceTitleSchool =>
      'Can you pick up something around school this week?';

  @override
  String get suggestLoadBalanceTitleFinance =>
      'Can you pick up something in finances this week?';

  @override
  String get suggestLoadBalanceTitleOther =>
      'Can you pick something up this week?';

  @override
  String suggestLoadBalanceExplanation(int count, String category) {
    return 'You have $count open tasks in $category. The suggestion is intentionally generic.';
  }

  @override
  String suggestLoadBalanceExplanationGeneric(String category) {
    return 'You have several open tasks in $category. The suggestion is intentionally generic.';
  }

  @override
  String get suggestFamilyMemberTitleSchool =>
      'School run or childcare this week?';

  @override
  String get suggestFamilyMemberExplanationSchool =>
      'Based on your tasks (without private details), school looks like a theme this week. Your family member sees this.';

  @override
  String get suggestFamilyMemberTitleHousehold =>
      'Can you pick up something around the house this week?';

  @override
  String get suggestFamilyMemberExplanationHousehold =>
      'You have several household tasks open. The suggestion is intentionally generic.';

  @override
  String get suggestFamilyMemberTitleHealth =>
      'Something around care or health to pick up?';

  @override
  String get suggestFamilyMemberExplanationHealth =>
      'Something around care is going on. Your family member only sees this generic question.';

  @override
  String get suggestFamilyMemberTitleSport =>
      'Sports bag or training this week?';

  @override
  String get suggestFamilyMemberExplanationSport =>
      'Based on your tasks, sport looks like a theme. No private details.';

  @override
  String get suggestFamilyMemberTitleAdmin => 'An admin chore this week?';

  @override
  String get suggestFamilyMemberExplanationAdmin =>
      'There is admin work open. The suggestion does not name a concrete task.';

  @override
  String get suggestCalendarTaxTitle => 'Check tax return';

  @override
  String get suggestCalendarTaxExplanation =>
      'March — time to check the tax return.';

  @override
  String get suggestCalendarSchoolTitle => 'Prepare school supplies';

  @override
  String get suggestCalendarSchoolExplanation =>
      'August — prepare school supplies for the new year.';

  @override
  String get suggestCalendarChristmasTitle => 'Prepare for Christmas';

  @override
  String get suggestCalendarChristmasExplanation =>
      'December — prepare for Christmas.';

  @override
  String suggestHabitRepeatExplanation(
    String title,
    int median,
    int daysSince,
  ) {
    return 'You did \"$title\" about every $median days. Last time: $daysSince days ago.';
  }

  @override
  String suggestHabitOnceExplanation(String title, int daysSince) {
    return 'You did \"$title\" $daysSince days ago. Schedule again?';
  }

  @override
  String suggestSeasonalExplanation(String title, String month) {
    return 'You completed \"$title\" in $month last year.';
  }

  @override
  String suggestStaleExplanation(String title, int days) {
    return '\"$title\" has been open for $days days without a reminder.';
  }

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get categoryHousehold => 'Household';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryAdmin => 'Admin';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryTitle => 'Category';

  @override
  String get categoryNewHint => 'New category';

  @override
  String get categoryNewAction => 'New category…';

  @override
  String get categoryRename => 'Rename category';

  @override
  String get categoryRenameHint => 'Category name';

  @override
  String get suggestionsTitle => 'Suggestions';

  @override
  String get suggestionsSubtitle => 'Handy tasks to consider today';

  @override
  String suggestionsProposedByFamilyMember(String name) {
    return 'Suggested by $name';
  }

  @override
  String get tasksDecline => 'Decline';

  @override
  String get kidsSectionTitle => 'Kids';

  @override
  String get kidsAllFilter => 'All kids';

  @override
  String kidsOpenTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open tasks',
      one: '1 open task',
    );
    return '$_temp0';
  }

  @override
  String get kidsDeleteTaskTitle => 'Remove kids task?';

  @override
  String kidsDeleteTaskBody(String title) {
    return '\"$title\" will be removed from the kids app.';
  }

  @override
  String get kidsPendingVerification => 'Waiting for confirmation';

  @override
  String kidsPendingExpandHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count waiting — open to confirm',
      one: '1 waiting — open to confirm',
    );
    return '$_temp0';
  }

  @override
  String get kidsAcceptCompletion => 'Accept';

  @override
  String get kidsRejectCompletion => 'Send back';

  @override
  String kidsXpProgress(int earned, int target) {
    return '$earned / $target XP';
  }

  @override
  String kidsXpTotal(int xp) {
    return '$xp XP';
  }

  @override
  String get kidsGoalSet => 'Set goal';

  @override
  String get kidsGoalEdit => 'Edit goal';

  @override
  String get kidsGoalRename => 'Rename goal';

  @override
  String get kidsGoalRemove => 'Remove goal';

  @override
  String get kidsGoalReset => 'Reset XP';

  @override
  String get kidsGoalTitleLabel => 'Goal';

  @override
  String get kidsGoalTitleHint => 'e.g. New bike';

  @override
  String get kidsGoalTargetLabel => 'XP needed';

  @override
  String get kidsGoalSave => 'Save goal';

  @override
  String get kidsGoalRemoved => 'Goal removed';

  @override
  String get kidsGoalSaved => 'Goal saved';

  @override
  String kidsGoalResetTitle(String name) {
    return 'Reset XP for $name?';
  }

  @override
  String get kidsGoalResetBody =>
      'XP goes back to 0 and completed kids tasks are removed. The goal title and target stay.';

  @override
  String kidsGoalResetDone(String name) {
    return 'XP reset for $name';
  }

  @override
  String get kidsCreateTask => 'Create task';

  @override
  String get kidsCreateForEveryone => 'Create for everyone';

  @override
  String kidsCreateForName(String name) {
    return 'Task for $name';
  }

  @override
  String get kidsCreateForEveryoneHint => 'Task for everyone';

  @override
  String kidsXpAppliesToNamed(String names) {
    return 'Only for $names';
  }

  @override
  String get kidsXpAppliesToEnabled => 'Only for kids with XP & goals on';

  @override
  String get kidsXpAndGoals => 'XP & goals';

  @override
  String get kidsXpAndGoalsSubtitle =>
      'Show XP rewards and goals for this child';

  @override
  String get kidsWeekOverviewTitle => 'This week';

  @override
  String get kidsWeekOverviewLegend => 'Due · done';

  @override
  String kidsWeekDayA11y(String weekday, int due, int done) {
    return '$weekday, $due due, $done done';
  }

  @override
  String get kidsOfflineBanner =>
      'Offline — kids tasks sync when WebDAV is back';

  @override
  String get kidsPendingSync => 'Waiting to sync';

  @override
  String get tasksSyncOffline => 'Offline — changes sync later';

  @override
  String get snoozeTitle => 'Snooze reminder';

  @override
  String get snooze10min => '10 minutes';

  @override
  String get snooze1hour => '1 hour';

  @override
  String get snooze3hours => '3 hours';

  @override
  String get snoozeTomorrowMorning => 'Tomorrow 09:00';

  @override
  String get snoozeCustom => 'Pick a time…';

  @override
  String get snoozeDone => 'Reminder snoozed';

  @override
  String get reminderDone => 'Task completed';

  @override
  String get noteReminderCleared => 'Reminder cleared';

  @override
  String get quickAddHint => 'New task…';

  @override
  String get quickAddMoreOptions => 'More options';

  @override
  String get notesQuickAddHint => 'New note…';

  @override
  String get timeInvalid => 'Enter a valid time (00:00 – 23:59).';

  @override
  String get timeOk => 'OK';
}

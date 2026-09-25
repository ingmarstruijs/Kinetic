import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get commonImport;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'(unknown)'**
  String get commonUnknown;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get themeLight;

  /// No description provided for @themeCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get themeCalm;

  /// No description provided for @themeNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get themeNight;

  /// No description provided for @themeLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Light blue'**
  String get themeLightDesc;

  /// No description provided for @themeCalmDesc.
  ///
  /// In en, this message translates to:
  /// **'Warm sand with terracotta accents'**
  String get themeCalmDesc;

  /// No description provided for @themeNightDesc.
  ///
  /// In en, this message translates to:
  /// **'OLED black'**
  String get themeNightDesc;

  /// No description provided for @themeChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get themeChoose;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsSectionSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSectionSync;

  /// No description provided for @linkWebTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Web'**
  String get linkWebTitle;

  /// No description provided for @linkWebSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open tasks in a browser on the same Wi‑Fi'**
  String get linkWebSettingsSubtitle;

  /// No description provided for @linkWebIntro.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR (or open the URL) on a computer on the same Wi‑Fi. Your vault keys stay on this phone — the browser only sees decrypted tasks over a short-lived session.'**
  String get linkWebIntro;

  /// No description provided for @linkWebPickIp.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi address'**
  String get linkWebPickIp;

  /// No description provided for @linkWebKeepAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep this screen open and the phone awake while using Link Web.'**
  String get linkWebKeepAwake;

  /// No description provided for @linkWebCopyUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get linkWebCopyUrl;

  /// No description provided for @linkWebCopied.
  ///
  /// In en, this message translates to:
  /// **'URL copied'**
  String get linkWebCopied;

  /// No description provided for @linkWebRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke & stop'**
  String get linkWebRevoke;

  /// No description provided for @linkWebStart.
  ///
  /// In en, this message translates to:
  /// **'Start bridge'**
  String get linkWebStart;

  /// No description provided for @linkWebNewSession.
  ///
  /// In en, this message translates to:
  /// **'New QR'**
  String get linkWebNewSession;

  /// No description provided for @settingsWebDavConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure WebDAV'**
  String get settingsWebDavConfigure;

  /// No description provided for @settingsWebDavConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get settingsWebDavConnected;

  /// No description provided for @settingsWebDavConnectHint.
  ///
  /// In en, this message translates to:
  /// **'Connect to a Nextcloud or WebDAV server'**
  String get settingsWebDavConnectHint;

  /// No description provided for @settingsWebDavTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off WebDAV sync'**
  String get settingsWebDavTurnOff;

  /// No description provided for @settingsWebDavTurnOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off WebDAV sync?'**
  String get settingsWebDavTurnOffTitle;

  /// No description provided for @settingsWebDavTurnOffBody.
  ///
  /// In en, this message translates to:
  /// **'Sync with the server stops. You also lose family linking, shared notes, kids tasks, and multi-device sync. Your private tasks and notes stay on this device. The recovery phrase still unlocks your local vault.'**
  String get settingsWebDavTurnOffBody;

  /// No description provided for @settingsWebDavTurnOffConfirm.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get settingsWebDavTurnOffConfirm;

  /// No description provided for @settingsWebDavTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'WebDAV sync turned off.'**
  String get settingsWebDavTurnedOff;

  /// No description provided for @settingsSectionFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get settingsSectionFamily;

  /// No description provided for @settingsFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Family member'**
  String get settingsFamilyMember;

  /// No description provided for @settingsFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get settingsFamilyMembers;

  /// No description provided for @settingsFamilyMemberLinked.
  ///
  /// In en, this message translates to:
  /// **'Family member linked'**
  String get settingsFamilyMemberLinked;

  /// No description provided for @settingsFamilyMemberLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Link with another family member'**
  String get settingsFamilyMemberLinkHint;

  /// No description provided for @settingsKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get settingsKids;

  /// No description provided for @settingsKidsParticipation.
  ///
  /// In en, this message translates to:
  /// **'Kids tasks on this device'**
  String get settingsKidsParticipation;

  /// No description provided for @settingsKidsParticipationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When off, this device cannot see, create, assign, or verify kids tasks'**
  String get settingsKidsParticipationSubtitle;

  /// No description provided for @settingsKidsLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Link the kids app'**
  String get settingsKidsLinkHint;

  /// No description provided for @settingsKidsEnrolledCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 kid linked} other{{count} kids linked}}'**
  String settingsKidsEnrolledCount(int count);

  /// No description provided for @settingsSectionVault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get settingsSectionVault;

  /// No description provided for @settingsVerifyPhrase.
  ///
  /// In en, this message translates to:
  /// **'Verify recovery phrase'**
  String get settingsVerifyPhrase;

  /// No description provided for @settingsVerifyPhraseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check that you still know the 12 words. We will not show them.'**
  String get settingsVerifyPhraseSubtitle;

  /// No description provided for @settingsSectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settingsSectionBackup;

  /// No description provided for @settingsExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExportBackup;

  /// No description provided for @settingsExportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted .kvault file. The recovery phrase is not included.'**
  String get settingsExportBackupSubtitle;

  /// No description provided for @settingsImportBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get settingsImportBackup;

  /// No description provided for @settingsImportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replaces all data on this phone'**
  String get settingsImportBackupSubtitle;

  /// No description provided for @notifServiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Notification service failed to start: {error}'**
  String notifServiceFailed(String error);

  /// No description provided for @notifDisabledBanner.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Turn them on in Settings to receive reminders.'**
  String get notifDisabledBanner;

  /// No description provided for @notifExactAlarmBanner.
  ///
  /// In en, this message translates to:
  /// **'Exact reminders are disabled. Allow \"Alarms & reminders\" for precise times.'**
  String get notifExactAlarmBanner;

  /// No description provided for @familyKeyScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan family key'**
  String get familyKeyScanTitle;

  /// No description provided for @familyKeyScanHint.
  ///
  /// In en, this message translates to:
  /// **'Point at the family member\'s QR code'**
  String get familyKeyScanHint;

  /// No description provided for @familyKeyEnterPhrase.
  ///
  /// In en, this message translates to:
  /// **'Enter phrase'**
  String get familyKeyEnterPhrase;

  /// No description provided for @familyKeyFound.
  ///
  /// In en, this message translates to:
  /// **'Key found'**
  String get familyKeyFound;

  /// No description provided for @familyKeyLinkMember.
  ///
  /// In en, this message translates to:
  /// **'Family member'**
  String get familyKeyLinkMember;

  /// No description provided for @familyKeyServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get familyKeyServer;

  /// No description provided for @familyKeyFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get familyKeyFingerprint;

  /// No description provided for @familyKeyServerMismatch.
  ///
  /// In en, this message translates to:
  /// **'The server in the invite ({scanned}) does not match your WebDAV server ({current}). Family sync only works when everyone uses the same server — linking is blocked.'**
  String familyKeyServerMismatch(String scanned, String current);

  /// No description provided for @familyKeyConfirmLinkMember.
  ///
  /// In en, this message translates to:
  /// **'Is this the right family member? Check the username above.'**
  String get familyKeyConfirmLinkMember;

  /// No description provided for @familyKeyAlreadyPairedWarning.
  ///
  /// In en, this message translates to:
  /// **'You already have a family key. Importing a new one will make data encrypted with the current key unreadable until you sync again.'**
  String get familyKeyAlreadyPairedWarning;

  /// No description provided for @familyKeyEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter family key'**
  String get familyKeyEnterTitle;

  /// No description provided for @familyKeyEnterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter their 12 words. You will then see the fingerprint to verify.'**
  String get familyKeyEnterSubtitle;

  /// No description provided for @familyKeySaved.
  ///
  /// In en, this message translates to:
  /// **'Family key saved.'**
  String get familyKeySaved;

  /// No description provided for @familyKeySaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String familyKeySaveError(String error);

  /// No description provided for @familyKeyInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code: {error}'**
  String familyKeyInvalidQr(String error);

  /// No description provided for @familyKeyShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share family key'**
  String get familyKeyShareTitle;

  /// No description provided for @familyKeyShareLegacyBody.
  ///
  /// In en, this message translates to:
  /// **'Have the family member scan this QR code. This family key is from before the recovery phrase and has no 12 words.'**
  String get familyKeyShareLegacyBody;

  /// No description provided for @familyKeyShareBody.
  ///
  /// In en, this message translates to:
  /// **'Have the family member scan this QR code, or type the 12 words.'**
  String get familyKeyShareBody;

  /// No description provided for @familyKeyShareNoPassword.
  ///
  /// In en, this message translates to:
  /// **'The code does not include the WebDAV password. Check the fingerprint together.'**
  String get familyKeyShareNoPassword;

  /// No description provided for @familyKeyShareNoEntropy.
  ///
  /// In en, this message translates to:
  /// **'No recovery-phrase data on this device. Create a new family key.'**
  String get familyKeyShareNoEntropy;

  /// No description provided for @familyKeyShareFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint  {fingerprint}'**
  String familyKeyShareFingerprint(String fingerprint);

  /// No description provided for @familyKeyLinkMemberScanned.
  ///
  /// In en, this message translates to:
  /// **'Family member has scanned'**
  String get familyKeyLinkMemberScanned;

  /// No description provided for @familyKeyShared.
  ///
  /// In en, this message translates to:
  /// **'Family key shared'**
  String get familyKeyShared;

  /// No description provided for @vaultWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your vault'**
  String get vaultWelcomeTitle;

  /// No description provided for @vaultWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Kinetic Link stores tasks and notes with a 12-word recovery phrase. Write that phrase on paper and keep it safe. We do not store the words on this device.'**
  String get vaultWelcomeBody;

  /// No description provided for @vaultNewVault.
  ///
  /// In en, this message translates to:
  /// **'New vault'**
  String get vaultNewVault;

  /// No description provided for @vaultRestoreVault.
  ///
  /// In en, this message translates to:
  /// **'Restore vault'**
  String get vaultRestoreVault;

  /// No description provided for @vaultCreateVault.
  ///
  /// In en, this message translates to:
  /// **'Create vault'**
  String get vaultCreateVault;

  /// No description provided for @vaultRecoveryPhrase.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase'**
  String get vaultRecoveryPhrase;

  /// No description provided for @vaultConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get vaultConfirm;

  /// No description provided for @vaultWriteWords.
  ///
  /// In en, this message translates to:
  /// **'Write these 12 words on paper and keep them safe. Without this phrase you cannot restore the vault on a new device.'**
  String get vaultWriteWords;

  /// No description provided for @vaultPhraseCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase copied'**
  String get vaultPhraseCopied;

  /// No description provided for @vaultIWroteThemDown.
  ///
  /// In en, this message translates to:
  /// **'I wrote them down'**
  String get vaultIWroteThemDown;

  /// No description provided for @vaultQuizPrompt.
  ///
  /// In en, this message translates to:
  /// **'Fill in the requested words to confirm you saved the phrase.'**
  String get vaultQuizPrompt;

  /// No description provided for @vaultWordN.
  ///
  /// In en, this message translates to:
  /// **'Word {n}'**
  String vaultWordN(int n);

  /// No description provided for @vaultBackToWords.
  ///
  /// In en, this message translates to:
  /// **'Back to the words'**
  String get vaultBackToWords;

  /// No description provided for @vaultQuizMismatch.
  ///
  /// In en, this message translates to:
  /// **'Not all words match. Try again.'**
  String get vaultQuizMismatch;

  /// No description provided for @vaultCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the vault: {error}'**
  String vaultCreateFailed(String error);

  /// No description provided for @vaultCouldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file.'**
  String get vaultCouldNotReadFile;

  /// No description provided for @vaultRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore vault'**
  String get vaultRestoreTitle;

  /// No description provided for @vaultRestoreIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose how to restore the vault. The recovery phrase is the same in both cases.'**
  String get vaultRestoreIntro;

  /// No description provided for @vaultRestoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'From file'**
  String get vaultRestoreFromFile;

  /// No description provided for @vaultRestoreFromWebDav.
  ///
  /// In en, this message translates to:
  /// **'From WebDAV'**
  String get vaultRestoreFromWebDav;

  /// No description provided for @vaultRestoreFromWebDavSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Server, credentials, and 12 words. No file needed.'**
  String get vaultRestoreFromWebDavSubtitle;

  /// No description provided for @vaultRestoreFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get vaultRestoreFileTitle;

  /// No description provided for @vaultRestoreFileBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery phrase, then choose the .kvault file.'**
  String get vaultRestoreFileBody;

  /// No description provided for @vaultChooseFileAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Choose file and restore'**
  String get vaultChooseFileAndRestore;

  /// No description provided for @vaultNoVaultOnServer.
  ///
  /// In en, this message translates to:
  /// **'No vault on this server. Create a new vault or choose a different server.'**
  String get vaultNoVaultOnServer;

  /// No description provided for @vaultPhraseMismatchServer.
  ///
  /// In en, this message translates to:
  /// **'This recovery phrase does not match the vault on this server.'**
  String get vaultPhraseMismatchServer;

  /// No description provided for @vaultRestoreWebDavTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from WebDAV'**
  String get vaultRestoreWebDavTitle;

  /// No description provided for @vaultRestoreWebDavBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your server and enter the same 12 words used when creating the vault.'**
  String get vaultRestoreWebDavBody;

  /// No description provided for @vaultServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get vaultServerUrl;

  /// No description provided for @vaultUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get vaultUsername;

  /// No description provided for @vaultPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get vaultPassword;

  /// No description provided for @vaultUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock vault'**
  String get vaultUnlock;

  /// No description provided for @vaultPhraseFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase (12 words)'**
  String get vaultPhraseFieldLabel;

  /// No description provided for @vaultMigrateTitle.
  ///
  /// In en, this message translates to:
  /// **'New recovery phrase'**
  String get vaultMigrateTitle;

  /// No description provided for @vaultMigrateBody.
  ///
  /// In en, this message translates to:
  /// **'Your current key is random (version 0.2) and cannot become 12 words. Tasks and notes on this device stay. We will create a new recovery phrase. On the next sync, personal files are re-encrypted. The family key stays the same — family members and kids do not need to re-link.'**
  String get vaultMigrateBody;

  /// No description provided for @vaultMigrateActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate new recovery phrase'**
  String get vaultMigrateActivate;

  /// No description provided for @vaultMigrateHeadline.
  ///
  /// In en, this message translates to:
  /// **'Write down these new 12 words. The old key will no longer work for WebDAV or a .kvault.'**
  String get vaultMigrateHeadline;

  /// No description provided for @vaultRestoreFromFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'12 words + encrypted .kvault file. No internet needed.'**
  String get vaultRestoreFromFileSubtitle;

  /// No description provided for @vaultBiometricsReason.
  ///
  /// In en, this message translates to:
  /// **'Show the recovery phrase on this device'**
  String get vaultBiometricsReason;

  /// No description provided for @vaultNoScreenLockTitle.
  ///
  /// In en, this message translates to:
  /// **'No screen lock'**
  String get vaultNoScreenLockTitle;

  /// No description provided for @vaultNoScreenLockBody.
  ///
  /// In en, this message translates to:
  /// **'This device has no Face ID, fingerprint, or PIN. Anyone with access to the app can see the words. Continue?'**
  String get vaultNoScreenLockBody;

  /// No description provided for @vaultShowAnyway.
  ///
  /// In en, this message translates to:
  /// **'Show anyway'**
  String get vaultShowAnyway;

  /// No description provided for @vaultRevealWarning.
  ///
  /// In en, this message translates to:
  /// **'Write the words down again on paper if you lost your copy. Do not leave this screen open.'**
  String get vaultRevealWarning;

  /// No description provided for @familyCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Family key'**
  String get familyCreateTitle;

  /// No description provided for @familyCreateWriteWords.
  ///
  /// In en, this message translates to:
  /// **'Write these 12 words down. They belong to the family key you share with family members. We do not store the words.'**
  String get familyCreateWriteWords;

  /// No description provided for @familyCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the family key: {error}'**
  String familyCreateFailed(String error);

  /// No description provided for @commonVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get commonVerify;

  /// No description provided for @commonLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get commonLeave;

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String relativeMinutesAgo(int count);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String relativeHoursAgo(int count);

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeYesterday;

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String relativeDaysAgo(int count);

  /// No description provided for @familyMemberVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify family key'**
  String get familyMemberVerifyTitle;

  /// No description provided for @familyMemberVerifyBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 12 words. We will not show them; we only check that they match.'**
  String get familyMemberVerifyBody;

  /// No description provided for @familyMemberVerifyOk.
  ///
  /// In en, this message translates to:
  /// **'The family key matches.'**
  String get familyMemberVerifyOk;

  /// No description provided for @familyMemberVerifyMismatch.
  ///
  /// In en, this message translates to:
  /// **'This recovery phrase does not match this family key.'**
  String get familyMemberVerifyMismatch;

  /// No description provided for @familyMemberRevealMissing.
  ///
  /// In en, this message translates to:
  /// **'This family key is from before the recovery phrase (0.2) or arrived as a raw key. We cannot show the words. Create a new family key and have family members and kids re-link.'**
  String get familyMemberRevealMissing;

  /// No description provided for @familyMemberUnlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave family?'**
  String get familyMemberUnlinkTitle;

  /// No description provided for @familyMemberUnlinkBody.
  ///
  /// In en, this message translates to:
  /// **'All shared notes will be removed from this device. Your own tasks and private notes stay. Other family members keep their connection — only you leave the shared workspace.'**
  String get familyMemberUnlinkBody;

  /// No description provided for @familyMemberShareViaQr.
  ///
  /// In en, this message translates to:
  /// **'Share family key via QR'**
  String get familyMemberShareViaQr;

  /// No description provided for @familyMemberShareViaQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have a family member scan the QR code to collaborate.'**
  String get familyMemberShareViaQrSubtitle;

  /// No description provided for @familyMemberScanKey.
  ///
  /// In en, this message translates to:
  /// **'Scan family key'**
  String get familyMemberScanKey;

  /// No description provided for @familyMemberScanKeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR or type their 12 words.'**
  String get familyMemberScanKeySubtitle;

  /// No description provided for @familyMemberReshareKey.
  ///
  /// In en, this message translates to:
  /// **'Share family key again'**
  String get familyMemberReshareKey;

  /// No description provided for @familyMemberReshareKeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share the key with a new device of a family member.'**
  String get familyMemberReshareKeySubtitle;

  /// No description provided for @familyMemberVerifyPhrase.
  ///
  /// In en, this message translates to:
  /// **'Verify recovery phrase'**
  String get familyMemberVerifyPhrase;

  /// No description provided for @familyMemberVerifyPhraseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check that you still know the 12 words of the family key.'**
  String get familyMemberVerifyPhraseSubtitle;

  /// No description provided for @familyMemberShowKey.
  ///
  /// In en, this message translates to:
  /// **'Show family key'**
  String get familyMemberShowKey;

  /// No description provided for @familyMemberShowKeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the 12 words on this device (screen lock).'**
  String get familyMemberShowKeySubtitle;

  /// No description provided for @familyMemberUnlink.
  ///
  /// In en, this message translates to:
  /// **'Leave family'**
  String get familyMemberUnlink;

  /// No description provided for @familyMemberUnlinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove the family key and shared notes from this device.'**
  String get familyMemberUnlinkSubtitle;

  /// No description provided for @familyMemberRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from family'**
  String get familyMemberRemoveTooltip;

  /// No description provided for @familyMemberRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String familyMemberRemoveTitle(String name);

  /// No description provided for @familyMemberRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this family\'s roster. Their app will disconnect on the next sync. The family key is not changed automatically — you can run the new-key wizard afterward so they cannot decrypt new shared data.'**
  String familyMemberRemoveBody(String name);

  /// No description provided for @familyMemberRemovedFromFamily.
  ///
  /// In en, this message translates to:
  /// **'You were removed from the family on another device.'**
  String get familyMemberRemovedFromFamily;

  /// No description provided for @familyKeyRotationOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new family key?'**
  String get familyKeyRotationOfferTitle;

  /// No description provided for @familyKeyRotationOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Removing a member does not change the family key. To keep them from reading new shared notes and tasks, create a new key and share it with everyone who should stay.'**
  String get familyKeyRotationOfferBody;

  /// No description provided for @familyKeyRotationOfferNow.
  ///
  /// In en, this message translates to:
  /// **'Start wizard'**
  String get familyKeyRotationOfferNow;

  /// No description provided for @familyKeyRotationOfferLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get familyKeyRotationOfferLater;

  /// No description provided for @familyKeyRotationTitle.
  ///
  /// In en, this message translates to:
  /// **'New family key'**
  String get familyKeyRotationTitle;

  /// No description provided for @familyKeyRotationIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Rotate the family key'**
  String get familyKeyRotationIntroTitle;

  /// No description provided for @familyKeyRotationIntroBody.
  ///
  /// In en, this message translates to:
  /// **'You will write down a new 12-word family key. Shared data on WebDAV is re-encrypted. Remaining family members and kids must scan a new QR to stay connected.'**
  String get familyKeyRotationIntroBody;

  /// No description provided for @familyKeyRotationStart.
  ///
  /// In en, this message translates to:
  /// **'Create new key'**
  String get familyKeyRotationStart;

  /// No description provided for @familyKeyRotationReencryptTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-encrypting shared data…'**
  String get familyKeyRotationReencryptTitle;

  /// No description provided for @familyKeyRotationReencryptPreparing.
  ///
  /// In en, this message translates to:
  /// **'Scanning shared folders…'**
  String get familyKeyRotationReencryptPreparing;

  /// No description provided for @familyKeyRotationReencryptProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} files'**
  String familyKeyRotationReencryptProgress(int done, int total);

  /// No description provided for @familyKeyRotationShareLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Share with family members'**
  String get familyKeyRotationShareLinkTitle;

  /// No description provided for @familyKeyRotationShareLinkBody.
  ///
  /// In en, this message translates to:
  /// **'Each remaining Kinetic Link adult must scan this QR or use tap-to-link. Their old key will not open new shared data.'**
  String get familyKeyRotationShareLinkBody;

  /// No description provided for @familyKeyRotationShareLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Show family QR'**
  String get familyKeyRotationShareLinkButton;

  /// No description provided for @familyKeyRotationShareLinkSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get familyKeyRotationShareLinkSkip;

  /// No description provided for @familyKeyRotationShareKidsTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-enroll kids'**
  String get familyKeyRotationShareKidsTitle;

  /// No description provided for @familyKeyRotationShareKidsBody.
  ///
  /// In en, this message translates to:
  /// **'Each child device needs a new enrollment QR with the updated family key.'**
  String get familyKeyRotationShareKidsBody;

  /// No description provided for @familyKeyRotationDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Family key updated'**
  String get familyKeyRotationDoneTitle;

  /// No description provided for @familyKeyRotationDoneBody.
  ///
  /// In en, this message translates to:
  /// **'This device uses the new key. Make sure every remaining family member and kid has scanned the new QR when you are ready.'**
  String get familyKeyRotationDoneBody;

  /// No description provided for @otherLinkMemberStatusPaired.
  ///
  /// In en, this message translates to:
  /// **'Family member linked — family key present'**
  String get otherLinkMemberStatusPaired;

  /// No description provided for @otherLinkMemberStatusUnpaired.
  ///
  /// In en, this message translates to:
  /// **'Family member not linked — scan or share the QR code to link'**
  String get otherLinkMemberStatusUnpaired;

  /// No description provided for @familyMemberLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen {when}'**
  String familyMemberLastSeen(String when);

  /// No description provided for @familyMemberLastSeenWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: last seen {when}'**
  String familyMemberLastSeenWarning(String when);

  /// No description provided for @familyMemberFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint {fingerprint}'**
  String familyMemberFingerprint(String fingerprint);

  /// No description provided for @kidsLinkApp.
  ///
  /// In en, this message translates to:
  /// **'Link kids app'**
  String get kidsLinkApp;

  /// No description provided for @kidsLinkAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have the kids app scan the QR code.'**
  String get kidsLinkAppSubtitle;

  /// No description provided for @kidsEnrolledSection.
  ///
  /// In en, this message translates to:
  /// **'ENROLLED KIDS'**
  String get kidsEnrolledSection;

  /// No description provided for @kidsNoneEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No kids linked yet.'**
  String get kidsNoneEnrolled;

  /// No description provided for @kidsRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from family'**
  String get kidsRemoveTooltip;

  /// No description provided for @kidsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String kidsRemoveTitle(String name);

  /// No description provided for @kidsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from the family list. The kids app will no longer receive family tasks unless linked again.'**
  String kidsRemoveBody(String name);

  /// No description provided for @kidsEnrolledOn.
  ///
  /// In en, this message translates to:
  /// **'Linked on {date}'**
  String kidsEnrolledOn(String date);

  /// No description provided for @kidsLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen {when}'**
  String kidsLastSeen(String when);

  /// No description provided for @kidsLastSeenWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: last seen {when}'**
  String kidsLastSeenWarning(String when);

  /// No description provided for @kidsEnrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Link kids app'**
  String get kidsEnrollTitle;

  /// No description provided for @kidsEnrollNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Child\'s name'**
  String get kidsEnrollNameTitle;

  /// No description provided for @kidsEnrollNameBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the child you want to link.'**
  String get kidsEnrollNameBody;

  /// No description provided for @kidsEnrollNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Child name'**
  String get kidsEnrollNameLabel;

  /// No description provided for @kidsEnrollContinueToQr.
  ///
  /// In en, this message translates to:
  /// **'Continue to QR code'**
  String get kidsEnrollContinueToQr;

  /// No description provided for @kidsEnrollQrTitle.
  ///
  /// In en, this message translates to:
  /// **'QR code for {name}'**
  String kidsEnrollQrTitle(String name);

  /// No description provided for @kidsEnrollQrBody.
  ///
  /// In en, this message translates to:
  /// **'Open the kids app on {name}\'s device and scan this code.'**
  String kidsEnrollQrBody(String name);

  /// No description provided for @kidsEnrollWhatShared.
  ///
  /// In en, this message translates to:
  /// **'What is shared?'**
  String get kidsEnrollWhatShared;

  /// No description provided for @kidsEnrollWhatSharedBody.
  ///
  /// In en, this message translates to:
  /// **'This QR code contains the server, account, and family key — not the WebDAV password. Type that password once on the kids device. Only share the code with the kids app on a trusted device.'**
  String get kidsEnrollWhatSharedBody;

  /// No description provided for @kidsEnrollWaitingDevice.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the kids device to connect…'**
  String get kidsEnrollWaitingDevice;

  /// No description provided for @kidsEnrollKeepWaiting.
  ///
  /// In en, this message translates to:
  /// **'Done — keep waiting for device'**
  String get kidsEnrollKeepWaiting;

  /// No description provided for @kidsWaitingForDevice.
  ///
  /// In en, this message translates to:
  /// **'Waiting for device'**
  String get kidsWaitingForDevice;

  /// No description provided for @kidsMarkActive.
  ///
  /// In en, this message translates to:
  /// **'Mark as linked'**
  String get kidsMarkActive;

  /// No description provided for @kidsDraftSection.
  ///
  /// In en, this message translates to:
  /// **'WAITING TO LINK'**
  String get kidsDraftSection;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageDutch.
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get settingsLanguageDutch;

  /// No description provided for @settingsLanguageChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsLanguageChoose;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @commonCloseAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonCloseAction;

  /// No description provided for @commonExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get commonExporting;

  /// No description provided for @commonImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get commonImporting;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get commonEveryone;

  /// No description provided for @commonTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commonTitle;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @commonContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get commonContent;

  /// No description provided for @commonLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get commonLow;

  /// No description provided for @commonMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get commonMedium;

  /// No description provided for @commonHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get commonHigh;

  /// No description provided for @commonPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get commonPrivate;

  /// No description provided for @commonShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get commonShared;

  /// No description provided for @commonKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get commonKids;

  /// No description provided for @commonFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Family member'**
  String get commonFamilyMember;

  /// No description provided for @commonReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get commonReminder;

  /// No description provided for @commonTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get commonTime;

  /// No description provided for @commonCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get commonCategory;

  /// No description provided for @commonPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get commonPriority;

  /// No description provided for @commonNoCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get commonNoCategory;

  /// No description provided for @commonSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String commonSaveError(String error);

  /// No description provided for @commonDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting: {error}'**
  String commonDeleteError(String error);

  /// No description provided for @relativeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String relativeWeeksAgo(int count);

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateDaysOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count}d overdue'**
  String dateDaysOverdue(int count);

  /// No description provided for @dateInDays.
  ///
  /// In en, this message translates to:
  /// **'In {count} days'**
  String dateInDays(int count);

  /// No description provided for @dateInHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 hour} other{In {count} hours}}'**
  String dateInHours(int count);

  /// No description provided for @dateTonightTime.
  ///
  /// In en, this message translates to:
  /// **'Tonight {time}'**
  String dateTonightTime(String time);

  /// No description provided for @dateTodayTime.
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String dateTodayTime(String time);

  /// No description provided for @dateYesterdayTime.
  ///
  /// In en, this message translates to:
  /// **'Yesterday {time}'**
  String dateYesterdayTime(String time);

  /// No description provided for @dateTomorrowTime.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow {time}'**
  String dateTomorrowTime(String time);

  /// No description provided for @dateWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dateWeekdayMonday;

  /// No description provided for @dateWeekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dateWeekdayTuesday;

  /// No description provided for @dateWeekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dateWeekdayWednesday;

  /// No description provided for @dateWeekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dateWeekdayThursday;

  /// No description provided for @dateWeekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dateWeekdayFriday;

  /// No description provided for @dateWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get dateWeekdaySaturday;

  /// No description provided for @dateWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get dateWeekdaySunday;

  /// No description provided for @dateWeekdayShortMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dateWeekdayShortMonday;

  /// No description provided for @dateWeekdayShortTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dateWeekdayShortTuesday;

  /// No description provided for @dateWeekdayShortWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dateWeekdayShortWednesday;

  /// No description provided for @dateWeekdayShortThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dateWeekdayShortThursday;

  /// No description provided for @dateWeekdayShortFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dateWeekdayShortFriday;

  /// No description provided for @dateWeekdayShortSaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get dateWeekdayShortSaturday;

  /// No description provided for @dateWeekdayShortSunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get dateWeekdayShortSunday;

  /// No description provided for @reminderWhyHabitTime.
  ///
  /// In en, this message translates to:
  /// **'You did this task {count}× on {weekday}'**
  String reminderWhyHabitTime(int count, String weekday);

  /// No description provided for @reminderWhyHabitInterval.
  ///
  /// In en, this message translates to:
  /// **'About every {median} days, last {daysSince} days ago'**
  String reminderWhyHabitInterval(int median, int daysSince);

  /// No description provided for @reminderWhyKeyword.
  ///
  /// In en, this message translates to:
  /// **'Matches \"{keyword}\" in the title'**
  String reminderWhyKeyword(String keyword);

  /// No description provided for @reminderWhyCategorySchool.
  ///
  /// In en, this message translates to:
  /// **'School tasks are usually planned in the morning'**
  String get reminderWhyCategorySchool;

  /// No description provided for @reminderWhyCategoryHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household tasks are often planned on weekends'**
  String get reminderWhyCategoryHousehold;

  /// No description provided for @reminderWhyCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health tasks are often reminded in the morning'**
  String get reminderWhyCategoryHealth;

  /// No description provided for @reminderWhyCategoryAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin tasks are often planned during the day'**
  String get reminderWhyCategoryAdmin;

  /// No description provided for @reminderWhyDefaultMorning.
  ///
  /// In en, this message translates to:
  /// **'Default morning reminder'**
  String get reminderWhyDefaultMorning;

  /// No description provided for @reminderWhyEvening.
  ///
  /// In en, this message translates to:
  /// **'Quick evening reminder'**
  String get reminderWhyEvening;

  /// No description provided for @reminderWhyTomorrowEvening.
  ///
  /// In en, this message translates to:
  /// **'Reminder tomorrow evening'**
  String get reminderWhyTomorrowEvening;

  /// No description provided for @reminderWhyQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick reminder'**
  String get reminderWhyQuick;

  /// No description provided for @dateMonthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get dateMonthJan;

  /// No description provided for @dateMonthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get dateMonthFeb;

  /// No description provided for @dateMonthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get dateMonthMar;

  /// No description provided for @dateMonthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get dateMonthApr;

  /// No description provided for @dateMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get dateMonthMay;

  /// No description provided for @dateMonthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get dateMonthJun;

  /// No description provided for @dateMonthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get dateMonthJul;

  /// No description provided for @dateMonthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get dateMonthAug;

  /// No description provided for @dateMonthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get dateMonthSep;

  /// No description provided for @dateMonthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get dateMonthOct;

  /// No description provided for @dateMonthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get dateMonthNov;

  /// No description provided for @dateMonthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dateMonthDec;

  /// No description provided for @connNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get connNotConnected;

  /// No description provided for @connNotConnectedSince.
  ///
  /// In en, this message translates to:
  /// **'Not connected since {when}'**
  String connNotConnectedSince(String when);

  /// No description provided for @connUnknownNoSync.
  ///
  /// In en, this message translates to:
  /// **'Connection unknown (no sync)'**
  String get connUnknownNoSync;

  /// No description provided for @connStale.
  ///
  /// In en, this message translates to:
  /// **'Connection stale ({when})'**
  String connStale(String when);

  /// No description provided for @connConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connConnected;

  /// No description provided for @connConnectedSince.
  ///
  /// In en, this message translates to:
  /// **'Connected ({when})'**
  String connConnectedSince(String when);

  /// No description provided for @tasksAmbientLoadOpen.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String tasksAmbientLoadOpen(int count);

  /// No description provided for @tasksAmbientLoadUnknown.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get tasksAmbientLoadUnknown;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders for tasks and assignments'**
  String get notifChannelDesc;

  /// No description provided for @notifReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get notifReminderTitle;

  /// No description provided for @backupNoVault.
  ///
  /// In en, this message translates to:
  /// **'No vault on this device.'**
  String get backupNoVault;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {path}'**
  String backupSaved(String path);

  /// No description provided for @backupExportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting: {error}'**
  String backupExportError(String error);

  /// No description provided for @backupVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify recovery phrase'**
  String get backupVerifyTitle;

  /// No description provided for @backupVerifyBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your 12 words. We will not show the phrase; we only check that it matches.'**
  String get backupVerifyBody;

  /// No description provided for @backupVerifyOk.
  ///
  /// In en, this message translates to:
  /// **'The recovery phrase matches.'**
  String get backupVerifyOk;

  /// No description provided for @backupVerifyMismatch.
  ///
  /// In en, this message translates to:
  /// **'This recovery phrase does not belong to this vault.'**
  String get backupVerifyMismatch;

  /// No description provided for @backupRevealTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase'**
  String get backupRevealTitle;

  /// No description provided for @backupRevealMissing.
  ///
  /// In en, this message translates to:
  /// **'We cannot show the words again on this device. Use your paper copy, or restore the vault with the 12 words.'**
  String get backupRevealMissing;

  /// No description provided for @backupImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get backupImportTitle;

  /// No description provided for @backupImportBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 12 words for this .kvault file.'**
  String get backupImportBody;

  /// No description provided for @backupImportOtherVaultBody.
  ///
  /// In en, this message translates to:
  /// **'This backup uses a different vault. Enter its 12 words.'**
  String get backupImportOtherVaultBody;

  /// No description provided for @backupImportOverwriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get backupImportOverwriteTitle;

  /// No description provided for @backupImportOverwriteBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes everything on this phone and puts the backup in its place. Newer data on this device is lost.'**
  String get backupImportOverwriteBody;

  /// No description provided for @backupImportOverwriteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backupImportOverwriteConfirm;

  /// No description provided for @backupImportWrongPhrase.
  ///
  /// In en, this message translates to:
  /// **'Wrong recovery phrase for this backup.'**
  String get backupImportWrongPhrase;

  /// No description provided for @backupCouldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file.'**
  String get backupCouldNotReadFile;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully.'**
  String get backupRestored;

  /// No description provided for @backupInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file: {error}'**
  String backupInvalidFile(String error);

  /// No description provided for @backupImportError.
  ///
  /// In en, this message translates to:
  /// **'Error importing: {error}'**
  String backupImportError(String error);

  /// No description provided for @backupRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring backup…'**
  String get backupRestoring;

  /// No description provided for @webdavSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up WebDAV'**
  String get webdavSetupTitle;

  /// No description provided for @webdavUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the server URL'**
  String get webdavUrlRequired;

  /// No description provided for @webdavUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the username'**
  String get webdavUsernameRequired;

  /// No description provided for @webdavPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the password'**
  String get webdavPasswordRequired;

  /// No description provided for @webdavTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get webdavTestConnection;

  /// No description provided for @webdavTestingConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing connection…'**
  String get webdavTestingConnection;

  /// No description provided for @webdavConnectionOk.
  ///
  /// In en, this message translates to:
  /// **'Connection succeeded'**
  String get webdavConnectionOk;

  /// No description provided for @webdavErrorAuth.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get webdavErrorAuth;

  /// No description provided for @webdavErrorNoWebDav.
  ///
  /// In en, this message translates to:
  /// **'This server does not appear to support WebDAV. Check the URL (for Nextcloud often …/remote.php/dav).'**
  String get webdavErrorNoWebDav;

  /// No description provided for @webdavErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check the server URL and your network.'**
  String get webdavErrorTimeout;

  /// No description provided for @webdavErrorUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check the URL and your network.'**
  String get webdavErrorUnreachable;

  /// No description provided for @webdavTestFirst.
  ///
  /// In en, this message translates to:
  /// **'Test the connection before saving.'**
  String get webdavTestFirst;

  /// No description provided for @webdavCreateVaultFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a vault before linking WebDAV.'**
  String get webdavCreateVaultFirst;

  /// No description provided for @webdavPhraseMismatchServer.
  ///
  /// In en, this message translates to:
  /// **'This server already has a vault that does not match your recovery phrase.'**
  String get webdavPhraseMismatchServer;

  /// No description provided for @webdavConfigSaved.
  ///
  /// In en, this message translates to:
  /// **'WebDAV configuration saved.'**
  String get webdavConfigSaved;

  /// No description provided for @webdavSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String webdavSaveError(String error);

  /// No description provided for @webdavMigrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Existing data found'**
  String get webdavMigrationTitle;

  /// No description provided for @webdavMigrationIntro.
  ///
  /// In en, this message translates to:
  /// **'The WebDAV server already has encrypted files:'**
  String get webdavMigrationIntro;

  /// No description provided for @webdavMigrationTaskFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{  • 1 task file} other{  • {count} task files}}'**
  String webdavMigrationTaskFiles(int count);

  /// No description provided for @webdavMigrationNoteFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{  • 1 note file} other{  • {count} note files}}'**
  String webdavMigrationNoteFiles(int count);

  /// No description provided for @webdavMigrationChoose.
  ///
  /// In en, this message translates to:
  /// **'These files are encrypted with a vault. Choose how to continue:'**
  String get webdavMigrationChoose;

  /// No description provided for @webdavMigrationCleanOption.
  ///
  /// In en, this message translates to:
  /// **'1. Clean install — remove the old files on the server and start fresh.'**
  String get webdavMigrationCleanOption;

  /// No description provided for @webdavMigrationImportOption.
  ///
  /// In en, this message translates to:
  /// **'2. Import backup — replaces all data on this phone with a .kvault file.'**
  String get webdavMigrationImportOption;

  /// No description provided for @webdavMigrationClean.
  ///
  /// In en, this message translates to:
  /// **'Clean install'**
  String get webdavMigrationClean;

  /// No description provided for @webdavMigrationImport.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get webdavMigrationImport;

  /// No description provided for @webdavBackupRestoredSync.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. The app will now sync with the server.'**
  String get webdavBackupRestoredSync;

  /// No description provided for @webdavRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Error restoring backup: {error}'**
  String webdavRestoreError(String error);

  /// No description provided for @webdavMigrationCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Migration check failed: {error}'**
  String webdavMigrationCheckFailed(String error);

  /// No description provided for @webdavFilesDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} files deleted.'**
  String webdavFilesDeleted(int count);

  /// No description provided for @webdavCleanupError.
  ///
  /// In en, this message translates to:
  /// **'Error cleaning up: {error}'**
  String webdavCleanupError(String error);

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksSectionTitle;

  /// No description provided for @tasksCompletedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks'**
  String get tasksCompletedTooltip;

  /// No description provided for @tasksSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed, tap to retry.'**
  String get tasksSyncFailed;

  /// No description provided for @tasksSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get tasksSyncing;

  /// No description provided for @syncStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncStatusTitle;

  /// No description provided for @syncStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get syncStatusIdle;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusError.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncStatusError;

  /// No description provided for @syncStatusRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry sync'**
  String get syncStatusRetry;

  /// No description provided for @syncStatusNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncStatusNeverSynced;

  /// No description provided for @syncStatusLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last success: {when}'**
  String syncStatusLastSuccess(String when);

  /// No description provided for @syncErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Sync timed out. Check your connection and try again.'**
  String get syncErrorTimeout;

  /// No description provided for @syncErrorAuth.
  ///
  /// In en, this message translates to:
  /// **'WebDAV login failed. Check username and password.'**
  String get syncErrorAuth;

  /// No description provided for @syncErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection.'**
  String get syncErrorNetwork;

  /// No description provided for @syncErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Try again or check WebDAV settings.'**
  String get syncErrorGeneric;

  /// No description provided for @settingsSyncHealthIdle.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get settingsSyncHealthIdle;

  /// No description provided for @settingsSyncHealthSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get settingsSyncHealthSyncing;

  /// No description provided for @settingsSyncHealthError.
  ///
  /// In en, this message translates to:
  /// **'Sync error — tap for details'**
  String get settingsSyncHealthError;

  /// No description provided for @settingsSyncHealthNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get settingsSyncHealthNever;

  /// No description provided for @settingsStartFamily.
  ///
  /// In en, this message translates to:
  /// **'Start family'**
  String get settingsStartFamily;

  /// No description provided for @settingsStartFamilyHint.
  ///
  /// In en, this message translates to:
  /// **'Guided setup: WebDAV, members, and kids'**
  String get settingsStartFamilyHint;

  /// No description provided for @familySetupPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your family?'**
  String get familySetupPromptTitle;

  /// No description provided for @familySetupPromptBody.
  ///
  /// In en, this message translates to:
  /// **'WebDAV sync is on, but you have not linked a family yet. Shared notes, kids tasks, and multi-device family sync need a family key.'**
  String get familySetupPromptBody;

  /// No description provided for @familySetupPromptIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get familySetupPromptIgnore;

  /// No description provided for @familySetupPromptRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind in {days} days'**
  String familySetupPromptRemind(int days);

  /// No description provided for @familySetupPromptStart.
  ///
  /// In en, this message translates to:
  /// **'Start guide'**
  String get familySetupPromptStart;

  /// No description provided for @webdavJoinFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Join family?'**
  String get webdavJoinFamilyTitle;

  /// No description provided for @webdavJoinFamilyBody.
  ///
  /// In en, this message translates to:
  /// **'Someone is already using Kinetic on this folder.'**
  String get webdavJoinFamilyBody;

  /// No description provided for @webdavJoinFamilyMembersOne.
  ///
  /// In en, this message translates to:
  /// **'{name} is already here.'**
  String webdavJoinFamilyMembersOne(String name);

  /// No description provided for @webdavJoinFamilyMembersMany.
  ///
  /// In en, this message translates to:
  /// **'Already here:'**
  String webdavJoinFamilyMembersMany(int count);

  /// No description provided for @webdavJoinFamilySharedOnly.
  ///
  /// In en, this message translates to:
  /// **'Family data found.'**
  String get webdavJoinFamilySharedOnly;

  /// No description provided for @webdavJoinFamilyLink.
  ///
  /// In en, this message translates to:
  /// **'Link now'**
  String get webdavJoinFamilyLink;

  /// No description provided for @webdavJoinFamilyLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get webdavJoinFamilyLater;

  /// No description provided for @webdavFamilyRestored.
  ///
  /// In en, this message translates to:
  /// **'Family key restored from this server.'**
  String get webdavFamilyRestored;

  /// No description provided for @wizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Start family'**
  String get wizardTitle;

  /// No description provided for @wizardStepWebDav.
  ///
  /// In en, this message translates to:
  /// **'Connect WebDAV'**
  String get wizardStepWebDav;

  /// No description provided for @wizardStepFamily.
  ///
  /// In en, this message translates to:
  /// **'Create or join family'**
  String get wizardStepFamily;

  /// No description provided for @wizardStepInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite a family member'**
  String get wizardStepInvite;

  /// No description provided for @wizardStepKids.
  ///
  /// In en, this message translates to:
  /// **'Enroll a kid'**
  String get wizardStepKids;

  /// No description provided for @wizardStepDone.
  ///
  /// In en, this message translates to:
  /// **'You\'re set'**
  String get wizardStepDone;

  /// No description provided for @wizardSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get wizardSkip;

  /// No description provided for @wizardNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get wizardNext;

  /// No description provided for @wizardDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get wizardDone;

  /// No description provided for @wizardInviteHint.
  ///
  /// In en, this message translates to:
  /// **'Share your family key with QR or hold phones close (tap to link).'**
  String get wizardInviteHint;

  /// No description provided for @wizardKidsPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'The child still needs the WebDAV password — it is not in the QR. Share it separately.'**
  String get wizardKidsPasswordHint;

  /// No description provided for @wizardFirstSuccessHint.
  ///
  /// In en, this message translates to:
  /// **'Try a shared note or assign a kid task to see sync in action.'**
  String get wizardFirstSuccessHint;

  /// No description provided for @wizardOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'Go to tasks'**
  String get wizardOpenTasks;

  /// No description provided for @bleShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to share'**
  String get bleShareTitle;

  /// No description provided for @bleJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to join'**
  String get bleJoinTitle;

  /// No description provided for @bleSearching.
  ///
  /// In en, this message translates to:
  /// **'Looking for a nearby Kinetic phone…'**
  String get bleSearching;

  /// No description provided for @bleAdvertising.
  ///
  /// In en, this message translates to:
  /// **'Ready — hold the other phone close'**
  String get bleAdvertising;

  /// No description provided for @bleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow link?'**
  String get bleConfirmTitle;

  /// No description provided for @bleConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to join your family.'**
  String bleConfirmBody(String name);

  /// No description provided for @bleConfirmAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get bleConfirmAllow;

  /// No description provided for @bleConfirmDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get bleConfirmDeny;

  /// No description provided for @bleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Linked successfully'**
  String get bleSuccess;

  /// No description provided for @bleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not link over Bluetooth. Try QR instead.'**
  String get bleFailed;

  /// No description provided for @bleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is unavailable. Use QR code instead.'**
  String get bleUnavailable;

  /// No description provided for @bleTimeout.
  ///
  /// In en, this message translates to:
  /// **'No nearby phone found. Move closer or use QR.'**
  String get bleTimeout;

  /// No description provided for @tasksForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get tasksForYou;

  /// No description provided for @tasksForFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'For {name}'**
  String tasksForFamilyMember(String name);

  /// No description provided for @tasksFromFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String tasksFromFamilyMember(String name);

  /// No description provided for @tasksForFamily.
  ///
  /// In en, this message translates to:
  /// **'For family'**
  String get tasksForFamily;

  /// No description provided for @tasksFromFamily.
  ///
  /// In en, this message translates to:
  /// **'From family'**
  String get tasksFromFamily;

  /// No description provided for @familyMemberGenericName.
  ///
  /// In en, this message translates to:
  /// **'family member'**
  String get familyMemberGenericName;

  /// No description provided for @tasksAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get tasksAccept;

  /// No description provided for @tasksXpResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset XP for {name}?'**
  String tasksXpResetTitle(String name);

  /// No description provided for @tasksXpResetBody.
  ///
  /// In en, this message translates to:
  /// **'This resets the XP counter to 0. The assignments stay.'**
  String get tasksXpResetBody;

  /// No description provided for @tasksXpResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get tasksXpResetAction;

  /// No description provided for @tasksXpResetDone.
  ///
  /// In en, this message translates to:
  /// **'XP reset for {name}'**
  String tasksXpResetDone(String name);

  /// No description provided for @tasksXpResetError.
  ///
  /// In en, this message translates to:
  /// **'Error resetting: {error}'**
  String tasksXpResetError(String error);

  /// No description provided for @tasksLoadKidsError.
  ///
  /// In en, this message translates to:
  /// **'Error loading kids assignments'**
  String get tasksLoadKidsError;

  /// No description provided for @tasksNoKidsAssignments.
  ///
  /// In en, this message translates to:
  /// **'No assignments'**
  String get tasksNoKidsAssignments;

  /// No description provided for @tasksResetXp.
  ///
  /// In en, this message translates to:
  /// **'Reset XP'**
  String get tasksResetXp;

  /// No description provided for @tasksDoneOn.
  ///
  /// In en, this message translates to:
  /// **'Done on {day}/{month}'**
  String tasksDoneOn(int day, int month);

  /// No description provided for @tasksCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks'**
  String get tasksCompletedTitle;

  /// No description provided for @tasksDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get tasksDeleteAll;

  /// No description provided for @tasksDeleteCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete completed tasks'**
  String get tasksDeleteCompletedTitle;

  /// No description provided for @tasksDeleteCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all completed tasks? This cannot be undone.'**
  String get tasksDeleteCompletedBody;

  /// No description provided for @tasksAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get tasksAllDone;

  /// No description provided for @tasksNoOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'You have no open tasks'**
  String get tasksNoOpenTasks;

  /// No description provided for @tasksNoPersonalOpen.
  ///
  /// In en, this message translates to:
  /// **'No personal tasks open'**
  String get tasksNoPersonalOpen;

  /// No description provided for @tasksNoCompleted.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks'**
  String get tasksNoCompleted;

  /// No description provided for @tasksNoCompletedHint.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks appear here'**
  String get tasksNoCompletedHint;

  /// No description provided for @tasksAssignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get tasksAssignment;

  /// No description provided for @taskDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get taskDeleteTitle;

  /// No description provided for @taskDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be permanently deleted. This cannot be undone.'**
  String taskDeleteBody(String title);

  /// No description provided for @taskForwardTitle.
  ///
  /// In en, this message translates to:
  /// **'Forward task'**
  String get taskForwardTitle;

  /// No description provided for @taskAssignmentCreated.
  ///
  /// In en, this message translates to:
  /// **'Assignment created ✓'**
  String get taskAssignmentCreated;

  /// No description provided for @taskNoConnectedFamily.
  ///
  /// In en, this message translates to:
  /// **'No connected family members or kids'**
  String get taskNoConnectedFamily;

  /// No description provided for @taskStaleConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection stale'**
  String get taskStaleConnectionTitle;

  /// No description provided for @taskStaleFamilyMemberBody.
  ///
  /// In en, this message translates to:
  /// **'This family member was last seen {status}. Send anyway?'**
  String taskStaleFamilyMemberBody(String status);

  /// No description provided for @taskStaleKidBody.
  ///
  /// In en, this message translates to:
  /// **'{name} was last seen {status}. Send anyway?'**
  String taskStaleKidBody(String name, String status);

  /// No description provided for @taskSendAnyway.
  ///
  /// In en, this message translates to:
  /// **'Send anyway'**
  String get taskSendAnyway;

  /// No description provided for @familyMemberPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Send to which family member?'**
  String get familyMemberPickerTitle;

  /// No description provided for @taskSendToFamilyMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Send to {name}?'**
  String taskSendToFamilyMemberTitle(String name);

  /// No description provided for @taskSendToFamilyMemberBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be sent as a proposal to {name} and removed from your list once they accept it.'**
  String taskSendToFamilyMemberBody(String title, String name);

  /// No description provided for @taskSendToKidTitle.
  ///
  /// In en, this message translates to:
  /// **'Send to {name}?'**
  String taskSendToKidTitle(String name);

  /// No description provided for @taskSendToKidBody.
  ///
  /// In en, this message translates to:
  /// **'The task disappears from your list once the child completes it.'**
  String get taskSendToKidBody;

  /// No description provided for @taskSendToKidLead.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be sent as an assignment to {name}.'**
  String taskSendToKidLead(String title, String name);

  /// No description provided for @taskSendToEveryoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visible to all enrolled kids'**
  String get taskSendToEveryoneSubtitle;

  /// No description provided for @taskSendToEveryoneBody.
  ///
  /// In en, this message translates to:
  /// **'Every enrolled child will see this assignment. It leaves your list once any child completes it.'**
  String get taskSendToEveryoneBody;

  /// No description provided for @taskXpReward.
  ///
  /// In en, this message translates to:
  /// **'XP reward:'**
  String get taskXpReward;

  /// No description provided for @taskNameHint.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskNameHint;

  /// No description provided for @taskAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get taskAddTime;

  /// No description provided for @taskAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get taskAddCategory;

  /// No description provided for @taskRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get taskRepeat;

  /// No description provided for @taskForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get taskForward;

  /// No description provided for @taskAssignToLabel.
  ///
  /// In en, this message translates to:
  /// **'Assign to'**
  String get taskAssignToLabel;

  /// No description provided for @taskAssignToMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get taskAssignToMe;

  /// No description provided for @taskRecurrenceNone.
  ///
  /// In en, this message translates to:
  /// **'No recurrence'**
  String get taskRecurrenceNone;

  /// No description provided for @taskRecurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get taskRecurrenceDaily;

  /// No description provided for @taskRecurrenceWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get taskRecurrenceWeekdays;

  /// No description provided for @taskRecurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get taskRecurrenceWeekly;

  /// No description provided for @taskRecurrenceBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Biweekly'**
  String get taskRecurrenceBiweekly;

  /// No description provided for @taskRecurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get taskRecurrenceMonthly;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @notesTabPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get notesTabPrivate;

  /// No description provided for @notesTabShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get notesTabShared;

  /// No description provided for @notesNewTooltip.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notesNewTooltip;

  /// No description provided for @notesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading notes'**
  String get notesLoadError;

  /// No description provided for @notesEmptyShared.
  ///
  /// In en, this message translates to:
  /// **'No shared notes'**
  String get notesEmptyShared;

  /// No description provided for @notesEmptyPrivate.
  ///
  /// In en, this message translates to:
  /// **'No private notes'**
  String get notesEmptyPrivate;

  /// No description provided for @notesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get notesEmpty;

  /// No description provided for @notesEmptySharedHint.
  ///
  /// In en, this message translates to:
  /// **'Notes shared with family members appear here'**
  String get notesEmptySharedHint;

  /// No description provided for @notesEmptyPrivateHint.
  ///
  /// In en, this message translates to:
  /// **'Your private notes appear here'**
  String get notesEmptyPrivateHint;

  /// No description provided for @notesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Private and shared notes appear here'**
  String get notesEmptyHint;

  /// No description provided for @notesSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get notesSaved;

  /// No description provided for @notesLastModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified'**
  String get notesLastModified;

  /// No description provided for @notesSharedBadge.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get notesSharedBadge;

  /// No description provided for @notesTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get notesTitleRequired;

  /// No description provided for @notesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get notesDeleteTitle;

  /// No description provided for @notesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The note moves to the trash. You can restore it from there.'**
  String get notesDeleteBody;

  /// No description provided for @notesTrashTooltip.
  ///
  /// In en, this message translates to:
  /// **'Deleted notes'**
  String get notesTrashTooltip;

  /// No description provided for @notesTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted notes'**
  String get notesTrashTitle;

  /// No description provided for @notesNoTrash.
  ///
  /// In en, this message translates to:
  /// **'No deleted notes'**
  String get notesNoTrash;

  /// No description provided for @notesNoTrashHint.
  ///
  /// In en, this message translates to:
  /// **'Deleted notes appear here'**
  String get notesNoTrashHint;

  /// No description provided for @notesRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get notesRestore;

  /// No description provided for @notesEmptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty trash?'**
  String get notesEmptyTrashTitle;

  /// No description provided for @notesEmptyTrashBody.
  ///
  /// In en, this message translates to:
  /// **'Deleted notes will be permanently removed. This cannot be undone.'**
  String get notesEmptyTrashBody;

  /// No description provided for @notesSharedWithFamily.
  ///
  /// In en, this message translates to:
  /// **'Shared with family'**
  String get notesSharedWithFamily;

  /// No description provided for @notesShareAllAdults.
  ///
  /// In en, this message translates to:
  /// **'All family members'**
  String get notesShareAllAdults;

  /// No description provided for @notesSharePickAdults.
  ///
  /// In en, this message translates to:
  /// **'Choose who can see this note'**
  String get notesSharePickAdults;

  /// No description provided for @notesShareAudienceHint.
  ///
  /// In en, this message translates to:
  /// **'Shared with selected members'**
  String get notesShareAudienceHint;

  /// No description provided for @notesSharedWithNames.
  ///
  /// In en, this message translates to:
  /// **'With {names}'**
  String notesSharedWithNames(String names);

  /// No description provided for @notesHideContent.
  ///
  /// In en, this message translates to:
  /// **'Require unlock'**
  String get notesHideContent;

  /// No description provided for @notesHideContentHint.
  ///
  /// In en, this message translates to:
  /// **'Hides previews and asks for biometrics or PIN to open. The note body still syncs via WebDAV unless “Keep on this device only” is on.'**
  String get notesHideContentHint;

  /// No description provided for @notesLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Keep on this device only'**
  String get notesLocalOnly;

  /// No description provided for @notesLocalOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Title and body never upload to WebDAV. Cannot share with family.'**
  String get notesLocalOnlyHint;

  /// No description provided for @notesLocalOnlyBadge.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get notesLocalOnlyBadge;

  /// No description provided for @notesLinkedTasks.
  ///
  /// In en, this message translates to:
  /// **'Linked tasks'**
  String get notesLinkedTasks;

  /// No description provided for @notesLinkTask.
  ///
  /// In en, this message translates to:
  /// **'Link tasks'**
  String get notesLinkTask;

  /// No description provided for @notesLinkTaskEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open tasks to link'**
  String get notesLinkTaskEmpty;

  /// No description provided for @notesFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'New from template'**
  String get notesFromTemplate;

  /// No description provided for @notesTemplateMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting notes'**
  String get notesTemplateMeeting;

  /// No description provided for @notesTemplateMeetingBody.
  ///
  /// In en, this message translates to:
  /// **'## Attendees\n\n## Agenda\n- \n\n## Actions\n- '**
  String get notesTemplateMeetingBody;

  /// No description provided for @notesTemplateShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get notesTemplateShopping;

  /// No description provided for @notesTemplateShoppingBody.
  ///
  /// In en, this message translates to:
  /// **'- \n- \n- '**
  String get notesTemplateShoppingBody;

  /// No description provided for @notesTemplateJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get notesTemplateJournal;

  /// No description provided for @notesTemplateJournalBody.
  ///
  /// In en, this message translates to:
  /// **'## Today\n\n## Grateful for\n- '**
  String get notesTemplateJournalBody;

  /// No description provided for @taskLinkedNotes.
  ///
  /// In en, this message translates to:
  /// **'Linked notes'**
  String get taskLinkedNotes;

  /// No description provided for @notesUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock this note'**
  String get notesUnlockReason;

  /// No description provided for @notesUnlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not unlock the note'**
  String get notesUnlockFailed;

  /// No description provided for @notesHideNeedsDeviceLock.
  ///
  /// In en, this message translates to:
  /// **'Turn on a screen lock on this device to require unlock'**
  String get notesHideNeedsDeviceLock;

  /// No description provided for @notesBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a note…'**
  String get notesBodyHint;

  /// No description provided for @notesMdBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get notesMdBold;

  /// No description provided for @notesMdItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get notesMdItalic;

  /// No description provided for @notesMdHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get notesMdHeading;

  /// No description provided for @notesMdBullet.
  ///
  /// In en, this message translates to:
  /// **'Bullet list'**
  String get notesMdBullet;

  /// No description provided for @notesMdCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Checkbox'**
  String get notesMdCheckbox;

  /// No description provided for @notesMdLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get notesMdLink;

  /// No description provided for @notesUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get notesUnsavedTitle;

  /// No description provided for @notesUnsavedBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save your changes?'**
  String get notesUnsavedBody;

  /// No description provided for @notesDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get notesDiscard;

  /// No description provided for @notesLockedBadge.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get notesLockedBadge;

  /// No description provided for @suggestWebDavRequired.
  ///
  /// In en, this message translates to:
  /// **'Link WebDAV first to send a suggestion.'**
  String get suggestWebDavRequired;

  /// No description provided for @suggestFamilyMemberSeesTitle.
  ///
  /// In en, this message translates to:
  /// **'What {name} sees'**
  String suggestFamilyMemberSeesTitle(String name);

  /// No description provided for @suggestFamilyMemberSeesGeneric.
  ///
  /// In en, this message translates to:
  /// **'Intentionally generic — no private titles or notes.'**
  String get suggestFamilyMemberSeesGeneric;

  /// No description provided for @suggestFamilyMemberSeesFull.
  ///
  /// In en, this message translates to:
  /// **'The title and any notes from this suggestion will be included.'**
  String get suggestFamilyMemberSeesFull;

  /// No description provided for @suggestSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get suggestSend;

  /// No description provided for @suggestSent.
  ///
  /// In en, this message translates to:
  /// **'Suggestion sent to {name}'**
  String suggestSent(String name);

  /// No description provided for @suggestReasonHabit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get suggestReasonHabit;

  /// No description provided for @suggestReasonFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Family complement'**
  String get suggestReasonFamilyMember;

  /// No description provided for @suggestReasonSeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get suggestReasonSeasonal;

  /// No description provided for @suggestReasonLoadBalance.
  ///
  /// In en, this message translates to:
  /// **'Load balance'**
  String get suggestReasonLoadBalance;

  /// No description provided for @suggestReasonStale.
  ///
  /// In en, this message translates to:
  /// **'Open task'**
  String get suggestReasonStale;

  /// No description provided for @suggestReasonCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get suggestReasonCalendar;

  /// No description provided for @suggestReasonCategorize.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get suggestReasonCategorize;

  /// No description provided for @suggestCategorizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set category {category} on {count} tasks?'**
  String suggestCategorizeTitle(int count, String category);

  /// No description provided for @suggestCategorizeExplanation.
  ///
  /// In en, this message translates to:
  /// **'These open tasks have no category yet. Accept only sets the label.'**
  String suggestCategorizeExplanation(int count);

  /// No description provided for @suggestLoadBalanceTitleHousehold.
  ///
  /// In en, this message translates to:
  /// **'Can you pick up something around the house this week?'**
  String get suggestLoadBalanceTitleHousehold;

  /// No description provided for @suggestLoadBalanceTitleHealth.
  ///
  /// In en, this message translates to:
  /// **'Can you pick up something around care or health this week?'**
  String get suggestLoadBalanceTitleHealth;

  /// No description provided for @suggestLoadBalanceTitleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Can you pick up something in admin this week?'**
  String get suggestLoadBalanceTitleAdmin;

  /// No description provided for @suggestLoadBalanceTitleSchool.
  ///
  /// In en, this message translates to:
  /// **'Can you pick up something around school this week?'**
  String get suggestLoadBalanceTitleSchool;

  /// No description provided for @suggestLoadBalanceTitleFinance.
  ///
  /// In en, this message translates to:
  /// **'Can you pick up something in finances this week?'**
  String get suggestLoadBalanceTitleFinance;

  /// No description provided for @suggestLoadBalanceTitleOther.
  ///
  /// In en, this message translates to:
  /// **'Can you pick something up this week?'**
  String get suggestLoadBalanceTitleOther;

  /// No description provided for @suggestLoadBalanceExplanation.
  ///
  /// In en, this message translates to:
  /// **'You have {count} open tasks in {category}. The suggestion is intentionally generic.'**
  String suggestLoadBalanceExplanation(int count, String category);

  /// No description provided for @suggestLoadBalanceExplanationGeneric.
  ///
  /// In en, this message translates to:
  /// **'You have several open tasks in {category}. The suggestion is intentionally generic.'**
  String suggestLoadBalanceExplanationGeneric(String category);

  /// No description provided for @suggestFamilyMemberTitleSchool.
  ///
  /// In en, this message translates to:
  /// **'School run or childcare this week?'**
  String get suggestFamilyMemberTitleSchool;

  /// No description provided for @suggestFamilyMemberExplanationSchool.
  ///
  /// In en, this message translates to:
  /// **'Based on your tasks (without private details), school looks like a theme this week. Your family member sees this.'**
  String get suggestFamilyMemberExplanationSchool;

  /// No description provided for @suggestFamilyMemberTitleHousehold.
  ///
  /// In en, this message translates to:
  /// **'Can you pick up something around the house this week?'**
  String get suggestFamilyMemberTitleHousehold;

  /// No description provided for @suggestFamilyMemberExplanationHousehold.
  ///
  /// In en, this message translates to:
  /// **'You have several household tasks open. The suggestion is intentionally generic.'**
  String get suggestFamilyMemberExplanationHousehold;

  /// No description provided for @suggestFamilyMemberTitleHealth.
  ///
  /// In en, this message translates to:
  /// **'Something around care or health to pick up?'**
  String get suggestFamilyMemberTitleHealth;

  /// No description provided for @suggestFamilyMemberExplanationHealth.
  ///
  /// In en, this message translates to:
  /// **'Something around care is going on. Your family member only sees this generic question.'**
  String get suggestFamilyMemberExplanationHealth;

  /// No description provided for @suggestFamilyMemberTitleSport.
  ///
  /// In en, this message translates to:
  /// **'Sports bag or training this week?'**
  String get suggestFamilyMemberTitleSport;

  /// No description provided for @suggestFamilyMemberExplanationSport.
  ///
  /// In en, this message translates to:
  /// **'Based on your tasks, sport looks like a theme. No private details.'**
  String get suggestFamilyMemberExplanationSport;

  /// No description provided for @suggestFamilyMemberTitleAdmin.
  ///
  /// In en, this message translates to:
  /// **'An admin chore this week?'**
  String get suggestFamilyMemberTitleAdmin;

  /// No description provided for @suggestFamilyMemberExplanationAdmin.
  ///
  /// In en, this message translates to:
  /// **'There is admin work open. The suggestion does not name a concrete task.'**
  String get suggestFamilyMemberExplanationAdmin;

  /// No description provided for @suggestCalendarTaxTitle.
  ///
  /// In en, this message translates to:
  /// **'Check tax return'**
  String get suggestCalendarTaxTitle;

  /// No description provided for @suggestCalendarTaxExplanation.
  ///
  /// In en, this message translates to:
  /// **'March — time to check the tax return.'**
  String get suggestCalendarTaxExplanation;

  /// No description provided for @suggestCalendarSchoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare school supplies'**
  String get suggestCalendarSchoolTitle;

  /// No description provided for @suggestCalendarSchoolExplanation.
  ///
  /// In en, this message translates to:
  /// **'August — prepare school supplies for the new year.'**
  String get suggestCalendarSchoolExplanation;

  /// No description provided for @suggestCalendarChristmasTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare for Christmas'**
  String get suggestCalendarChristmasTitle;

  /// No description provided for @suggestCalendarChristmasExplanation.
  ///
  /// In en, this message translates to:
  /// **'December — prepare for Christmas.'**
  String get suggestCalendarChristmasExplanation;

  /// No description provided for @suggestHabitRepeatExplanation.
  ///
  /// In en, this message translates to:
  /// **'You did \"{title}\" about every {median} days. Last time: {daysSince} days ago.'**
  String suggestHabitRepeatExplanation(String title, int median, int daysSince);

  /// No description provided for @suggestHabitOnceExplanation.
  ///
  /// In en, this message translates to:
  /// **'You did \"{title}\" {daysSince} days ago. Schedule again?'**
  String suggestHabitOnceExplanation(String title, int daysSince);

  /// No description provided for @suggestSeasonalExplanation.
  ///
  /// In en, this message translates to:
  /// **'You completed \"{title}\" in {month} last year.'**
  String suggestSeasonalExplanation(String title, String month);

  /// No description provided for @suggestStaleExplanation.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" has been open for {days} days without a reminder.'**
  String suggestStaleExplanation(String title, int days);

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @categoryHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get categoryHousehold;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get categoryAdmin;

  /// No description provided for @categorySchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get categorySchool;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get categoryFinance;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryTitle;

  /// No description provided for @categoryNewHint.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryNewHint;

  /// No description provided for @categoryNewAction.
  ///
  /// In en, this message translates to:
  /// **'New category…'**
  String get categoryNewAction;

  /// No description provided for @categoryRename.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get categoryRename;

  /// No description provided for @categoryRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryRenameHint;

  /// No description provided for @suggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestionsTitle;

  /// No description provided for @suggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Handy tasks to consider today'**
  String get suggestionsSubtitle;

  /// No description provided for @suggestionsProposedByFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Suggested by {name}'**
  String suggestionsProposedByFamilyMember(String name);

  /// No description provided for @tasksDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get tasksDecline;

  /// No description provided for @kidsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kidsSectionTitle;

  /// No description provided for @kidsAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All kids'**
  String get kidsAllFilter;

  /// No description provided for @kidsOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 open task} other{{count} open tasks}}'**
  String kidsOpenTasks(int count);

  /// No description provided for @kidsDeleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove kids task?'**
  String get kidsDeleteTaskTitle;

  /// No description provided for @kidsDeleteTaskBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed from the kids app.'**
  String kidsDeleteTaskBody(String title);

  /// No description provided for @kidsPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation'**
  String get kidsPendingVerification;

  /// No description provided for @kidsPendingExpandHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 waiting — open to confirm} other{{count} waiting — open to confirm}}'**
  String kidsPendingExpandHint(int count);

  /// No description provided for @kidsAcceptCompletion.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get kidsAcceptCompletion;

  /// No description provided for @kidsRejectCompletion.
  ///
  /// In en, this message translates to:
  /// **'Send back'**
  String get kidsRejectCompletion;

  /// No description provided for @kidsXpProgress.
  ///
  /// In en, this message translates to:
  /// **'{earned} / {target} XP'**
  String kidsXpProgress(int earned, int target);

  /// No description provided for @kidsXpTotal.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String kidsXpTotal(int xp);

  /// No description provided for @kidsGoalSet.
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get kidsGoalSet;

  /// No description provided for @kidsGoalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get kidsGoalEdit;

  /// No description provided for @kidsGoalRename.
  ///
  /// In en, this message translates to:
  /// **'Rename goal'**
  String get kidsGoalRename;

  /// No description provided for @kidsGoalRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove goal'**
  String get kidsGoalRemove;

  /// No description provided for @kidsGoalReset.
  ///
  /// In en, this message translates to:
  /// **'Reset XP'**
  String get kidsGoalReset;

  /// No description provided for @kidsGoalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get kidsGoalTitleLabel;

  /// No description provided for @kidsGoalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New bike'**
  String get kidsGoalTitleHint;

  /// No description provided for @kidsGoalTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'XP needed'**
  String get kidsGoalTargetLabel;

  /// No description provided for @kidsGoalSave.
  ///
  /// In en, this message translates to:
  /// **'Save goal'**
  String get kidsGoalSave;

  /// No description provided for @kidsGoalRemoved.
  ///
  /// In en, this message translates to:
  /// **'Goal removed'**
  String get kidsGoalRemoved;

  /// No description provided for @kidsGoalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved'**
  String get kidsGoalSaved;

  /// No description provided for @kidsGoalResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset XP for {name}?'**
  String kidsGoalResetTitle(String name);

  /// No description provided for @kidsGoalResetBody.
  ///
  /// In en, this message translates to:
  /// **'XP goes back to 0 and completed kids tasks are removed. The goal title and target stay.'**
  String get kidsGoalResetBody;

  /// No description provided for @kidsGoalResetDone.
  ///
  /// In en, this message translates to:
  /// **'XP reset for {name}'**
  String kidsGoalResetDone(String name);

  /// No description provided for @kidsCreateTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get kidsCreateTask;

  /// No description provided for @kidsCreateForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Create for everyone'**
  String get kidsCreateForEveryone;

  /// No description provided for @kidsCreateForName.
  ///
  /// In en, this message translates to:
  /// **'Task for {name}'**
  String kidsCreateForName(String name);

  /// No description provided for @kidsCreateForEveryoneHint.
  ///
  /// In en, this message translates to:
  /// **'Task for everyone'**
  String get kidsCreateForEveryoneHint;

  /// No description provided for @kidsXpAppliesToNamed.
  ///
  /// In en, this message translates to:
  /// **'Only for {names}'**
  String kidsXpAppliesToNamed(String names);

  /// No description provided for @kidsXpAppliesToEnabled.
  ///
  /// In en, this message translates to:
  /// **'Only for kids with XP & goals on'**
  String get kidsXpAppliesToEnabled;

  /// No description provided for @kidsXpAndGoals.
  ///
  /// In en, this message translates to:
  /// **'XP & goals'**
  String get kidsXpAndGoals;

  /// No description provided for @kidsXpAndGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show XP rewards and goals for this child'**
  String get kidsXpAndGoalsSubtitle;

  /// No description provided for @kidsWeekOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get kidsWeekOverviewTitle;

  /// No description provided for @kidsWeekOverviewLegend.
  ///
  /// In en, this message translates to:
  /// **'Due · done'**
  String get kidsWeekOverviewLegend;

  /// No description provided for @kidsWeekDayA11y.
  ///
  /// In en, this message translates to:
  /// **'{weekday}, {due} due, {done} done'**
  String kidsWeekDayA11y(String weekday, int due, int done);

  /// No description provided for @kidsOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — kids tasks sync when WebDAV is back'**
  String get kidsOfflineBanner;

  /// No description provided for @kidsPendingSync.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get kidsPendingSync;

  /// No description provided for @tasksSyncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — changes sync later'**
  String get tasksSyncOffline;

  /// No description provided for @snoozeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snooze reminder'**
  String get snoozeTitle;

  /// No description provided for @snooze10min.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get snooze10min;

  /// No description provided for @snooze1hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get snooze1hour;

  /// No description provided for @snooze3hours.
  ///
  /// In en, this message translates to:
  /// **'3 hours'**
  String get snooze3hours;

  /// No description provided for @snoozeTomorrowMorning.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow 09:00'**
  String get snoozeTomorrowMorning;

  /// No description provided for @snoozeCustom.
  ///
  /// In en, this message translates to:
  /// **'Pick a time…'**
  String get snoozeCustom;

  /// No description provided for @snoozeDone.
  ///
  /// In en, this message translates to:
  /// **'Reminder snoozed'**
  String get snoozeDone;

  /// No description provided for @reminderDone.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get reminderDone;

  /// No description provided for @noteReminderCleared.
  ///
  /// In en, this message translates to:
  /// **'Reminder cleared'**
  String get noteReminderCleared;

  /// No description provided for @quickAddHint.
  ///
  /// In en, this message translates to:
  /// **'New task…'**
  String get quickAddHint;

  /// No description provided for @quickAddMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get quickAddMoreOptions;

  /// No description provided for @notesQuickAddHint.
  ///
  /// In en, this message translates to:
  /// **'New note…'**
  String get notesQuickAddHint;

  /// No description provided for @timeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time (00:00 – 23:59).'**
  String get timeInvalid;

  /// No description provided for @timeOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get timeOk;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

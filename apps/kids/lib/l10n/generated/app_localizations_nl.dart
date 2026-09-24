// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get leaveFamilyTitle => 'Familie verlaten?';

  @override
  String get leaveFamilyMessage =>
      'De koppeling met de familie wordt verwijderd. Je lokale opdrachten blijven bewaard.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get leave => 'Verlaten';

  @override
  String get linkFamilyTitle => 'Familie koppelen';

  @override
  String get scanQrCode => 'Scan de QR-code';

  @override
  String get scanQrInstructions =>
      'Open Kinetic Link, ga naar Instellingen → Familie → Kinderenapp koppelen, scan de QR-code en typ daarna het WebDAV-wachtwoord.';

  @override
  String invalidQrCode(Object error) {
    return 'Ongeldige QR-code: $error';
  }

  @override
  String get qrCodeFoundConfirm =>
      'QR-code gevonden. Koppel dit apparaat aan de familie?';

  @override
  String get account => 'Account';

  @override
  String get server => 'Server';

  @override
  String get enterWebDavPassword =>
      'Typ het WebDAV-wachtwoord uit Kinetic Link. Dat staat niet in de QR-code.';

  @override
  String get webDavPassword => 'WebDAV-wachtwoord';

  @override
  String get link => 'Koppelen';

  @override
  String get myTasks => 'Mijn Opdrachten';

  @override
  String get sync => 'Synchroniseren';

  @override
  String get syncFailed => 'Sync mislukt — tik om opnieuw te proberen';

  @override
  String get syncOk => 'Gesynchroniseerd';

  @override
  String get leaveFamily => 'Familie verlaten';

  @override
  String errorWithDetails(Object error) {
    return 'Fout: $error';
  }

  @override
  String get allDone => 'Alles klaar!';

  @override
  String get noTasksRightNow => 'Geen opdrachten op dit moment.';

  @override
  String get stillToDo => 'Nog te doen';

  @override
  String get waitingForLink => 'Wacht op Link';

  @override
  String get completed => 'Afgerond';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityHigh => 'Hoog';

  @override
  String get priorityNormal => 'Normaal';

  @override
  String get priorityLow => 'Laag';

  @override
  String get today => 'Vandaag';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get overdue => 'Verlopen';

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Fout';

  @override
  String taskNotFound(Object error) {
    return 'Taak niet gevonden: $error';
  }

  @override
  String get taskDetails => 'Taakdetails';

  @override
  String get details => 'Gegevens';

  @override
  String get dueDate => 'Vervaldatum';

  @override
  String get noDueDate => 'Geen vervaldatum';

  @override
  String get priority => 'Prioriteit';

  @override
  String get category => 'Categorie';

  @override
  String get experience => 'Ervaring';

  @override
  String get notes => 'Opmerkingen';

  @override
  String get delete => 'Verwijderen';

  @override
  String get categoryHousehold => 'Huishouden';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryHealth => 'Gezondheid';

  @override
  String get categoryShopping => 'Boodschappen';

  @override
  String get categoryEntertainment => 'Recreatie';

  @override
  String get categoryOther => 'Overig';

  @override
  String get notificationChannelName => 'Opdrachten';

  @override
  String get notificationChannelDescription =>
      'Meldingen voor nieuwe opdrachten van Link.';

  @override
  String get newTaskNotificationTitle => 'Nieuwe opdracht';

  @override
  String get chooseLanguage => 'Kies taal';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get continueLabel => 'Doorgaan';

  @override
  String get settings => 'Instellingen';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsTheme => 'Thema';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get keepGoing => 'Ga zo door!';

  @override
  String goalProgress(int earned, int target) {
    return '$earned / $target XP';
  }

  @override
  String totalXp(int xp) {
    return '$xp XP';
  }

  @override
  String get confirmCompleteTitle => 'Klaar?';

  @override
  String get confirmCompleteBody =>
      'Weet je zeker dat je klaar bent? We sturen nu een bevestigingsvraag naar Link.';

  @override
  String get confirmCompleteAction => 'Ja, ik ben klaar';

  @override
  String get awaitingLinkConfirm => 'Wacht tot Link bevestigt';

  @override
  String get cleanUpCompleted => 'Opschonen';
}

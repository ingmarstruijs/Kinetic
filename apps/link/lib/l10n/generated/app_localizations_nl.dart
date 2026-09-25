// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get navTasks => 'Taken';

  @override
  String get navNotes => 'Notities';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonSave => 'Opslaan';

  @override
  String get commonSaving => 'Opslaan…';

  @override
  String get commonDelete => 'Verwijderen';

  @override
  String get commonOk => 'OK';

  @override
  String get commonError => 'Fout';

  @override
  String get commonImport => 'Importeren';

  @override
  String get commonContinue => 'Doorgaan';

  @override
  String get commonClose => 'Sluiten';

  @override
  String get commonBack => 'Terug';

  @override
  String get commonCopy => 'Kopiëren';

  @override
  String get commonUnknown => '(onbekend)';

  @override
  String get themeLight => 'Standaard';

  @override
  String get themeCalm => 'Kalm';

  @override
  String get themeNight => 'Nacht';

  @override
  String get themeLightDesc => 'Helder blauw';

  @override
  String get themeCalmDesc => 'Warm zand met terracotta accenten';

  @override
  String get themeNightDesc => 'OLED zwart';

  @override
  String get themeChoose => 'Thema kiezen';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsSectionAppearance => 'Uiterlijk';

  @override
  String get settingsTheme => 'Thema';

  @override
  String get settingsSectionSync => 'Synchronisatie';

  @override
  String get linkWebTitle => 'Link Web';

  @override
  String get linkWebSettingsSubtitle =>
      'Open taken in een browser op hetzelfde wifi';

  @override
  String get linkWebExperimentalBanner => 'Experimenteel';

  @override
  String get linkWebExperimentalBody =>
      'Link Web is een vroege preview. Verwacht ruwe randen, alleen lokaal wifi, en mogelijke breaking changes. Vertrouw er nog niet op voor kritieke workflows.';

  @override
  String get linkWebIntro =>
      'Open taken op je computer; de kluissleutels blijven op deze telefoon.';

  @override
  String get linkWebSteps =>
      '1. Houd dit scherm open (telefoon wakker, zelfde wifi als de computer).\n2. Open op de computer de URL hieronder — of scan de QR.\n3. Taken verschijnen automatisch in de browser.';

  @override
  String get linkWebPickIp => 'Wifi-adres';

  @override
  String get linkWebKeepAwake =>
      'Laat dit scherm open zolang je Link Web gebruikt.';

  @override
  String get linkWebCopyUrl => 'URL kopiëren';

  @override
  String get linkWebCopied => 'URL gekopieerd';

  @override
  String get linkWebRevoke => 'Intrekken & stoppen';

  @override
  String get linkWebStart => 'Bridge starten';

  @override
  String get linkWebNewSession => 'Nieuwe QR';

  @override
  String get settingsWebDavConfigure => 'WebDAV configureren';

  @override
  String get settingsWebDavConnected => 'Verbonden';

  @override
  String get settingsWebDavConnectHint =>
      'Verbind met een Nextcloud- of WebDAV-server';

  @override
  String get settingsWebDavTurnOff => 'WebDAV-sync uitzetten';

  @override
  String get settingsWebDavTurnOffTitle => 'WebDAV-sync uitzetten?';

  @override
  String get settingsWebDavTurnOffBody =>
      'Synchronisatie met de server stopt. Je verliest ook familiekoppeling, gedeelde notities, kindertaken en sync tussen apparaten. Privé-taken en -notities blijven op dit apparaat. De herstelzin blijft je lokale kluis openen.';

  @override
  String get settingsWebDavTurnOffConfirm => 'Uitzetten';

  @override
  String get settingsWebDavTurnedOff => 'WebDAV-sync uitgeschakeld.';

  @override
  String get settingsSectionFamily => 'Familie';

  @override
  String get settingsFamilyMember => 'Gezinslid';

  @override
  String get settingsFamilyMembers => 'Gezinsleden';

  @override
  String get settingsFamilyMemberLinked => 'Gezinslid gekoppeld';

  @override
  String get settingsFamilyMemberLinkHint => 'Koppel met een ander gezinslid';

  @override
  String get settingsKids => 'Kinderen';

  @override
  String get settingsKidsParticipation => 'Kindertaken op dit apparaat';

  @override
  String get settingsKidsParticipationSubtitle =>
      'Uit = dit apparaat kan kindertaken niet zien, maken, toewijzen of goedkeuren';

  @override
  String get settingsKidsLinkHint => 'Koppel de kinderenapp';

  @override
  String settingsKidsEnrolledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kinderen gekoppeld',
      one: '1 kind gekoppeld',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionVault => 'Kluis';

  @override
  String get settingsVerifyPhrase => 'Herstelzin controleren';

  @override
  String get settingsVerifyPhraseSubtitle =>
      'Controleer of je de 12 woorden nog kent. We tonen ze niet.';

  @override
  String get settingsSectionBackup => 'Back-up & Herstel';

  @override
  String get settingsExportBackup => 'Back-up exporteren';

  @override
  String get settingsExportBackupSubtitle =>
      'Versleuteld .kvault-bestand. De herstelzin zit er niet in.';

  @override
  String get settingsImportBackup => 'Back-up importeren';

  @override
  String get settingsImportBackupSubtitle =>
      'Vervangt alle data op deze telefoon';

  @override
  String notifServiceFailed(String error) {
    return 'Meldingenservice kon niet starten: $error';
  }

  @override
  String get notifDisabledBanner =>
      'Meldingen zijn uitgeschakeld. Zet ze aan in Instellingen om herinneringen te ontvangen.';

  @override
  String get notifExactAlarmBanner =>
      'Precieze herinneringen zijn uitgeschakeld. Sta \"Alarmen & herinneringen\" toe voor exacte tijden.';

  @override
  String get familyKeyScanTitle => 'Familiesleutel scannen';

  @override
  String get familyKeyScanHint => 'Richt op de QR-code van het gezinslid';

  @override
  String get familyKeyEnterPhrase => 'Zin invoeren';

  @override
  String get familyKeyFound => 'Sleutel gevonden';

  @override
  String get familyKeyLinkMember => 'Gezinslid';

  @override
  String get familyKeyServer => 'Server';

  @override
  String get familyKeyFingerprint => 'Vingerafdruk';

  @override
  String familyKeyServerMismatch(String scanned, String current) {
    return 'De server in de uitnodiging ($scanned) komt niet overeen met jouw WebDAV-server ($current). Familiesync werkt alleen als iedereen dezelfde server gebruikt — linken is geblokkeerd.';
  }

  @override
  String get familyKeyConfirmLinkMember =>
      'Is dit het juiste gezinslid? Controleer de gebruikersnaam hierboven.';

  @override
  String get familyKeyAlreadyPairedWarning =>
      'Je hebt al een familiesleutel. Als je een nieuwe importeert, wordt data die al met de huidige sleutel is versleuteld onleesbaar totdat je opnieuw synchroniseert.';

  @override
  String get familyKeyEnterTitle => 'Familiesleutel invoeren';

  @override
  String get familyKeyEnterSubtitle =>
      'Vul hun 12 woorden in. Daarna zie je de vingerafdruk ter controle.';

  @override
  String get familyKeySaved => 'Familiesleutel opgeslagen.';

  @override
  String familyKeySaveError(String error) {
    return 'Fout bij opslaan: $error';
  }

  @override
  String familyKeyInvalidQr(String error) {
    return 'Ongeldige QR-code: $error';
  }

  @override
  String get familyKeyShareTitle => 'Familiesleutel delen';

  @override
  String get familyKeyShareLegacyBody =>
      'Laat het gezinslid deze QR-code scannen. Deze familiesleutel is van vóór de herstelzin en heeft geen 12 woorden.';

  @override
  String get familyKeyShareBody =>
      'Laat het gezinslid deze QR-code scannen, of de 12 woorden typen.';

  @override
  String get familyKeyShareNoPassword =>
      'De code bevat geen WebDAV-wachtwoord. Controleer samen de vingerafdruk.';

  @override
  String get familyKeyShareNoEntropy =>
      'Geen herstelzin-gegevens op dit apparaat. Maak een nieuwe familiesleutel.';

  @override
  String familyKeyShareFingerprint(String fingerprint) {
    return 'Vingerafdruk  $fingerprint';
  }

  @override
  String get familyKeyLinkMemberScanned => 'Gezinslid heeft gescand';

  @override
  String get familyKeyShared => 'Familiesleutel gedeeld';

  @override
  String get vaultWelcomeTitle => 'Jouw kluis';

  @override
  String get vaultWelcomeBody =>
      'Kinetic Link bewaart taken en notities met een herstelzin van 12 woorden. Schrijf die zin op papier en bewaar hem veilig. We slaan de woorden niet op dit apparaat op.';

  @override
  String get vaultNewVault => 'Nieuwe kluis';

  @override
  String get vaultRestoreVault => 'Kluis herstellen';

  @override
  String get vaultCreateVault => 'Kluis aanmaken';

  @override
  String get vaultRecoveryPhrase => 'Herstelzin';

  @override
  String get vaultConfirm => 'Bevestigen';

  @override
  String get vaultWriteWords =>
      'Schrijf deze 12 woorden op papier en bewaar ze veilig. Zonder deze zin kun je de kluis niet op een nieuw apparaat herstellen.';

  @override
  String get vaultPhraseCopied => 'Herstelzin gekopieerd';

  @override
  String get vaultIWroteThemDown => 'Ik heb ze opgeschreven';

  @override
  String get vaultQuizPrompt =>
      'Vul de gevraagde woorden in om te bevestigen dat je de zin hebt bewaard.';

  @override
  String vaultWordN(int n) {
    return 'Woord $n';
  }

  @override
  String get vaultBackToWords => 'Terug naar de woorden';

  @override
  String get vaultQuizMismatch => 'Niet alle woorden kloppen. Probeer opnieuw.';

  @override
  String vaultCreateFailed(String error) {
    return 'Kon de kluis niet aanmaken: $error';
  }

  @override
  String get vaultCouldNotReadFile => 'Kon het bestand niet lezen.';

  @override
  String get vaultRestoreTitle => 'Kluis herstellen';

  @override
  String get vaultRestoreIntro =>
      'Kies hoe je de kluis terugzet. De herstelzin is in beide gevallen dezelfde.';

  @override
  String get vaultRestoreFromFile => 'Vanaf bestand';

  @override
  String get vaultRestoreFromWebDav => 'Vanaf WebDAV';

  @override
  String get vaultRestoreFromWebDavSubtitle =>
      'Server, inloggegevens en 12 woorden. Geen bestand nodig.';

  @override
  String get vaultRestoreFileTitle => 'Herstellen vanaf bestand';

  @override
  String get vaultRestoreFileBody =>
      'Vul je herstelzin in en kies daarna het .kvault-bestand.';

  @override
  String get vaultChooseFileAndRestore => 'Bestand kiezen en herstellen';

  @override
  String get vaultNoVaultOnServer =>
      'Geen kluis op deze server. Maak een nieuwe kluis of kies een andere server.';

  @override
  String get vaultPhraseMismatchServer =>
      'Deze herstelzin hoort niet bij de kluis op deze server.';

  @override
  String get vaultRestoreWebDavTitle => 'Herstellen vanaf WebDAV';

  @override
  String get vaultRestoreWebDavBody =>
      'Log in op je server en vul dezelfde 12 woorden in als bij het aanmaken van de kluis.';

  @override
  String get vaultServerUrl => 'Server-URL';

  @override
  String get vaultUsername => 'Gebruikersnaam';

  @override
  String get vaultPassword => 'Wachtwoord';

  @override
  String get vaultUnlock => 'Kluis ontgrendelen';

  @override
  String get vaultPhraseFieldLabel => 'Herstelzin (12 woorden)';

  @override
  String get vaultMigrateTitle => 'Nieuwe herstelzin';

  @override
  String get vaultMigrateBody =>
      'Je huidige sleutel is willekeurig (versie 0.2) en kan niet in 12 woorden. Taken en notities op dit apparaat blijven staan. We maken een nieuwe herstelzin. Bij de volgende sync worden persoonlijke bestanden opnieuw versleuteld. De familiesleutel blijft hetzelfde — gezinsleden en kinderen hoeven niet opnieuw te koppelen.';

  @override
  String get vaultMigrateActivate => 'Nieuwe herstelzin activeren';

  @override
  String get vaultMigrateHeadline =>
      'Schrijf deze nieuwe 12 woorden op. De oude sleutel werkt daarna niet meer voor WebDAV of een .kvault.';

  @override
  String get vaultRestoreFromFileSubtitle =>
      '12 woorden + versleuteld .kvault-bestand. Geen internet nodig.';

  @override
  String get vaultBiometricsReason => 'Toon de herstelzin op dit apparaat';

  @override
  String get vaultNoScreenLockTitle => 'Geen schermvergrendeling';

  @override
  String get vaultNoScreenLockBody =>
      'Dit apparaat heeft geen Face ID, vingerafdruk of pincode. Iedereen met toegang tot de app kan de woorden zien. Doorgaan?';

  @override
  String get vaultShowAnyway => 'Toch tonen';

  @override
  String get vaultRevealWarning =>
      'Schrijf de woorden opnieuw op papier als je de kopie kwijt bent. Laat dit scherm niet openstaan.';

  @override
  String get familyCreateTitle => 'Familiesleutel';

  @override
  String get familyCreateWriteWords =>
      'Schrijf deze 12 woorden op. Ze horen bij de familiesleutel die je deelt met gezinsleden. We slaan de woorden niet op.';

  @override
  String familyCreateFailed(String error) {
    return 'Kon de familiesleutel niet aanmaken: $error';
  }

  @override
  String get commonVerify => 'Controleren';

  @override
  String get commonLeave => 'Verlaten';

  @override
  String get relativeJustNow => 'zojuist';

  @override
  String relativeMinutesAgo(int count) {
    return '$count minuten geleden';
  }

  @override
  String relativeHoursAgo(int count) {
    return '$count uur geleden';
  }

  @override
  String get relativeYesterday => 'gisteren';

  @override
  String relativeDaysAgo(int count) {
    return '$count dagen geleden';
  }

  @override
  String get familyMemberVerifyTitle => 'Familiesleutel controleren';

  @override
  String get familyMemberVerifyBody =>
      'Vul de 12 woorden in. We tonen ze niet; we controleren alleen of ze kloppen.';

  @override
  String get familyMemberVerifyOk => 'De familiesleutel klopt.';

  @override
  String get familyMemberVerifyMismatch =>
      'Deze herstelzin hoort niet bij deze familiesleutel.';

  @override
  String get familyMemberRevealMissing =>
      'Deze familiesleutel is van voor de herstelzin (0.2) of kwam binnen als ruwe sleutel. We kunnen de woorden niet tonen. Maak een nieuwe familiesleutel en laat gezinsleden en kinderen opnieuw koppelen.';

  @override
  String get familyMemberUnlinkTitle => 'Familie verlaten?';

  @override
  String get familyMemberUnlinkBody =>
      'Alle gedeelde notities worden van dit apparaat verwijderd. Je eigen taken en privé-notities blijven behouden. Andere gezinsleden verliezen de verbinding niet — alleen jij verlaat de gedeelde werkruimte.';

  @override
  String get familyMemberShareViaQr => 'Familiesleutel delen via QR';

  @override
  String get familyMemberShareViaQrSubtitle =>
      'Laat een gezinslid de QR-code scannen om samen te werken.';

  @override
  String get familyMemberScanKey => 'Familiesleutel scannen';

  @override
  String get familyMemberScanKeySubtitle => 'Scan de QR of typ hun 12 woorden.';

  @override
  String get familyMemberReshareKey => 'Familiesleutel opnieuw delen';

  @override
  String get familyMemberReshareKeySubtitle =>
      'Deel de sleutel met een nieuw apparaat van een gezinslid.';

  @override
  String get familyMemberVerifyPhrase => 'Herstelzin controleren';

  @override
  String get familyMemberVerifyPhraseSubtitle =>
      'Controleer of je de 12 woorden van de familiesleutel nog kent.';

  @override
  String get familyMemberShowKey => 'Familiesleutel tonen';

  @override
  String get familyMemberShowKeySubtitle =>
      'Toon de 12 woorden op dit apparaat (schermvergrendeling).';

  @override
  String get familyMemberUnlink => 'Familie verlaten';

  @override
  String get familyMemberUnlinkSubtitle =>
      'Verwijder de familiesleutel en gedeelde notities van dit apparaat.';

  @override
  String get familyMemberRemoveTooltip => 'Uit familie verwijderen';

  @override
  String familyMemberRemoveTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String familyMemberRemoveBody(String name) {
    return '$name wordt uit de familielijst gehaald. Hun app ontkoppelt bij de volgende sync. De familiesleutel verandert niet automatisch — daarna kun je de wizard voor een nieuwe sleutel starten zodat zij geen nieuwe gedeelde data kunnen lezen.';
  }

  @override
  String get familyMemberRemovedFromFamily =>
      'Je bent op een ander apparaat uit de familie verwijderd.';

  @override
  String get familyKeyRotationOfferTitle => 'Nieuwe familiesleutel maken?';

  @override
  String get familyKeyRotationOfferBody =>
      'Iemand verwijderen verandert de familiesleutel niet. Maak een nieuwe sleutel en deel die met iedereen die mag blijven, zodat de verwijderde persoon geen nieuwe gedeelde data kan lezen.';

  @override
  String get familyKeyRotationOfferNow => 'Wizard starten';

  @override
  String get familyKeyRotationOfferLater => 'Niet nu';

  @override
  String get familyKeyRotationTitle => 'Nieuwe familiesleutel';

  @override
  String get familyKeyRotationIntroTitle => 'Familiesleutel roteren';

  @override
  String get familyKeyRotationIntroBody =>
      'Je noteert een nieuwe familiesleutel van 12 woorden. Gedeelde data op WebDAV wordt opnieuw versleuteld. Overgebleven gezinsleden en kinderen moeten een nieuwe QR scannen.';

  @override
  String get familyKeyRotationStart => 'Nieuwe sleutel maken';

  @override
  String get familyKeyRotationReencryptTitle =>
      'Gedeelde data opnieuw versleutelen…';

  @override
  String get familyKeyRotationReencryptPreparing => 'Gedeelde mappen scannen…';

  @override
  String familyKeyRotationReencryptProgress(int done, int total) {
    return '$done van $total bestanden';
  }

  @override
  String get familyKeyRotationShareLinkTitle => 'Delen met gezinsleden';

  @override
  String get familyKeyRotationShareLinkBody =>
      'Elke volwassene met Kinetic Link moet deze QR scannen of tap-to-link gebruiken. De oude sleutel opent geen nieuwe gedeelde data meer.';

  @override
  String get familyKeyRotationShareLinkButton => 'Familie-QR tonen';

  @override
  String get familyKeyRotationShareLinkSkip => 'Nu overslaan';

  @override
  String get familyKeyRotationShareKidsTitle => 'Kinderen opnieuw inschrijven';

  @override
  String get familyKeyRotationShareKidsBody =>
      'Elk kinderapparaat heeft een nieuwe inschrijf-QR nodig met de bijgewerkte familiesleutel.';

  @override
  String get familyKeyRotationDoneTitle => 'Familiesleutel bijgewerkt';

  @override
  String get familyKeyRotationDoneBody =>
      'Dit apparaat gebruikt de nieuwe sleutel. Zorg dat elk gezinslid en kind de nieuwe QR heeft gescand wanneer je klaar bent.';

  @override
  String get otherLinkMemberStatusPaired =>
      'Gezinslid gekoppeld — familiesleutel aanwezig';

  @override
  String get otherLinkMemberStatusUnpaired =>
      'Gezinslid niet gekoppeld — scan of deel de QR-code om te koppelen';

  @override
  String familyMemberLastSeen(String when) {
    return 'Laatst gezien $when';
  }

  @override
  String familyMemberLastSeenWarning(String when) {
    return 'Waarschuwing: laatst gezien $when';
  }

  @override
  String familyMemberFingerprint(String fingerprint) {
    return 'Vingerafdruk $fingerprint';
  }

  @override
  String get kidsLinkApp => 'Kinderenapp koppelen';

  @override
  String get kidsLinkAppSubtitle => 'Laat de kinderenapp de QR-code scannen.';

  @override
  String get kidsEnrolledSection => 'GEKOPPELDE KINDEREN';

  @override
  String get kidsNoneEnrolled => 'Nog geen kinderen gekoppeld.';

  @override
  String get kidsRemoveTooltip => 'Verwijder uit familie';

  @override
  String kidsRemoveTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String kidsRemoveBody(String name) {
    return '$name wordt uit de familielijst verwijderd. De kinderenapp kan daarna geen familietaken meer ontvangen tenzij opnieuw gekoppeld.';
  }

  @override
  String kidsEnrolledOn(String date) {
    return 'Gekoppeld op $date';
  }

  @override
  String kidsLastSeen(String when) {
    return 'Voor het laatst gezien $when';
  }

  @override
  String kidsLastSeenWarning(String when) {
    return 'Waarschuwing: voor het laatst gezien $when';
  }

  @override
  String get kidsEnrollTitle => 'Kinderenapp koppelen';

  @override
  String get kidsEnrollNameTitle => 'Naam van het kind';

  @override
  String get kidsEnrollNameBody =>
      'Voer de naam in van het kind dat je wilt koppelen.';

  @override
  String get kidsEnrollNameLabel => 'Naam kind';

  @override
  String get kidsEnrollContinueToQr => 'Doorgaan naar QR-code';

  @override
  String kidsEnrollQrTitle(String name) {
    return 'QR-code voor $name';
  }

  @override
  String kidsEnrollQrBody(String name) {
    return 'Open de kinderenapp op het toestel van $name en scan deze code.';
  }

  @override
  String get kidsEnrollWhatShared => 'Wat wordt er gedeeld?';

  @override
  String get kidsEnrollWhatSharedBody =>
      'Deze QR-code bevat de server, het account en de familiesleutel — niet het WebDAV-wachtwoord. Typ dat wachtwoord één keer op het kindertoestel. Deel de code alleen met de kinderenapp op een vertrouwd apparaat.';

  @override
  String get kidsEnrollWaitingDevice =>
      'Wachten tot het kindertoestel verbindt…';

  @override
  String get kidsEnrollKeepWaiting => 'Klaar — blijf wachten op toestel';

  @override
  String get kidsWaitingForDevice => 'Wachten op toestel';

  @override
  String get kidsMarkActive => 'Markeer als gekoppeld';

  @override
  String get kidsDraftSection => 'WACHT OP KOPPELING';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageDutch => 'Nederlands';

  @override
  String get settingsLanguageChoose => 'Taal kiezen';

  @override
  String get commonAdd => 'Toevoegen';

  @override
  String get commonSend => 'Sturen';

  @override
  String get commonRetry => 'Opnieuw proberen';

  @override
  String get commonDismiss => 'Afwijzen';

  @override
  String get commonCloseAction => 'Sluiten';

  @override
  String get commonExporting => 'Exporteren…';

  @override
  String get commonImporting => 'Importeren…';

  @override
  String get commonNone => 'Geen';

  @override
  String get commonEveryone => 'Iedereen';

  @override
  String get commonTitle => 'Titel';

  @override
  String get commonNotes => 'Notities';

  @override
  String get commonContent => 'Inhoud';

  @override
  String get commonLow => 'Laag';

  @override
  String get commonMedium => 'Middel';

  @override
  String get commonHigh => 'Hoog';

  @override
  String get commonPrivate => 'Privé';

  @override
  String get commonShared => 'Gedeeld';

  @override
  String get commonKids => 'Kinderen';

  @override
  String get commonFamilyMember => 'Gezinslid';

  @override
  String get commonReminder => 'Herinnering';

  @override
  String get commonTime => 'Tijd';

  @override
  String get commonCategory => 'Categorie';

  @override
  String get commonPriority => 'Prioriteit';

  @override
  String get commonNoCategory => 'Geen categorie';

  @override
  String commonSaveError(String error) {
    return 'Fout bij opslaan: $error';
  }

  @override
  String commonDeleteError(String error) {
    return 'Fout bij verwijderen: $error';
  }

  @override
  String relativeWeeksAgo(int count) {
    return '$count weken geleden';
  }

  @override
  String get dateToday => 'Vandaag';

  @override
  String get dateTomorrow => 'Morgen';

  @override
  String get dateYesterday => 'Gisteren';

  @override
  String dateDaysOverdue(int count) {
    return '${count}d te laat';
  }

  @override
  String dateInDays(int count) {
    return 'Over $count dagen';
  }

  @override
  String dateInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Over $count uur',
      one: 'Over 1 uur',
    );
    return '$_temp0';
  }

  @override
  String dateTonightTime(String time) {
    return 'Vanavond $time';
  }

  @override
  String dateTodayTime(String time) {
    return 'Vandaag $time';
  }

  @override
  String dateYesterdayTime(String time) {
    return 'Gisteren $time';
  }

  @override
  String dateTomorrowTime(String time) {
    return 'Morgen $time';
  }

  @override
  String get dateWeekdayMonday => 'Maandag';

  @override
  String get dateWeekdayTuesday => 'Dinsdag';

  @override
  String get dateWeekdayWednesday => 'Woensdag';

  @override
  String get dateWeekdayThursday => 'Donderdag';

  @override
  String get dateWeekdayFriday => 'Vrijdag';

  @override
  String get dateWeekdaySaturday => 'Zaterdag';

  @override
  String get dateWeekdaySunday => 'Zondag';

  @override
  String get dateWeekdayShortMonday => 'Ma';

  @override
  String get dateWeekdayShortTuesday => 'Di';

  @override
  String get dateWeekdayShortWednesday => 'Wo';

  @override
  String get dateWeekdayShortThursday => 'Do';

  @override
  String get dateWeekdayShortFriday => 'Vr';

  @override
  String get dateWeekdayShortSaturday => 'Za';

  @override
  String get dateWeekdayShortSunday => 'Zo';

  @override
  String reminderWhyHabitTime(int count, String weekday) {
    return 'Je deed deze taak $count× op $weekday';
  }

  @override
  String reminderWhyHabitInterval(int median, int daysSince) {
    return 'Ongeveer elke $median dagen, voor het laatst $daysSince dagen geleden';
  }

  @override
  String reminderWhyKeyword(String keyword) {
    return 'Komt overeen met \"$keyword\" in de titel';
  }

  @override
  String get reminderWhyCategorySchool =>
      'Schooltaken worden meestal \'s ochtends gepland';

  @override
  String get reminderWhyCategoryHousehold =>
      'Huishoudelijke taken worden vaak in het weekend gepland';

  @override
  String get reminderWhyCategoryHealth =>
      'Gezondheidstaken worden vaak \'s ochtends herinnerd';

  @override
  String get reminderWhyCategoryAdmin =>
      'Administratieve taken worden vaak overdag gepland';

  @override
  String get reminderWhyDefaultMorning => 'Standaard herinnering in de ochtend';

  @override
  String get reminderWhyEvening => 'Snelle herinnering vanavond';

  @override
  String get reminderWhyTomorrowEvening => 'Herinnering morgenavond';

  @override
  String get reminderWhyQuick => 'Snelle herinnering';

  @override
  String get dateMonthJan => 'jan';

  @override
  String get dateMonthFeb => 'feb';

  @override
  String get dateMonthMar => 'mrt';

  @override
  String get dateMonthApr => 'apr';

  @override
  String get dateMonthMay => 'mei';

  @override
  String get dateMonthJun => 'jun';

  @override
  String get dateMonthJul => 'jul';

  @override
  String get dateMonthAug => 'aug';

  @override
  String get dateMonthSep => 'sep';

  @override
  String get dateMonthOct => 'okt';

  @override
  String get dateMonthNov => 'nov';

  @override
  String get dateMonthDec => 'dec';

  @override
  String get connNotConnected => 'Niet verbonden';

  @override
  String connNotConnectedSince(String when) {
    return 'Niet verbonden sinds $when';
  }

  @override
  String get connUnknownNoSync => 'Verbinding onbekend (geen sync)';

  @override
  String connStale(String when) {
    return 'Verbinding verouderd ($when)';
  }

  @override
  String get connConnected => 'Verbonden';

  @override
  String connConnectedSince(String when) {
    return 'Verbonden ($when)';
  }

  @override
  String tasksAmbientLoadOpen(int count) {
    return '$count open';
  }

  @override
  String get tasksAmbientLoadUnknown => '—';

  @override
  String get notifChannelName => 'Taakherinneringen';

  @override
  String get notifChannelDesc => 'Herinneringen voor taken en opdrachten';

  @override
  String get notifReminderTitle => 'Herinnering';

  @override
  String get backupNoVault => 'Geen kluis op dit apparaat.';

  @override
  String backupSaved(String path) {
    return 'Back-up opgeslagen: $path';
  }

  @override
  String backupExportError(String error) {
    return 'Fout bij exporteren: $error';
  }

  @override
  String get backupVerifyTitle => 'Herstelzin controleren';

  @override
  String get backupVerifyBody =>
      'Vul je 12 woorden in. We tonen de zin niet; we controleren alleen of hij klopt.';

  @override
  String get backupVerifyOk => 'De herstelzin klopt.';

  @override
  String get backupVerifyMismatch =>
      'Deze herstelzin hoort niet bij deze kluis.';

  @override
  String get backupRevealTitle => 'Herstelzin';

  @override
  String get backupRevealMissing =>
      'We kunnen de woorden op dit apparaat niet opnieuw tonen. Gebruik je papieren kopie, of herstel de kluis met de 12 woorden.';

  @override
  String get backupImportTitle => 'Back-up importeren';

  @override
  String get backupImportBody =>
      'Vul de 12 woorden in voor dit .kvault-bestand.';

  @override
  String get backupImportOtherVaultBody =>
      'Deze back-up hoort bij een andere kluis. Vul die 12 woorden in.';

  @override
  String get backupImportOverwriteTitle => 'Alle data vervangen?';

  @override
  String get backupImportOverwriteBody =>
      'Dit wist alles op deze telefoon en zet de back-up ervoor in de plaats. Nieuwere data op dit apparaat gaat verloren.';

  @override
  String get backupImportOverwriteConfirm => 'Vervangen';

  @override
  String get backupImportWrongPhrase =>
      'Verkeerde herstelzin voor deze back-up.';

  @override
  String get backupCouldNotReadFile => 'Kon het bestand niet lezen.';

  @override
  String get backupRestored => 'Back-up succesvol hersteld.';

  @override
  String backupInvalidFile(String error) {
    return 'Ongeldig back-upbestand: $error';
  }

  @override
  String backupImportError(String error) {
    return 'Fout bij importeren: $error';
  }

  @override
  String get backupRestoring => 'Back-up herstellen…';

  @override
  String get webdavSetupTitle => 'WebDAV instellen';

  @override
  String get webdavUrlRequired => 'Vul de server-URL in';

  @override
  String get webdavUsernameRequired => 'Vul de gebruikersnaam in';

  @override
  String get webdavPasswordRequired => 'Vul het wachtwoord in';

  @override
  String get webdavTestConnection => 'Verbinding testen';

  @override
  String get webdavTestingConnection => 'Verbinding testen…';

  @override
  String get webdavConnectionOk => 'Verbinding geslaagd';

  @override
  String get webdavErrorAuth => 'Verkeerde gebruikersnaam of wachtwoord.';

  @override
  String get webdavErrorNoWebDav =>
      'Deze server lijkt geen WebDAV te ondersteunen. Controleer de URL (bij Nextcloud vaak …/remote.php/dav).';

  @override
  String get webdavErrorTimeout =>
      'Verbinding time-out. Controleer de server-URL en je netwerk.';

  @override
  String get webdavErrorUnreachable =>
      'Server niet bereikbaar. Controleer de URL en je netwerk.';

  @override
  String get webdavTestFirst => 'Test de verbinding eerst voordat je opslaat.';

  @override
  String get webdavCreateVaultFirst =>
      'Maak eerst een kluis voordat je WebDAV koppelt.';

  @override
  String get webdavPhraseMismatchServer =>
      'Op deze server staat al een kluis die niet bij jouw herstelzin past.';

  @override
  String get webdavConfigSaved => 'WebDAV-configuratie opgeslagen.';

  @override
  String webdavSaveError(String error) {
    return 'Fout bij opslaan: $error';
  }

  @override
  String get webdavMigrationTitle => 'Bestaande gegevens gevonden';

  @override
  String get webdavMigrationIntro =>
      'Op de WebDAV-server staan al versleutelde bestanden:';

  @override
  String webdavMigrationTaskFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '  • $count taakbestanden',
      one: '  • 1 taakbestand',
    );
    return '$_temp0';
  }

  @override
  String webdavMigrationNoteFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '  • $count notitiebestanden',
      one: '  • 1 notitiebestand',
    );
    return '$_temp0';
  }

  @override
  String get webdavMigrationChoose =>
      'Deze bestanden zijn versleuteld met een kluis. Kies hoe je verder wilt gaan:';

  @override
  String get webdavMigrationCleanOption =>
      '1. Schone installatie — verwijder de oude bestanden op de server en begin opnieuw.';

  @override
  String get webdavMigrationImportOption =>
      '2. Back-up importeren — vervangt alle data op deze telefoon met een .kvault-bestand.';

  @override
  String get webdavMigrationClean => 'Schone installatie';

  @override
  String get webdavMigrationImport => 'Back-up importeren';

  @override
  String get webdavBackupRestoredSync =>
      'Back-up hersteld. De app synchroniseert nu met de server.';

  @override
  String webdavRestoreError(String error) {
    return 'Fout bij herstellen van back-up: $error';
  }

  @override
  String webdavMigrationCheckFailed(String error) {
    return 'Migratiecontrole mislukt: $error';
  }

  @override
  String webdavFilesDeleted(int count) {
    return '$count bestanden verwijderd.';
  }

  @override
  String webdavCleanupError(String error) {
    return 'Fout bij opschonen: $error';
  }

  @override
  String get tasksTitle => 'Taken';

  @override
  String get tasksSectionTitle => 'Taken';

  @override
  String get tasksCompletedTooltip => 'Voltooide taken';

  @override
  String get tasksSyncFailed => 'Sync mislukt, tap om opnieuw te proberen.';

  @override
  String get tasksSyncing => 'Synchroniseren';

  @override
  String get syncStatusTitle => 'Syncstatus';

  @override
  String get syncStatusIdle => 'Bijgewerkt';

  @override
  String get syncStatusSyncing => 'Synchroniseren…';

  @override
  String get syncStatusError => 'Sync mislukt';

  @override
  String get syncStatusRetry => 'Opnieuw synchroniseren';

  @override
  String get syncStatusNeverSynced => 'Nog niet gesynchroniseerd';

  @override
  String syncStatusLastSuccess(String when) {
    return 'Laatst geslaagd: $when';
  }

  @override
  String get syncErrorTimeout =>
      'Sync time-out. Controleer je verbinding en probeer opnieuw.';

  @override
  String get syncErrorAuth =>
      'WebDAV-login mislukt. Controleer gebruikersnaam en wachtwoord.';

  @override
  String get syncErrorNetwork =>
      'Server niet bereikbaar. Controleer je verbinding.';

  @override
  String get syncErrorGeneric =>
      'Sync mislukt. Probeer opnieuw of controleer WebDAV-instellingen.';

  @override
  String get settingsSyncHealthIdle => 'Gesynchroniseerd';

  @override
  String get settingsSyncHealthSyncing => 'Synchroniseren…';

  @override
  String get settingsSyncHealthError => 'Syncfout — tik voor details';

  @override
  String get settingsSyncHealthNever => 'Nog niet gesynchroniseerd';

  @override
  String get settingsStartFamily => 'Gezin starten';

  @override
  String get settingsStartFamilyHint =>
      'Begeleide setup: WebDAV, leden en kids';

  @override
  String get familySetupPromptTitle => 'Gezin instellen?';

  @override
  String get familySetupPromptBody =>
      'WebDAV-sync staat aan, maar je hebt nog geen gezin gekoppeld. Gedeelde notities, kindertaken en familiesync tussen apparaten vragen om een familiesleutel.';

  @override
  String get familySetupPromptIgnore => 'Negeren';

  @override
  String familySetupPromptRemind(int days) {
    return 'Herinner over $days dagen';
  }

  @override
  String get familySetupPromptStart => 'Start guide';

  @override
  String get webdavJoinFamilyTitle => 'Gezin koppelen?';

  @override
  String get webdavJoinFamilyBody =>
      'Er gebruikt al iemand Kinetic op deze map.';

  @override
  String webdavJoinFamilyMembersOne(String name) {
    return '$name staat hier al.';
  }

  @override
  String webdavJoinFamilyMembersMany(int count) {
    return 'Al aanwezig:';
  }

  @override
  String get webdavJoinFamilySharedOnly => 'Gezinsdata gevonden.';

  @override
  String get webdavJoinFamilyLink => 'Nu koppelen';

  @override
  String get webdavJoinFamilyLater => 'Niet nu';

  @override
  String get webdavFamilyRestored =>
      'Familiesleutel hersteld vanaf deze server.';

  @override
  String get wizardTitle => 'Gezin starten';

  @override
  String get wizardStepWebDav => 'WebDAV verbinden';

  @override
  String get wizardStepFamily => 'Gezin maken of joinen';

  @override
  String get wizardStepInvite => 'Gezinslid uitnodigen';

  @override
  String get wizardStepKids => 'Kind inschrijven';

  @override
  String get wizardStepDone => 'Klaar';

  @override
  String get wizardSkip => 'Overslaan';

  @override
  String get wizardNext => 'Verder';

  @override
  String get wizardDone => 'Klaar';

  @override
  String get wizardInviteHint =>
      'Deel je familiesleutel met QR of houd telefoons dichtbij (tap to link).';

  @override
  String get wizardKidsPasswordHint =>
      'Het kind heeft nog het WebDAV-wachtwoord nodig — dat zit niet in de QR. Deel het apart.';

  @override
  String get wizardFirstSuccessHint =>
      'Probeer een gedeelde notitie of ken een kid-taak toe om sync te zien.';

  @override
  String get wizardOpenTasks => 'Naar taken';

  @override
  String get bleShareTitle => 'Tik om te delen';

  @override
  String get bleJoinTitle => 'Tik om te joinen';

  @override
  String get bleSearching => 'Zoeken naar een Kinetic-telefoon in de buurt…';

  @override
  String get bleAdvertising => 'Klaar — houd de andere telefoon dichtbij';

  @override
  String get bleConfirmTitle => 'Koppelen toestaan?';

  @override
  String bleConfirmBody(String name) {
    return '$name wil bij je gezin.';
  }

  @override
  String get bleConfirmAllow => 'Toestaan';

  @override
  String get bleConfirmDeny => 'Weigeren';

  @override
  String get bleSuccess => 'Gekoppeld';

  @override
  String get bleFailed => 'Koppelen via Bluetooth mislukt. Probeer QR.';

  @override
  String get bleUnavailable =>
      'Bluetooth niet beschikbaar. Gebruik de QR-code.';

  @override
  String get bleTimeout =>
      'Geen telefoon in de buurt. Kom dichterbij of gebruik QR.';

  @override
  String get tasksForYou => 'Voor jou';

  @override
  String tasksForFamilyMember(String name) {
    return 'Voor $name';
  }

  @override
  String tasksFromFamilyMember(String name) {
    return 'Van $name';
  }

  @override
  String get tasksForFamily => 'Voor familie';

  @override
  String get tasksFromFamily => 'Van familie';

  @override
  String get familyMemberGenericName => 'gezinslid';

  @override
  String get tasksAccept => 'Accepteren';

  @override
  String tasksXpResetTitle(String name) {
    return 'XP resetten voor $name?';
  }

  @override
  String get tasksXpResetBody =>
      'Dit stelt de XP-teller terug naar 0. De opdrachten blijven bewaard.';

  @override
  String get tasksXpResetAction => 'Resetten';

  @override
  String tasksXpResetDone(String name) {
    return 'XP gereset voor $name';
  }

  @override
  String tasksXpResetError(String error) {
    return 'Fout bij resetten: $error';
  }

  @override
  String get tasksLoadKidsError => 'Fout bij laden van kinderopdrachten';

  @override
  String get tasksNoKidsAssignments => 'Geen opdrachten';

  @override
  String get tasksResetXp => 'Reset XP';

  @override
  String tasksDoneOn(int day, int month) {
    return 'Gedaan op $day/$month';
  }

  @override
  String get tasksCompletedTitle => 'Voltooide taken';

  @override
  String get tasksDeleteAll => 'Verwijder alles';

  @override
  String get tasksDeleteCompletedTitle => 'Voltooide taken verwijderen';

  @override
  String get tasksDeleteCompletedBody =>
      'Weet je zeker dat je alle voltooide taken wilt verwijderen? Dit kan niet ongedaan worden gemaakt.';

  @override
  String get tasksAllDone => 'Alles klaar!';

  @override
  String get tasksNoOpenTasks => 'Je hebt geen openstaande taken';

  @override
  String get tasksNoPersonalOpen => 'Geen persoonlijke taken open';

  @override
  String get tasksNoCompleted => 'Geen voltooide taken';

  @override
  String get tasksNoCompletedHint => 'Voltooide taken verschijnen hier';

  @override
  String get tasksAssignment => 'Opdracht';

  @override
  String get taskDeleteTitle => 'Taak verwijderen?';

  @override
  String taskDeleteBody(String title) {
    return '\"$title\" wordt definitief verwijderd. Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get taskForwardTitle => 'Taak doorsturen';

  @override
  String get taskAssignmentCreated => 'Opdracht aangemaakt ✓';

  @override
  String get taskNoConnectedFamily => 'Geen verbonden gezinsleden of kinderen';

  @override
  String get taskStaleConnectionTitle => 'Verbinding verouderd';

  @override
  String taskStaleFamilyMemberBody(String status) {
    return 'Dit gezinslid is voor het laatst gezien $status. Toch sturen?';
  }

  @override
  String taskStaleKidBody(String name, String status) {
    return '$name is voor het laatst gezien $status. Toch sturen?';
  }

  @override
  String get taskSendAnyway => 'Toch sturen';

  @override
  String get familyMemberPickerTitle => 'Naar welk gezinslid sturen?';

  @override
  String taskSendToFamilyMemberTitle(String name) {
    return 'Stuur naar $name?';
  }

  @override
  String taskSendToFamilyMemberBody(String title, String name) {
    return '\"$title\" wordt als voorstel naar $name gestuurd en verdwijnt uit jouw lijst zodra zij/hij het accepteert.';
  }

  @override
  String taskSendToKidTitle(String name) {
    return 'Stuur naar $name?';
  }

  @override
  String get taskSendToKidBody =>
      'De taak verdwijnt uit jouw lijst zodra het kind hem afrondt.';

  @override
  String taskSendToKidLead(String title, String name) {
    return '\"$title\" wordt als opdracht naar $name gestuurd.';
  }

  @override
  String get taskSendToEveryoneSubtitle =>
      'Zichtbaar voor alle gekoppelde kinderen';

  @override
  String get taskSendToEveryoneBody =>
      'Elk gekoppeld kind ziet deze opdracht. Hij verdwijnt uit jouw lijst zodra een kind hem afrondt.';

  @override
  String get taskXpReward => 'XP beloning:';

  @override
  String get taskNameHint => 'Taaknaam';

  @override
  String get taskAddTime => 'Tijd toevoegen';

  @override
  String get taskAddCategory => 'Categorie toevoegen';

  @override
  String get taskRepeat => 'Herhalen';

  @override
  String get taskForward => 'Doorsturen';

  @override
  String get taskAssignToLabel => 'Toewijzen aan';

  @override
  String get taskAssignToMe => 'Mij';

  @override
  String get taskRecurrenceNone => 'Geen herhaling';

  @override
  String get taskRecurrenceDaily => 'Dagelijks';

  @override
  String get taskRecurrenceWeekdays => 'Werkdagen';

  @override
  String get taskRecurrenceWeekly => 'Wekelijks';

  @override
  String get taskRecurrenceBiweekly => 'Tweewekelijks';

  @override
  String get taskRecurrenceMonthly => 'Maandelijks';

  @override
  String get notesTitle => 'Notities';

  @override
  String get notesTabPrivate => 'Privé';

  @override
  String get notesTabShared => 'Gedeeld';

  @override
  String get notesNewTooltip => 'Nieuwe notitie';

  @override
  String get notesLoadError => 'Fout bij laden notities';

  @override
  String get notesEmptyShared => 'Geen gedeelde notities';

  @override
  String get notesEmptyPrivate => 'Geen privé notities';

  @override
  String get notesEmpty => 'Geen notities';

  @override
  String get notesEmptySharedHint =>
      'Notities gedeeld met gezinsleden verschijnen hier';

  @override
  String get notesEmptyPrivateHint => 'Je privé notities verschijnen hier';

  @override
  String get notesEmptyHint => 'Privé- en gedeelde notities verschijnen hier';

  @override
  String get notesSaved => 'Notitie opgeslagen';

  @override
  String get notesLastModified => 'Laatst gewijzigd';

  @override
  String get notesSharedBadge => 'Gedeeld';

  @override
  String get notesTitleRequired => 'Titel is verplicht';

  @override
  String get notesDeleteTitle => 'Notitie verwijderen?';

  @override
  String get notesDeleteBody =>
      'De notitie gaat naar de prullenbak. Je kunt hem daar terugzetten.';

  @override
  String get notesTrashTooltip => 'Verwijderde notities';

  @override
  String get notesTrashTitle => 'Verwijderde notities';

  @override
  String get notesNoTrash => 'Geen verwijderde notities';

  @override
  String get notesNoTrashHint => 'Verwijderde notities verschijnen hier';

  @override
  String get notesRestore => 'Terugzetten';

  @override
  String get notesEmptyTrashTitle => 'Prullenbak legen?';

  @override
  String get notesEmptyTrashBody =>
      'Verwijderde notities worden definitief gewist. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get notesSharedWithFamily => 'Gedeeld met gezin';

  @override
  String get notesShareAllAdults => 'Alle gezinsleden';

  @override
  String get notesSharePickAdults => 'Kies wie deze notitie mag zien';

  @override
  String get notesShareAudienceHint => 'Gedeeld met geselecteerde leden';

  @override
  String notesSharedWithNames(String names) {
    return 'Met $names';
  }

  @override
  String get notesHideContent => 'Ontgrendelen vereisen';

  @override
  String get notesHideContentHint =>
      'Verbergt voorvertoningen en vraagt biometrie of pincode bij openen. De inhoud sync nog via WebDAV, tenzij ‘Alleen op dit apparaat’ aan staat.';

  @override
  String get notesLocalOnly => 'Alleen op dit apparaat';

  @override
  String get notesLocalOnlyHint =>
      'Titel en inhoud worden nooit naar WebDAV geüpload. Delen met gezin kan niet.';

  @override
  String get notesLocalOnlyBadge => 'Dit apparaat';

  @override
  String get notesLinkedTasks => 'Gekoppelde taken';

  @override
  String get notesLinkTask => 'Taken koppelen';

  @override
  String get notesLinkTaskEmpty => 'Geen open taken om te koppelen';

  @override
  String get notesFromTemplate => 'Nieuw van sjabloon';

  @override
  String get notesTemplateMeeting => 'Vergadernotities';

  @override
  String get notesTemplateMeetingBody =>
      '## Aanwezigen\n\n## Agenda\n- \n\n## Acties\n- ';

  @override
  String get notesTemplateShopping => 'Boodschappenlijst';

  @override
  String get notesTemplateShoppingBody => '- \n- \n- ';

  @override
  String get notesTemplateJournal => 'Dagboek';

  @override
  String get notesTemplateJournalBody => '## Vandaag\n\n## Dankbaar voor\n- ';

  @override
  String get taskLinkedNotes => 'Gekoppelde notities';

  @override
  String get notesUnlockReason => 'Ontgrendel deze notitie';

  @override
  String get notesUnlockFailed => 'Notitie kon niet worden ontgrendeld';

  @override
  String get notesHideNeedsDeviceLock =>
      'Zet een schermvergrendeling aan om ontgrendelen te vereisen';

  @override
  String get notesBodyHint => 'Schrijf een notitie…';

  @override
  String get notesMdBold => 'Vet';

  @override
  String get notesMdItalic => 'Cursief';

  @override
  String get notesMdHeading => 'Kop';

  @override
  String get notesMdBullet => 'Opsomming';

  @override
  String get notesMdCheckbox => 'Checkbox';

  @override
  String get notesMdLink => 'Link';

  @override
  String get notesUnsavedTitle => 'Niet-opgeslagen wijzigingen';

  @override
  String get notesUnsavedBody => 'Wil je je wijzigingen opslaan?';

  @override
  String get notesDiscard => 'Verwerpen';

  @override
  String get notesLockedBadge => 'Vergrendeld';

  @override
  String get suggestWebDavRequired =>
      'Koppel eerst WebDAV om een voorstel te sturen.';

  @override
  String suggestFamilyMemberSeesTitle(String name) {
    return 'Dit ziet $name';
  }

  @override
  String get suggestFamilyMemberSeesGeneric =>
      'Bewust algemeen — geen privé-titels of notities.';

  @override
  String get suggestFamilyMemberSeesFull =>
      'Titel en eventuele notities van deze suggestie gaan mee.';

  @override
  String get suggestSend => 'Versturen';

  @override
  String suggestSent(String name) {
    return 'Voorstel naar $name gestuurd';
  }

  @override
  String get suggestReasonHabit => 'Gewoonte';

  @override
  String get suggestReasonFamilyMember => 'Gezinsaanvulling';

  @override
  String get suggestReasonSeasonal => 'Seizoensgebonden';

  @override
  String get suggestReasonLoadBalance => 'Taakverdeling';

  @override
  String get suggestReasonStale => 'Open taak';

  @override
  String get suggestReasonCalendar => 'Kalender';

  @override
  String get suggestReasonCategorize => 'Categorie';

  @override
  String suggestCategorizeTitle(int count, String category) {
    return 'Categorie $category zetten op $count taken?';
  }

  @override
  String suggestCategorizeExplanation(int count) {
    return 'Deze open taken hebben nog geen categorie. Accepteren zet alleen het label.';
  }

  @override
  String get suggestLoadBalanceTitleHousehold =>
      'Kun jij deze week iets in huis oppakken?';

  @override
  String get suggestLoadBalanceTitleHealth =>
      'Kun jij deze week iets rond zorg of gezondheid oppakken?';

  @override
  String get suggestLoadBalanceTitleAdmin =>
      'Kun jij deze week iets administratiefs oppakken?';

  @override
  String get suggestLoadBalanceTitleSchool =>
      'Kun jij deze week iets rond school oppakken?';

  @override
  String get suggestLoadBalanceTitleFinance =>
      'Kun jij deze week iets rond financiën oppakken?';

  @override
  String get suggestLoadBalanceTitleOther => 'Kun jij deze week iets oppakken?';

  @override
  String suggestLoadBalanceExplanation(int count, String category) {
    return 'Je hebt $count open taken in $category. De hint is bewust algemeen.';
  }

  @override
  String suggestLoadBalanceExplanationGeneric(String category) {
    return 'Je hebt meerdere open taken in $category. De hint is bewust algemeen.';
  }

  @override
  String get suggestFamilyMemberTitleSchool =>
      'Schoolrondje of opvang deze week?';

  @override
  String get suggestFamilyMemberExplanationSchool =>
      'Op basis van je taken (zonder privédetails) lijkt school een thema deze week. Je gezinslid ziet dit.';

  @override
  String get suggestFamilyMemberTitleHousehold =>
      'Kun jij deze week iets in huis oppakken?';

  @override
  String get suggestFamilyMemberExplanationHousehold =>
      'Je hebt meerdere huishoudelijke taken open. De hint is bewust algemeen.';

  @override
  String get suggestFamilyMemberTitleHealth =>
      'Iets rond zorg of gezondheid oppakken?';

  @override
  String get suggestFamilyMemberExplanationHealth =>
      'Er speelt iets rond zorg. Je gezinslid ziet alleen deze algemene vraag.';

  @override
  String get suggestFamilyMemberTitleSport => 'Sporttas of training deze week?';

  @override
  String get suggestFamilyMemberExplanationSport =>
      'Op basis van je taken lijkt sport een thema. Geen privédetails.';

  @override
  String get suggestFamilyMemberTitleAdmin =>
      'Een administratieve klus deze week?';

  @override
  String get suggestFamilyMemberExplanationAdmin =>
      'Er staat administratie open. De hint noemt geen concrete taak.';

  @override
  String get suggestCalendarTaxTitle => 'Belastingaangifte controleren';

  @override
  String get suggestCalendarTaxExplanation =>
      'Maart — tijd om de belastingaangifte te controleren.';

  @override
  String get suggestCalendarSchoolTitle => 'Schoolspullen klaarzetten';

  @override
  String get suggestCalendarSchoolExplanation =>
      'Augustus — schoolspullen klaarzetten voor het nieuwe jaar.';

  @override
  String get suggestCalendarChristmasTitle => 'Kerst voorbereiden';

  @override
  String get suggestCalendarChristmasExplanation =>
      'December — kerst voorbereiden.';

  @override
  String suggestHabitRepeatExplanation(
    String title,
    int median,
    int daysSince,
  ) {
    return 'Je deed \"$title\" ongeveer elke $median dagen. Vorige keer: $daysSince dagen geleden.';
  }

  @override
  String suggestHabitOnceExplanation(String title, int daysSince) {
    return 'Je deed \"$title\" $daysSince dagen geleden. Opnieuw inplannen?';
  }

  @override
  String suggestSeasonalExplanation(String title, String month) {
    return 'Je hebt \"$title\" vorig jaar in $month afgerond.';
  }

  @override
  String suggestStaleExplanation(String title, int days) {
    return '\"$title\" staat $days dagen open zonder herinnering.';
  }

  @override
  String get monthJanuary => 'januari';

  @override
  String get monthFebruary => 'februari';

  @override
  String get monthMarch => 'maart';

  @override
  String get monthApril => 'april';

  @override
  String get monthMay => 'mei';

  @override
  String get monthJune => 'juni';

  @override
  String get monthJuly => 'juli';

  @override
  String get monthAugust => 'augustus';

  @override
  String get monthSeptember => 'september';

  @override
  String get monthOctober => 'oktober';

  @override
  String get monthNovember => 'november';

  @override
  String get monthDecember => 'december';

  @override
  String get categoryHousehold => 'Huishouden';

  @override
  String get categoryHealth => 'Gezondheid';

  @override
  String get categoryAdmin => 'Administratie';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryFinance => 'Financiën';

  @override
  String get categoryOther => 'Overig';

  @override
  String get categoryTitle => 'Categorie';

  @override
  String get categoryNewHint => 'Nieuwe categorie';

  @override
  String get categoryNewAction => 'Nieuwe categorie…';

  @override
  String get categoryRename => 'Categorie hernoemen';

  @override
  String get categoryRenameHint => 'Categorienaam';

  @override
  String get suggestionsTitle => 'Suggesties';

  @override
  String get suggestionsSubtitle => 'Handige taken om vandaag te overwegen';

  @override
  String suggestionsProposedByFamilyMember(String name) {
    return 'Voorgesteld door $name';
  }

  @override
  String get tasksDecline => 'Weigeren';

  @override
  String get kidsSectionTitle => 'Kinderen';

  @override
  String get kidsAllFilter => 'Alle kinderen';

  @override
  String kidsOpenTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open taken',
      one: '1 open taak',
    );
    return '$_temp0';
  }

  @override
  String get kidsDeleteTaskTitle => 'Kindertaak verwijderen?';

  @override
  String kidsDeleteTaskBody(String title) {
    return '\"$title\" verdwijnt uit de kinderenapp.';
  }

  @override
  String get kidsPendingVerification => 'Wacht op bevestiging';

  @override
  String kidsPendingExpandHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wachten — klap open om te bevestigen',
      one: '1 wacht — klap open om te bevestigen',
    );
    return '$_temp0';
  }

  @override
  String get kidsAcceptCompletion => 'Accepteren';

  @override
  String get kidsRejectCompletion => 'Terugsturen';

  @override
  String kidsXpProgress(int earned, int target) {
    return '$earned / $target XP';
  }

  @override
  String kidsXpTotal(int xp) {
    return '$xp XP';
  }

  @override
  String get kidsGoalSet => 'Goal instellen';

  @override
  String get kidsGoalEdit => 'Goal bewerken';

  @override
  String get kidsGoalRename => 'Goal hernoemen';

  @override
  String get kidsGoalRemove => 'Goal verwijderen';

  @override
  String get kidsGoalReset => 'XP resetten';

  @override
  String get kidsGoalTitleLabel => 'Goal';

  @override
  String get kidsGoalTitleHint => 'bijv. Nieuwe fiets';

  @override
  String get kidsGoalTargetLabel => 'XP nodig';

  @override
  String get kidsGoalSave => 'Goal opslaan';

  @override
  String get kidsGoalRemoved => 'Goal verwijderd';

  @override
  String get kidsGoalSaved => 'Goal opgeslagen';

  @override
  String kidsGoalResetTitle(String name) {
    return 'XP resetten voor $name?';
  }

  @override
  String get kidsGoalResetBody =>
      'XP gaat terug naar 0 en voltooide kindertaken verdwijnen. De goal-tekst en target blijven.';

  @override
  String kidsGoalResetDone(String name) {
    return 'XP gereset voor $name';
  }

  @override
  String get kidsCreateTask => 'Taak maken';

  @override
  String get kidsCreateForEveryone => 'Voor iedereen maken';

  @override
  String kidsCreateForName(String name) {
    return 'Taak voor $name';
  }

  @override
  String get kidsCreateForEveryoneHint => 'Taak voor iedereen';

  @override
  String kidsXpAppliesToNamed(String names) {
    return 'Alleen voor $names';
  }

  @override
  String get kidsXpAppliesToEnabled =>
      'Alleen voor kinderen met XP & goals aan';

  @override
  String get kidsXpAndGoals => 'XP & goals';

  @override
  String get kidsXpAndGoalsSubtitle =>
      'Toon XP-beloningen en goals voor dit kind';

  @override
  String get kidsWeekOverviewTitle => 'Deze week';

  @override
  String get kidsWeekOverviewLegend => 'Te doen · klaar';

  @override
  String kidsWeekDayA11y(String weekday, int due, int done) {
    return '$weekday, $due te doen, $done klaar';
  }

  @override
  String get kidsOfflineBanner =>
      'Offline — kindertaken synchroniseren als WebDAV terug is';

  @override
  String get kidsPendingSync => 'Wacht op sync';

  @override
  String get tasksSyncOffline => 'Offline — wijzigingen synchroniseren later';

  @override
  String get snoozeTitle => 'Herinnering uitstellen';

  @override
  String get snooze10min => '10 minuten';

  @override
  String get snooze1hour => '1 uur';

  @override
  String get snooze3hours => '3 uur';

  @override
  String get snoozeTomorrowMorning => 'Morgen 09:00';

  @override
  String get snoozeCustom => 'Kies een tijd…';

  @override
  String get snoozeDone => 'Herinnering uitgesteld';

  @override
  String get reminderDone => 'Taak afgerond';

  @override
  String get noteReminderCleared => 'Herinnering gewist';

  @override
  String get quickAddHint => 'Nieuwe taak…';

  @override
  String get quickAddMoreOptions => 'Meer opties';

  @override
  String get notesQuickAddHint => 'Nieuwe notitie…';

  @override
  String get timeInvalid => 'Voer een geldige tijd in (00:00 – 23:59).';

  @override
  String get timeOk => 'OK';
}

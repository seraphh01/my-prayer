import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

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
    Locale('ro')
  ];

  /// App name shown on the splash screen and browser/window title.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciuni și cântări'**
  String get appTitle;

  /// Congregation name shown on the splash screen and about/settings pages.
  ///
  /// In ro, this message translates to:
  /// **'Congregația Surorilor Maicii Domnului'**
  String get congregationTitle;

  /// Generic loading placeholder.
  ///
  /// In ro, this message translates to:
  /// **'Se încarcă…'**
  String get loading;

  /// Title of the home 'today's prayers' summary tile.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciuni de azi'**
  String get todayPrayersTileTitle;

  /// Retry button label after a load failure.
  ///
  /// In ro, this message translates to:
  /// **'Reîncearcă'**
  String get retry;

  /// Error shown when the prayer catalog fails to load.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunile nu au putut fi încărcate. Vă rugăm să încercați din nou mai târziu sau verificați conexiunea la internet.'**
  String get prayersLoadError;

  /// Shown when a catalog search returns no results.
  ///
  /// In ro, this message translates to:
  /// **'Nu există rugăciuni cu acest nume.'**
  String get noSearchResults;

  /// Shown on the home page when there are no prayers recommended for today.
  ///
  /// In ro, this message translates to:
  /// **'Nicio recomandare pentru astăzi. Deschide calendarul pentru rugăciunile zilei.'**
  String get noTodayRecommendation;

  /// Snackbar shown when a saved/favorite prayer reference can no longer be resolved.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunea salvată nu este validă. Vă rugăm să salvați o rugăciune din nou.'**
  String get invalidSavedPrayer;

  /// Home page section header above the prayer type catalog.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciuni și cântări'**
  String get homeCatalogSectionTitle;

  /// Home page section header for the last opened prayer.
  ///
  /// In ro, this message translates to:
  /// **'Continuă de unde ai rămas'**
  String get continueWhereYouLeftOff;

  /// Home page section header / label for favorite prayers.
  ///
  /// In ro, this message translates to:
  /// **'Favorite'**
  String get favorites;

  /// Hint text of the home page search field.
  ///
  /// In ro, this message translates to:
  /// **'Caută rugăciuni și cântări'**
  String get searchHint;

  /// Home page section header for today's prayers, with the formatted date.
  ///
  /// In ro, this message translates to:
  /// **'Pentru astăzi · {date}'**
  String todaySectionLabel(String date);

  /// No description provided for @aboutPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Cine suntem'**
  String get aboutPageTitle;

  /// No description provided for @aboutParagraph1.
  ///
  /// In ro, this message translates to:
  /// **'Această aplicație este un proiect al Congregației Surorilor Maicii Domnului, care își are sediul Casei Generale în Cluj-Napoca, România.'**
  String get aboutParagraph1;

  /// No description provided for @aboutParagraph2.
  ///
  /// In ro, this message translates to:
  /// **'Congregația Surorilor Maicii Domnului (CMD) a fost întemeiată la Blaj, în 2 februarie 1921, de Mitropolitul Dr. Vasile Suciu, și așezată sub ocrotirea Preasfintei Fecioare Maria. De la începuturi, viața Surorilor s-a fundamentat pe rugăciune, muncă și slujirea aproapelui.'**
  String get aboutParagraph2;

  /// No description provided for @aboutParagraph3.
  ///
  /// In ro, this message translates to:
  /// **'Spiritualitatea CMD își are izvorul în Cuvântul lui Dumnezeu, în viața liturgică a Bisericii și în exemplul Preasfintei Fecioare Maria.'**
  String get aboutParagraph3;

  /// No description provided for @aboutParagraph4.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunea liturgică, celebrată în tradiția bizantină, se află în centrul vieții comunităților CMD și dă ritm fiecărei zile. Prin această aplicație, Surorile împărtășesc o parte din comoara spirituală moștenită în cei peste 100 de ani de existență celor care vor să descopere sau să aprofundeze rugăciunile și cântările greco-catolice.'**
  String get aboutParagraph4;

  /// No description provided for @aboutParagraph5.
  ///
  /// In ro, this message translates to:
  /// **'Aplicația cuprinde rugăciuni pentru diferitele momente ale zilei, precum și cântări care însoțesc anul liturgic și însuflețesc evlavia credincioșilor. Ea poate să fie un ajutor pentru rugăciunea personală și familială și, totodată, o cale de apropiere de frumusețea și profunzimea spiritualității bizantine.'**
  String get aboutParagraph5;

  /// No description provided for @aboutParagraph6.
  ///
  /// In ro, this message translates to:
  /// **'La Mănăstirea Maicii Domnului – Sanctuar Arhiepiscopal Major din Cluj-Napoca, Surorile se roagă pentru intențiile încredințate lor, primesc și însoțesc persoanele care caută un cuvânt de lumină și slujesc viața liturgică a Bisericii.'**
  String get aboutParagraph6;

  /// No description provided for @aboutPrayerTitle.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciune către Maica Domnului'**
  String get aboutPrayerTitle;

  /// No description provided for @aboutPrayerText.
  ///
  /// In ro, this message translates to:
  /// **'Preasfântă Fecioară Maria, Maica lui Dumnezeu, păstrează-ne sub ocrotirea ta. Călăuzește-ne pașii către Fiul tău, Isus Cristos, și dobândește-ne o inimă curată, pace sufletească și statornicie în rugăciune. Amin.'**
  String get aboutPrayerText;

  /// No description provided for @privacyPolicyPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Politica de confidențialitate'**
  String get privacyPolicyPageTitle;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In ro, this message translates to:
  /// **'Politica de confidențialitate a aplicației Rugăciuni și cântări – CMD\n\nUltima actualizare: 09.07.2026\n\nIntroducere\n\n  Aplicația Rugăciuni și cântări – CMD este pusă la dispoziția utilizatorilor de către Congregația Surorilor Maicii Domnului. Această politică explică modul în care aplicația utilizează datele necesare funcționării sale.\n\nDate stocate pe dispozitiv\n\n  Aplicația păstrează local, pe dispozitivul utilizatorului, preferințele de afișare și redare, rugăciunile favorite, descărcările pentru utilizare offline, jurnalul de rugăciune și program de rugăciune configurat de utilizator. Jurnalul de rugăciune este păstrat local timp de cel mult 31 de zile.\n\nNotificări și redare audio\n\n  Cu acordul utilizatorului, aplicația trimite notificări locale pentru program de rugăciune al utilizatorului. Informațiile necesare acestor notificări rămân pe dispozitiv. Aplicația poate reda audio în fundal și poate afișa controale de redare în sistemul de operare. Aplicația nu solicită acces la microfon.\n\nConținut și conexiune la internet\n\nPentru a încărca rugăciuni, texte, imagini și fișiere audio, aplicația se conectează la infrastructura Supabase. Furnizorul serviciului poate prelucra date tehnice de conexiune, precum adresa IP și jurnale de securitate, necesare furnizării și protejării serviciului. Conținutul descărcat pentru utilizare offline este stocat pe dispozitiv.\n\nDate personale și partajare\n\nAplicația nu solicită crearea unui cont și nu colectează în mod intenționat numele, adresa de e-mail, numărul de telefon, locația sau contacte ale utilizatorului. Nu folosim servicii de publicitate comportamentală și nu vindem date personale.\n\nSecuritate și control\n\nPuteți șterge datele stocate local prin eliminarea favoritelor, a jurnalului, a programului de rugăciune și a descărcărilor din aplicație sau prin ștergerea datelor aplicației din setările dispozitivului. Permisiunea pentru notificări poate fi retrasă oricând din setările sistemului.\n\nContact\n\nPentru întrebări legate de această politică, ne puteți contacta la:\n\nSeraphicApps\nCongregația Surorilor Maicii Domnului\nEmail: sserafim.socaciu@gmail.com\n\nAceastă politică poate fi actualizată periodic. Orice modificare survenită va fi publicată pe această pagină.'**
  String get privacyPolicyBody;

  /// No description provided for @journalPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Jurnal de rugăciune'**
  String get journalPageTitle;

  /// No description provided for @journalToday.
  ///
  /// In ro, this message translates to:
  /// **'Astăzi'**
  String get journalToday;

  /// No description provided for @journalYesterday.
  ///
  /// In ro, this message translates to:
  /// **'Ieri'**
  String get journalYesterday;

  /// No description provided for @journalEmptyTitle.
  ///
  /// In ro, this message translates to:
  /// **'Nicio rugăciune înregistrată'**
  String get journalEmptyTitle;

  /// No description provided for @journalEmptySubtitle.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunile deschise apar aici automat.'**
  String get journalEmptySubtitle;

  /// No description provided for @journalTodayCount.
  ///
  /// In ro, this message translates to:
  /// **'Astăzi — {count} rugăciuni'**
  String journalTodayCount(int count);

  /// No description provided for @journalHistoryTitle.
  ///
  /// In ro, this message translates to:
  /// **'Istoric (ultima lună)'**
  String get journalHistoryTitle;

  /// No description provided for @guidePageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Îndrumar'**
  String get guidePageTitle;

  /// No description provided for @guideIntro.
  ///
  /// In ro, this message translates to:
  /// **'Acest îndrumar li se adresează tuturor celor care doresc să se apropie mai mult de Dumnezeu și să descopere bogăția rugăciunii Bisericii Române Unite cu Roma, Greco-Catolică, în tradiția de rugăciune a Congregației Surorilor Maicii Domnului.\n\nAplicația cuprinde rugăciuni și cântări care ne ajută să-I încredințăm lui Dumnezeu începutul și sfârșitul fiecărei zile, bucuriile, încercările și oamenii pe care îi purtăm în inimă.'**
  String get guideIntro;

  /// No description provided for @guideQuote.
  ///
  /// In ro, this message translates to:
  /// **'Fie ca aceste rugăciuni să ne apropie de Cristos, să ne deschidă inima către aproapele și să ne ajute să trăim fiecare zi în comuniune cu Biserica, sub ocrotirea Preasfintei Fecioare Maria.'**
  String get guideQuote;

  /// No description provided for @guideEmptyTypes.
  ///
  /// In ro, this message translates to:
  /// **'Nu am găsit niciun tip de rugăciune.'**
  String get guideEmptyTypes;

  /// No description provided for @guideOpenPrayers.
  ///
  /// In ro, this message translates to:
  /// **'Vezi rugăciunile'**
  String get guideOpenPrayers;

  /// No description provided for @guideMeaningUtrenia.
  ///
  /// In ro, this message translates to:
  /// **'Utrenia este rugăciunea de dimineață a Bisericii. Prin psalmi, cântări și rugăciuni, Îi mulțumim lui Dumnezeu pentru lumina unei noi zile și Îi încredințăm gândurile, lucrările și toate acțiunile noastre. Este chemarea de a începe fiecare zi în lumina lui Cristos.'**
  String get guideMeaningUtrenia;

  /// No description provided for @guideMeaningCanonicalHours.
  ///
  /// In ro, this message translates to:
  /// **'Orele canonice (sau Ceasurile) așază rugăciunea în diferitele momente ale zilei și ne amintesc faptul că întreaga noastră viață Îi aparține lui Dumnezeu. Prin Ceasul întâi, al treilea, al șaselea și al nouălea, ne oprim din preocupările zilnice pentru a ne întoarce mintea și inima către El.'**
  String get guideMeaningCanonicalHours;

  /// No description provided for @guideMeaningVespers.
  ///
  /// In ro, this message translates to:
  /// **'Vecernia este rugăciunea de seară a Bisericii. Îi mulțumim lui Dumnezeu pentru binele primit, Îi cerem iertare pentru greșelile săvârșite și așezăm în mâinile Sale ziua care se încheie. În lumina blândă a serii, Îi încredințăm Lui viața noastră întreagă și pe toți cei dragi.'**
  String get guideMeaningVespers;

  /// No description provided for @guideMeaningRosary.
  ///
  /// In ro, this message translates to:
  /// **'Rozariul ne ajută să contemplăm tainele vieții lui Isus Cristos împreună cu Preasfânta Fecioară Maria. Repetarea rugăciunilor adună mintea și liniștește inima, pentru ca privirea noastră să rămână îndreptată spre Cristos și spre Evanghelia Sa.'**
  String get guideMeaningRosary;

  /// No description provided for @guideMeaningOurFather.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunea Domnească este rugăciunea pe care însuși Isus ne-a dăruit-o: ne învață să-L numim pe Dumnezeu Tată și să căutăm voia Lui.'**
  String get guideMeaningOurFather;

  /// No description provided for @guideMeaningCreed.
  ///
  /// In ro, this message translates to:
  /// **'Crezul este mărturisirea credinței Bisericii: rezumă lucrarea Tatălui, a Fiului și a Spiritului Sfânt.'**
  String get guideMeaningCreed;

  /// No description provided for @guideMeaningAngelus.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunea Îngerului Domnului amintește Buna Vestire și întruparea Fiului lui Dumnezeu pentru mântuirea noastră.'**
  String get guideMeaningAngelus;

  /// No description provided for @guideMeaningMorning.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunea de dimineață încredințează lui Dumnezeu ziua care începe și cere lumină, pace și credincioșie.'**
  String get guideMeaningMorning;

  /// No description provided for @guideMeaningEvening.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunea de seară este un timp de mulțumire, cercetare a inimii și odihnire în grija lui Dumnezeu.'**
  String get guideMeaningEvening;

  /// No description provided for @guideMeaningAcathist.
  ///
  /// In ro, this message translates to:
  /// **'Acatistul este o rugăciune de laudă și cinstire adusă Preasfintei Născătoare de Dumnezeu și Pururea Fecioarei Maria. Este un imn prin care îi aducem mulțumire Maicii Domnului pentru tot ceea ce I-a permis lui Dumnezeu să înfăptuiască, prin ea, în economia mântuirii și îi cerem să mijlocească pentru noi înaintea Fiului său, Isus Cristos, în bucurii, în încercări și în toate nevoile vieții.'**
  String get guideMeaningAcathist;

  /// No description provided for @guideMeaningParaclis.
  ///
  /// In ro, this message translates to:
  /// **'Paraclisul este rugăciunea celui care caută ajutor și mângâiere. Prin cuvintele acestei rugăciuni, ne îndreptăm către Maica Domnului și îi încredințăm suferințele, neliniștile și speranțele noastre, cerându-i să ne ocrotească și să ne călăuzească spre Cristos.'**
  String get guideMeaningParaclis;

  /// No description provided for @guideMeaningPsalms.
  ///
  /// In ro, this message translates to:
  /// **'Psalmii sunt rugăciunea inspirată a poporului lui Dumnezeu: în ei se întâlnesc lauda, durerea, încrederea, pocăința și speranța.'**
  String get guideMeaningPsalms;

  /// No description provided for @guideMeaningHymns.
  ///
  /// In ro, this message translates to:
  /// **'Cântarea este rugăciunea care se înalță din inimă. Cântările liturgice, pricesnele și colindele păstrează și transmit credința Bisericii, unind cuvântul rugăciunii cu frumusețea muzicii și a tradiției creștine.'**
  String get guideMeaningHymns;

  /// No description provided for @guideMeaningDaily.
  ///
  /// In ro, this message translates to:
  /// **'Această secțiune reunește rugăciuni specifice pentru diferitele momente și împrejurări ale vieții: dimineața și seara, înainte și după masă, în clipe de mulțumire, de încercare sau de pocăință. Rostită cu statornicie, rugăciunea nu rămâne doar un moment al zilei, ci devine un mod de a trăi în prezența lui Dumnezeu.'**
  String get guideMeaningDaily;

  /// No description provided for @guideMeaningRepentance.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunile de pocăință ne ajută să ne recunoaștem cu sinceritate păcatul și să primim milostivirea vindecătoare a lui Dumnezeu.'**
  String get guideMeaningRepentance;

  /// No description provided for @guideMeaningFamily.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunea pentru familie încredințează Domnului relațiile, bucuriile și greutățile celor dragi, cerând pace și unitate.'**
  String get guideMeaningFamily;

  /// No description provided for @guideMeaningMotherOfGod.
  ///
  /// In ro, this message translates to:
  /// **'Această rugăciune ne îndreaptă către Maica Domnului, care mijlocește pentru noi și ne conduce întotdeauna la Fiul ei.'**
  String get guideMeaningMotherOfGod;

  /// No description provided for @guideMeaningSaint.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunea cere mijlocirea unui sfânt, martor al lui Cristos și frate mai mare pe drumul credinței.'**
  String get guideMeaningSaint;

  /// No description provided for @guideMeaningDefault.
  ///
  /// In ro, this message translates to:
  /// **'„{title}” este un drum de rugăciune din tradiția Bisericii Greco-Catolice. Prin aceste texte, credința Bisericii devine laudă, cerere și apropiere de Dumnezeu.'**
  String guideMeaningDefault(String title);

  /// No description provided for @cancel.
  ///
  /// In ro, this message translates to:
  /// **'Anulează'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ro, this message translates to:
  /// **'Salvează'**
  String get save;

  /// No description provided for @close.
  ///
  /// In ro, this message translates to:
  /// **'Închide'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In ro, this message translates to:
  /// **'Șterge'**
  String get delete;

  /// No description provided for @reminderChangePrayer.
  ///
  /// In ro, this message translates to:
  /// **'Schimbă rugăciunea'**
  String get reminderChangePrayer;

  /// No description provided for @reminderSelectPrayerError.
  ///
  /// In ro, this message translates to:
  /// **'Selectează o rugăciune'**
  String get reminderSelectPrayerError;

  /// No description provided for @reminderSelectDaysError.
  ///
  /// In ro, this message translates to:
  /// **'Selectează cel puțin o zi'**
  String get reminderSelectDaysError;

  /// No description provided for @reminderEditTitle.
  ///
  /// In ro, this message translates to:
  /// **'Editează înregistrarea'**
  String get reminderEditTitle;

  /// No description provided for @reminderNewTitle.
  ///
  /// In ro, this message translates to:
  /// **'Înregistrare nouă'**
  String get reminderNewTitle;

  /// No description provided for @reminderPrefilledFromCalendar.
  ///
  /// In ro, this message translates to:
  /// **'Ora și zilele au fost completate din calendarul liturgic.'**
  String get reminderPrefilledFromCalendar;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In ro, this message translates to:
  /// **'Ora'**
  String get reminderTimeLabel;

  /// No description provided for @reminderDaysOfWeekLabel.
  ///
  /// In ro, this message translates to:
  /// **'Zile din săptămână'**
  String get reminderDaysOfWeekLabel;

  /// No description provided for @remindersLoadError.
  ///
  /// In ro, this message translates to:
  /// **'Nu s-a putut încărca lista de rugăciuni. Verifică conexiunea.'**
  String get remindersLoadError;

  /// No description provided for @reminderDeleteConfirmTitle.
  ///
  /// In ro, this message translates to:
  /// **'Șterge înregistrarea?'**
  String get reminderDeleteConfirmTitle;

  /// No description provided for @reminderDeleteConfirmBody.
  ///
  /// In ro, this message translates to:
  /// **'Înregistrarea pentru „{title}” la {time} va fi ștearsă.'**
  String reminderDeleteConfirmBody(String title, String time);

  /// No description provided for @remindersPageTitleWeb.
  ///
  /// In ro, this message translates to:
  /// **'Program rugăciune'**
  String get remindersPageTitleWeb;

  /// No description provided for @remindersUnavailableOnWeb.
  ///
  /// In ro, this message translates to:
  /// **'Programul de rugăciune este disponibil doar pe telefon.'**
  String get remindersUnavailableOnWeb;

  /// No description provided for @remindersPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Programul meu de rugăciune'**
  String get remindersPageTitle;

  /// No description provided for @remindersDoneEditing.
  ///
  /// In ro, this message translates to:
  /// **'Gata'**
  String get remindersDoneEditing;

  /// No description provided for @remindersEdit.
  ///
  /// In ro, this message translates to:
  /// **'Editează'**
  String get remindersEdit;

  /// No description provided for @remindersAdd.
  ///
  /// In ro, this message translates to:
  /// **'Adaugă'**
  String get remindersAdd;

  /// No description provided for @remindersEnableNotificationsPrompt.
  ///
  /// In ro, this message translates to:
  /// **'Activează notificările în setările telefonului.'**
  String get remindersEnableNotificationsPrompt;

  /// No description provided for @remindersOpenSettings.
  ///
  /// In ro, this message translates to:
  /// **'Setări'**
  String get remindersOpenSettings;

  /// No description provided for @remindersEmptyState.
  ///
  /// In ro, this message translates to:
  /// **'Nu ai un program stabilit. Apasă + pentru a începe.'**
  String get remindersEmptyState;

  /// No description provided for @settingsPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Setări'**
  String get settingsPageTitle;

  /// No description provided for @playbackSpeedTitle.
  ///
  /// In ro, this message translates to:
  /// **'Viteză de redare'**
  String get playbackSpeedTitle;

  /// No description provided for @playbackSpeedHint.
  ///
  /// In ro, this message translates to:
  /// **'Repornește redarea audio pentru a aplica'**
  String get playbackSpeedHint;

  /// No description provided for @fontStyleTitle.
  ///
  /// In ro, this message translates to:
  /// **'Stil font'**
  String get fontStyleTitle;

  /// No description provided for @fontSizeTitle.
  ///
  /// In ro, this message translates to:
  /// **'Mărime font'**
  String get fontSizeTitle;

  /// No description provided for @appThemeTitle.
  ///
  /// In ro, this message translates to:
  /// **'Temă aplicație'**
  String get appThemeTitle;

  /// No description provided for @themeAutoHint.
  ///
  /// In ro, this message translates to:
  /// **'Auto - se sincronizează cu tema telefonului dumneavoastră (folosește Sepia pentru luminos și Întunecat pentru întunecat).'**
  String get themeAutoHint;

  /// No description provided for @themeModeLight.
  ///
  /// In ro, this message translates to:
  /// **'Luminos'**
  String get themeModeLight;

  /// No description provided for @themeModeSepia.
  ///
  /// In ro, this message translates to:
  /// **'Sepia'**
  String get themeModeSepia;

  /// No description provided for @themeModeDark.
  ///
  /// In ro, this message translates to:
  /// **'Întunecat'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In ro, this message translates to:
  /// **'Auto'**
  String get themeModeSystem;

  /// No description provided for @freeStorageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Eliberează spațiul de stocare'**
  String get freeStorageTitle;

  /// No description provided for @storageOccupied.
  ///
  /// In ro, this message translates to:
  /// **'Descărcările ocupă {mb} MB în memorie.'**
  String storageOccupied(String mb);

  /// No description provided for @freeStorageConfirmTitle.
  ///
  /// In ro, this message translates to:
  /// **'Eliberare spațiu de stocare'**
  String get freeStorageConfirmTitle;

  /// No description provided for @freeStorageConfirmBody.
  ///
  /// In ro, this message translates to:
  /// **'Această acțiune va șterge descărcările din memoria telefonului. Vei elibera {mb} MB, iar rugăciunile nu vor mai fi disponibile fără conexiune la internet.'**
  String freeStorageConfirmBody(String mb);

  /// No description provided for @freeStorageAction.
  ///
  /// In ro, this message translates to:
  /// **'Eliberează spațiul'**
  String get freeStorageAction;

  /// No description provided for @genericErrorTitle.
  ///
  /// In ro, this message translates to:
  /// **'A apărut o eroare!'**
  String get genericErrorTitle;

  /// No description provided for @freeStorageErrorBody.
  ///
  /// In ro, this message translates to:
  /// **'Spațiul de stocare nu a putut fi eliberat. Încearcă să îl eliberezi din setările telefonului.'**
  String get freeStorageErrorBody;

  /// No description provided for @ok.
  ///
  /// In ro, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @appUpToDate.
  ///
  /// In ro, this message translates to:
  /// **'Aplicația este actualizată la ultima versiune.\nUltima actualizare: {date}'**
  String appUpToDate(String date);

  /// No description provided for @checkForUpdates.
  ///
  /// In ro, this message translates to:
  /// **'Verifică actualizările aplicației'**
  String get checkForUpdates;

  /// No description provided for @currentVersion.
  ///
  /// In ro, this message translates to:
  /// **'Versiunea curentă: {version}'**
  String currentVersion(String version);

  /// No description provided for @lastContentUpdate.
  ///
  /// In ro, this message translates to:
  /// **'Ultima actualizare: {date}'**
  String lastContentUpdate(String date);

  /// No description provided for @congregationNameUpper.
  ///
  /// In ro, this message translates to:
  /// **'CONGREGAȚIA SURORILOR MAICII DOMNULUI'**
  String get congregationNameUpper;

  /// No description provided for @congregationAddress.
  ///
  /// In ro, this message translates to:
  /// **'Str. Romul Ladea, nr. 6, 400481, Cluj-Napoca'**
  String get congregationAddress;

  /// No description provided for @onboardingAppTitleLine1.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciuni și Cântări'**
  String get onboardingAppTitleLine1;

  /// No description provided for @onboardingAppTitleLine2.
  ///
  /// In ro, this message translates to:
  /// **'Greco-Catolice'**
  String get onboardingAppTitleLine2;

  /// No description provided for @onboardingCongregationLine1.
  ///
  /// In ro, this message translates to:
  /// **'Congregația Surorilor'**
  String get onboardingCongregationLine1;

  /// No description provided for @onboardingCongregationLine2.
  ///
  /// In ro, this message translates to:
  /// **'Maicii Domnului'**
  String get onboardingCongregationLine2;

  /// No description provided for @onboardingMadeBy.
  ///
  /// In ro, this message translates to:
  /// **'Realizată de'**
  String get onboardingMadeBy;

  /// No description provided for @onboardingExpandGroup.
  ///
  /// In ro, this message translates to:
  /// **'Restrânge'**
  String get onboardingExpandGroup;

  /// No description provided for @onboardingCollapseGroup.
  ///
  /// In ro, this message translates to:
  /// **'Extinde'**
  String get onboardingCollapseGroup;

  /// No description provided for @onboardingChangePrayer.
  ///
  /// In ro, this message translates to:
  /// **'Alegeți altă rugăciune'**
  String get onboardingChangePrayer;

  /// No description provided for @onboardingDefaultPrayerTypeLabel.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciune'**
  String get onboardingDefaultPrayerTypeLabel;

  /// No description provided for @onboardingWelcomeHeading.
  ///
  /// In ro, this message translates to:
  /// **'Cuvânt de bun-venit'**
  String get onboardingWelcomeHeading;

  /// No description provided for @onboardingWelcomeAddress.
  ///
  /// In ro, this message translates to:
  /// **'Surorile Congregației Maicii Domnului vă întâmpină cu bucurie și vă invită să vă opriți, pentru câteva clipe, în liniștea rugăciunii.'**
  String get onboardingWelcomeAddress;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In ro, this message translates to:
  /// **'În această aplicație veți găsi rugăciuni și cântări interpretate și înregistrate de Surori, astfel încât, zi de zi, oriunde v-ați afla, să puteți fi însoțiți de rugăciunea lor.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingWelcomeGuide.
  ///
  /// In ro, this message translates to:
  /// **'În continuare, vă prezentăm câteva informații care vă vor ajuta să descoperiți conținutul aplicației și să îl folosiți potrivit nevoilor dumneavoastră sufletești.'**
  String get onboardingWelcomeGuide;

  /// No description provided for @onboardingWelcomeBlessing.
  ///
  /// In ro, this message translates to:
  /// **'Fie ca Domnul să vă binecuvânteze, iar Preacurata Fecioară Maria să vă păstreze sub ocrotirea ei!'**
  String get onboardingWelcomeBlessing;

  /// No description provided for @onboardingWelcomeSignOff.
  ///
  /// In ro, this message translates to:
  /// **'Cu dragoste în Cristos,\nSurorile Congregației Maicii Domnului'**
  String get onboardingWelcomeSignOff;

  /// No description provided for @onboardingTextStepTitle.
  ///
  /// In ro, this message translates to:
  /// **'Personalizați textul'**
  String get onboardingTextStepTitle;

  /// No description provided for @onboardingTextStepBody.
  ///
  /// In ro, this message translates to:
  /// **'Adaptați fontul și mărimea textului acum sau oricând din Setări.'**
  String get onboardingTextStepBody;

  /// No description provided for @onboardingReadingExampleLabel.
  ///
  /// In ro, this message translates to:
  /// **'Exemplu de citire'**
  String get onboardingReadingExampleLabel;

  /// No description provided for @onboardingReadingPreviewQuote.
  ///
  /// In ro, this message translates to:
  /// **'„Tatăl nostru, care ești în ceruri, sfințească-se numele Tău…”'**
  String get onboardingReadingPreviewQuote;

  /// No description provided for @onboardingReminderTime.
  ///
  /// In ro, this message translates to:
  /// **'Ora: {time}'**
  String onboardingReminderTime(String time);

  /// No description provided for @onboardingReminderDaysLabel.
  ///
  /// In ro, this message translates to:
  /// **'Zile'**
  String get onboardingReminderDaysLabel;

  /// No description provided for @onboardingReminderStepTitle.
  ///
  /// In ro, this message translates to:
  /// **'Programul meu de rugăciune'**
  String get onboardingReminderStepTitle;

  /// No description provided for @onboardingReminderStepBodyWeb.
  ///
  /// In ro, this message translates to:
  /// **'Amintirile sunt disponibile doar din aplicație. Pe web puteți continua; le veți putea configura din Setări pe dispozitivul mobil.'**
  String get onboardingReminderStepBodyWeb;

  /// No description provided for @onboardingReminderStepBodyMobile.
  ///
  /// In ro, this message translates to:
  /// **'Opțional: setați o amintire pentru o rugăciune de astăzi. Ora și zilele sunt completate automat, și le puteți modifica ulterior.'**
  String get onboardingReminderStepBodyMobile;

  /// No description provided for @onboardingReminderNoPrayersToday.
  ///
  /// In ro, this message translates to:
  /// **'Nu am găsit rugăciuni pentru astăzi. Puteți adăuga o amintire mai târziu din aplicație.'**
  String get onboardingReminderNoPrayersToday;

  /// No description provided for @onboardingFavoritesStepTitle.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciuni favorite'**
  String get onboardingFavoritesStepTitle;

  /// No description provided for @onboardingFavoritesStepBody.
  ///
  /// In ro, this message translates to:
  /// **'Dacă doriți, alegeți o rugăciune favorită pentru început. Rugăciunile favorite sunt mai ușor de găsit și ascultat.'**
  String get onboardingFavoritesStepBody;

  /// No description provided for @onboardingFavoritesLoadError.
  ///
  /// In ro, this message translates to:
  /// **'Nu am putut încărca lista acum. Puteți adăuga favorite mai târziu din aplicație.'**
  String get onboardingFavoritesLoadError;

  /// No description provided for @onboardingAudioStepTitle.
  ///
  /// In ro, this message translates to:
  /// **'Ascultați rugăciunile'**
  String get onboardingAudioStepTitle;

  /// No description provided for @onboardingAudioStepBody.
  ///
  /// In ro, this message translates to:
  /// **'Majoritatea rugăciunilor pot fi ascultate în aplicație. Apăsați redare pentru un scurt exemplu — primul mister din Rozariul de durere.'**
  String get onboardingAudioStepBody;

  /// No description provided for @onboardingAudioLoadError.
  ///
  /// In ro, this message translates to:
  /// **'Nu am putut încărca exemplul audio acum. Puteți asculta rugăciuni din aplicație.'**
  String get onboardingAudioLoadError;

  /// No description provided for @onboardingAudioPause.
  ///
  /// In ro, this message translates to:
  /// **'Pauză'**
  String get onboardingAudioPause;

  /// No description provided for @onboardingAudioPlay.
  ///
  /// In ro, this message translates to:
  /// **'Redare'**
  String get onboardingAudioPlay;

  /// No description provided for @onboardingClosingTitle.
  ///
  /// In ro, this message translates to:
  /// **'Multe de descoperit'**
  String get onboardingClosingTitle;

  /// No description provided for @onboardingClosingCalendarTitle.
  ///
  /// In ro, this message translates to:
  /// **'Calendar'**
  String get onboardingClosingCalendarTitle;

  /// No description provided for @onboardingClosingCalendarSubtitle.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunile din fiecare zi'**
  String get onboardingClosingCalendarSubtitle;

  /// No description provided for @onboardingClosingDownloadsTitle.
  ///
  /// In ro, this message translates to:
  /// **'Descărcări'**
  String get onboardingClosingDownloadsTitle;

  /// No description provided for @onboardingClosingDownloadsSubtitle.
  ///
  /// In ro, this message translates to:
  /// **'Descarcă rugăciuni și cântări pentru a le asculta offline.'**
  String get onboardingClosingDownloadsSubtitle;

  /// No description provided for @onboardingClosingJournalTitle.
  ///
  /// In ro, this message translates to:
  /// **'Jurnal de rugăciune'**
  String get onboardingClosingJournalTitle;

  /// No description provided for @onboardingClosingGuideTitle.
  ///
  /// In ro, this message translates to:
  /// **'Îndrumar'**
  String get onboardingClosingGuideTitle;

  /// No description provided for @onboardingClosingGuideSubtitle.
  ///
  /// In ro, this message translates to:
  /// **'Află pe scurt sensul și folosul fiecărei rugăciuni.'**
  String get onboardingClosingGuideSubtitle;

  /// No description provided for @onboardingClosingMoreTitle.
  ///
  /// In ro, this message translates to:
  /// **'Și multe altele...'**
  String get onboardingClosingMoreTitle;

  /// No description provided for @onboardingClosingBlessing.
  ///
  /// In ro, this message translates to:
  /// **'Vă dorim să aveți un timp binecuvântat de rugăciune!'**
  String get onboardingClosingBlessing;

  /// No description provided for @onboardingBack.
  ///
  /// In ro, this message translates to:
  /// **'Înapoi'**
  String get onboardingBack;

  /// No description provided for @onboardingSkip.
  ///
  /// In ro, this message translates to:
  /// **'Sari peste'**
  String get onboardingSkip;

  /// No description provided for @onboardingContinue.
  ///
  /// In ro, this message translates to:
  /// **'Continuă'**
  String get onboardingContinue;

  /// No description provided for @onboardingStart.
  ///
  /// In ro, this message translates to:
  /// **'Începe'**
  String get onboardingStart;

  /// No description provided for @calendarPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Calendar'**
  String get calendarPageTitle;

  /// No description provided for @allPrayersPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Toate rugăciunile'**
  String get allPrayersPageTitle;

  /// No description provided for @gotIt.
  ///
  /// In ro, this message translates to:
  /// **'Am înțeles'**
  String get gotIt;

  /// No description provided for @favoritesPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciuni favorite'**
  String get favoritesPageTitle;

  /// No description provided for @favoritesInfoDialogBody.
  ///
  /// In ro, this message translates to:
  /// **'Trage cu degetul pentru a reordona. Trage spre stânga pentru ștergere. Rugăciunile descărcate au pictograma offline.'**
  String get favoritesInfoDialogBody;

  /// No description provided for @downloadedPageTitle.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciuni descărcate'**
  String get downloadedPageTitle;

  /// No description provided for @downloadedInfoDialogBody.
  ///
  /// In ro, this message translates to:
  /// **'Rugăciunile descărcate sunt disponibile in mod offline. Le puteți șterge prin acțiunea de slide către stânga. Atenție, ștergerea din această listă nu implică și ștergerea din memorie. Pentru a șterge din memorie, accesați pagina de setări.'**
  String get downloadedInfoDialogBody;

  /// No description provided for @bookmarkSaved.
  ///
  /// In ro, this message translates to:
  /// **'Semnul de carte către {location} a fost salvat!'**
  String bookmarkSaved(String location);

  /// No description provided for @downloadCompletedTitle.
  ///
  /// In ro, this message translates to:
  /// **'Descărcarea a fost finalizată!'**
  String get downloadCompletedTitle;

  /// No description provided for @downloadFailedTitle.
  ///
  /// In ro, this message translates to:
  /// **'Descărcarea nu a putut fi finalizată!'**
  String get downloadFailedTitle;

  /// No description provided for @downloadFailedBody.
  ///
  /// In ro, this message translates to:
  /// **'Ne pare rău, a intervenit o eroare. Încearcă mai târziu.'**
  String get downloadFailedBody;

  /// No description provided for @emptyStateTitle.
  ///
  /// In ro, this message translates to:
  /// **'Încă nu ai nimic aici'**
  String get emptyStateTitle;

  /// No description provided for @emptyDownloadedHint.
  ///
  /// In ro, this message translates to:
  /// **'Descarcă rugăciunile dorite apâsând pe '**
  String get emptyDownloadedHint;

  /// No description provided for @emptyFavoriteHint.
  ///
  /// In ro, this message translates to:
  /// **'Salvează rugăciunile preferate apâsând pe ♡ '**
  String get emptyFavoriteHint;

  /// No description provided for @emptyListDefaultTitle.
  ///
  /// In ro, this message translates to:
  /// **'Textul va apărea curând'**
  String get emptyListDefaultTitle;

  /// No description provided for @emptyListDefaultSubtitle.
  ///
  /// In ro, this message translates to:
  /// **'Vă mulțumim pentru răbdare!'**
  String get emptyListDefaultSubtitle;

  /// No description provided for @textLoadFailedTitle.
  ///
  /// In ro, this message translates to:
  /// **'Textul nu a putut fi încărcat!'**
  String get textLoadFailedTitle;

  /// No description provided for @textLoadFailedSubtitle.
  ///
  /// In ro, this message translates to:
  /// **'Vă rugăm încercați mai târziu.'**
  String get textLoadFailedSubtitle;

  /// No description provided for @subtypesLoadFailedTitle.
  ///
  /// In ro, this message translates to:
  /// **'Nu s-a putut încărca.'**
  String get subtypesLoadFailedTitle;

  /// No description provided for @subtypesLoadFailedSubtitle.
  ///
  /// In ro, this message translates to:
  /// **'Verifică conexiunea la internet sau mergi la rugăciunile descărcate.'**
  String get subtypesLoadFailedSubtitle;

  /// No description provided for @readingAnchorTitle.
  ///
  /// In ro, this message translates to:
  /// **'Poziție derulare automată text'**
  String get readingAnchorTitle;

  /// No description provided for @readingAnchorHint.
  ///
  /// In ro, this message translates to:
  /// **'Unde se derulează automat textul când asculti o rugăciune'**
  String get readingAnchorHint;

  /// No description provided for @autoScrollTitle.
  ///
  /// In ro, this message translates to:
  /// **'Derulare automată text'**
  String get autoScrollTitle;

  /// No description provided for @autoScrollSubtitle.
  ///
  /// In ro, this message translates to:
  /// **'Textul urmărește automat redarea audio'**
  String get autoScrollSubtitle;

  /// No description provided for @chooseChapterDefaultTitle.
  ///
  /// In ro, this message translates to:
  /// **'Mergi la secțiunea dorită'**
  String get chooseChapterDefaultTitle;

  /// No description provided for @favoriteRemoved.
  ///
  /// In ro, this message translates to:
  /// **'{title} - {subtitle} nu mai este in lista de favorite!'**
  String favoriteRemoved(String title, String subtitle);

  /// No description provided for @favoriteAdded.
  ///
  /// In ro, this message translates to:
  /// **'{title} - {subtitle} a fost salvată în lista de favorite!'**
  String favoriteAdded(String title, String subtitle);

  /// No description provided for @downloadsMenuTitle.
  ///
  /// In ro, this message translates to:
  /// **'Descărcări'**
  String get downloadsMenuTitle;

  /// No description provided for @expandHeader.
  ///
  /// In ro, this message translates to:
  /// **'Extinde antetul'**
  String get expandHeader;

  /// No description provided for @collapseHeader.
  ///
  /// In ro, this message translates to:
  /// **'Restrânge antetul'**
  String get collapseHeader;
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
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prayers and Hymns';

  @override
  String get congregationTitle =>
      'Congregation of the Sisters of the Mother of God';

  @override
  String get loading => 'Loading…';

  @override
  String get todayPrayersTileTitle => 'Today\'s prayers';

  @override
  String get retry => 'Retry';

  @override
  String get prayersLoadError =>
      'Prayers could not be loaded. Please try again later or check your internet connection.';

  @override
  String get noSearchResults => 'No prayers found with that name.';

  @override
  String get noTodayRecommendation =>
      'No recommendation for today. Open the calendar for today\'s prayers.';

  @override
  String get invalidSavedPrayer =>
      'The saved prayer is no longer valid. Please save a prayer again.';

  @override
  String get homeCatalogSectionTitle => 'Prayers and Hymns';

  @override
  String get continueWhereYouLeftOff => 'Continue where you left off';

  @override
  String get favorites => 'Favorites';

  @override
  String get searchHint => 'Search prayers and hymns';

  @override
  String todaySectionLabel(String date) {
    return 'For today · $date';
  }

  @override
  String get aboutPageTitle => 'Who we are';

  @override
  String get aboutParagraph1 =>
      'This application is a project of the Congregation of the Sisters of the Mother of God, whose Generalate is based in Cluj-Napoca, Romania.';

  @override
  String get aboutParagraph2 =>
      'The Congregation of the Sisters of the Mother of God (CMD) was founded in Blaj on February 2, 1921, by Metropolitan Dr. Vasile Suciu, and placed under the protection of the Blessed Virgin Mary. From the beginning, the Sisters\' life has been grounded in prayer, work, and service to others.';

  @override
  String get aboutParagraph3 =>
      'CMD\'s spirituality has its source in the Word of God, in the liturgical life of the Church, and in the example of the Blessed Virgin Mary.';

  @override
  String get aboutParagraph4 =>
      'Liturgical prayer, celebrated in the Byzantine tradition, is at the heart of CMD communities\' life and gives rhythm to each day. Through this app, the Sisters share part of the spiritual treasure inherited over more than 100 years of existence with those who want to discover or deepen Greek-Catholic prayers and hymns.';

  @override
  String get aboutParagraph5 =>
      'The app contains prayers for the different moments of the day, as well as hymns that accompany the liturgical year and enliven the faithful\'s devotion. It can be an aid for personal and family prayer, and also a way of drawing closer to the beauty and depth of Byzantine spirituality.';

  @override
  String get aboutParagraph6 =>
      'At the Monastery of the Mother of God – Major Archiepiscopal Sanctuary in Cluj-Napoca, the Sisters pray for the intentions entrusted to them, welcome and accompany people seeking a word of light, and serve the liturgical life of the Church.';

  @override
  String get aboutPrayerTitle => 'Prayer to the Mother of God';

  @override
  String get aboutPrayerText =>
      'Most Holy Virgin Mary, Mother of God, keep us under your protection. Guide our steps toward your Son, Jesus Christ, and obtain for us a pure heart, peace of soul, and steadfastness in prayer. Amen.';

  @override
  String get privacyPolicyPageTitle => 'Privacy Policy';

  @override
  String get privacyPolicyBody =>
      'Privacy Policy of the Prayers and Hymns – CMD app\n\nLast updated: 09.07.2026\n\nIntroduction\n\n  The Prayers and Hymns – CMD app is made available to users by the Congregation of the Sisters of the Mother of God. This policy explains how the app uses the data necessary for it to function.\n\nData stored on the device\n\n  The app locally stores, on the user\'s device, display and playback preferences, favorite prayers, downloads for offline use, the prayer journal, and the user\'s configured prayer schedule. The prayer journal is kept locally for at most 31 days.\n\nNotifications and audio playback\n\n  With the user\'s consent, the app sends local notifications for the user\'s prayer schedule. The information required for these notifications stays on the device. The app can play audio in the background and may show playback controls in the operating system. The app does not request microphone access.\n\nContent and internet connection\n\nTo load prayers, texts, images, and audio files, the app connects to the Supabase infrastructure. The service provider may process technical connection data, such as IP address and security logs, necessary to provide and protect the service. Content downloaded for offline use is stored on the device.\n\nPersonal data and sharing\n\nThe app does not require creating an account and does not intentionally collect the user\'s name, email address, phone number, location, or contacts. We do not use behavioral advertising services and we do not sell personal data.\n\nSecurity and control\n\nYou can delete locally stored data by removing favorites, the journal, the prayer schedule, and downloads from the app, or by clearing the app\'s data from the device settings. Notification permission can be withdrawn at any time from the system settings.\n\nContact\n\nFor questions about this policy, you can contact us at:\n\nSeraphicApps\nCongregation of the Sisters of the Mother of God\nEmail: sserafim.socaciu@gmail.com\n\nThis policy may be updated periodically. Any changes will be published on this page.';

  @override
  String get journalPageTitle => 'Prayer journal';

  @override
  String get journalToday => 'Today';

  @override
  String get journalYesterday => 'Yesterday';

  @override
  String get journalEmptyTitle => 'No prayers recorded';

  @override
  String get journalEmptySubtitle =>
      'Prayers you open appear here automatically.';

  @override
  String journalTodayCount(int count) {
    return 'Today — $count prayers';
  }

  @override
  String get journalHistoryTitle => 'History (last month)';

  @override
  String get guidePageTitle => 'Guide';

  @override
  String get guideIntro =>
      'This guide is addressed to everyone who wants to draw closer to God and discover the richness of the prayer of the Romanian Church United with Rome, Greek-Catholic, in the prayer tradition of the Congregation of the Sisters of the Mother of God.\n\nThe app contains prayers and hymns that help us entrust to God the beginning and end of each day, our joys, our trials, and the people we carry in our hearts.';

  @override
  String get guideQuote =>
      'May these prayers draw us closer to Christ, open our hearts to our neighbor, and help us live each day in communion with the Church, under the protection of the Blessed Virgin Mary.';

  @override
  String get guideEmptyTypes => 'No prayer type was found.';

  @override
  String get guideOpenPrayers => 'See the prayers';

  @override
  String get guideMeaningUtrenia =>
      'Matins is the Church\'s morning prayer. Through psalms, hymns, and prayers, we thank God for the light of a new day and entrust to Him our thoughts, our work, and all our actions. It is a call to begin each day in the light of Christ.';

  @override
  String get guideMeaningCanonicalHours =>
      'The canonical hours (or Hours) place prayer at the different moments of the day and remind us that our whole life belongs to God. Through the First, Third, Sixth, and Ninth Hour, we pause from our daily concerns to turn our mind and heart back to Him.';

  @override
  String get guideMeaningVespers =>
      'Vespers is the Church\'s evening prayer. We thank God for the good we have received, ask forgiveness for our wrongdoings, and place the closing day in His hands. In the gentle light of evening, we entrust to Him our whole life and all those we love.';

  @override
  String get guideMeaningRosary =>
      'The Rosary helps us contemplate the mysteries of the life of Jesus Christ together with the Blessed Virgin Mary. Repeating the prayers gathers the mind and quiets the heart, so that our gaze remains fixed on Christ and His Gospel.';

  @override
  String get guideMeaningOurFather =>
      'The Lord\'s Prayer is the prayer Jesus himself gave us: it teaches us to call God Father and to seek His will.';

  @override
  String get guideMeaningCreed =>
      'The Creed is the Church\'s profession of faith: it summarizes the work of the Father, the Son, and the Holy Spirit.';

  @override
  String get guideMeaningAngelus =>
      'The Angelus prayer recalls the Annunciation and the incarnation of the Son of God for our salvation.';

  @override
  String get guideMeaningMorning =>
      'The morning prayer entrusts to God the day that is beginning and asks for light, peace, and faithfulness.';

  @override
  String get guideMeaningEvening =>
      'The evening prayer is a time of thanksgiving, examination of the heart, and rest in God\'s care.';

  @override
  String get guideMeaningAcathist =>
      'The Akathist is a prayer of praise and honor offered to the Most Holy Mother of God and Ever-Virgin Mary. It is a hymn through which we thank the Mother of God for everything God allowed her to accomplish in the economy of salvation, asking her to intercede for us before her Son, Jesus Christ, in joys, trials, and every need of life.';

  @override
  String get guideMeaningParaclis =>
      'The Paraclis is the prayer of one who seeks help and comfort. Through the words of this prayer, we turn to the Mother of God and entrust to her our sufferings, worries, and hopes, asking her to protect and guide us toward Christ.';

  @override
  String get guideMeaningPsalms =>
      'The Psalms are the inspired prayer of God\'s people: in them praise, sorrow, trust, repentance, and hope all meet.';

  @override
  String get guideMeaningHymns =>
      'Hymnody is the prayer that rises from the heart. Liturgical hymns, carols, and songs preserve and pass on the Church\'s faith, joining the word of prayer with the beauty of music and Christian tradition.';

  @override
  String get guideMeaningDaily =>
      'This section brings together prayers for the different moments and circumstances of life: morning and evening, before and after meals, in moments of thanksgiving, trial, or repentance. Prayed steadfastly, prayer no longer remains just a moment of the day, but becomes a way of living in God\'s presence.';

  @override
  String get guideMeaningRepentance =>
      'Prayers of repentance help us sincerely acknowledge our sin and receive God\'s healing mercy.';

  @override
  String get guideMeaningFamily =>
      'The prayer for the family entrusts to the Lord the relationships, joys, and burdens of loved ones, asking for peace and unity.';

  @override
  String get guideMeaningMotherOfGod =>
      'This prayer turns us toward the Mother of God, who intercedes for us and always leads us to her Son.';

  @override
  String get guideMeaningSaint =>
      'This prayer asks for the intercession of a saint, a witness of Christ and an elder brother or sister on the path of faith.';

  @override
  String guideMeaningDefault(String title) {
    return '\"$title\" is a path of prayer from the tradition of the Greek-Catholic Church. Through these texts, the Church\'s faith becomes praise, petition, and closeness to God.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get reminderChangePrayer => 'Change prayer';

  @override
  String get reminderSelectPrayerError => 'Select a prayer';

  @override
  String get reminderSelectDaysError => 'Select at least one day';

  @override
  String get reminderEditTitle => 'Edit reminder';

  @override
  String get reminderNewTitle => 'New reminder';

  @override
  String get reminderPrefilledFromCalendar =>
      'The time and days were filled in from the liturgical calendar.';

  @override
  String get reminderTimeLabel => 'Time';

  @override
  String get reminderDaysOfWeekLabel => 'Days of the week';

  @override
  String get remindersLoadError =>
      'The prayer list could not be loaded. Check your connection.';

  @override
  String get reminderDeleteConfirmTitle => 'Delete this reminder?';

  @override
  String reminderDeleteConfirmBody(String title, String time) {
    return 'The reminder for \"$title\" at $time will be deleted.';
  }

  @override
  String get remindersPageTitleWeb => 'Prayer schedule';

  @override
  String get remindersUnavailableOnWeb =>
      'The prayer schedule is only available on the phone.';

  @override
  String get remindersPageTitle => 'My prayer schedule';

  @override
  String get remindersDoneEditing => 'Done';

  @override
  String get remindersEdit => 'Edit';

  @override
  String get remindersAdd => 'Add';

  @override
  String get remindersEnableNotificationsPrompt =>
      'Enable notifications in your phone\'s settings.';

  @override
  String get remindersOpenSettings => 'Settings';

  @override
  String get remindersEmptyState =>
      'You have no schedule set up. Tap + to get started.';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get playbackSpeedTitle => 'Playback speed';

  @override
  String get playbackSpeedHint => 'Restart audio playback to apply';

  @override
  String get fontStyleTitle => 'Font style';

  @override
  String get fontSizeTitle => 'Font size';

  @override
  String get appThemeTitle => 'App theme';

  @override
  String get themeAutoHint =>
      'Auto - syncs with your phone\'s theme (uses Sepia for light and Dark for dark).';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSepia => 'Sepia';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeSystem => 'Auto';

  @override
  String get freeStorageTitle => 'Free up storage space';

  @override
  String storageOccupied(String mb) {
    return 'Downloads occupy $mb MB of storage.';
  }

  @override
  String get freeStorageConfirmTitle => 'Free up storage space';

  @override
  String freeStorageConfirmBody(String mb) {
    return 'This action will delete downloads from your phone\'s storage. You will free up $mb MB, and prayers will no longer be available without an internet connection.';
  }

  @override
  String get freeStorageAction => 'Free up space';

  @override
  String get genericErrorTitle => 'An error occurred!';

  @override
  String get freeStorageErrorBody =>
      'The storage space could not be freed. Try freeing it from your phone\'s settings.';

  @override
  String get ok => 'Ok';

  @override
  String appUpToDate(String date) {
    return 'The app is up to date.\nLast update: $date';
  }

  @override
  String get checkForUpdates => 'Check for app updates';

  @override
  String currentVersion(String version) {
    return 'Current version: $version';
  }

  @override
  String lastContentUpdate(String date) {
    return 'Last update: $date';
  }

  @override
  String get congregationNameUpper =>
      'CONGREGATION OF THE SISTERS OF THE MOTHER OF GOD';

  @override
  String get congregationAddress =>
      'Str. Romul Ladea, nr. 6, 400481, Cluj-Napoca';

  @override
  String get onboardingAppTitleLine1 => 'Prayers and Hymns';

  @override
  String get onboardingAppTitleLine2 => 'Greek-Catholic';

  @override
  String get onboardingCongregationLine1 => 'Congregation of the Sisters';

  @override
  String get onboardingCongregationLine2 => 'of the Mother of God';

  @override
  String get onboardingMadeBy => 'Made by';

  @override
  String get onboardingExpandGroup => 'Collapse';

  @override
  String get onboardingCollapseGroup => 'Expand';

  @override
  String get onboardingChangePrayer => 'Choose another prayer';

  @override
  String get onboardingDefaultPrayerTypeLabel => 'Prayer';

  @override
  String get onboardingWelcomeHeading => 'Welcome';

  @override
  String get onboardingWelcomeAddress =>
      'The Sisters of the Congregation of the Mother of God welcome you with joy and invite you to pause, for a few moments, in the stillness of prayer.';

  @override
  String get onboardingWelcomeBody =>
      'In this app you will find prayers and hymns performed and recorded by the Sisters, so that, day by day, wherever you may be, you can be accompanied by their prayer.';

  @override
  String get onboardingWelcomeGuide =>
      'Next, we present a few pieces of information that will help you discover the app\'s content and use it according to your spiritual needs.';

  @override
  String get onboardingWelcomeBlessing =>
      'May the Lord bless you, and may the Most Pure Virgin Mary keep you under her protection!';

  @override
  String get onboardingWelcomeSignOff =>
      'With love in Christ,\nThe Sisters of the Congregation of the Mother of God';

  @override
  String get onboardingTextStepTitle => 'Customize the text';

  @override
  String get onboardingTextStepBody =>
      'Adjust the font and text size now or anytime from Settings.';

  @override
  String get onboardingReadingExampleLabel => 'Reading example';

  @override
  String get onboardingReadingPreviewQuote =>
      '\"Our Father, who art in heaven, hallowed be thy name…\"';

  @override
  String onboardingReminderTime(String time) {
    return 'Time: $time';
  }

  @override
  String get onboardingReminderDaysLabel => 'Days';

  @override
  String get onboardingReminderStepTitle => 'My prayer schedule';

  @override
  String get onboardingReminderStepBodyWeb =>
      'Reminders are only available from the app. On the web you can continue; you\'ll be able to set them up from Settings on your mobile device.';

  @override
  String get onboardingReminderStepBodyMobile =>
      'Optional: set a reminder for a prayer today. The time and days are filled in automatically, and you can change them later.';

  @override
  String get onboardingReminderNoPrayersToday =>
      'No prayers were found for today. You can add a reminder later from the app.';

  @override
  String get onboardingFavoritesStepTitle => 'Favorite prayers';

  @override
  String get onboardingFavoritesStepBody =>
      'If you\'d like, choose a favorite prayer to start. Favorite prayers are easier to find and listen to.';

  @override
  String get onboardingFavoritesLoadError =>
      'The list could not be loaded right now. You can add favorites later from the app.';

  @override
  String get onboardingAudioStepTitle => 'Listen to the prayers';

  @override
  String get onboardingAudioStepBody =>
      'Most prayers can be listened to in the app. Tap play for a short example — the first mystery of the Sorrowful Rosary.';

  @override
  String get onboardingAudioLoadError =>
      'The audio example could not be loaded right now. You can listen to prayers from the app.';

  @override
  String get onboardingAudioPause => 'Pause';

  @override
  String get onboardingAudioPlay => 'Play';

  @override
  String get onboardingClosingTitle => 'There\'s much to discover';

  @override
  String get onboardingClosingCalendarTitle => 'Calendar';

  @override
  String get onboardingClosingCalendarSubtitle => 'The prayers for each day';

  @override
  String get onboardingClosingDownloadsTitle => 'Downloads';

  @override
  String get onboardingClosingDownloadsSubtitle =>
      'Download prayers and hymns to listen to them offline.';

  @override
  String get onboardingClosingJournalTitle => 'Prayer journal';

  @override
  String get onboardingClosingGuideTitle => 'Guide';

  @override
  String get onboardingClosingGuideSubtitle =>
      'Learn briefly the meaning and use of each prayer.';

  @override
  String get onboardingClosingMoreTitle => 'And much more...';

  @override
  String get onboardingClosingBlessing =>
      'We wish you a blessed time of prayer!';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingStart => 'Start';

  @override
  String get calendarPageTitle => 'Calendar';

  @override
  String get allPrayersPageTitle => 'All prayers';

  @override
  String get gotIt => 'Got it';

  @override
  String get favoritesPageTitle => 'Favorite prayers';

  @override
  String get favoritesInfoDialogBody =>
      'Drag to reorder. Swipe left to delete. Downloaded prayers show the offline icon.';

  @override
  String get downloadedPageTitle => 'Downloaded prayers';

  @override
  String get downloadedInfoDialogBody =>
      'Downloaded prayers are available offline. You can delete them by swiping left. Note: deleting from this list does not remove them from storage. To free up storage, go to the Settings page.';

  @override
  String bookmarkSaved(String location) {
    return 'Bookmark for $location was saved!';
  }

  @override
  String get downloadCompletedTitle => 'Download completed!';

  @override
  String get downloadFailedTitle => 'Download could not be completed!';

  @override
  String get downloadFailedBody => 'Sorry, an error occurred. Try again later.';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get emptyDownloadedHint => 'Download the prayers you want by tapping ';

  @override
  String get emptyFavoriteHint => 'Save your favorite prayers by tapping ♡ ';

  @override
  String get emptyListDefaultTitle => 'The text will appear soon';

  @override
  String get emptyListDefaultSubtitle => 'Thank you for your patience!';

  @override
  String get textLoadFailedTitle => 'The text could not be loaded!';

  @override
  String get textLoadFailedSubtitle => 'Please try again later.';

  @override
  String get subtypesLoadFailedTitle => 'Could not load.';

  @override
  String get subtypesLoadFailedSubtitle =>
      'Check your internet connection or go to downloaded prayers.';

  @override
  String get readingAnchorTitle => 'Auto-scroll position';

  @override
  String get readingAnchorHint =>
      'Where the text auto-scrolls to while you listen to a prayer';

  @override
  String get autoScrollTitle => 'Auto-scroll text';

  @override
  String get autoScrollSubtitle =>
      'The text follows the audio playback automatically';

  @override
  String get chooseChapterDefaultTitle => 'Go to the desired section';

  @override
  String favoriteRemoved(String title, String subtitle) {
    return '$title - $subtitle is no longer in your favorites!';
  }

  @override
  String favoriteAdded(String title, String subtitle) {
    return '$title - $subtitle was saved to your favorites!';
  }

  @override
  String get downloadsMenuTitle => 'Downloads';

  @override
  String get expandHeader => 'Expand header';

  @override
  String get collapseHeader => 'Collapse header';
}

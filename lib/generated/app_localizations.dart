// GENERATED - DO NOT EDIT MANUALLY
// ignore_for_file: type=lint

import 'dart:ui';
import 'package:flutter/widgets.dart';

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = locale;

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  String get appTitle;
  String get navDashboard;
  String get navMyTrips;
  String get navArchive;
  String get navSettings;
  String get actionSave;
  String get actionCancel;
  String get actionDelete;
  String get actionEdit;
  String get actionAdd;
  String get actionClose;
  String get actionConfirm;
  String get actionBack;
  String get actionYes;
  String get actionNo;
  String get actionUpdate;
  String get actionApply;
  String get actionClear;
  String get fieldNotes;
  String get fieldName;
  String get fieldCategory;
  String get fieldDate;
  String get fieldPhone;
  String get fieldWebsite;
  String get fieldAddress;
  String get fieldStatus;
  String get fieldQuantity;
  String get fieldStoragePlace;
  String get fieldCurrency;
  String get fieldAmount;
  String get dashboardTitle;
  String get dashboardActiveTrip;
  String get dashboardNoActiveTrip;
  String get dashboardStartPlanning;
  String get dashboardPackingProgress;
  String get dashboardTaskProgress;
  String get dashboardDepartingToday;
  String get dashboardDepartingTomorrow;
  String get dashboardPacked;
  String get dashboardTasksDone;
  String get dashboardExpenses;
  String get dashboardSpent;
  String get tripsTitle;
  String get tripsNewTrip;
  String get tripsAddTrip;
  String get tripsEditTrip;
  String get tripsDeleteTrip;
  String get tripsArchiveTrip;
  String get tripsSetPlanned;
  String get tripsSetActive;
  String get tripsTripName;
  String get tripsDestination;
  String get tripsCountry;
  String get tripsTripType;
  String get tripsTripPurpose;
  String get tripsDeparture;
  String get tripsReturn;
  String get tripsDuration;
  String get tripsNoTrips;
  String get tripsNoTripsSubtitle;
  String get tripsTabActive;
  String get tripsTabPlanned;
  String get tripsTabArchived;
  String get tripsStatusActive;
  String get tripsStatusPlanned;
  String get tripsStatusArchived;
  String get tripDetailTitle;
  String get tripDetailOverview;
  String get tripDetailSections;
  String get tripDetailDepartingToday;
  String get tripDetailDepartingTomorrow;
  String get packingTitle;
  String get packingAddItem;
  String get packingEditItem;
  String get packingItemName;
  String get packingProgress;
  String get packingStatusPacked;
  String get packingStatusNotPacked;
  String get packingSaveTemplate;
  String get packingLoadTemplate;
  String get packingExportExcel;
  String get packingImportExcel;
  String get packingUncheckAll;
  String get packingDeleteAll;
  String get packingNoItems;
  String get packingNoItemsSubtitle;
  String get packingItemTasks;
  String get packingAllTasksDone;
  String get packingDeselectAll;
  String get packingMarkPacked;
  String get packingMarkUnpacked;
  String get packingTemplateTitle;
  String get packingTemplateDescription;
  String get packingNoTemplates;
  String get packingLoadTemplateTitle;
  String get packingSaveTemplateTitle;
  String get tasksTitle;
  String get tasksAddTask;
  String get tasksTaskName;
  String get tasksDueDate;
  String get tasksProgress;
  String get tasksTabPending;
  String get tasksTabInProgress;
  String get tasksTabDone;
  String get tasksStatusPending;
  String get tasksStatusInProgress;
  String get tasksStatusDone;
  String get tasksOverdue;
  String get tasksNoPending;
  String get tasksNoInProgress;
  String get tasksNoDone;
  String get tasksStart;
  String get tasksComplete;
  String get tasksMarkPending;
  String get tasksMarkInProgress;
  String get tasksMarkDone;
  String get addressesTitle;
  String get addressesAddAddress;
  String get addressesMapButton;
  String get addressesNoAddresses;
  String get addressesNoAddressesSubtitle;
  String get addressesCatHotel;
  String get addressesCatAirport;
  String get addressesCatRestaurant;
  String get addressesCatLandmark;
  String get addressesCatOffice;
  String get addressesCatHospital;
  String get addressesCatTransport;
  String get addressesCatShopping;
  String get addressesCatOther;
  String get receiptsTitle;
  String get receiptsAddReceipt;
  String get receiptsReceiptName;
  String get receiptsTotalExpenses;
  String get receiptsNoReceipts;
  String get receiptsNoReceiptsSubtitle;
  String get receiptsPhotoAttached;
  String get receiptsCatFood;
  String get receiptsCatTransport;
  String get receiptsCatAccommodation;
  String get receiptsCatEntertainment;
  String get receiptsCatShopping;
  String get receiptsCatHealth;
  String get receiptsCatCommunication;
  String get receiptsCatFees;
  String get receiptsCatOther;
  String get documentsTitle;
  String get documentsAddDocument;
  String get documentsDocumentName;
  String get documentsNoDocuments;
  String get documentsNoDocumentsSubtitle;
  String get documentsNoFileAttached;
  String get documentsFileAttached;
  String get documentsTypeTicket;
  String get documentsTypeVoucher;
  String get documentsTypeLetter;
  String get documentsTypePassport;
  String get documentsTypeVisa;
  String get documentsTypeInsurance;
  String get documentsTypeReservation;
  String get documentsTypeItinerary;
  String get documentsTypeOther;
  String get archiveTitle;
  String get archiveNoTrips;
  String get archiveNoTripsSubtitle;
  String get archiveCloneTrip;
  String get archiveCloneTitle;
  String get archiveCloneNewName;
  String get archiveClonePacking;
  String get archiveClonePackingSubtitle;
  String get archiveCloneTasks;
  String get archiveCloneTasksSubtitle;
  String get archiveCloneAddresses;
  String get archiveCloneAddressesSubtitle;
  String get archiveCloneDates;
  String get archiveCloneDeparture;
  String get archiveCloneReturn;
  String get archiveCloneOpenTrip;
  String get settingsAppearance;
  String get settingsSelectTheme;
  String get themeLight;
  String get themeDark;
  String get themeSystem;
  String get settingsTextSize;
  String get fontSmall;
  String get fontNormal;
  String get fontLarge;
  String get settingsColorTheme;
  String get colorOceanDusk;
  String get colorOceanMidnight;
  String get colorAmberSunset;
  String get colorCobaltStorm;
  String get colorGrassForest;
  String get colorOrchidDusk;
  String get settingsTitle;
  String get settingsDataManagement;
  String get settingsExportBackup;
  String get settingsExportBackupSubtitle;
  String get settingsRestoreBackup;
  String get settingsRestoreBackupSubtitle;
  String get settingsDangerZone;
  String get settingsResetData;
  String get settingsResetDataSubtitle;
  String get settingsLanguage;
  String get settingsSelectLanguage;
  String get settingsLanguageEditor;
  String get settingsLanguageEditorSubtitle;
  String get settingsAbout;
  String get settingsAboutSubtitle;
  String get settingsRestoreConfirmTitle;
  String get settingsRestoreConfirmBody;
  String get settingsResetStep1Title;
  String get settingsResetStep1Body;
  String get settingsResetStep2Title;
  String get settingsResetStep2Body;
  String get settingsResetKeyword;
  String get settingsResetButton;
  String get settingsResetSuccess;
  String get langEnglish;
  String get langHebrew;
  String get tripTypeLeisure;
  String get tripTypeBusiness;
  String get tripTypeFamily;
  String get tripPurposeHoliday;
  String get tripPurposeWorkTrip;
  String get tripPurposeFamilyVisit;
  String get tripPurposeConference;
  String get packingCatClothing;
  String get packingCatToiletries;
  String get packingCatElectronics;
  String get packingCatDocuments;
  String get packingCatMedication;
  String get packingCatFoodSnacks;
  String get packingCatAccessories;
  String get packingCatSportOutdoor;
  String get packingCatBabyKids;
  String get packingCatWorkOffice;
  String get packingCatOther;
  String get storageCheckin;
  String get storageHandLuggage;
  String get storageBackpack;
  String get storageToiletryBag;
  String get storageLaptopBag;
  String get storageHandbag;
  String get storageWallet;
  String get storageMoneyBelt;
  String get storageCarBoot;
  String get storageShippingBox;
  String get storageOther;
  String get packingItemNameHint;
  String get packingItemNameRequired;
  String get packingSelectCategory;
  String get packingStoragePlaceHint;
  String get packingCustomStorageHint;
  String get packingNotesHint;
  String get packingItemTasksLabel;
  String get packingItemTasksHint;
  String get packingAddTaskHint;
  String get packingUpdateItem;
  String get packingErrorSaving;
  String get templateSaveTitle;
  String get templateNameLabel;
  String get templateNameHint;
  String get templateDescLabel;
  String get templateDescHint;
  String get templateSaveButton;
  String get templateErrorSaving;
  String get templateLoadTitle;
  String get templateNoTemplates;
  String get templateNoTemplatesSubtitle;
  String get tripTypeAdventure;
  String get tripTypeMedical;
  String get tripTypeOther;
  String get tripPurposeMedical;
  String get tripPurposeOther;
  String get packingUncategorised;
  String get packingExcelHeaderName;
  String get packingExcelHeaderCategory;
  String get packingExcelHeaderQuantity;
  String get packingExcelHeaderStorage;
  String get packingExcelHeaderStatus;
  String get packingExcelHeaderNotes;
  String get tripDetailTypeBadge;
  String get validatorRequired;
  String get backupRestoredSuccess;
  String get backupRestoreFailed;
  String get resetConfirmMismatch;
  String get settingsContinue;
  String get settingsBackupFailed;
  String get imageLoadError;
  String fieldExchangeRate(String currency);
  String dashboardDaysUntil(int days);
  String tripsDays(int count);
  String tripDetailDaysUntil(int days);
  String packingPackedCount(int packed, int total);
  String packingTasksPending(int count);
  String packingSelectAll(int count);
  String tasksDoneCount(int done, int total);
  String templateSaveSubtitle(int count);
  String templateItemCount(int count);
  String packingSelectedCount(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(_AppLocalizationsImpl(locale.languageCode));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class _AppLocalizationsImpl extends AppLocalizations {
  _AppLocalizationsImpl(String locale) : super(locale);

  // Expose locale string for languageCode access in getters
  Locale get locale => Locale(localeName);


  @override
  String get appTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'TripReady';
      default:
        return 'TripReady';
    }
  }
  @override
  String get navDashboard {
    switch (locale.languageCode) {
      case 'he':
        return 'לוח בקרה';
      default:
        return 'Dashboard';
    }
  }
  @override
  String get navMyTrips {
    switch (locale.languageCode) {
      case 'he':
        return 'הנסיעות שלי';
      default:
        return 'My Trips';
    }
  }
  @override
  String get navArchive {
    switch (locale.languageCode) {
      case 'he':
        return 'ארכיון';
      default:
        return 'Archive';
    }
  }
  @override
  String get navSettings {
    switch (locale.languageCode) {
      case 'he':
        return 'הגדרות';
      default:
        return 'Settings';
    }
  }
  @override
  String get actionSave {
    switch (locale.languageCode) {
      case 'he':
        return 'שמור';
      default:
        return 'Save';
    }
  }
  @override
  String get actionCancel {
    switch (locale.languageCode) {
      case 'he':
        return 'ביטול';
      default:
        return 'Cancel';
    }
  }
  @override
  String get actionDelete {
    switch (locale.languageCode) {
      case 'he':
        return 'מחק';
      default:
        return 'Delete';
    }
  }
  @override
  String get actionEdit {
    switch (locale.languageCode) {
      case 'he':
        return 'ערוך';
      default:
        return 'Edit';
    }
  }
  @override
  String get actionAdd {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף';
      default:
        return 'Add';
    }
  }
  @override
  String get actionClose {
    switch (locale.languageCode) {
      case 'he':
        return 'סגור';
      default:
        return 'Close';
    }
  }
  @override
  String get actionConfirm {
    switch (locale.languageCode) {
      case 'he':
        return 'אישור';
      default:
        return 'Confirm';
    }
  }
  @override
  String get actionBack {
    switch (locale.languageCode) {
      case 'he':
        return 'חזרה';
      default:
        return 'Back';
    }
  }
  @override
  String get actionYes {
    switch (locale.languageCode) {
      case 'he':
        return 'כן';
      default:
        return 'Yes';
    }
  }
  @override
  String get actionNo {
    switch (locale.languageCode) {
      case 'he':
        return 'לא';
      default:
        return 'No';
    }
  }
  @override
  String get actionUpdate {
    switch (locale.languageCode) {
      case 'he':
        return 'עדכן';
      default:
        return 'Update';
    }
  }
  @override
  String get actionApply {
    switch (locale.languageCode) {
      case 'he':
        return 'החל';
      default:
        return 'Apply';
    }
  }
  @override
  String get actionClear {
    switch (locale.languageCode) {
      case 'he':
        return 'נקה סינון';
      default:
        return 'Clear Filters';
    }
  }
  @override
  String get fieldNotes {
    switch (locale.languageCode) {
      case 'he':
        return 'הערות';
      default:
        return 'Notes';
    }
  }
  @override
  String get fieldName {
    switch (locale.languageCode) {
      case 'he':
        return 'שם';
      default:
        return 'Name';
    }
  }
  @override
  String get fieldCategory {
    switch (locale.languageCode) {
      case 'he':
        return 'קטגוריה';
      default:
        return 'Category';
    }
  }
  @override
  String get fieldDate {
    switch (locale.languageCode) {
      case 'he':
        return 'תאריך';
      default:
        return 'Date';
    }
  }
  @override
  String get fieldPhone {
    switch (locale.languageCode) {
      case 'he':
        return 'טלפון';
      default:
        return 'Phone';
    }
  }
  @override
  String get fieldWebsite {
    switch (locale.languageCode) {
      case 'he':
        return 'אתר אינטרנט';
      default:
        return 'Website';
    }
  }
  @override
  String get fieldAddress {
    switch (locale.languageCode) {
      case 'he':
        return 'כתובת';
      default:
        return 'Address';
    }
  }
  @override
  String get fieldStatus {
    switch (locale.languageCode) {
      case 'he':
        return 'סטטוס';
      default:
        return 'Status';
    }
  }
  @override
  String get fieldQuantity {
    switch (locale.languageCode) {
      case 'he':
        return 'כמות';
      default:
        return 'Quantity';
    }
  }
  @override
  String get fieldStoragePlace {
    switch (locale.languageCode) {
      case 'he':
        return 'מקום אחסון';
      default:
        return 'Storage Place';
    }
  }
  @override
  String get fieldCurrency {
    switch (locale.languageCode) {
      case 'he':
        return 'מטבע';
      default:
        return 'Currency';
    }
  }
  @override
  String get fieldAmount {
    switch (locale.languageCode) {
      case 'he':
        return 'סכום';
      default:
        return 'Amount';
    }
  }
  @override
  String get dashboardTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'לוח בקרה';
      default:
        return 'Dashboard';
    }
  }
  @override
  String get dashboardActiveTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'נסיעה פעילה';
      default:
        return 'Active Trip';
    }
  }
  @override
  String get dashboardNoActiveTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'אין נסיעה פעילה';
      default:
        return 'No active trip';
    }
  }
  @override
  String get dashboardStartPlanning {
    switch (locale.languageCode) {
      case 'he':
        return 'התחל לתכנן את הנסיעה הבאה שלך';
      default:
        return 'Start planning your next trip';
    }
  }
  @override
  String get dashboardPackingProgress {
    switch (locale.languageCode) {
      case 'he':
        return 'התקדמות אריזה';
      default:
        return 'Packing Progress';
    }
  }
  @override
  String get dashboardTaskProgress {
    switch (locale.languageCode) {
      case 'he':
        return 'התקדמות משימות';
      default:
        return 'Task Progress';
    }
  }
  @override
  String get dashboardDepartingToday {
    switch (locale.languageCode) {
      case 'he':
        return '🛫 יוצאים היום!';
      default:
        return '🛫 Departing today!';
    }
  }
  @override
  String get dashboardDepartingTomorrow {
    switch (locale.languageCode) {
      case 'he':
        return '🗓 יוצאים מחר!';
      default:
        return '🗓 Departing tomorrow!';
    }
  }
  @override
  String get dashboardPacked {
    switch (locale.languageCode) {
      case 'he':
        return 'ארוז';
      default:
        return 'Packed';
    }
  }
  @override
  String get dashboardTasksDone {
    switch (locale.languageCode) {
      case 'he':
        return 'משימות שבוצעו';
      default:
        return 'Tasks Done';
    }
  }
  @override
  String get dashboardExpenses {
    switch (locale.languageCode) {
      case 'he':
        return 'הוצאות';
      default:
        return 'Expenses';
    }
  }
  @override
  String get dashboardSpent {
    switch (locale.languageCode) {
      case 'he':
        return 'הוצאתי';
      default:
        return 'Spent';
    }
  }
  @override
  String get tripsTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'הנסיעות שלי';
      default:
        return 'My Trips';
    }
  }
  @override
  String get tripsNewTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'נסיעה חדשה';
      default:
        return 'New Trip';
    }
  }
  @override
  String get tripsAddTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף נסיעה';
      default:
        return 'Add Trip';
    }
  }
  @override
  String get tripsEditTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'ערוך נסיעה';
      default:
        return 'Edit Trip';
    }
  }
  @override
  String get tripsDeleteTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'מחק נסיעה';
      default:
        return 'Delete Trip';
    }
  }
  @override
  String get tripsArchiveTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'העבר לארכיון';
      default:
        return 'Archive Trip';
    }
  }
  @override
  String get tripsSetPlanned {
    switch (localeName) {
      case 'he': return 'העבר לתכנון';
      default:   return 'Set as Planned';
    }
  }
  @override
  String get tripsSetActive {
    switch (locale.languageCode) {
      case 'he':
        return 'הגדר כפעילה';
      default:
        return 'Set as Active';
    }
  }
  @override
  String get tripsTripName {
    switch (locale.languageCode) {
      case 'he':
        return 'שם הנסיעה';
      default:
        return 'Trip Name';
    }
  }
  @override
  String get tripsDestination {
    switch (locale.languageCode) {
      case 'he':
        return 'יעד';
      default:
        return 'Destination';
    }
  }
  @override
  String get tripsCountry {
    switch (locale.languageCode) {
      case 'he':
        return 'מדינה';
      default:
        return 'Country';
    }
  }
  @override
  String get tripsTripType {
    switch (locale.languageCode) {
      case 'he':
        return 'סוג הנסיעה';
      default:
        return 'Trip Type';
    }
  }
  @override
  String get tripsTripPurpose {
    switch (locale.languageCode) {
      case 'he':
        return 'מטרת הנסיעה';
      default:
        return 'Trip Purpose';
    }
  }
  @override
  String get tripsDeparture {
    switch (locale.languageCode) {
      case 'he':
        return 'יציאה';
      default:
        return 'Departure';
    }
  }
  @override
  String get tripsReturn {
    switch (locale.languageCode) {
      case 'he':
        return 'חזרה';
      default:
        return 'Return';
    }
  }
  @override
  String get tripsDuration {
    switch (locale.languageCode) {
      case 'he':
        return 'משך';
      default:
        return 'Duration';
    }
  }
  @override
  String get tripsNoTrips {
    switch (locale.languageCode) {
      case 'he':
        return 'אין נסיעות עדיין';
      default:
        return 'No trips yet';
    }
  }
  @override
  String get tripsNoTripsSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'לחץ על הכפתור למטה להוספת הנסיעה הראשונה.';
      default:
        return 'Tap the button below to add your first trip.';
    }
  }
  @override
  String get tripsTabActive {
    switch (locale.languageCode) {
      case 'he':
        return 'פעיל';
      default:
        return 'Active';
    }
  }
  @override
  String get tripsTabPlanned {
    switch (locale.languageCode) {
      case 'he':
        return 'מתוכנן';
      default:
        return 'Planned';
    }
  }
  @override
  String get tripsTabArchived {
    switch (locale.languageCode) {
      case 'he':
        return 'בארכיון';
      default:
        return 'Archived';
    }
  }
  @override
  String get tripsStatusActive {
    switch (locale.languageCode) {
      case 'he':
        return 'פעילה';
      default:
        return 'Active';
    }
  }
  @override
  String get tripsStatusPlanned {
    switch (locale.languageCode) {
      case 'he':
        return 'מתוכננת';
      default:
        return 'Planned';
    }
  }
  @override
  String get tripsStatusArchived {
    switch (locale.languageCode) {
      case 'he':
        return 'בארכיון';
      default:
        return 'Archived';
    }
  }
  @override
  String get tripDetailTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'פרטי נסיעה';
      default:
        return 'Trip Detail';
    }
  }
  @override
  String get tripDetailOverview {
    switch (locale.languageCode) {
      case 'he':
        return 'סקירה כללית';
      default:
        return 'Overview';
    }
  }
  @override
  String get tripDetailSections {
    switch (locale.languageCode) {
      case 'he':
        return 'חלקי הנסיעה';
      default:
        return 'Trip Sections';
    }
  }
  @override
  String get tripDetailDepartingToday {
    switch (locale.languageCode) {
      case 'he':
        return '🛫 יוצאים היום!';
      default:
        return '🛫 Departing today!';
    }
  }
  @override
  String get tripDetailDepartingTomorrow {
    switch (locale.languageCode) {
      case 'he':
        return '🗓 יוצאים מחר!';
      default:
        return '🗓 Departing tomorrow!';
    }
  }
  @override
  String get packingTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'רשימת אריזה';
      default:
        return 'Packing List';
    }
  }
  @override
  String get packingAddItem {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף פריט';
      default:
        return 'Add Item';
    }
  }
  @override
  String get packingEditItem {
    switch (locale.languageCode) {
      case 'he':
        return 'ערוך פריט';
      default:
        return 'Edit Item';
    }
  }
  @override
  String get packingItemName {
    switch (locale.languageCode) {
      case 'he':
        return 'שם פריט';
      default:
        return 'Item Name';
    }
  }
  @override
  String get packingProgress {
    switch (locale.languageCode) {
      case 'he':
        return 'התקדמות אריזה';
      default:
        return 'Packing Progress';
    }
  }
  @override
  String get packingStatusPacked {
    switch (locale.languageCode) {
      case 'he':
        return 'ארוז';
      default:
        return 'Packed';
    }
  }
  @override
  String get packingStatusNotPacked {
    switch (locale.languageCode) {
      case 'he':
        return 'לא ארוז';
      default:
        return 'Not Packed';
    }
  }
  @override
  String get packingSaveTemplate {
    switch (locale.languageCode) {
      case 'he':
        return 'שמור כתבנית';
      default:
        return 'Save as Template';
    }
  }
  @override
  String get packingLoadTemplate {
    switch (locale.languageCode) {
      case 'he':
        return 'טען תבנית';
      default:
        return 'Load Template';
    }
  }
  @override
  String get packingExportExcel {
    switch (locale.languageCode) {
      case 'he':
        return 'ייצא לאקסל';
      default:
        return 'Export as Excel';
    }
  }
  @override
  String get packingImportExcel {
    switch (locale.languageCode) {
      case 'he':
        return 'ייבא מאקסל';
      default:
        return 'Import from Excel';
    }
  }
  @override
  String get packingUncheckAll {
    switch (locale.languageCode) {
      case 'he':
        return 'בטל סימון לכל הפריטים';
      default:
        return 'Uncheck All Items';
    }
  }
  @override
  String get packingDeleteAll {
    switch (locale.languageCode) {
      case 'he':
        return 'מחק את כל הפריטים';
      default:
        return 'Delete All Items';
    }
  }
  @override
  String get packingNoItems {
    switch (locale.languageCode) {
      case 'he':
        return 'אין פריטים עדיין';
      default:
        return 'No items yet';
    }
  }
  @override
  String get packingNoItemsSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף פריטים ידנית, טען תבנית, או ייבא מאקסל.';
      default:
        return 'Add items manually, load a template, or import from Excel.';
    }
  }
  @override
  String get packingItemTasks {
    switch (locale.languageCode) {
      case 'he':
        return 'משימות פריט';
      default:
        return 'Item Tasks';
    }
  }
  @override
  String get packingAllTasksDone {
    switch (locale.languageCode) {
      case 'he':
        return 'כל המשימות הושלמו';
      default:
        return 'All tasks done';
    }
  }
  @override
  String get packingDeselectAll {
    switch (locale.languageCode) {
      case 'he':
        return 'בטל בחירת הכל';
      default:
        return 'Deselect all';
    }
  }
  @override
  String get packingMarkPacked {
    switch (locale.languageCode) {
      case 'he':
        return 'סמן כארוז';
      default:
        return 'Mark as Packed';
    }
  }
  @override
  String get packingMarkUnpacked {
    switch (locale.languageCode) {
      case 'he':
        return 'סמן כלא ארוז';
      default:
        return 'Mark as Not Packed';
    }
  }
  @override
  String get packingTemplateTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'שם התבנית';
      default:
        return 'Template Name';
    }
  }
  @override
  String get packingTemplateDescription {
    switch (locale.languageCode) {
      case 'he':
        return 'תיאור';
      default:
        return 'Description';
    }
  }
  @override
  String get packingNoTemplates {
    switch (locale.languageCode) {
      case 'he':
        return 'אין תבניות שמורות עדיין';
      default:
        return 'No templates saved yet';
    }
  }
  @override
  String get packingLoadTemplateTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'טען תבנית';
      default:
        return 'Load Template';
    }
  }
  @override
  String get packingSaveTemplateTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'שמור כתבנית';
      default:
        return 'Save as Template';
    }
  }
  @override
  String get tasksTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'משימות';
      default:
        return 'Tasks';
    }
  }
  @override
  String get tasksAddTask {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף משימה';
      default:
        return 'Add Task';
    }
  }
  @override
  String get tasksTaskName {
    switch (locale.languageCode) {
      case 'he':
        return 'שם משימה';
      default:
        return 'Task Name';
    }
  }
  @override
  String get tasksDueDate {
    switch (locale.languageCode) {
      case 'he':
        return 'תאריך יעד';
      default:
        return 'Due Date';
    }
  }
  @override
  String get tasksProgress {
    switch (locale.languageCode) {
      case 'he':
        return 'התקדמות משימות';
      default:
        return 'Task Progress';
    }
  }
  @override
  String get tasksTabPending {
    switch (locale.languageCode) {
      case 'he':
        return 'ממתין';
      default:
        return 'Pending';
    }
  }
  @override
  String get tasksTabInProgress {
    switch (locale.languageCode) {
      case 'he':
        return 'בביצוע';
      default:
        return 'In Progress';
    }
  }
  @override
  String get tasksTabDone {
    switch (locale.languageCode) {
      case 'he':
        return 'הושלם';
      default:
        return 'Done';
    }
  }
  @override
  String get tasksStatusPending {
    switch (locale.languageCode) {
      case 'he':
        return 'ממתין';
      default:
        return 'Pending';
    }
  }
  @override
  String get tasksStatusInProgress {
    switch (locale.languageCode) {
      case 'he':
        return 'בביצוע';
      default:
        return 'In Progress';
    }
  }
  @override
  String get tasksStatusDone {
    switch (locale.languageCode) {
      case 'he':
        return 'הושלם';
      default:
        return 'Done';
    }
  }
  @override
  String get tasksOverdue {
    switch (locale.languageCode) {
      case 'he':
        return 'באיחור';
      default:
        return 'OVERDUE';
    }
  }
  @override
  String get tasksNoPending {
    switch (locale.languageCode) {
      case 'he':
        return 'אין משימות ממתינות';
      default:
        return 'No pending tasks';
    }
  }
  @override
  String get tasksNoInProgress {
    switch (locale.languageCode) {
      case 'he':
        return 'אין משימות בביצוע';
      default:
        return 'No tasks in progress';
    }
  }
  @override
  String get tasksNoDone {
    switch (locale.languageCode) {
      case 'he':
        return 'אין משימות שהושלמו עדיין';
      default:
        return 'No completed tasks yet';
    }
  }
  @override
  String get tasksStart {
    switch (locale.languageCode) {
      case 'he':
        return 'התחל';
      default:
        return 'Start';
    }
  }
  @override
  String get tasksComplete {
    switch (locale.languageCode) {
      case 'he':
        return 'סיים';
      default:
        return 'Complete';
    }
  }
  @override
  String get tasksMarkPending {
    switch (locale.languageCode) {
      case 'he':
        return 'סמן כממתין';
      default:
        return 'Mark as Pending';
    }
  }
  @override
  String get tasksMarkInProgress {
    switch (locale.languageCode) {
      case 'he':
        return 'סמן כבביצוע';
      default:
        return 'Mark as In Progress';
    }
  }
  @override
  String get tasksMarkDone {
    switch (locale.languageCode) {
      case 'he':
        return 'סמן כהושלם';
      default:
        return 'Mark as Done';
    }
  }
  @override
  String get addressesTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'כתובות';
      default:
        return 'Addresses';
    }
  }
  @override
  String get addressesAddAddress {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף כתובת';
      default:
        return 'Add Address';
    }
  }
  @override
  String get addressesMapButton {
    switch (locale.languageCode) {
      case 'he':
        return 'מפה';
      default:
        return 'Map';
    }
  }
  @override
  String get addressesNoAddresses {
    switch (locale.languageCode) {
      case 'he':
        return 'אין כתובות שמורות';
      default:
        return 'No addresses saved';
    }
  }
  @override
  String get addressesNoAddressesSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף מלונות, מסעדות, אתרי תיירות ועוד.';
      default:
        return 'Add hotels, restaurants, landmarks and more.';
    }
  }
  @override
  String get addressesCatHotel {
    switch (locale.languageCode) {
      case 'he':
        return 'מלון';
      default:
        return 'Hotel';
    }
  }
  @override
  String get addressesCatAirport {
    switch (locale.languageCode) {
      case 'he':
        return 'שדה תעופה';
      default:
        return 'Airport';
    }
  }
  @override
  String get addressesCatRestaurant {
    switch (locale.languageCode) {
      case 'he':
        return 'מסעדה';
      default:
        return 'Restaurant';
    }
  }
  @override
  String get addressesCatLandmark {
    switch (locale.languageCode) {
      case 'he':
        return 'אתר תיירות';
      default:
        return 'Landmark';
    }
  }
  @override
  String get addressesCatOffice {
    switch (locale.languageCode) {
      case 'he':
        return 'משרד';
      default:
        return 'Office';
    }
  }
  @override
  String get addressesCatHospital {
    switch (locale.languageCode) {
      case 'he':
        return 'בית חולים';
      default:
        return 'Hospital';
    }
  }
  @override
  String get addressesCatTransport {
    switch (locale.languageCode) {
      case 'he':
        return 'תחבורה';
      default:
        return 'Transport';
    }
  }
  @override
  String get addressesCatShopping {
    switch (locale.languageCode) {
      case 'he':
        return 'קניות';
      default:
        return 'Shopping';
    }
  }
  @override
  String get addressesCatOther {
    switch (locale.languageCode) {
      case 'he':
        return 'אחר';
      default:
        return 'Other';
    }
  }
  @override
  String get receiptsTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'קבלות והוצאות';
      default:
        return 'Receipts & Expenses';
    }
  }
  @override
  String get receiptsAddReceipt {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף קבלה';
      default:
        return 'Add Receipt';
    }
  }
  @override
  String get receiptsReceiptName {
    switch (locale.languageCode) {
      case 'he':
        return 'שם קבלה';
      default:
        return 'Receipt Name';
    }
  }
  @override
  String get receiptsTotalExpenses {
    switch (locale.languageCode) {
      case 'he':
        return 'סך הוצאות';
      default:
        return 'Total Expenses';
    }
  }
  @override
  String get receiptsNoReceipts {
    switch (locale.languageCode) {
      case 'he':
        return 'אין קבלות עדיין';
      default:
        return 'No receipts yet';
    }
  }
  @override
  String get receiptsNoReceiptsSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'עקוב אחר ההוצאות שלך על ידי הוספת קבלות.';
      default:
        return 'Track your expenses by adding receipts.';
    }
  }
  @override
  String get receiptsPhotoAttached {
    switch (locale.languageCode) {
      case 'he':
        return 'תמונה מצורפת';
      default:
        return 'Photo attached';
    }
  }
  @override
  String get receiptsCatFood {
    switch (locale.languageCode) {
      case 'he':
        return 'אוכל ומשקאות';
      default:
        return 'Food & Drink';
    }
  }
  @override
  String get receiptsCatTransport {
    switch (locale.languageCode) {
      case 'he':
        return 'תחבורה';
      default:
        return 'Transport';
    }
  }
  @override
  String get receiptsCatAccommodation {
    switch (locale.languageCode) {
      case 'he':
        return 'לינה';
      default:
        return 'Accommodation';
    }
  }
  @override
  String get receiptsCatEntertainment {
    switch (locale.languageCode) {
      case 'he':
        return 'בידור';
      default:
        return 'Entertainment';
    }
  }
  @override
  String get receiptsCatShopping {
    switch (locale.languageCode) {
      case 'he':
        return 'קניות';
      default:
        return 'Shopping';
    }
  }
  @override
  String get receiptsCatHealth {
    switch (locale.languageCode) {
      case 'he':
        return 'בריאות';
      default:
        return 'Health';
    }
  }
  @override
  String get receiptsCatCommunication {
    switch (locale.languageCode) {
      case 'he':
        return 'תקשורת';
      default:
        return 'Communication';
    }
  }
  @override
  String get receiptsCatFees {
    switch (locale.languageCode) {
      case 'he':
        return 'עמלות וחיובים';
      default:
        return 'Fees & Charges';
    }
  }
  @override
  String get receiptsCatOther {
    switch (locale.languageCode) {
      case 'he':
        return 'אחר';
      default:
        return 'Other';
    }
  }
  @override
  String get documentsTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'מסמכים';
      default:
        return 'Documents';
    }
  }
  @override
  String get documentsAddDocument {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף מסמך';
      default:
        return 'Add Document';
    }
  }
  @override
  String get documentsDocumentName {
    switch (locale.languageCode) {
      case 'he':
        return 'שם מסמך';
      default:
        return 'Document Name';
    }
  }
  @override
  String get documentsNoDocuments {
    switch (locale.languageCode) {
      case 'he':
        return 'אין מסמכים עדיין';
      default:
        return 'No documents yet';
    }
  }
  @override
  String get documentsNoDocumentsSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף כרטיסים, שוברים, מכתבים ומסמכים נוספים.';
      default:
        return 'Add tickets, vouchers, letters and other documents.';
    }
  }
  @override
  String get documentsNoFileAttached {
    switch (locale.languageCode) {
      case 'he':
        return 'אין קובץ מצורף';
      default:
        return 'No file attached';
    }
  }
  @override
  String get documentsFileAttached {
    switch (locale.languageCode) {
      case 'he':
        return 'קובץ מצורף';
      default:
        return 'File attached';
    }
  }
  @override
  String get documentsTypeTicket {
    switch (locale.languageCode) {
      case 'he':
        return 'כרטיס';
      default:
        return 'Ticket';
    }
  }
  @override
  String get documentsTypeVoucher {
    switch (locale.languageCode) {
      case 'he':
        return 'שובר';
      default:
        return 'Voucher';
    }
  }
  @override
  String get documentsTypeLetter {
    switch (locale.languageCode) {
      case 'he':
        return 'מכתב';
      default:
        return 'Letter';
    }
  }
  @override
  String get documentsTypePassport {
    switch (locale.languageCode) {
      case 'he':
        return 'דרכון';
      default:
        return 'Passport';
    }
  }
  @override
  String get documentsTypeVisa {
    switch (locale.languageCode) {
      case 'he':
        return 'ויזה';
      default:
        return 'Visa';
    }
  }
  @override
  String get documentsTypeInsurance {
    switch (locale.languageCode) {
      case 'he':
        return 'ביטוח';
      default:
        return 'Insurance';
    }
  }
  @override
  String get documentsTypeReservation {
    switch (locale.languageCode) {
      case 'he':
        return 'הזמנה';
      default:
        return 'Reservation';
    }
  }
  @override
  String get documentsTypeItinerary {
    switch (locale.languageCode) {
      case 'he':
        return 'מסלול';
      default:
        return 'Itinerary';
    }
  }
  @override
  String get documentsTypeOther {
    switch (locale.languageCode) {
      case 'he':
        return 'אחר';
      default:
        return 'Other';
    }
  }
  @override
  String get archiveTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'ארכיון';
      default:
        return 'Archive';
    }
  }
  @override
  String get archiveNoTrips {
    switch (locale.languageCode) {
      case 'he':
        return 'אין נסיעות בארכיון';
      default:
        return 'No archived trips';
    }
  }
  @override
  String get archiveNoTripsSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'נסיעות שהועברו לארכיון יופיעו כאן לעיון.';
      default:
        return 'Trips you archive will appear here for reference.';
    }
  }
  @override
  String get archiveCloneTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'שכפל לנסיעה חדשה';
      default:
        return 'Clone to New Trip';
    }
  }
  @override
  String get archiveCloneTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'שכפול נסיעה';
      default:
        return 'Clone Trip';
    }
  }
  @override
  String get archiveCloneNewName {
    switch (locale.languageCode) {
      case 'he':
        return 'שם הנסיעה החדשה';
      default:
        return 'New Trip Name';
    }
  }
  @override
  String get archiveClonePacking {
    switch (locale.languageCode) {
      case 'he':
        return 'רשימת אריזה';
      default:
        return 'Packing List';
    }
  }
  @override
  String get archiveClonePackingSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'כל הפריטים (מאופס ללא ארוז)';
      default:
        return 'All items (reset to unpacked)';
    }
  }
  @override
  String get archiveCloneTasks {
    switch (locale.languageCode) {
      case 'he':
        return 'משימות';
      default:
        return 'Tasks';
    }
  }
  @override
  String get archiveCloneTasksSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'כל המשימות (מאופס לממתין)';
      default:
        return 'All tasks (reset to pending)';
    }
  }
  @override
  String get archiveCloneAddresses {
    switch (locale.languageCode) {
      case 'he':
        return 'כתובות';
      default:
        return 'Addresses';
    }
  }
  @override
  String get archiveCloneAddressesSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'מלונות, מסעדות, אתרי תיירות';
      default:
        return 'Hotels, restaurants, landmarks';
    }
  }
  @override
  String get archiveCloneDates {
    switch (locale.languageCode) {
      case 'he': return 'תאריכי טיול';
      default:   return 'Trip Dates';
    }
  }
  @override
  String get archiveCloneDeparture {
    switch (locale.languageCode) {
      case 'he': return 'יציאה';
      default:   return 'Departure';
    }
  }
  @override
  String get archiveCloneReturn {
    switch (locale.languageCode) {
      case 'he': return 'חזרה';
      default:   return 'Return';
    }
  }
  @override
  String get archiveCloneOpenTrip {
    switch (locale.languageCode) {
      case 'he': return 'פתח טיול חדש';
      default:   return 'Open New Trip';
    }
  }
  @override
  String get settingsAppearance {
    switch (localeName) {
      case 'he': return 'מראה';
      default:   return 'Appearance';
    }
  }
  @override
  String get settingsSelectTheme {
    switch (localeName) {
      case 'he': return 'בחר ערכת נושא';
      default:   return 'Select Theme';
    }
  }
  @override
  String get themeLight {
    switch (localeName) {
      case 'he': return 'בהיר';
      default:   return 'Light';
    }
  }
  @override
  String get themeDark {
    switch (localeName) {
      case 'he': return 'כהה';
      default:   return 'Dark';
    }
  }
  @override
  String get themeSystem {
    switch (localeName) {
      case 'he': return 'לפי מערכת';
      default:   return 'System';
    }
  }
  @override
  String get settingsTextSize {
    switch (localeName) {
      case 'he': return 'גודל טקסט';
      default:   return 'Text Size';
    }
  }
  @override
  String get fontSmall {
    switch (localeName) {
      case 'he': return 'קטן';
      default:   return 'Small';
    }
  }
  @override
  String get fontNormal {
    switch (localeName) {
      case 'he': return 'רגיל';
      default:   return 'Normal';
    }
  }
  @override
  String get fontLarge {
    switch (localeName) {
      case 'he': return 'גדול';
      default:   return 'Large';
    }
  }
  @override
  String get settingsColorTheme {
    switch (localeName) {
      case 'he': return 'ערכת צבעים';
      default:   return 'Color Theme';
    }
  }
  @override
  String get colorOceanDusk {
    switch (localeName) {
      case 'he': return 'אוקיינוס · דמדומים';
      default:   return 'Ocean · Dusk';
    }
  }
  @override
  String get colorOceanMidnight {
    switch (localeName) {
      case 'he': return 'אוקיינוס · חצות';
      default:   return 'Ocean · Midnight';
    }
  }
  @override
  String get colorAmberSunset {
    switch (localeName) {
      case 'he': return 'ענבר · שקיעה';
      default:   return 'Amber · Sunset';
    }
  }
  @override
  String get colorCobaltStorm {
    switch (localeName) {
      case 'he': return 'כחול · סערה';
      default:   return 'Cobalt · Storm';
    }
  }
  @override
  String get colorGrassForest {
    switch (localeName) {
      case 'he': return 'ירוק · יער';
      default:   return 'Grass · Forest';
    }
  }
  @override
  String get colorOrchidDusk {
    switch (localeName) {
      case 'he': return 'סחלב · דמדומים';
      default:   return 'Orchid · Dusk';
    }
  }
  @override
  String get settingsTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'הגדרות';
      default:
        return 'Settings';
    }
  }
  @override
  String get settingsDataManagement {
    switch (locale.languageCode) {
      case 'he':
        return 'ניהול נתונים';
      default:
        return 'Data Management';
    }
  }
  @override
  String get settingsExportBackup {
    switch (locale.languageCode) {
      case 'he':
        return 'ייצא גיבוי';
      default:
        return 'Export Backup';
    }
  }
  @override
  String get settingsExportBackupSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'שמור עותק של כל נתוני הנסיעות שלך';
      default:
        return 'Save a copy of all your trip data';
    }
  }
  @override
  String get settingsRestoreBackup {
    switch (locale.languageCode) {
      case 'he':
        return 'שחזר גיבוי';
      default:
        return 'Restore Backup';
    }
  }
  @override
  String get settingsRestoreBackupSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'שחזר מקובץ גיבוי שיוצא קודם';
      default:
        return 'Restore from a previously exported backup file';
    }
  }
  @override
  String get settingsDangerZone {
    switch (locale.languageCode) {
      case 'he':
        return 'אזור מסוכן';
      default:
        return 'Danger Zone';
    }
  }
  @override
  String get settingsResetData {
    switch (locale.languageCode) {
      case 'he':
        return 'אפס נתוני אפליקציה';
      default:
        return 'Reset App Data';
    }
  }
  @override
  String get settingsResetDataSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'מחק לצמיתות את כל הנסיעות, רשימות האריזה, המשימות וכל שאר הנתונים';
      default:
        return 'Permanently delete all trips, packing lists, tasks and all other data';
    }
  }
  @override
  String get settingsLanguage {
    switch (locale.languageCode) {
      case 'he':
        return 'שפה';
      default:
        return 'Language';
    }
  }
  @override
  String get settingsSelectLanguage {
    switch (locale.languageCode) {
      case 'he':
        return 'בחר שפה';
      default:
        return 'Select Language';
    }
  }
  @override
  String get settingsLanguageEditor {
    switch (locale.languageCode) {
      case 'he':
        return 'ערוך תרגומים';
      default:
        return 'Edit Translations';
    }
  }
  @override
  String get settingsLanguageEditorSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'צפה והתאם אישית מחרוזות מתורגמות';
      default:
        return 'View and customise translated strings';
    }
  }
  @override
  String get settingsAbout {
    switch (locale.languageCode) {
      case 'he':
        return 'אודות';
      default:
        return 'About';
    }
  }
  @override
  String get settingsAboutSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'גרסה 1.1.0 · מתכנן נסיעות אישי';
      default:
        return 'Version 1.1.0 · Personal travel planner';
    }
  }
  @override
  String get settingsRestoreConfirmTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'שחזור גיבוי';
      default:
        return 'Restore Backup';
    }
  }
  @override
  String get settingsRestoreConfirmBody {
    switch (locale.languageCode) {
      case 'he':
        return 'פעולה זו תחליף את כל הנתונים הנוכחיים בקובץ הגיבוי. הנתונים הנוכחיים שלך יאבדו.\n\nהמשך?';
      default:
        return 'This will replace ALL current data with the backup file. Your current data will be lost.\n\nContinue?';
    }
  }
  @override
  String get settingsResetStep1Title {
    switch (locale.languageCode) {
      case 'he':
        return 'איפוס נתוני אפליקציה';
      default:
        return 'Reset App Data';
    }
  }
  @override
  String get settingsResetStep1Body {
    switch (locale.languageCode) {
      case 'he':
        return 'פעולה זו תמחק לצמיתות את הכל:\n\n• כל הנסיעות (פעילות, מתוכננות ובארכיון)\n• כל רשימות האריזה והתבניות\n• כל המשימות, הכתובות והמסמכים\n• כל הקבלות ורשומות ההוצאות\n\nלא ניתן לבטל פעולה זו.\n\nהאם אתה בטוח שברצונך להמשיך?';
      default:
        return 'This will permanently delete EVERYTHING:\n\n• All trips (active, planned and archived)\n• All packing lists and templates\n• All tasks, addresses and documents\n• All receipts and expense records\n\nThis action CANNOT be undone.\n\nAre you sure you want to continue?';
    }
  }
  @override
  String get settingsResetStep2Title {
    switch (locale.languageCode) {
      case 'he':
        return 'אישור סופי';
      default:
        return 'Final Confirmation';
    }
  }
  @override
  String get settingsResetStep2Body {
    switch (locale.languageCode) {
      case 'he':
        return 'לאישור, הקלד את המילה הבאה בדיוק כפי שמוצגת:';
      default:
        return 'To confirm, type the word below exactly as shown:';
    }
  }
  @override
  String get settingsResetKeyword {
    switch (locale.languageCode) {
      case 'he':
        return 'RESET';
      default:
        return 'RESET';
    }
  }
  @override
  String get settingsResetButton {
    switch (locale.languageCode) {
      case 'he':
        return 'אפס הכל';
      default:
        return 'Reset Everything';
    }
  }
  @override
  String get settingsResetSuccess {
    switch (locale.languageCode) {
      case 'he':
        return 'נתוני האפליקציה אופסו. כל הרשומות נמחקו.';
      default:
        return 'App data has been reset. All records deleted.';
    }
  }
  @override
  String get langEnglish {
    switch (locale.languageCode) {
      case 'he':
        return 'English';
      default:
        return 'English';
    }
  }
  @override
  String get langHebrew {
    switch (locale.languageCode) {
      case 'he':
        return 'עברית';
      default:
        return 'עברית';
    }
  }
  @override
  String get tripTypeLeisure {
    switch (locale.languageCode) {
      case 'he':
        return 'פנאי';
      default:
        return 'Leisure';
    }
  }
  @override
  String get tripTypeBusiness {
    switch (locale.languageCode) {
      case 'he':
        return 'עסקים';
      default:
        return 'Business';
    }
  }
  @override
  String get tripTypeFamily {
    switch (locale.languageCode) {
      case 'he':
        return 'משפחה';
      default:
        return 'Family';
    }
  }
  @override
  String get tripPurposeHoliday {
    switch (locale.languageCode) {
      case 'he':
        return 'חופשה';
      default:
        return 'Holiday';
    }
  }
  @override
  String get tripPurposeWorkTrip {
    switch (locale.languageCode) {
      case 'he':
        return 'נסיעת עבודה';
      default:
        return 'Work Trip';
    }
  }
  @override
  String get tripPurposeFamilyVisit {
    switch (locale.languageCode) {
      case 'he':
        return 'ביקור משפחה';
      default:
        return 'Family Visit';
    }
  }
  @override
  String get tripPurposeConference {
    switch (locale.languageCode) {
      case 'he':
        return 'כנס';
      default:
        return 'Conference';
    }
  }
  @override
  String get packingCatClothing {
    switch (locale.languageCode) {
      case 'he':
        return 'ביגוד';
      default:
        return 'Clothing';
    }
  }
  @override
  String get packingCatToiletries {
    switch (locale.languageCode) {
      case 'he':
        return 'טיפוח';
      default:
        return 'Toiletries';
    }
  }
  @override
  String get packingCatElectronics {
    switch (locale.languageCode) {
      case 'he':
        return 'אלקטרוניקה';
      default:
        return 'Electronics';
    }
  }
  @override
  String get packingCatDocuments {
    switch (locale.languageCode) {
      case 'he':
        return 'מסמכים';
      default:
        return 'Documents';
    }
  }
  @override
  String get packingCatMedication {
    switch (locale.languageCode) {
      case 'he':
        return 'תרופות';
      default:
        return 'Medication';
    }
  }
  @override
  String get packingCatFoodSnacks {
    switch (locale.languageCode) {
      case 'he':
        return 'אוכל וחטיפים';
      default:
        return 'Food & Snacks';
    }
  }
  @override
  String get packingCatAccessories {
    switch (locale.languageCode) {
      case 'he':
        return 'אביזרים';
      default:
        return 'Accessories';
    }
  }
  @override
  String get packingCatSportOutdoor {
    switch (locale.languageCode) {
      case 'he':
        return 'ספורט וטבע';
      default:
        return 'Sport & Outdoor';
    }
  }
  @override
  String get packingCatBabyKids {
    switch (locale.languageCode) {
      case 'he':
        return 'תינוק וילדים';
      default:
        return 'Baby & Kids';
    }
  }
  @override
  String get packingCatWorkOffice {
    switch (locale.languageCode) {
      case 'he':
        return 'עבודה ומשרד';
      default:
        return 'Work & Office';
    }
  }
  @override
  String get packingCatOther {
    switch (locale.languageCode) {
      case 'he':
        return 'אחר';
      default:
        return 'Other';
    }
  }
  @override
  String get storageCheckin {
    switch (locale.languageCode) {
      case 'he':
        return 'מזוודה לטעינה';
      default:
        return 'Check-in Luggage';
    }
  }
  @override
  String get storageHandLuggage {
    switch (locale.languageCode) {
      case 'he':
        return 'כבודת יד';
      default:
        return 'Hand Luggage';
    }
  }
  @override
  String get storageBackpack {
    switch (locale.languageCode) {
      case 'he':
        return 'תיק גב';
      default:
        return 'Backpack';
    }
  }
  @override
  String get storageToiletryBag {
    switch (locale.languageCode) {
      case 'he':
        return 'תיק טיפוח';
      default:
        return 'Toiletry Bag';
    }
  }
  @override
  String get storageLaptopBag {
    switch (locale.languageCode) {
      case 'he':
        return 'תיק מחשב';
      default:
        return 'Laptop Bag';
    }
  }
  @override
  String get storageHandbag {
    switch (locale.languageCode) {
      case 'he':
        return 'תיק יד';
      default:
        return 'Handbag / Purse';
    }
  }
  @override
  String get storageWallet {
    switch (locale.languageCode) {
      case 'he':
        return 'ארנק';
      default:
        return 'Wallet';
    }
  }
  @override
  String get storageMoneyBelt {
    switch (locale.languageCode) {
      case 'he':
        return 'חגורת כסף';
      default:
        return 'Money Belt';
    }
  }
  @override
  String get storageCarBoot {
    switch (locale.languageCode) {
      case 'he':
        return 'תא מטען';
      default:
        return 'Car Boot';
    }
  }
  @override
  String get storageShippingBox {
    switch (locale.languageCode) {
      case 'he':
        return 'קופסת משלוח';
      default:
        return 'Shipping Box';
    }
  }
  @override
  String get storageOther {
    switch (locale.languageCode) {
      case 'he':
        return 'אחר';
      default:
        return 'Other';
    }
  }
  @override
  String get packingItemNameHint {
    switch (locale.languageCode) {
      case 'he':
        return 'לדוגמה: דרכון, מטען, חולצה...';
      default:
        return 'e.g. Passport, Charger, T-shirt...';
    }
  }
  @override
  String get packingItemNameRequired {
    switch (locale.languageCode) {
      case 'he':
        return 'שם הפריט הוא שדה חובה';
      default:
        return 'Item name is required';
    }
  }
  @override
  String get packingSelectCategory {
    switch (locale.languageCode) {
      case 'he':
        return 'בחר קטגוריה';
      default:
        return 'Select a category';
    }
  }
  @override
  String get packingStoragePlaceHint {
    switch (locale.languageCode) {
      case 'he':
        return 'היכן תאחסן פריט זה?';
      default:
        return 'Where will you store this?';
    }
  }
  @override
  String get packingCustomStorageHint {
    switch (locale.languageCode) {
      case 'he':
        return 'לדוגמה: מזוודה 23 ק"ג, תיק מצלמה...';
      default:
        return 'e.g. Luggage 23 kg, Camera Bag...';
    }
  }
  @override
  String get packingNotesHint {
    switch (locale.languageCode) {
      case 'he':
        return 'הערות על פריט זה...';
      default:
        return 'Any notes about this item...';
    }
  }
  @override
  String get packingItemTasksLabel {
    switch (locale.languageCode) {
      case 'he':
        return 'משימות פריט';
      default:
        return 'Item Tasks';
    }
  }
  @override
  String get packingItemTasksHint {
    switch (locale.languageCode) {
      case 'he':
        return 'לדוגמה: לקנות, לגהץ';
      default:
        return 'e.g. to buy, to iron';
    }
  }
  @override
  String get packingAddTaskHint {
    switch (locale.languageCode) {
      case 'he':
        return 'הוסף משימה לפריט זה...';
      default:
        return 'Add a task for this item...';
    }
  }
  @override
  String get packingUpdateItem {
    switch (locale.languageCode) {
      case 'he':
        return 'עדכן פריט';
      default:
        return 'Update Item';
    }
  }
  @override
  String get packingErrorSaving {
    switch (locale.languageCode) {
      case 'he':
        return 'שגיאה בשמירת הפריט';
      default:
        return 'Error saving item';
    }
  }
  @override
  String get templateSaveTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'שמור כתבנית';
      default:
        return 'Save as Template';
    }
  }
  @override
  String get templateNameLabel {
    switch (locale.languageCode) {
      case 'he':
        return 'שם התבנית';
      default:
        return 'Template Name';
    }
  }
  @override
  String get templateNameHint {
    switch (locale.languageCode) {
      case 'he':
        return 'לדוגמה: חופשת קיץ';
      default:
        return 'e.g. Summer Holiday Packing';
    }
  }
  @override
  String get templateDescLabel {
    switch (locale.languageCode) {
      case 'he':
        return 'תיאור (אופציונלי)';
      default:
        return 'Description (optional)';
    }
  }
  @override
  String get templateDescHint {
    switch (locale.languageCode) {
      case 'he':
        return 'לדוגמה: לנסיעות חוף של שבוע-שבועיים';
      default:
        return 'e.g. For 1-2 week beach trips';
    }
  }
  @override
  String get templateSaveButton {
    switch (locale.languageCode) {
      case 'he':
        return 'שמור תבנית';
      default:
        return 'Save Template';
    }
  }
  @override
  String get templateErrorSaving {
    switch (locale.languageCode) {
      case 'he':
        return 'שגיאה בשמירת התבנית';
      default:
        return 'Error saving template';
    }
  }
  @override
  String get templateLoadTitle {
    switch (locale.languageCode) {
      case 'he':
        return 'טען תבנית';
      default:
        return 'Load Template';
    }
  }
  @override
  String get templateNoTemplates {
    switch (locale.languageCode) {
      case 'he':
        return 'אין תבניות שמורות עדיין';
      default:
        return 'No templates saved yet';
    }
  }
  @override
  String get templateNoTemplatesSubtitle {
    switch (locale.languageCode) {
      case 'he':
        return 'שמור תחילה רשימת אריזה כתבנית.';
      default:
        return 'Save a packing list as a template first.';
    }
  }
  @override
  String get tripTypeAdventure {
    switch (locale.languageCode) {
      case 'he':
        return 'הרפתקה';
      default:
        return 'Adventure';
    }
  }
  @override
  String get tripTypeMedical {
    switch (locale.languageCode) {
      case 'he':
        return 'רפואי';
      default:
        return 'Medical';
    }
  }
  @override
  String get tripTypeOther {
    switch (locale.languageCode) {
      case 'he':
        return 'אחר';
      default:
        return 'Other';
    }
  }
  @override
  String get tripPurposeMedical {
    switch (locale.languageCode) {
      case 'he':
        return 'מסיבות רפואיות';
      default:
        return 'Medical';
    }
  }
  @override
  String get tripPurposeOther {
    switch (locale.languageCode) {
      case 'he':
        return 'אחר';
      default:
        return 'Other';
    }
  }
  @override
  String get packingUncategorised {
    switch (locale.languageCode) {
      case 'he':
        return 'ללא קטגוריה';
      default:
        return 'Uncategorised';
    }
  }
  @override
  String get packingExcelHeaderName {
    switch (locale.languageCode) {
      case 'he':
        return 'שם';
      default:
        return 'Name';
    }
  }
  @override
  String get packingExcelHeaderCategory {
    switch (locale.languageCode) {
      case 'he':
        return 'קטגוריה';
      default:
        return 'Category';
    }
  }
  @override
  String get packingExcelHeaderQuantity {
    switch (locale.languageCode) {
      case 'he':
        return 'כמות';
      default:
        return 'Quantity';
    }
  }
  @override
  String get packingExcelHeaderStorage {
    switch (locale.languageCode) {
      case 'he':
        return 'מקום אחסון';
      default:
        return 'Storage Place';
    }
  }
  @override
  String get packingExcelHeaderStatus {
    switch (locale.languageCode) {
      case 'he':
        return 'סטטוס';
      default:
        return 'Status';
    }
  }
  @override
  String get packingExcelHeaderNotes {
    switch (locale.languageCode) {
      case 'he':
        return 'הערות';
      default:
        return 'Notes';
    }
  }
  @override
  String get tripDetailTypeBadge {
    switch (locale.languageCode) {
      case 'he':
        return 'סוג';
      default:
        return 'Type';
    }
  }
  @override
  String get validatorRequired {
    switch (locale.languageCode) {
      case 'he':
        return 'שדה חובה';
      default:
        return 'Required';
    }
  }
  @override
  String get backupRestoredSuccess {
    switch (locale.languageCode) {
      case 'he':
        return 'הגיבוי שוחזר בהצלחה. הפעל מחדש את האפליקציה.';
      default:
        return 'Backup restored successfully. Restart the app to see changes.';
    }
  }
  @override
  String get backupRestoreFailed {
    switch (locale.languageCode) {
      case 'he':
        return 'השחזור נכשל או בוטל. הנתונים שלך לא השתנו.';
      default:
        return 'Restore failed or cancelled. Your data is unchanged.';
    }
  }
  @override
  String get resetConfirmMismatch {
    switch (locale.languageCode) {
      case 'he':
        return 'חייב להתאים בדיוק';
      default:
        return 'Must match exactly';
    }
  }
  @override
  String get settingsContinue {
    switch (locale.languageCode) {
      case 'he':
        return 'המשך';
      default:
        return 'Continue';
    }
  }
  @override
  String get settingsBackupFailed {
    switch (locale.languageCode) {
      case 'he':
        return 'הגיבוי נכשל. לא נמצאו נתונים.';
      default:
        return 'Backup failed. No data found.';
    }
  }
  @override
  String get imageLoadError {
    switch (locale.languageCode) {
      case 'he':
        return 'לא ניתן לטעון את התמונה';
      default:
        return 'Could not load image';
    }
  }

  String fieldExchangeRate(String currency) {
    switch (locale.languageCode) {
      case 'he':
        return 'שער חליפין ל' + currency.toString() + '';
      default:
        return 'Exchange Rate to ' + currency.toString() + '';
    }
  }
  String dashboardDaysUntil(int days) {
    switch (locale.languageCode) {
      case 'he':
        return '' + days.toString() + ' ימים עד היציאה';
      default:
        return '' + days.toString() + ' days until departure';
    }
  }
  String tripsDays(int count) {
    switch (locale.languageCode) {
      case 'he':
        return '' + count.toString() + ' ימים';
      default:
        return '' + count.toString() + ' days';
    }
  }
  String tripDetailDaysUntil(int days) {
    switch (locale.languageCode) {
      case 'he':
        return '' + days.toString() + ' ימים עד היציאה';
      default:
        return '' + days.toString() + ' days until departure';
    }
  }
  String packingPackedCount(int packed, int total) {
    switch (locale.languageCode) {
      case 'he':
        return '' + packed.toString() + ' / ' + total.toString() + ' ארוז';
      default:
        return '' + packed.toString() + ' / ' + total.toString() + ' packed';
    }
  }
  String packingTasksPending(int count) {
    switch (locale.languageCode) {
      case 'he':
        return '' + count.toString() + ' משימות ממתינות';
      default:
        return '' + count.toString() + ' task(s) pending';
    }
  }
  String packingSelectAll(int count) {
    switch (locale.languageCode) {
      case 'he':
        return 'בחר הכל (' + count.toString() + ')';
      default:
        return 'Select all (' + count.toString() + ')';
    }
  }
  String tasksDoneCount(int done, int total) {
    switch (locale.languageCode) {
      case 'he':
        return '' + done.toString() + ' / ' + total.toString() + ' הושלמו';
      default:
        return '' + done.toString() + ' / ' + total.toString() + ' completed';
    }
  }
  String templateSaveSubtitle(int count) {
    switch (locale.languageCode) {
      case 'he':
        return 'זה ישמור ' + count.toString() + ' פריטים כתבנית לשימוש חוזר.';
      default:
        return 'This will save ' + count.toString() + ' item(s) as a reusable template.';
    }
  }
  String templateItemCount(int count) {
    switch (locale.languageCode) {
      case 'he':
        return '' + count.toString() + ' פריטים';
      default:
        return '' + count.toString() + ' items';
    }
  }
  String packingSelectedCount(int count) {
    switch (locale.languageCode) {
      case 'he':
        return '' + count.toString() + ' נבחרו';
      default:
        return '' + count.toString() + ' selected';
    }
  }
}

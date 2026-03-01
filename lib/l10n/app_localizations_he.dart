// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'TripReady';

  @override
  String get navDashboard => 'לוח בקרה';

  @override
  String get navMyTrips => 'הנסיעות שלי';

  @override
  String get navArchive => 'ארכיון';

  @override
  String get navSettings => 'הגדרות';

  @override
  String get actionSave => 'שמור';

  @override
  String get actionCancel => 'ביטול';

  @override
  String get actionDelete => 'מחק';

  @override
  String get actionEdit => 'ערוך';

  @override
  String get actionAdd => 'הוסף';

  @override
  String get actionClose => 'סגור';

  @override
  String get actionConfirm => 'אישור';

  @override
  String get actionBack => 'חזרה';

  @override
  String get actionYes => 'כן';

  @override
  String get actionNo => 'לא';

  @override
  String get actionUpdate => 'עדכן';

  @override
  String get actionApply => 'החל';

  @override
  String get actionClear => 'נקה סינון';

  @override
  String get fieldNotes => 'הערות';

  @override
  String get fieldName => 'שם';

  @override
  String get fieldCategory => 'קטגוריה';

  @override
  String get fieldDate => 'תאריך';

  @override
  String get fieldPhone => 'טלפון';

  @override
  String get fieldWebsite => 'אתר אינטרנט';

  @override
  String get fieldAddress => 'כתובת';

  @override
  String get fieldStatus => 'סטטוס';

  @override
  String get fieldQuantity => 'כמות';

  @override
  String get fieldStoragePlace => 'מקום אחסון';

  @override
  String get fieldCurrency => 'מטבע';

  @override
  String get fieldAmount => 'סכום';

  @override
  String fieldExchangeRate(String currency) {
    return 'שער חליפין ל$currency';
  }

  @override
  String get dashboardTitle => 'לוח בקרה';

  @override
  String get dashboardActiveTrip => 'נסיעה פעילה';

  @override
  String get dashboardNoActiveTrip => 'אין נסיעה פעילה';

  @override
  String get dashboardStartPlanning => 'התחל לתכנן את הנסיעה הבאה שלך';

  @override
  String get dashboardPackingProgress => 'התקדמות אריזה';

  @override
  String get dashboardTaskProgress => 'התקדמות משימות';

  @override
  String dashboardDaysUntil(int days) {
    return '$days ימים עד היציאה';
  }

  @override
  String get dashboardDepartingToday => '🛫 יוצאים היום!';

  @override
  String get dashboardDepartingTomorrow => '🗓 יוצאים מחר!';

  @override
  String get dashboardPacked => 'ארוז';

  @override
  String get dashboardTasksDone => 'משימות שבוצעו';

  @override
  String get dashboardExpenses => 'הוצאות';

  @override
  String get dashboardSpent => 'הוצאתי';

  @override
  String get tripsTitle => 'הנסיעות שלי';

  @override
  String get tripsNewTrip => 'נסיעה חדשה';

  @override
  String get tripsAddTrip => 'הוסף נסיעה';

  @override
  String get tripsEditTrip => 'ערוך נסיעה';

  @override
  String get tripsDeleteTrip => 'מחק נסיעה';

  @override
  String get tripsArchiveTrip => 'העבר לארכיון';

  @override
  String get tripsSetActive => 'הגדר כפעילה';

  @override
  String get tripsTripName => 'שם הנסיעה';

  @override
  String get tripsDestination => 'יעד';

  @override
  String get tripsCountry => 'מדינה';

  @override
  String get tripsTripType => 'סוג הנסיעה';

  @override
  String get tripsTripPurpose => 'מטרת הנסיעה';

  @override
  String get tripsDeparture => 'יציאה';

  @override
  String get tripsReturn => 'חזרה';

  @override
  String get tripsDuration => 'משך';

  @override
  String tripsDays(int count) {
    return '$count ימים';
  }

  @override
  String get tripsNoTrips => 'אין נסיעות עדיין';

  @override
  String get tripsNoTripsSubtitle =>
      'לחץ על הכפתור למטה להוספת הנסיעה הראשונה.';

  @override
  String get tripsTabActive => 'פעיל';

  @override
  String get tripsTabPlanned => 'מתוכנן';

  @override
  String get tripsTabArchived => 'בארכיון';

  @override
  String get tripsStatusActive => 'פעילה';

  @override
  String get tripsStatusPlanned => 'מתוכננת';

  @override
  String get tripsStatusArchived => 'בארכיון';

  @override
  String get tripDetailTitle => 'פרטי נסיעה';

  @override
  String get tripDetailOverview => 'סקירה כללית';

  @override
  String get tripDetailSections => 'חלקי הנסיעה';

  @override
  String tripDetailDaysUntil(int days) {
    return '$days ימים עד היציאה';
  }

  @override
  String get tripDetailDepartingToday => '🛫 יוצאים היום!';

  @override
  String get tripDetailDepartingTomorrow => '🗓 יוצאים מחר!';

  @override
  String get packingTitle => 'רשימת אריזה';

  @override
  String get packingAddItem => 'הוסף פריט';

  @override
  String get packingEditItem => 'ערוך פריט';

  @override
  String get packingItemName => 'שם פריט';

  @override
  String get packingProgress => 'התקדמות אריזה';

  @override
  String packingPackedCount(int packed, int total) {
    return '$packed / $total ארוז';
  }

  @override
  String get packingStatusPacked => 'ארוז';

  @override
  String get packingStatusNotPacked => 'לא ארוז';

  @override
  String get packingSaveTemplate => 'שמור כתבנית';

  @override
  String get packingLoadTemplate => 'טען תבנית';

  @override
  String get packingExportExcel => 'ייצא לאקסל';

  @override
  String get packingImportExcel => 'ייבא מאקסל';

  @override
  String get packingUncheckAll => 'בטל סימון לכל הפריטים';

  @override
  String get packingDeleteAll => 'מחק את כל הפריטים';

  @override
  String get packingNoItems => 'אין פריטים עדיין';

  @override
  String get packingNoItemsSubtitle =>
      'הוסף פריטים ידנית, טען תבנית, או ייבא מאקסל.';

  @override
  String get packingItemTasks => 'משימות פריט';

  @override
  String get packingAllTasksDone => 'כל המשימות הושלמו';

  @override
  String packingTasksPending(int count) {
    return '$count משימות ממתינות';
  }

  @override
  String packingSelectAll(int count) {
    return 'בחר הכל ($count)';
  }

  @override
  String get packingDeselectAll => 'בטל בחירת הכל';

  @override
  String get packingMarkPacked => 'סמן כארוז';

  @override
  String get packingMarkUnpacked => 'סמן כלא ארוז';

  @override
  String get packingTemplateTitle => 'שם התבנית';

  @override
  String get packingTemplateDescription => 'תיאור';

  @override
  String get packingNoTemplates => 'אין תבניות שמורות עדיין';

  @override
  String get packingLoadTemplateTitle => 'טען תבנית';

  @override
  String get packingSaveTemplateTitle => 'שמור כתבנית';

  @override
  String get tasksTitle => 'משימות';

  @override
  String get tasksAddTask => 'הוסף משימה';

  @override
  String get tasksTaskName => 'שם משימה';

  @override
  String get tasksDueDate => 'תאריך יעד';

  @override
  String get tasksProgress => 'התקדמות משימות';

  @override
  String get tasksTabPending => 'ממתין';

  @override
  String get tasksTabInProgress => 'בביצוע';

  @override
  String get tasksTabDone => 'הושלם';

  @override
  String get tasksStatusPending => 'ממתין';

  @override
  String get tasksStatusInProgress => 'בביצוע';

  @override
  String get tasksStatusDone => 'הושלם';

  @override
  String get tasksOverdue => 'באיחור';

  @override
  String get tasksNoPending => 'אין משימות ממתינות';

  @override
  String get tasksNoInProgress => 'אין משימות בביצוע';

  @override
  String get tasksNoDone => 'אין משימות שהושלמו עדיין';

  @override
  String tasksDoneCount(int done, int total) {
    return '$done / $total הושלמו';
  }

  @override
  String get tasksStart => 'התחל';

  @override
  String get tasksComplete => 'סיים';

  @override
  String get tasksMarkPending => 'סמן כממתין';

  @override
  String get tasksMarkInProgress => 'סמן כבביצוע';

  @override
  String get tasksMarkDone => 'סמן כהושלם';

  @override
  String get addressesTitle => 'כתובות';

  @override
  String get addressesAddAddress => 'הוסף כתובת';

  @override
  String get addressesMapButton => 'מפה';

  @override
  String get addressesNoAddresses => 'אין כתובות שמורות';

  @override
  String get addressesNoAddressesSubtitle =>
      'הוסף מלונות, מסעדות, אתרי תיירות ועוד.';

  @override
  String get addressesCatHotel => 'מלון';

  @override
  String get addressesCatAirport => 'שדה תעופה';

  @override
  String get addressesCatRestaurant => 'מסעדה';

  @override
  String get addressesCatLandmark => 'אתר תיירות';

  @override
  String get addressesCatOffice => 'משרד';

  @override
  String get addressesCatHospital => 'בית חולים';

  @override
  String get addressesCatTransport => 'תחבורה';

  @override
  String get addressesCatShopping => 'קניות';

  @override
  String get addressesCatOther => 'אחר';

  @override
  String get receiptsTitle => 'קבלות והוצאות';

  @override
  String get receiptsAddReceipt => 'הוסף קבלה';

  @override
  String get receiptsReceiptName => 'שם קבלה';

  @override
  String get receiptsTotalExpenses => 'סך הוצאות';

  @override
  String get receiptsNoReceipts => 'אין קבלות עדיין';

  @override
  String get receiptsNoReceiptsSubtitle =>
      'עקוב אחר ההוצאות שלך על ידי הוספת קבלות.';

  @override
  String get receiptsPhotoAttached => 'תמונה מצורפת';

  @override
  String get receiptsCatFood => 'אוכל ומשקאות';

  @override
  String get receiptsCatTransport => 'תחבורה';

  @override
  String get receiptsCatAccommodation => 'לינה';

  @override
  String get receiptsCatEntertainment => 'בידור';

  @override
  String get receiptsCatShopping => 'קניות';

  @override
  String get receiptsCatHealth => 'בריאות';

  @override
  String get receiptsCatCommunication => 'תקשורת';

  @override
  String get receiptsCatFees => 'עמלות וחיובים';

  @override
  String get receiptsCatOther => 'אחר';

  @override
  String get documentsTitle => 'מסמכים';

  @override
  String get documentsAddDocument => 'הוסף מסמך';

  @override
  String get documentsDocumentName => 'שם מסמך';

  @override
  String get documentsNoDocuments => 'אין מסמכים עדיין';

  @override
  String get documentsNoDocumentsSubtitle =>
      'הוסף כרטיסים, שוברים, מכתבים ומסמכים נוספים.';

  @override
  String get documentsNoFileAttached => 'אין קובץ מצורף';

  @override
  String get documentsFileAttached => 'קובץ מצורף';

  @override
  String get documentsTypeTicket => 'כרטיס';

  @override
  String get documentsTypeVoucher => 'שובר';

  @override
  String get documentsTypeLetter => 'מכתב';

  @override
  String get documentsTypePassport => 'דרכון';

  @override
  String get documentsTypeVisa => 'ויזה';

  @override
  String get documentsTypeInsurance => 'ביטוח';

  @override
  String get documentsTypeReservation => 'הזמנה';

  @override
  String get documentsTypeItinerary => 'מסלול';

  @override
  String get documentsTypeOther => 'אחר';

  @override
  String get archiveTitle => 'ארכיון';

  @override
  String get archiveNoTrips => 'אין נסיעות בארכיון';

  @override
  String get archiveNoTripsSubtitle =>
      'נסיעות שהועברו לארכיון יופיעו כאן לעיון.';

  @override
  String get archiveCloneTrip => 'שכפל לנסיעה חדשה';

  @override
  String get archiveCloneTitle => 'שכפול נסיעה';

  @override
  String get archiveCloneNewName => 'שם הנסיעה החדשה';

  @override
  String get archiveClonePacking => 'רשימת אריזה';

  @override
  String get archiveClonePackingSubtitle => 'כל הפריטים (מאופס ללא ארוז)';

  @override
  String get archiveCloneTasks => 'משימות';

  @override
  String get archiveCloneTasksSubtitle => 'כל המשימות (מאופס לממתין)';

  @override
  String get archiveCloneAddresses => 'כתובות';

  @override
  String get archiveCloneAddressesSubtitle => 'מלונות, מסעדות, אתרי תיירות';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get settingsDataManagement => 'ניהול נתונים';

  @override
  String get settingsExportBackup => 'ייצא גיבוי';

  @override
  String get settingsExportBackupSubtitle =>
      'שמור עותק של כל נתוני הנסיעות שלך';

  @override
  String get settingsRestoreBackup => 'שחזר גיבוי';

  @override
  String get settingsRestoreBackupSubtitle => 'שחזר מקובץ גיבוי שיוצא קודם';

  @override
  String get settingsDangerZone => 'אזור מסוכן';

  @override
  String get settingsResetData => 'אפס נתוני אפליקציה';

  @override
  String get settingsResetDataSubtitle =>
      'מחק לצמיתות את כל הנסיעות, רשימות האריזה, המשימות וכל שאר הנתונים';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get settingsSelectLanguage => 'בחר שפה';

  @override
  String get settingsLanguageEditor => 'ערוך תרגומים';

  @override
  String get settingsLanguageEditorSubtitle =>
      'צפה והתאם אישית מחרוזות מתורגמות';

  @override
  String get settingsAbout => 'אודות';

  @override
  String get settingsAboutSubtitle => 'גרסה 1.1.0 · מתכנן נסיעות אישי';

  @override
  String get settingsRestoreConfirmTitle => 'שחזור גיבוי';

  @override
  String get settingsRestoreConfirmBody =>
      'פעולה זו תחליף את כל הנתונים הנוכחיים בקובץ הגיבוי. הנתונים הנוכחיים שלך יאבדו.\n\nהמשך?';

  @override
  String get settingsResetStep1Title => 'איפוס נתוני אפליקציה';

  @override
  String get settingsResetStep1Body =>
      'פעולה זו תמחק לצמיתות את הכל:\n\n• כל הנסיעות (פעילות, מתוכננות ובארכיון)\n• כל רשימות האריזה והתבניות\n• כל המשימות, הכתובות והמסמכים\n• כל הקבלות ורשומות ההוצאות\n\nלא ניתן לבטל פעולה זו.\n\nהאם אתה בטוח שברצונך להמשיך?';

  @override
  String get settingsResetStep2Title => 'אישור סופי';

  @override
  String get settingsResetStep2Body =>
      'לאישור, הקלד את המילה הבאה בדיוק כפי שמוצגת:';

  @override
  String get settingsResetKeyword => 'RESET';

  @override
  String get settingsResetButton => 'אפס הכל';

  @override
  String get settingsResetSuccess => 'נתוני האפליקציה אופסו. כל הרשומות נמחקו.';

  @override
  String get langEnglish => 'English';

  @override
  String get langHebrew => 'עברית';

  @override
  String get tripTypeLeisure => 'פנאי';

  @override
  String get tripTypeBusiness => 'עסקים';

  @override
  String get tripTypeFamily => 'משפחה';

  @override
  String get tripPurposeHoliday => 'חופשה';

  @override
  String get tripPurposeWorkTrip => 'נסיעת עבודה';

  @override
  String get tripPurposeFamilyVisit => 'ביקור משפחה';

  @override
  String get tripPurposeConference => 'כנס';

  @override
  String get packingCatClothing => 'ביגוד';

  @override
  String get packingCatToiletries => 'טיפוח';

  @override
  String get packingCatElectronics => 'אלקטרוניקה';

  @override
  String get packingCatDocuments => 'מסמכים';

  @override
  String get packingCatMedication => 'תרופות';

  @override
  String get packingCatFoodSnacks => 'אוכל וחטיפים';

  @override
  String get packingCatAccessories => 'אביזרים';

  @override
  String get packingCatSportOutdoor => 'ספורט וטבע';

  @override
  String get packingCatBabyKids => 'תינוק וילדים';

  @override
  String get packingCatWorkOffice => 'עבודה ומשרד';

  @override
  String get packingCatOther => 'אחר';

  @override
  String get storageCheckin => 'מזוודה לטעינה';

  @override
  String get storageHandLuggage => 'כבודת יד';

  @override
  String get storageBackpack => 'תיק גב';

  @override
  String get storageToiletryBag => 'תיק טיפוח';

  @override
  String get storageLaptopBag => 'תיק מחשב';

  @override
  String get storageHandbag => 'תיק יד';

  @override
  String get storageWallet => 'ארנק';

  @override
  String get storageMoneyBelt => 'חגורת כסף';

  @override
  String get storageCarBoot => 'תא מטען';

  @override
  String get storageShippingBox => 'קופסת משלוח';

  @override
  String get storageOther => 'אחר';

  @override
  String get packingItemNameHint => 'לדוגמה: דרכון, מטען, חולצה...';

  @override
  String get packingItemNameRequired => 'שם הפריט הוא שדה חובה';

  @override
  String get packingSelectCategory => 'בחר קטגוריה';

  @override
  String get packingStoragePlaceHint => 'היכן תאחסן פריט זה?';

  @override
  String get packingCustomStorageHint => 'לדוגמה: מזוודה 23 ק\"ג, תיק מצלמה...';

  @override
  String get packingNotesHint => 'הערות על פריט זה...';

  @override
  String get packingItemTasksLabel => 'משימות פריט';

  @override
  String get packingItemTasksHint => 'לדוגמה: לקנות, לגהץ';

  @override
  String get packingAddTaskHint => 'הוסף משימה לפריט זה...';

  @override
  String get packingUpdateItem => 'עדכן פריט';

  @override
  String get packingErrorSaving => 'שגיאה בשמירת הפריט';

  @override
  String get templateSaveTitle => 'שמור כתבנית';

  @override
  String templateSaveSubtitle(int count) {
    return 'זה ישמור $count פריטים כתבנית לשימוש חוזר.';
  }

  @override
  String get templateNameLabel => 'שם התבנית';

  @override
  String get templateNameHint => 'לדוגמה: חופשת קיץ';

  @override
  String get templateDescLabel => 'תיאור (אופציונלי)';

  @override
  String get templateDescHint => 'לדוגמה: לנסיעות חוף של שבוע-שבועיים';

  @override
  String get templateSaveButton => 'שמור תבנית';

  @override
  String get templateErrorSaving => 'שגיאה בשמירת התבנית';

  @override
  String get templateLoadTitle => 'טען תבנית';

  @override
  String get templateNoTemplates => 'אין תבניות שמורות עדיין';

  @override
  String get templateNoTemplatesSubtitle => 'שמור תחילה רשימת אריזה כתבנית.';

  @override
  String templateItemCount(int count) {
    return '$count פריטים';
  }

  @override
  String packingSelectedCount(int count) {
    return '$count נבחרו';
  }

  @override
  String get tripTypeAdventure => 'הרפתקה';

  @override
  String get tripTypeMedical => 'רפואי';

  @override
  String get tripTypeOther => 'אחר';

  @override
  String get tripPurposeMedical => 'מסיבות רפואיות';

  @override
  String get tripPurposeOther => 'אחר';

  @override
  String get packingUncategorised => 'ללא קטגוריה';

  @override
  String get packingExcelHeaderName => 'שם';

  @override
  String get packingExcelHeaderCategory => 'קטגוריה';

  @override
  String get packingExcelHeaderQuantity => 'כמות';

  @override
  String get packingExcelHeaderStorage => 'מקום אחסון';

  @override
  String get packingExcelHeaderStatus => 'סטטוס';

  @override
  String get packingExcelHeaderNotes => 'הערות';

  @override
  String get tripDetailTypeBadge => 'סוג';

  @override
  String get validatorRequired => 'שדה חובה';

  @override
  String get backupRestoredSuccess =>
      'הגיבוי שוחזר בהצלחה. הפעל מחדש את האפליקציה.';

  @override
  String get backupRestoreFailed =>
      'השחזור נכשל או בוטל. הנתונים שלך לא השתנו.';

  @override
  String get resetConfirmMismatch => 'חייב להתאים בדיוק';

  @override
  String get settingsContinue => 'המשך';

  @override
  String get settingsBackupFailed => 'הגיבוי נכשל. לא נמצאו נתונים.';

  @override
  String get imageLoadError => 'לא ניתן לטעון את התמונה';
}

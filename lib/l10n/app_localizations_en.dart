// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TripReady';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMyTrips => 'My Trips';

  @override
  String get navArchive => 'Archive';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClose => 'Close';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionBack => 'Back';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get actionUpdate => 'Update';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionClear => 'Clear Filters';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldQuantity => 'Quantity';

  @override
  String get fieldStoragePlace => 'Storage Place';

  @override
  String get fieldCurrency => 'Currency';

  @override
  String get fieldAmount => 'Amount';

  @override
  String fieldExchangeRate(String currency) {
    return 'Exchange Rate to $currency';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardActiveTrip => 'Active Trip';

  @override
  String get dashboardNoActiveTrip => 'No active trip';

  @override
  String get dashboardStartPlanning => 'Start planning your next trip';

  @override
  String get dashboardPackingProgress => 'Packing Progress';

  @override
  String get dashboardTaskProgress => 'Task Progress';

  @override
  String dashboardDaysUntil(int days) {
    return '$days days until departure';
  }

  @override
  String get dashboardDepartingToday => '🛫 Departing today!';

  @override
  String get dashboardDepartingTomorrow => '🗓 Departing tomorrow!';

  @override
  String get dashboardPacked => 'Packed';

  @override
  String get dashboardTasksDone => 'Tasks Done';

  @override
  String get dashboardExpenses => 'Expenses';

  @override
  String get dashboardSpent => 'Spent';

  @override
  String get tripsTitle => 'My Trips';

  @override
  String get tripsNewTrip => 'New Trip';

  @override
  String get tripsAddTrip => 'Add Trip';

  @override
  String get tripsEditTrip => 'Edit Trip';

  @override
  String get tripsDeleteTrip => 'Delete Trip';

  @override
  String get tripsArchiveTrip => 'Archive Trip';

  @override
  String get tripsSetActive => 'Set as Active';

  @override
  String get tripsTripName => 'Trip Name';

  @override
  String get tripsDestination => 'Destination';

  @override
  String get tripsCountry => 'Country';

  @override
  String get tripsTripType => 'Trip Type';

  @override
  String get tripsTripPurpose => 'Trip Purpose';

  @override
  String get tripsDeparture => 'Departure';

  @override
  String get tripsReturn => 'Return';

  @override
  String get tripsDuration => 'Duration';

  @override
  String tripsDays(int count) {
    return '$count days';
  }

  @override
  String get tripsNoTrips => 'No trips yet';

  @override
  String get tripsNoTripsSubtitle =>
      'Tap the button below to add your first trip.';

  @override
  String get tripsTabActive => 'Active';

  @override
  String get tripsTabPlanned => 'Planned';

  @override
  String get tripsTabArchived => 'Archived';

  @override
  String get tripsStatusActive => 'Active';

  @override
  String get tripsStatusPlanned => 'Planned';

  @override
  String get tripsStatusArchived => 'Archived';

  @override
  String get tripDetailTitle => 'Trip Detail';

  @override
  String get tripDetailOverview => 'Overview';

  @override
  String get tripDetailSections => 'Trip Sections';

  @override
  String tripDetailDaysUntil(int days) {
    return '$days days until departure';
  }

  @override
  String get tripDetailDepartingToday => '🛫 Departing today!';

  @override
  String get tripDetailDepartingTomorrow => '🗓 Departing tomorrow!';

  @override
  String get packingTitle => 'Packing List';

  @override
  String get packingAddItem => 'Add Item';

  @override
  String get packingEditItem => 'Edit Item';

  @override
  String get packingItemName => 'Item Name';

  @override
  String get packingProgress => 'Packing Progress';

  @override
  String packingPackedCount(int packed, int total) {
    return '$packed / $total packed';
  }

  @override
  String get packingStatusPacked => 'Packed';

  @override
  String get packingStatusNotPacked => 'Not Packed';

  @override
  String get packingSaveTemplate => 'Save as Template';

  @override
  String get packingLoadTemplate => 'Load Template';

  @override
  String get packingExportExcel => 'Export as Excel';

  @override
  String get packingImportExcel => 'Import from Excel';

  @override
  String get packingUncheckAll => 'Uncheck All Items';

  @override
  String get packingDeleteAll => 'Delete All Items';

  @override
  String get packingNoItems => 'No items yet';

  @override
  String get packingNoItemsSubtitle =>
      'Add items manually, load a template, or import from Excel.';

  @override
  String get packingItemTasks => 'Item Tasks';

  @override
  String get packingAllTasksDone => 'All tasks done';

  @override
  String packingTasksPending(int count) {
    return '$count task(s) pending';
  }

  @override
  String packingSelectAll(int count) {
    return 'Select all ($count)';
  }

  @override
  String get packingDeselectAll => 'Deselect all';

  @override
  String get packingMarkPacked => 'Mark as Packed';

  @override
  String get packingMarkUnpacked => 'Mark as Not Packed';

  @override
  String get packingTemplateTitle => 'Template Name';

  @override
  String get packingTemplateDescription => 'Description';

  @override
  String get packingNoTemplates => 'No templates saved yet';

  @override
  String get packingLoadTemplateTitle => 'Load Template';

  @override
  String get packingSaveTemplateTitle => 'Save as Template';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksAddTask => 'Add Task';

  @override
  String get tasksTaskName => 'Task Name';

  @override
  String get tasksDueDate => 'Due Date';

  @override
  String get tasksProgress => 'Task Progress';

  @override
  String get tasksTabPending => 'Pending';

  @override
  String get tasksTabInProgress => 'In Progress';

  @override
  String get tasksTabDone => 'Done';

  @override
  String get tasksStatusPending => 'Pending';

  @override
  String get tasksStatusInProgress => 'In Progress';

  @override
  String get tasksStatusDone => 'Done';

  @override
  String get tasksOverdue => 'OVERDUE';

  @override
  String get tasksNoPending => 'No pending tasks';

  @override
  String get tasksNoInProgress => 'No tasks in progress';

  @override
  String get tasksNoDone => 'No completed tasks yet';

  @override
  String tasksDoneCount(int done, int total) {
    return '$done / $total completed';
  }

  @override
  String get tasksStart => 'Start';

  @override
  String get tasksComplete => 'Complete';

  @override
  String get tasksMarkPending => 'Mark as Pending';

  @override
  String get tasksMarkInProgress => 'Mark as In Progress';

  @override
  String get tasksMarkDone => 'Mark as Done';

  @override
  String get addressesTitle => 'Addresses';

  @override
  String get addressesAddAddress => 'Add Address';

  @override
  String get addressesMapButton => 'Map';

  @override
  String get addressesNoAddresses => 'No addresses saved';

  @override
  String get addressesNoAddressesSubtitle =>
      'Add hotels, restaurants, landmarks and more.';

  @override
  String get addressesCatHotel => 'Hotel';

  @override
  String get addressesCatAirport => 'Airport';

  @override
  String get addressesCatRestaurant => 'Restaurant';

  @override
  String get addressesCatLandmark => 'Landmark';

  @override
  String get addressesCatOffice => 'Office';

  @override
  String get addressesCatHospital => 'Hospital';

  @override
  String get addressesCatTransport => 'Transport';

  @override
  String get addressesCatShopping => 'Shopping';

  @override
  String get addressesCatOther => 'Other';

  @override
  String get receiptsTitle => 'Receipts & Expenses';

  @override
  String get receiptsAddReceipt => 'Add Receipt';

  @override
  String get receiptsReceiptName => 'Receipt Name';

  @override
  String get receiptsTotalExpenses => 'Total Expenses';

  @override
  String get receiptsNoReceipts => 'No receipts yet';

  @override
  String get receiptsNoReceiptsSubtitle =>
      'Track your expenses by adding receipts.';

  @override
  String get receiptsPhotoAttached => 'Photo attached';

  @override
  String get receiptsCatFood => 'Food & Drink';

  @override
  String get receiptsCatTransport => 'Transport';

  @override
  String get receiptsCatAccommodation => 'Accommodation';

  @override
  String get receiptsCatEntertainment => 'Entertainment';

  @override
  String get receiptsCatShopping => 'Shopping';

  @override
  String get receiptsCatHealth => 'Health';

  @override
  String get receiptsCatCommunication => 'Communication';

  @override
  String get receiptsCatFees => 'Fees & Charges';

  @override
  String get receiptsCatOther => 'Other';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get documentsAddDocument => 'Add Document';

  @override
  String get documentsDocumentName => 'Document Name';

  @override
  String get documentsNoDocuments => 'No documents yet';

  @override
  String get documentsNoDocumentsSubtitle =>
      'Add tickets, vouchers, letters and other documents.';

  @override
  String get documentsNoFileAttached => 'No file attached';

  @override
  String get documentsFileAttached => 'File attached';

  @override
  String get documentsTypeTicket => 'Ticket';

  @override
  String get documentsTypeVoucher => 'Voucher';

  @override
  String get documentsTypeLetter => 'Letter';

  @override
  String get documentsTypePassport => 'Passport';

  @override
  String get documentsTypeVisa => 'Visa';

  @override
  String get documentsTypeInsurance => 'Insurance';

  @override
  String get documentsTypeReservation => 'Reservation';

  @override
  String get documentsTypeItinerary => 'Itinerary';

  @override
  String get documentsTypeOther => 'Other';

  @override
  String get archiveTitle => 'Archive';

  @override
  String get archiveNoTrips => 'No archived trips';

  @override
  String get archiveNoTripsSubtitle =>
      'Trips you archive will appear here for reference.';

  @override
  String get archiveCloneTrip => 'Clone to New Trip';

  @override
  String get archiveCloneTitle => 'Clone Trip';

  @override
  String get archiveCloneNewName => 'New Trip Name';

  @override
  String get archiveClonePacking => 'Packing List';

  @override
  String get archiveClonePackingSubtitle => 'All items (reset to unpacked)';

  @override
  String get archiveCloneTasks => 'Tasks';

  @override
  String get archiveCloneTasksSubtitle => 'All tasks (reset to pending)';

  @override
  String get archiveCloneAddresses => 'Addresses';

  @override
  String get archiveCloneAddressesSubtitle => 'Hotels, restaurants, landmarks';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDataManagement => 'Data Management';

  @override
  String get settingsExportBackup => 'Export Backup';

  @override
  String get settingsExportBackupSubtitle =>
      'Save a copy of all your trip data';

  @override
  String get settingsRestoreBackup => 'Restore Backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Restore from a previously exported backup file';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsResetData => 'Reset App Data';

  @override
  String get settingsResetDataSubtitle =>
      'Permanently delete all trips, packing lists, tasks and all other data';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSelectLanguage => 'Select Language';

  @override
  String get settingsLanguageEditor => 'Edit Translations';

  @override
  String get settingsLanguageEditorSubtitle =>
      'View and customise translated strings';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'Version 1.1.0 · Personal travel planner';

  @override
  String get settingsRestoreConfirmTitle => 'Restore Backup';

  @override
  String get settingsRestoreConfirmBody =>
      'This will replace ALL current data with the backup file. Your current data will be lost.\n\nContinue?';

  @override
  String get settingsResetStep1Title => 'Reset App Data';

  @override
  String get settingsResetStep1Body =>
      'This will permanently delete EVERYTHING:\n\n• All trips (active, planned and archived)\n• All packing lists and templates\n• All tasks, addresses and documents\n• All receipts and expense records\n\nThis action CANNOT be undone.\n\nAre you sure you want to continue?';

  @override
  String get settingsResetStep2Title => 'Final Confirmation';

  @override
  String get settingsResetStep2Body =>
      'To confirm, type the word below exactly as shown:';

  @override
  String get settingsResetKeyword => 'RESET';

  @override
  String get settingsResetButton => 'Reset Everything';

  @override
  String get settingsResetSuccess =>
      'App data has been reset. All records deleted.';

  @override
  String get langEnglish => 'English';

  @override
  String get langHebrew => 'עברית';

  @override
  String get tripTypeLeisure => 'Leisure';

  @override
  String get tripTypeBusiness => 'Business';

  @override
  String get tripTypeFamily => 'Family';

  @override
  String get tripPurposeHoliday => 'Holiday';

  @override
  String get tripPurposeWorkTrip => 'Work Trip';

  @override
  String get tripPurposeFamilyVisit => 'Family Visit';

  @override
  String get tripPurposeConference => 'Conference';

  @override
  String get packingCatClothing => 'Clothing';

  @override
  String get packingCatToiletries => 'Toiletries';

  @override
  String get packingCatElectronics => 'Electronics';

  @override
  String get packingCatDocuments => 'Documents';

  @override
  String get packingCatMedication => 'Medication';

  @override
  String get packingCatFoodSnacks => 'Food & Snacks';

  @override
  String get packingCatAccessories => 'Accessories';

  @override
  String get packingCatSportOutdoor => 'Sport & Outdoor';

  @override
  String get packingCatBabyKids => 'Baby & Kids';

  @override
  String get packingCatWorkOffice => 'Work & Office';

  @override
  String get packingCatOther => 'Other';

  @override
  String get storageCheckin => 'Check-in Luggage';

  @override
  String get storageHandLuggage => 'Hand Luggage';

  @override
  String get storageBackpack => 'Backpack';

  @override
  String get storageToiletryBag => 'Toiletry Bag';

  @override
  String get storageLaptopBag => 'Laptop Bag';

  @override
  String get storageHandbag => 'Handbag / Purse';

  @override
  String get storageWallet => 'Wallet';

  @override
  String get storageMoneyBelt => 'Money Belt';

  @override
  String get storageCarBoot => 'Car Boot';

  @override
  String get storageShippingBox => 'Shipping Box';

  @override
  String get storageOther => 'Other';

  @override
  String get packingItemNameHint => 'e.g. Passport, Charger, T-shirt...';

  @override
  String get packingItemNameRequired => 'Item name is required';

  @override
  String get packingSelectCategory => 'Select a category';

  @override
  String get packingStoragePlaceHint => 'Where will you store this?';

  @override
  String get packingCustomStorageHint => 'e.g. Luggage 23 kg, Camera Bag...';

  @override
  String get packingNotesHint => 'Any notes about this item...';

  @override
  String get packingItemTasksLabel => 'Item Tasks';

  @override
  String get packingItemTasksHint => 'e.g. to buy, to iron';

  @override
  String get packingAddTaskHint => 'Add a task for this item...';

  @override
  String get packingUpdateItem => 'Update Item';

  @override
  String get packingErrorSaving => 'Error saving item';

  @override
  String get templateSaveTitle => 'Save as Template';

  @override
  String templateSaveSubtitle(int count) {
    return 'This will save $count item(s) as a reusable template.';
  }

  @override
  String get templateNameLabel => 'Template Name';

  @override
  String get templateNameHint => 'e.g. Summer Holiday Packing';

  @override
  String get templateDescLabel => 'Description (optional)';

  @override
  String get templateDescHint => 'e.g. For 1-2 week beach trips';

  @override
  String get templateSaveButton => 'Save Template';

  @override
  String get templateErrorSaving => 'Error saving template';

  @override
  String get templateLoadTitle => 'Load Template';

  @override
  String get templateNoTemplates => 'No templates saved yet';

  @override
  String get templateNoTemplatesSubtitle =>
      'Save a packing list as a template first.';

  @override
  String templateItemCount(int count) {
    return '$count items';
  }

  @override
  String packingSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get tripTypeAdventure => 'Adventure';

  @override
  String get tripTypeMedical => 'Medical';

  @override
  String get tripTypeOther => 'Other';

  @override
  String get tripPurposeMedical => 'Medical';

  @override
  String get tripPurposeOther => 'Other';

  @override
  String get packingUncategorised => 'Uncategorised';

  @override
  String get packingExcelHeaderName => 'Name';

  @override
  String get packingExcelHeaderCategory => 'Category';

  @override
  String get packingExcelHeaderQuantity => 'Quantity';

  @override
  String get packingExcelHeaderStorage => 'Storage Place';

  @override
  String get packingExcelHeaderStatus => 'Status';

  @override
  String get packingExcelHeaderNotes => 'Notes';

  @override
  String get tripDetailTypeBadge => 'Type';

  @override
  String get validatorRequired => 'Required';

  @override
  String get backupRestoredSuccess =>
      'Backup restored successfully. Restart the app to see changes.';

  @override
  String get backupRestoreFailed =>
      'Restore failed or cancelled. Your data is unchanged.';

  @override
  String get resetConfirmMismatch => 'Must match exactly';

  @override
  String get settingsContinue => 'Continue';

  @override
  String get settingsBackupFailed => 'Backup failed. No data found.';

  @override
  String get imageLoadError => 'Could not load image';
}

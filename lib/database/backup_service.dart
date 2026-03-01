import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  /// Export: copies the SQLite database file to the user's Documents folder
  Future<String?> exportBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final sourceFile = File(join(dbPath, 'tripready.db'));

      if (!await sourceFile.exists()) {
        return null;
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-')
          .substring(0, 19);
      final destPath = join(docsDir.path, 'tripready_backup_$timestamp.db');
      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      return null;
    }
  }

  /// Import: lets user pick a backup .db file and replaces the current database
  Future<bool> importBackup() async {
    try {
      // Close current database connection
      await DatabaseHelper.instance.close();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        // Re-open database
        await DatabaseHelper.instance.database;
        return false;
      }

      final selectedFile = File(result.files.single.path!);

      // Basic validation: check SQLite magic bytes
      final bytes = await selectedFile.openRead(0, 16).first;
      final magic = String.fromCharCodes(bytes.take(6));
      if (!magic.startsWith('SQLite')) {
        await DatabaseHelper.instance.database;
        return false;
      }

      final dbPath = await getDatabasesPath();
      final destPath = join(dbPath, 'tripready.db');

      // Backup current db before overwriting
      final currentDb = File(destPath);
      if (await currentDb.exists()) {
        await currentDb.copy('$destPath.bak');
      }

      // Copy selected file to db location
      await selectedFile.copy(destPath);

      // Re-initialise database connection
      await DatabaseHelper.instance.database;
      return true;
    } catch (e) {
      // Try to restore from backup on failure
      try {
        final dbPath = await getDatabasesPath();
        final bak = File(join(dbPath, 'tripready.db.bak'));
        if (await bak.exists()) {
          await bak.copy(join(dbPath, 'tripready.db'));
        }
        await DatabaseHelper.instance.database;
      } catch (_) {}
      return false;
    }
  }
}

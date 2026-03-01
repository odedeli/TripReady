import '../models/receipt.dart';
import 'database_helper.dart';

extension ReceiptDatabase on DatabaseHelper {

  Future<List<Receipt>> getReceipts(String tripId) async {
    final db = await database;
    final rows = await db.query(
      'receipts',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map((r) => Receipt.fromMap(r)).toList();
  }

  Future<void> insertReceipt(Receipt receipt) async {
    final db = await database;
    await db.insert('receipts', receipt.toMap());
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final db = await database;
    await db.update('receipts', receipt.toMap(),
        where: 'id = ?', whereArgs: [receipt.id]);
  }

  Future<void> deleteReceipt(String receiptId) async {
    final db = await database;
    await db.delete('receipts', where: 'id = ?', whereArgs: [receiptId]);
  }

  /// Returns total converted amount and breakdown by type
  Future<Map<String, double>> getReceiptSummary(String tripId) async {
    final receipts = await getReceipts(tripId);
    final Map<String, double> summary = {'total': 0};
    for (final r in receipts) {
      summary['total'] = (summary['total'] ?? 0) + r.convertedAmount;
      summary[r.type.name] = (summary[r.type.name] ?? 0) + r.convertedAmount;
    }
    return summary;
  }
}

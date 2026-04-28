import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('custody.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE custodies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        initialAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        currency TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        custodyId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        receiptImage TEXT,
        invoiceNumber TEXT,
        FOREIGN KEY (custodyId) REFERENCES custodies (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE expenses ADD COLUMN invoiceNumber TEXT');
    }
  }

  // ==================== عمليات العهدة ====================
  Future<int> insertCustody(CustodyModel custody) async {
    final db = await database;
    return await db.insert('custodies', custody.toMap());
  }

  Future<List<CustodyModel>> getAllCustodies() async {
    final db = await database;
    final result = await db.query('custodies', orderBy: 'createdAt DESC');
    return result.map((map) => CustodyModel.fromMap(map)).toList();
  }

  Future<CustodyModel?> getCustodyById(int id) async {
    final db = await database;
    final result =
        await db.query('custodies', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return CustodyModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateCustody(CustodyModel custody) async {
    final db = await database;
    return await db.update('custodies', custody.toMap(),
        where: 'id = ?', whereArgs: [custody.id]);
  }

  Future<int> deleteCustody(int id) async {
    final db = await database;
    return await db.delete('custodies', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== عمليات المصاريف ====================
  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.update('expenses', expense.toMap(),
        where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<List<ExpenseModel>> getExpensesByCustody(int custodyId) async {
    final db = await database;
    final result = await db.query('expenses',
        where: 'custodyId = ?', whereArgs: [custodyId], orderBy: 'date DESC');
    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpensesByCustody(int custodyId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE custodyId = ?',
        [custodyId]);
    return result.first['total'] as double? ?? 0.0;
  }

  Future<void> initDatabase() async {
    await database;
  }
}

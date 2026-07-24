import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';

class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();
  Future<Database> get database async{
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'farm_managemnet.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
    );
  }
  Future _createDatabase(Database db,int version) async {
    await db.execute('''
        CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        date TEXT NOT NULL
        )
''');
  }

  Future<int> insertExpense(Expense expense) async{
    final db = await database;
    return await db.insert(
        'expenses',
        expense.toMap(),
    );
  }

  Future<List<Expense>> getAllExpenses() async {

    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('expenses');

    return List.generate(
        maps.length,
        (index) => Expense.fromMap(maps[index]),
    );
  }

  Future<int> deleteExpense(int id) async{
    final db = await database;

    return await db.delete(
      'expenses',
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<int> updateExpense(Expense expense) async{
    final db = await database;

    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id=?',
      whereArgs: [expense.id],
    );
  }
}
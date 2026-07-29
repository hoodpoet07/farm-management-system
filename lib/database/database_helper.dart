import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
import '../models/purchase.dart';
import '../models/supplier.dart';

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
    final path = join(dbPath, 'farm_management.db');

    return await openDatabase(
        path,
        version: 3,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
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
    
    await db.execute('''
    CREATE TABLE purchases(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      itemName TEXT NOT NULL,
      supplier TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      unitPrice REAL NOT NULL,
      totalPrice REAL NOT NULL,
      date TEXT NOT NULL
      )
''');

  await db.execute('''
  CREATE TABLE suppliers(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
    )
    ''');
  await db.execute('''
    CREATE TABLE chicken_batches(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    batchName TEXT NOT NULL,
    breed TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    costPerBird REAL NOT NULL,
    arrivalDate TEXT NOT NULL
      );
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

  Future<int> updateExpense(Expense expense) async{
    final db = await database;

    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id=?',
      whereArgs: [expense.id],
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
  Future<int> insertPurchase(Purchase purchase) async{
    final db = await database;

    return await db.insert(
      'purchases',
      purchase.toMap(),
    );
  }

  Future<List<Purchase>> getAllPurchases() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
      await db.query('purchases');

    return List.generate(
      maps.length,
      (index)=> Purchase.fromMap(maps[index]),
    );
  }

  Future<int> updatePurchase(Purchase purchase) async {
    final db = await database;

    return await db.update(
      'purchases',
      purchase.toMap(),
      where: 'id=?',
      whereArgs: [purchase.id],
    );
  }

  Future<int> deletePurchase(int id) async {
    final db = await database;

    return await db.delete(
      'purchases',
      where: 'id=?',
      whereArgs: [id],
    );
  }
  Future<int> insertSupplier(Supplier supplier) async{
    final db =await database;

    return await db.insert(
      'suppliers',
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore, 
    );
  }
  Future<List<Supplier>> getAllSuppliers() async {
    final db= await database;

    final maps = await db.query(
      'suppliers',
      orderBy: 'name ASC',
    );

    return maps.map((e)=> Supplier.fromMap(e)).toList();
  }
}

Future<void> _upgradeDatabase(
  Database db,
  int oldVersion,
  int newVersion,
) async{
  if (oldVersion<2){

    await db.execute('''
      CREATE TABLE purchases(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemName TEXT NOT NULL,
        supplier TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        totalPrice REAL NOT NULL,
        date TEXT NOT NULL
      )
''');
  }
  if(oldVersion<3){
    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
        )
''');
  }
}
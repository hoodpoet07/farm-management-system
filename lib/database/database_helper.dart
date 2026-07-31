import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
import '../models/purchase.dart';
import '../models/supplier.dart';
import '../models/chicken_batch.dart';
import '../models/mortality.dart';
import '../models/sales.dart';

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
        version: 5,
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

  await db.execute('''
    CREATE TABLE mortality(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    batchId INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    reason TEXT NOT NULL,
    date TEXT NOT NULL
);
''');

  await db.execute('''
    CREATE TABLE sales(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      batchId INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      pricePerBird REAL NOT NULL,
      totalAmount REAL NOT NULL,
      customerName TEXT,
      date TEXT NOT NULL
      )
  ''');
  }
  
  Future<int> insertSale(Sale sale) async {
  final db = await database;
  return await db.insert('sales', sale.toMap());
 }

  Future<List<Sale>> getSalesByBatch(int batchId) async {
    final db = await database;
    final maps = await db.query(
      'sales',
      where: 'batchId = ?',
      whereArgs: [batchId],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  Future<double> getTotalSalesAmount() async {
  final db = await database;
  final result = await db.rawQuery('SELECT SUM(totalAmount) as total FROM sales');
  return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalSoldByBatch(int batchId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM sales WHERE batchId = ?',
      [batchId],
    );
    return (result.first['total'] as num?)?.toInt() ?? 0;
  }
  Future<int> insertChickenBatch(ChickenBatch batch) async {
    final db = await database;
    return await db.insert(
      'chicken_batches',
      batch.toMap(),
    );
  }

  Future<List<ChickenBatch>> getAllChickenBatches() async {
    final db = await database;
    final maps = await db.query('chicken_batches', orderBy: 'id DESC');
    return List.generate(
      maps.length,
      (index) => ChickenBatch.fromMap(maps[index]),
    );
  } 

  Future<int> getTotalChickensCount() async {
  final db = await database;
  
  final batchRes = await db.rawQuery('SELECT SUM(quantity) as total FROM chicken_batches');
  final mortalityRes = await db.rawQuery('SELECT SUM(quantity) as total FROM mortality');
  final salesRes = await db.rawQuery('SELECT SUM(quantity) as total FROM sales');

  final totalBatches = (batchRes.first['total'] as num?)?.toInt() ?? 0;
  final totalMortality = (mortalityRes.first['total'] as num?)?.toInt() ?? 0;
  final totalSales = (salesRes.first['total'] as num?)?.toInt() ?? 0;

  final remaining = totalBatches - totalMortality - totalSales;
  return remaining < 0 ? 0 : remaining;
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

  Future<double> getTotalExpensesAmount() async {
  final db = await database;
  final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
  return (result.first['total'] as num?)?.toDouble() ?? 0.0;
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
  Future<double> getTotalPurchasesAmount() async {
  final db = await database;
  final result = await db.rawQuery('SELECT SUM(totalPrice) as total FROM purchases');
  return (result.first['total'] as num?)?.toDouble() ?? 0.0;
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

  Future<int> insertMortality(Mortality mortality) async {
    final db = await database;
    return await db.insert(
      'mortality',
      mortality.toMap(),
    );
  }

  Future<List<Mortality>> getMortalityByBatch(int batchId) async {
  final db = await database;
  final maps = await db.query(
    'mortality',
    where: 'batchId = ?',
    whereArgs: [batchId],
  );

  return List.generate(
    maps.length,
    (index) => Mortality.fromMap(maps[index]),
  );
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
  if (oldVersion<4){
    await db.execute('''
        CREATE TABLE IF NOT EXISTS chicken_batches(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          batchName TEXT NOT NULL,
          breed TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          costPerBird REAL NOT NULL,
          arrivalDate TEXT NOT NULL
        )
''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mortality(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        batchId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        reason TEXT NOT NULL,
        date TEXT NOT NULL
      )
''');
  }
  if (oldVersion<5){
    await db.execute('''
    CREATE TABLE IF NOT EXISTS sales(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      batchId INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      pricePerBird REAL NOT NULL,
      totalAmount REAL NOT NULL,
      customerName TEXT,
      date TEXT NOT NULL
    )
  ''');
  }
}
}

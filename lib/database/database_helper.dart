import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
import '../models/purchase.dart';
import '../models/supplier.dart';
import '../models/chicken_batch.dart';
import '../models/mortality.dart';
import '../models/sales.dart';
import '../models/chat_history.dart';
import '../models/chat_session.dart';
import '../models/user.dart';
import '../models/feed.dart';
import 'package:flutter/foundation.dart';

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
        version: 7,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
    );
  }

  Future<Map<String, dynamic>> getSystemSummaryContext() async {
    final activeBirds = await getTotalChickensCount();
    final sales = await getTotalSalesAmount();
    final expenses = await getTotalFeedCost();
    final feedCost = await getTotalFeedCost();
    final mortality = await getTotalMortalityCount();

    return{
      "activeBirds": activeBirds,
      "totalSales": sales,
      "totalExpenses": expenses,
      "totalFeedCost": feedCost,
      "totalMortality": mortality,
    };
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

  await db.execute('''
    CREATE TABLE chat_sessions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      createdAt TEXT NOT NULL)'''
);

  await db.execute('''
    CREATE TABLE chat_messages(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sessionId INTEGER NOT NULL,
      message TEXT NOT NULL,
      isUser INTEGER NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY(sessionId) REFERENCES chat_sessions(id) 
    )
''');

  await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL
      )
    ''');

  await db.insert('users',{
    'username': 'admin',
    'password': 'admin123',
    'role': 'admin',
  });

    await db.execute('''
      CREATE TABLE feed_inventory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        feedName TEXT NOT NULL,
        category TEXT NOT NULL,
        quantityKg REAL NOT NULL,
        costPerKg REAL NOT NULL,
        dateAdded TEXT NOT NULL
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

 Future<int> createChatSession(ChatSession session) async {
  final db= await database;
  return await db.insert(
    'chat_sessions',
    session.toMap(),
  );
 }

 Future<List<ChatSession>> getChatSessions() async {
  final db = await database;

  final maps = await db.query(
    'chat_sessions',
    orderBy: 'id DESC',
  );

  return maps
      .map((e) => ChatSession.fromMap(e))
      .toList();
}
  Future<int> insertChatMessage(
    ChatHistory message) async {

  final db = await database;

  return await db.insert(
    'chat_messages',
    message.toMap(),
  );
}

  Future<List<ChatHistory>> getChatMessages(
    int sessionId) async {

  final db = await database;

  final maps = await db.query(
    'chat_messages',
    where: 'sessionId=?',
    whereArgs: [sessionId],
    orderBy: 'id ASC',
  );

  return maps
      .map((e) => ChatHistory.fromMap(e))
      .toList();
}

  Future<void> deleteChatSession(
    int sessionId) async {

  final db = await database;

  await db.delete(
    'chat_messages',
    where: 'sessionId=?',
    whereArgs: [sessionId],
  );

  await db.delete(
    'chat_sessions',
    where: 'id=?',
    whereArgs: [sessionId],
  );
 }

  Future<User?> loginUser(String username, String password) async{
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if(res.isNotEmpty){
      return User.fromMap(res.first);
    }
    return null;
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users',user.toMap());
  }

  Future<List<User>> getAllUSers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'id ASC');
    return maps.map((e)=> User.fromMap(e)).toList();
  }

  Future<int> deleteUser(int id) async{
    final db = await database;
    return await db.delete('users',where: 'id=?',whereArgs: [id]);
  }

  Future<int> insertFeed(Feed feed) async {
  final db = await database;
  return await db.insert('feed_inventory', feed.toMap());
}

  Future<List<Feed>> getAllFeeds() async {
    final db = await database;
    final maps = await db.query('feed_inventory', orderBy: 'id DESC');
    return maps.map((e) => Feed.fromMap(e)).toList();
  }

  Future<int> deleteFeed(int id) async {
    final db = await database;
    return await db.delete('feed_inventory', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalFeedCost() async {
    final db = await database;
    try{
      final result = await db.rawQuery('SELECT SUM(quantityKg * costPerKg) as total FROM feed_inventory',);
      if(result.isNotEmpty && result.first['total'] != null){
        return (result.first['total'] as num).toDouble();
      }
    }catch(e){
      debugPrint("Error fetching feed cost summary: $e");
    }
    return 0.0;
  }

  Future<int> getTotalMortalityCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(quantity) as total FROM mortality');
    return (result.first['total'] as num?)?.toInt() ?? 0;
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
  if (oldVersion < 6) {

  await db.execute('''
  CREATE TABLE IF NOT EXISTS chat_sessions(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    createdAt TEXT NOT NULL
  )
  ''');

  await db.execute('''
  CREATE TABLE IF NOT EXISTS chat_messages(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sessionId INTEGER NOT NULL,
    message TEXT NOT NULL,
    isUser INTEGER NOT NULL,
    timestamp TEXT NOT NULL,
    FOREIGN KEY(sessionId) REFERENCES chat_sessions(id)
  )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL
    )
  ''');

  await db.rawInsert('''
    INSERT OR IGNORE INTO users (username, password, role) 
    VALUES ('admin', 'admin123', 'admin')
  ''');
  }
  if (oldVersion < 8) {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS feed_inventory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      feedName TEXT NOT NULL,
      category TEXT NOT NULL,
      quantityKg REAL NOT NULL,
      costPerKg REAL NOT NULL,
      dateAdded TEXT NOT NULL
    )
  ''');
}
}
}

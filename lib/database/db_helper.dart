import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';
import '../models/banner.dart'; 
import '../models/address_model.dart'; // ✅ Naya model import kiya
import 'dart:convert';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'scentview.db');
    return await openDatabase(
      path,
      // 👇 VERSION 4: Version barha diya taake naya 'addresses' table ban sakay
      version: 4, 
      onCreate: (db, version) async {
        await _createProductTable(db);
        await _createBannerTable(db);
        await _createAddressTable(db); // ✅ Naya table
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Agar addresses table pehle nahi tha to ab bana do
          await _createAddressTable(db);
        }
      },
    );
  }

  // === TABLE CREATION LOGIC ===
  
  Future<void> _createProductTable(Database db) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        name TEXT,
        description TEXT,
        price TEXT,
        sale_price TEXT,
        stock INTEGER,
        badge_text TEXT,
        is_featured INTEGER,
        main_image_url TEXT,
        fragrance_notes TEXT
      )
    ''');
  }

  Future<void> _createBannerTable(Database db) async {
    await db.execute('''
      CREATE TABLE banners(
        id TEXT PRIMARY KEY,
        title TEXT,
        image_url TEXT,
        target_screen TEXT,
        target_id TEXT,
        is_active INTEGER,
        description TEXT,
        sort_order INTEGER
      )
    ''');
  }

  // ✅ NEW: ADDRESS TABLE
  Future<void> _createAddressTable(Database db) async {
    await db.execute('''
      CREATE TABLE addresses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        fullName TEXT,
        phone TEXT,
        fullAddress TEXT,
        isDefault INTEGER
      )
    ''');
  }

  // === PRODUCT METHODS ===
  
  Future<void> insertProducts(List<Product> products) async {
    final db = await database;
    await db.delete('products'); 
    
    Batch batch = db.batch();
    for (var product in products) {
      batch.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // === BANNER METHODS ===

  Future<void> insertBanners(List<Banner> banners) async {
    try {
      final db = await database;
      await db.delete('banners'); 
      Batch batch = db.batch();
      for (var banner in banners) {
        batch.insert('banners', banner.toDbMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("❌ DBHelper Banner Error: $e");
    }
  }

  Future<List<Banner>> getBanners() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('banners', orderBy: 'sort_order ASC');
    return List.generate(maps.length, (i) => Banner.fromDbMap(maps[i]));
  }

  // === ✅ ADDRESS METHODS (NEW) ===

  Future<void> insertAddress(UserAddress address) async {
    final db = await database;
    await db.insert(
      'addresses',
      address.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserAddress>> getAddresses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('addresses');
    return List.generate(maps.length, (i) {
      return UserAddress(
        id: maps[i]['id'],
        title: maps[i]['title'],
        fullName: maps[i]['fullName'],
        phone: maps[i]['phone'],
        fullAddress: maps[i]['fullAddress'],
        isDefault: maps[i]['isDefault'] == 1,
      );
    });
  }

// DBHelper class ke andar:
// 1. Version update: version: 7
// 2. Table create karein onCreate mein:
// await db.execute("CREATE TABLE search_history(id INTEGER PRIMARY KEY AUTOINCREMENT, query TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)");

// 3. Ye functions add karein:
Future<void> saveSearchQuery(String query) async {
  final db = await database;
  // Agar pehle se wahi word hai to delete karo taake duplicate na ho
  await db.delete('search_history', where: 'query = ?', whereArgs: [query]);
  // Naya insert karo
  await db.insert('search_history', {'query': query});
}

Future<List<String>> getRecentSearches() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('search_history', orderBy: 'timestamp DESC', limit: 5);
  return List.generate(maps.length, (i) => maps[i]['query'] as String);
}

Future<void> clearSearchHistory() async {
  final db = await database;
  await db.delete('search_history');
}
  Future<void> deleteAddress(int id) async {
    final db = await database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }
}
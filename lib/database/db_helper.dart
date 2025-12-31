import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';
import '../models/banner.dart'; 
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
      // 👇 VERSION 3: Ye zaroori hai taake mobile naya table accept kare
      version: 3, 
      onCreate: (db, version) async {
        // Jab pehli baar app install ho
        await _createProductTable(db);
        await _createBannerTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Jab purane user ke paas update jaye
        if (oldVersion < 3) {
          // Safety ke liye: Agar table adhoora bana ho to delete kar ke naya banao
          await db.execute("DROP TABLE IF EXISTS banners"); 
          await _createBannerTable(db);
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

  // === PRODUCT METHODS ===
  
  Future<void> insertProducts(List<Product> products) async {
    final db = await database;
    await db.delete('products'); // Purana data saaf karo
    
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

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // === BANNER METHODS (OFFLINE FIX) ===

  Future<void> insertBanners(List<Banner> banners) async {
    try {
      final db = await database;
      await db.delete('banners'); // Purane banners delete karo
      
      Batch batch = db.batch();
      for (var banner in banners) {
        batch.insert(
          'banners',
          banner.toDbMap(), 
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      print("✅ DBHelper: Banners Saved Successfully");
    } catch (e) {
      print("❌ DBHelper Error: $e");
    }
  }

  Future<List<Banner>> getBanners() async {
    try {
      final db = await database;
      // Banners ko sort order ke hisaab se laao
      final List<Map<String, dynamic>> maps = await db.query('banners', orderBy: 'sort_order ASC');

      print("✅ DBHelper: Fetched ${maps.length} Banners");
      return List.generate(maps.length, (i) {
        return Banner.fromDbMap(maps[i]); 
      });
    } catch (e) {
      print("❌ DBHelper Fetch Error: $e");
      return [];
    }
  }
}
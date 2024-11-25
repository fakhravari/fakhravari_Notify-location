import 'dart:convert';
import 'package:fakhravari/ApiService/ApiService.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InsertLocationModel {
  String id;
  double x_Longitude;
  double y_Latitude;

  InsertLocationModel({
    required this.id,
    required this.x_Longitude,
    required this.y_Latitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x_Longitude': x_Longitude,
      'y_Latitude': y_Latitude,
    };
  }
}

class LocationDatabase {
  static final LocationDatabase instance = LocationDatabase._init();
  static Database? _database;

  LocationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('location.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id TEXT PRIMARY KEY,
        latitude REAL,
        longitude REAL,
        timestamp TEXT,
        isSent INTEGER
      )
    ''');
  }

  Future<InsertLocationModel?> insertLocation(
      double latitude, double longitude) async {
    try {
      final db = await instance.database;
      var date = DateTime.now();
      var id = date.toIso8601String();
      await db.insert('locations', {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'isSent': 0
      });
      return InsertLocationModel(
        id: DateTime.now().toIso8601String(),
        y_Latitude: latitude,
        x_Longitude: longitude,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUnsentLocations() async {
    final db = await instance.database;
    return await db.query('locations', where: 'isSent = ?', whereArgs: [0]);
  }

  Future<void> updateLocationStatus(String id) async {
    final db = await instance.database;
    await db.update('locations', {'isSent': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<String> sendUnsentLocations() async {
    try {
      var locations = await getUnsentLocations();

      var all = locations
          .map((item) => InsertLocationModel(
              id: item['id'],
              y_Latitude: item['latitude'],
              x_Longitude: item['longitude']))
          .toList();

      for (var element in all) {
        await ApiService().sendDataToApi(jsonEncode(element));
        await LocationDatabase.instance.updateLocationStatus(element.id);
      }

      return 'true';
    } catch (e) {
      return e.toString();
    }
  }
}

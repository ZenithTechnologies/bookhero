import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bookhero.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE eras (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE series (
      id INTEGER PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      year_range TEXT,
      comic_type TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE issues (
      id INTEGER PRIMARY KEY,
      series_id INTEGER NOT NULL,
      issue_number INTEGER NOT NULL,
      obtained INTEGER DEFAULT 0,
      tags TEXT, -- stored as a JSON string
      cover_type TEXT,
      variant TEXT,
      special_edition TEXT,
      description TEXT,
      event_id INTEGER,
      FOREIGN KEY(series_id) REFERENCES series(id),
      FOREIGN KEY(event_id) REFERENCES events(id)
    )
  ''');
  }

  // SERIES CRUD
  Future<int> insertSeries(Map<String, dynamic> series) async {
    final dbClient = await db;
    return await dbClient.insert('series', series);
  }

  Future<List<Map<String, dynamic>>> getAllSeries() async {
    final dbClient = await db;
    return await dbClient.query('series');
  }

  Future<int> updateSeries(int id, Map<String, dynamic> series) async {
    final dbClient = await db;
    return await dbClient.update(
      'series',
      series,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSeries(int id) async {
    final dbClient = await db;
    return await dbClient.delete('series', where: 'id = ?', whereArgs: [id]);
  }

  // ISSUE CRUD
  Future<int> insertIssue(Map<String, dynamic> issue) async {
    final dbClient = await db;
    return await dbClient.insert('issues', issue);
  }

  Future<List<Map<String, dynamic>>> getIssuesBySeriesId(int seriesId) async {
    final dbClient = await db;
    return await dbClient.query(
      'issues',
      where: 'series_id = ?',
      whereArgs: [seriesId],
    );
  }

  Future<int> updateIssue(int id, Map<String, dynamic> issue) async {
    final dbClient = await db;
    return await dbClient.update(
      'issues',
      issue,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIssue(int id) async {
    final dbClient = await db;
    return await dbClient.delete('issues', where: 'id = ?', whereArgs: [id]);
  }

  // EVENT CRUD
  Future<int> insertEvent(String name) async {
    final dbClient = await db;
    return await dbClient.insert('events', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final dbClient = await db;
    return await dbClient.query('events');
  }

  Future<int> updateEvent(int id, String name) async {
    final dbClient = await db;
    return await dbClient.update(
      'events',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final dbClient = await db;
    return await dbClient.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // ERA CRUD
  Future<int> insertEra(String name) async {
    final dbClient = await db;
    return await dbClient.insert('eras', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getAllEras() async {
    final dbClient = await db;
    return await dbClient.query('eras');
  }

  Future<int> updateEra(int id, String name) async {
    final dbClient = await db;
    return await dbClient.update(
      'eras',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEra(int id) async {
    final dbClient = await db;
    return await dbClient.delete('eras', where: 'id = ?', whereArgs: [id]);
  }
}

import '../models/workout.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await _initDB('gym_tracker.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(

      path,

      version: 1,

      onCreate: _createDB,

    );
  }

  Future _createDB(Database db, int version) async {

    await db.execute('''

      CREATE TABLE workout (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        exercise TEXT NOT NULL,

        setNo INTEGER,

        weight REAL,

        reps INTEGER,

        workoutDate TEXT

      )

    ''');

  }

  // Insert Workout
Future<int> insertWorkout(Workout workout) async {

  final db = await instance.database;

  return await db.insert(
    'workout',
    workout.toMap(),
  );
}

// Get All Workouts
Future<List<Workout>> getAllWorkouts() async {

  final db = await instance.database;

  final result = await db.query(
    'workout',
    orderBy: 'id DESC',
  );

  return result.map((json) => Workout.fromMap(json)).toList();
}

// Delete Workout
Future<int> deleteWorkout(int id) async {

  final db = await instance.database;

  return await db.delete(
    'workout',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Update Workout
Future<int> updateWorkout(Workout workout) async {

  final db = await instance.database;

  return await db.update(
    'workout',
    workout.toMap(),
    where: 'id = ?',
    whereArgs: [workout.id],
  );
}

}
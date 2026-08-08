import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/exercise.dart';
import 'models/workout.dart';

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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  exercise TEXT NOT NULL,
  setNo INTEGER,
  weight REAL,
  reps INTEGER,
  workoutDate TEXT,
  duration REAL,
  elevation REAL
)
    ''');

    await db.execute('''
      CREATE TABLE exercise_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bodyArea TEXT NOT NULL,
        exercise TEXT NOT NULL,
        setEnabled INTEGER NOT NULL,
        weightEnabled INTEGER NOT NULL,
        repsEnabled INTEGER NOT NULL
      )
    ''');

    await _insertExercises(db);
  }

  Future<void> _upgradeDB(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 2) {
    await db.execute('''
      CREATE TABLE exercise_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bodyArea TEXT NOT NULL,
        exercise TEXT NOT NULL,
        setEnabled INTEGER NOT NULL,
        weightEnabled INTEGER NOT NULL,
        repsEnabled INTEGER NOT NULL
      )
    ''');

    await _insertExercises(db);
  }

  if (oldVersion < 3) {
    await db.execute(
      'ALTER TABLE workout ADD COLUMN duration REAL',
    );

    await db.execute(
      'ALTER TABLE workout ADD COLUMN elevation REAL',
    );
  }
}

  Future<void> _insertExercises(Database db) async {
    final exercises = [
      Exercise(
        bodyArea: 'Leg',
        exercise: 'Free Squats',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Leg',
        exercise: 'Static Lunges',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Leg',
        exercise: 'Leg Press',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Leg',
        exercise: 'Standing Calf',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Leg',
        exercise: 'Leg Curl',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Leg',
        exercise: 'Leg Ext',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Back',
        exercise: 'Lat Pull',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Back',
        exercise: 'Seated Row',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Chest Press',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Shoulder',
        exercise: 'Shoulder Press',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Flat Dumbbell Press',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Flat Barbell Press',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Decline Dumbbell Press',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Decline Barbell Press',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Pec Fly',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Pectoral Fly',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Back',
        exercise: 'Deltoid Fly',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: '',
        exercise: 'Dumbbell Race',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Shoulder',
        exercise: 'Dumbbell Shrugs',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Back',
        exercise: 'Chin Assist',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Dip Assist',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Bicep',
        exercise: 'Bicep Curl',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Tricep',
        exercise: 'Triceps Press',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: '',
        exercise: 'Hammer Curl',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Back',
        exercise: 'Bent Over Row',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Shoulder',
        exercise: 'Deltoid Raise',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Shoulder',
        exercise: 'Face Pull Down',
        setEnabled: true,
        weightEnabled: true,
        repsEnabled: true,
      ),
      Exercise(
        bodyArea: 'Cardio',
        exercise: 'Trade Mill',
        setEnabled: false,
        weightEnabled: false,
        repsEnabled: false,
      ),
      Exercise(
        bodyArea: 'Cardio',
        exercise: 'Cross Trainer',
        setEnabled: false,
        weightEnabled: false,
        repsEnabled: false,
      ),
      Exercise(
        bodyArea: 'Cardio',
        exercise: 'Bike',
        setEnabled: false,
        weightEnabled: false,
        repsEnabled: false,
      ),
      Exercise(
        bodyArea: 'Cardio',
        exercise: 'Rowing Machine',
        setEnabled: false,
        weightEnabled: false,
        repsEnabled: false,
      ),
      Exercise(
        bodyArea: 'Chest',
        exercise: 'Push Up',
        setEnabled: true,
        weightEnabled: false,
        repsEnabled: true,
      ),
    ];

    for (final exercise in exercises) {
      await db.insert(
        'exercise_master',
        exercise.toMap(),
      );
    }
  }

  // INSERT WORKOUT
  Future<int> insertWorkout(Workout workout) async {
    final db = await instance.database;

    return await db.insert(
      'workout',
      workout.toMap(),
    );
  }

  // GET ALL WORKOUTS
  Future<List<Workout>> getAllWorkouts() async {
    final db = await instance.database;

    final result = await db.query(
      'workout',
      orderBy: 'id DESC',
    );

    return result.map((json) => Workout.fromMap(json)).toList();
  }

  // GET ALL EXERCISES
  Future<List<Exercise>> getAllExercises() async {
    final db = await instance.database;

    final result = await db.query(
      'exercise_master',
      orderBy: 'bodyArea ASC, exercise ASC',
    );

    return result.map((json) => Exercise.fromMap(json)).toList();
  }

  // DELETE WORKOUT
  Future<int> deleteWorkout(int id) async {
    final db = await instance.database;

    return await db.delete(
      'workout',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE WORKOUT
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
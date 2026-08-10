import 'dart:io';
import 'package:flutter/services.dart';

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

  const isSit = bool.fromEnvironment(
    'SIT',
    defaultValue: false,
  );

  // For SIT, preload the database containing existing workout data
  // only when the database does not already exist.
  if (isSit && !await File(path).exists()) {
    final data = await rootBundle.load(
      'assets/database/sit_seed.db',
    );

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    await File(path).writeAsBytes(
      bytes,
      flush: true,
    );
  }

  return await openDatabase(
    path,
    version: 4,
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
  // Version 4: Replace exercise master with the new clean list
  if (oldVersion < 4) {
    await db.delete('exercise_master');
    await _insertExercises(db);
  }
}

 Future _insertExercises(Database db) async {
  final exercises = [
    // ==================== LEG ====================
    Exercise(
      bodyArea: 'Leg',
      exercise: 'Squats',
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
      exercise: 'Standing Calf Raise',
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
      exercise: 'Leg Extension',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Leg',
      exercise: 'Romanian Deadlift',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Leg',
      exercise: 'Bulgarian Split Squat',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),

    // ==================== BACK ====================
    Exercise(
      bodyArea: 'Back',
      exercise: 'Lat Pull - Wide Grip',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Back',
      exercise: 'Lat Pull - Close Grip',
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
      bodyArea: 'Back',
      exercise: 'Bent Over Row',
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
      bodyArea: 'Back',
      exercise: 'Pull Up',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Back',
      exercise: 'Assisted Pull Up',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),

    // ==================== CHEST ====================
    Exercise(
      bodyArea: 'Chest',
      exercise: 'Chest Press - Machine',
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
      exercise: 'Incline Chest Press - Machine',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Chest',
      exercise: 'Incline Dumbbell Press',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Chest',
      exercise: 'Incline Barbell Press',
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
      exercise: 'Pectoral Fly',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Chest',
      exercise: 'Cable Crossover',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Chest',
      exercise: 'Push Up',
      setEnabled: true,
      weightEnabled: false,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Chest',
      exercise: 'Dip Assist',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),

    // ==================== SHOULDER ====================
    Exercise(
      bodyArea: 'Shoulder',
      exercise: 'Shoulder Press - Machine',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Shoulder',
      exercise: 'Shoulder Press - Barbell',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Shoulder',
      exercise: 'Shoulder Press - Dumbbells',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Shoulder',
      exercise: 'Dumbbell Front Raise',
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
      bodyArea: 'Shoulder',
      exercise: 'Side Lateral Raise - Dumbbells',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Shoulder',
      exercise: 'Side Lateral Raise - Barbell',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Shoulder',
      exercise: 'Side Lateral Raise - Machine',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),

    // ==================== BICEP ====================
    Exercise(
      bodyArea: 'Bicep',
      exercise: 'Bicep Curl - Barbell',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Bicep',
      exercise: 'Bicep Curl - Dumbbells',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Bicep',
      exercise: 'Hammer Curl',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Bicep',
      exercise: 'Preacher Curl',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Bicep',
      exercise: 'Cable Curl',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),

    // ==================== TRICEP ====================
    Exercise(
      bodyArea: 'Tricep',
      exercise: 'Triceps Press',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Tricep',
      exercise: 'Cable Triceps Pushdown',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Tricep',
      exercise: 'Overhead Triceps Extension',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Tricep',
      exercise: 'Skull Crusher',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Tricep',
      exercise: 'Triceps Dip',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),

    // ==================== CORE ====================
    Exercise(
      bodyArea: 'Core',
      exercise: 'Leg Raises',
      setEnabled: true,
      weightEnabled: false,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Core',
      exercise: 'Crunches',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Core',
      exercise: 'Plank',
      setEnabled: true,
      weightEnabled: false,
      repsEnabled: false,
    ),
    Exercise(
      bodyArea: 'Core',
      exercise: 'Hanging Leg Raises',
      setEnabled: true,
      weightEnabled: false,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Core',
      exercise: 'Bicycle Crunch',
      setEnabled: true,
      weightEnabled: false,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Core',
      exercise: 'High Knees',
      setEnabled: true,
      weightEnabled: false,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Core',
      exercise: 'Mountain Climber',
      setEnabled: true,
      weightEnabled: false,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Core',
      exercise: 'Flutter Kicks',
      setEnabled: true,
      weightEnabled: false,
      repsEnabled: true,
    ),
    Exercise(
      bodyArea: 'Core',
      exercise: 'Russian Twist',
      setEnabled: true,
      weightEnabled: true,
      repsEnabled: true,
    ),

    // ==================== CARDIO ====================
    Exercise(
      bodyArea: 'Cardio',
      exercise: 'Treadmill',
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

  Future<List<Map<String, dynamic>>> getWorkoutStats(
  DateTime startDate,
  DateTime endDate,
) async {
  final db = await instance.database;

  final result = await db.rawQuery(
    '''
    SELECT
      w.exercise,
      w.setNo,
      w.weight,
      w.reps,
      w.duration,
      w.elevation,
      w.workoutDate,
      e.bodyArea
    FROM workout w
    LEFT JOIN exercise_master e
      ON w.exercise = e.exercise
    WHERE w.workoutDate >= ?
      AND w.workoutDate < ?
    ORDER BY w.id DESC
    ''',
    [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ],
  );

  return result;
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
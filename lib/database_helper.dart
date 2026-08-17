import 'dart:io';
import 'package:flutter/services.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/exercise.dart';
import 'models/workout.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  static Future<Database>? _databaseFuture;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _databaseFuture ??= _initDB('gym_tracker.db');

    try {
      _database = await _databaseFuture!;
      return _database!;
    } catch (_) {
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  const isSit = bool.fromEnvironment(
    'SIT',
    defaultValue: false,
  );

  final db = await openDatabase(
    path,
    version: 10,
    onCreate: _createDB,
    onUpgrade: _upgradeDB,
  );

  // Make sure required tables exist for all databases,
  // including restored/seed databases.
  await _ensureRequiredTables(db);

  // Bootstrap seed data only when exercise master is empty.
  final exerciseCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM exercise_master',
        ),
      ) ??
      0;

  if (exerciseCount == 0) {
    await _importSeedData(
      db,
      dbPath,
      isSit,
    );
  }

  // Make sure required exercises exist even in older/restored seed databases.
  await _ensureRequiredExercises(db);

  // // Temporary diagnostic log.
  // final verifyExercises = await db.rawQuery(
  //   'SELECT COUNT(*) AS c FROM exercise_master',
  // );

  // final verifyWorkouts = await db.rawQuery(
  //   'SELECT COUNT(*) AS c FROM workout',
  // );

  

  return db;
}
  Future<void> _importSeedData(
    Database db,
    String dbPath,
    bool isSit,
  ) async {
    final seedAsset = isSit
        ? 'assets/database/sit_seed.db'
        : 'assets/database/prod_seed.db';

    final seedPath = join(
      dbPath,
      isSit ? 'gym_tracker_sit_seed.db' : 'gym_tracker_prod_seed.db',
    );

    final seedFile = File(seedPath);

    try {
      if (await seedFile.exists()) {
        await seedFile.delete();
      }

      final data = await rootBundle.load(seedAsset);

      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await seedFile.writeAsBytes(
        bytes,
        flush: true,
      );

      final seedDb = await openDatabase(
        seedPath,
        readOnly: true,
      );

      try {
        final exerciseRows = await seedDb.query(
          'exercise_master',
          orderBy: 'id ASC',
        );

        final workoutRows = await seedDb.query(
          'workout',
          orderBy: 'id ASC',
        );

    

        await db.transaction((txn) async {
          for (final row in exerciseRows) {
            await txn.insert(
              'exercise_master',
              Map<String, dynamic>.from(row),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          for (final row in workoutRows) {
            await txn.insert(
              'workout',
              Map<String, dynamic>.from(row),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        });

        // final finalExercises = await db.rawQuery(
        //   'SELECT COUNT(*) AS c FROM exercise_master',
        // );

        // final finalWorkouts = await db.rawQuery(
        //   'SELECT COUNT(*) AS c FROM workout',
        // );

      
      } finally {
        await seedDb.close();
      }
    } finally {
      if (await seedFile.exists()) {
        await seedFile.delete();
      }
    }
  }

Future<void> _ensureRequiredTables(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS body_profile (
      id INTEGER PRIMARY KEY,
      name TEXT,
      height REAL,
      heightUnit TEXT NOT NULL DEFAULT 'cm',
      profileCompleted INTEGER NOT NULL DEFAULT 0,
      updatedDate TEXT
    )
  ''');

  // Make sure older/restored databases also get the new columns.
  await _addColumnIfMissing(
    db,
    'body_profile',
    'name',
    'TEXT',
  );

  await _addColumnIfMissing(
    db,
    'body_profile',
    'profileCompleted',
    'INTEGER NOT NULL DEFAULT 0',
  );

  await db.execute('''
    CREATE TABLE IF NOT EXISTS weight_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      weight REAL NOT NULL,
      recordedDate TEXT NOT NULL
    )
  ''');


  await db.execute('''
    CREATE TABLE IF NOT EXISTS weight_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      weight REAL NOT NULL,
      recordedDate TEXT NOT NULL
    )
  ''');
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
  elevation REAL,
  distance REAL,
  calories REAL
)
    ''');

    await db.execute('''
  CREATE TABLE exercise_master (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bodyArea TEXT NOT NULL,
    exercise TEXT NOT NULL,
    setEnabled INTEGER NOT NULL,
    weightEnabled INTEGER NOT NULL,
    repsEnabled INTEGER NOT NULL,
    measurementType TEXT NOT NULL DEFAULT 'reps'
  )
''');

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

  if (oldVersion < 5) {
    await _addColumnIfMissing(
      db,
      'workout',
      'distance',
      'REAL',
    );

    await _addColumnIfMissing(
      db,
      'workout',
      'calories',
      'REAL',
    );
  }

  // Version 6: Add body profile and weight history.
  if (oldVersion < 6) {
    await db.execute('''
      CREATE TABLE body_profile (
        id INTEGER PRIMARY KEY,
        height REAL,
        heightUnit TEXT NOT NULL DEFAULT 'cm',
        updatedDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE weight_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        recordedDate TEXT NOT NULL
      )
    ''');
  }

  // Version 7: Temporary non-destructive migration verification.
  // This table is only used to prove that onUpgrade runs successfully.
  if (oldVersion < 7) {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS db_migration_test (
        id INTEGER PRIMARY KEY,
        migratedFrom INTEGER NOT NULL,
        migratedTo INTEGER NOT NULL,
        migratedDate TEXT NOT NULL
      )
    ''');

    await db.insert(
      'db_migration_test',
      {
        'id': 1,
        'migratedFrom': oldVersion,
        'migratedTo': 7,
        'migratedDate': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

    // Version 8: Add user profile information.
  if (oldVersion < 8) {
    await _addColumnIfMissing(
      db,
      'body_profile',
      'name',
      'TEXT',
    );

    await _addColumnIfMissing(
      db,
      'body_profile',
      'profileCompleted',
      'INTEGER NOT NULL DEFAULT 0',
    );
  }

  // Version 9: Add measurement type to exercise master.
  if (oldVersion < 9) {
    await _addColumnIfMissing(
      db,
      'exercise_master',
      'measurementType',
      "TEXT NOT NULL DEFAULT 'reps'",
    );
  }

  // Version 10: Add/update required exercises.
  if (oldVersion < 10) {
    await _addColumnIfMissing(
      db,
      'exercise_master',
      'measurementType',
      "TEXT NOT NULL DEFAULT 'reps'",
    );

    await _ensureRequiredExercises(db);
  }
}

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info($table)',
    );

    final exists = columns.any(
      (row) => row['name'] == column,
    );

    if (!exists) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $type',
      );
    }
  }

 Future<void> _ensureRequiredExercises(Database db) async {
    final tiltResult = await db.query(
      'exercise_master',
      columns: ['id'],
      where: 'exercise = ?',
      whereArgs: ['Tilt Seated Calf Raise'],
      limit: 1,
    );

    if (tiltResult.isEmpty) {
      await db.insert(
        'exercise_master',
        {
          'bodyArea': 'Leg',
          'exercise': 'Tilt Seated Calf Raise',
          'setEnabled': 1,
          'weightEnabled': 1,
          'repsEnabled': 1,
          'measurementType': 'reps',
        },
      );
    }

    // Plank is time-based and should be recorded in seconds.
    await db.update(
      'exercise_master',
      {'measurementType': 'duration_sec'},
      where: 'exercise = ?',
      whereArgs: ['Plank'],
    );
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
  exercise: 'Tilt Seated Calf Raise',
  setEnabled: true,
  weightEnabled: true,
  repsEnabled: true,
  measurementType: 'reps',
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
  measurementType: 'duration_sec',
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
      w.distance,
      w.calories,
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

  // ==================== BODY PROFILE ====================

    // SAVE COMPLETE USER PROFILE
  Future<int> saveUserProfile({
    required String name,
    required double height,
    required double weight,
  }) async {
    final db = await instance.database;

    final now = DateTime.now().toIso8601String();

    final existing = await db.query(
      'body_profile',
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert(
        'body_profile',
        {
          'id': 1,
          'name': name,
          'height': height,
          'heightUnit': 'cm',
          'profileCompleted': 1,
          'updatedDate': now,
        },
      );
    } else {
      await db.update(
        'body_profile',
        {
          'name': name,
          'height': height,
          'heightUnit': 'cm',
          'profileCompleted': 1,
          'updatedDate': now,
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }

    // Initial weight is stored in weight history.
    await db.insert(
      'weight_history',
      {
        'weight': weight,
        'recordedDate': now,
      },
    );

    return 1;
  }

  // CHECK WHETHER USER PROFILE IS COMPLETED
  Future<bool> isProfileCompleted() async {
    final profile = await getBodyProfile();

    if (profile == null) {
      return false;
    }

    return profile['profileCompleted'] == 1;
  }

    // GET USER NAME
  Future<String> getUserName() async {
    final profile = await getBodyProfile();

    if (profile == null) {
      return '';
    }

    return profile['name']?.toString() ?? '';
  }

Future<void> updateUserName(String name) async {
  final db = await instance.database;

  await db.update(
    'body_profile',
    {
      'name': name.trim(),
      'updatedDate': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [1],
  );
}

  // SAVE / UPDATE HEIGHT
  Future<int> saveHeight(
    double height, {
    String unit = 'cm',
  }) async {
    final db = await instance.database;

    final existing = await db.query(
      'body_profile',
      limit: 1,
    );

    final data = <String, dynamic>{
      'height': height,
      'heightUnit': unit,
      'updatedDate': DateTime.now().toIso8601String(),
    };

    if (existing.isEmpty) {
      return await db.insert(
        'body_profile',
        {
          'id': 1,
          ...data,
        },
      );
    }

    return await db.update(
      'body_profile',
      data,
      where: 'id = ?',
      whereArgs: [existing.first['id']],
    );
  }

  // GET BODY PROFILE
  Future<Map<String, dynamic>?> getBodyProfile() async {
    final db = await instance.database;

    final result = await db.query(
      'body_profile',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ADD WEIGHT ENTRY
  Future<int> addWeight(
    double weight, {
    DateTime? recordedDate,
  }) async {
    final db = await instance.database;

    return await db.insert(
      'weight_history',
      {
        'weight': weight,
        'recordedDate':
            (recordedDate ?? DateTime.now()).toIso8601String(),
      },
    );
  }

  // GET WEIGHT HISTORY
  Future<List<Map<String, dynamic>>> getWeightHistory() async {
    final db = await instance.database;

    return await db.query(
      'weight_history',
      orderBy: 'recordedDate DESC, id DESC',
    );
  }

  // GET LATEST WEIGHT
  Future<Map<String, dynamic>?> getLatestWeight() async {
    final db = await instance.database;

    final result = await db.query(
      'weight_history',
      orderBy: 'recordedDate DESC, id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // DELETE WEIGHT ENTRY
  Future<int> deleteWeight(int id) async {
    final db = await instance.database;

    return await db.delete(
      'weight_history',
      where: 'id = ?',
      whereArgs: [id],
    );
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
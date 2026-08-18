import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/workout.dart';
import 'add_workout_screen.dart';
import 'workout_history_screen.dart';
import 'body_profile_screen.dart';
import 'muscle_detail_screen.dart';
import 'progress_screen.dart';
import '../widgets/body_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  // 0 = Daily
  // 1 = Weekly
  // 2 = Monthly
  // 3 = Yearly
  int selectedPeriod = 0;
  List<Workout> workouts = [];
  bool isLoading = true;

  double? _heightCm;
double? _currentWeight;
String _userName = '';

  @override
void initState() {
  super.initState();
  loadStats();
  loadBodyMetrics();
}
  Future<void> loadStats() async {
    setState(() {
      isLoading = true;
    });
    final now = DateTime.now();
    late DateTime startDate;
    late DateTime endDate;
    if (selectedPeriod == 0) {
      // DAILY
      startDate = DateTime(
        now.year,
        now.month,
        now.day,
      );
      endDate = startDate.add(
        const Duration(days: 1),
      );
    } else if (selectedPeriod == 1) {
      // WEEKLY
      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );
      // Monday = 1, Sunday = 7
      final daysFromMonday =
          today.weekday - DateTime.monday;
      startDate = today.subtract(
        Duration(days: daysFromMonday),
      );
      endDate = startDate.add(
        const Duration(days: 7),
      );
    } else if (selectedPeriod == 2) {
      // MONTHLY
      startDate = DateTime(
        now.year,
        now.month,
        1,
      );
      endDate = DateTime(
        now.year,
        now.month + 1,
        1,
      );
    } else {
      // YEARLY
      startDate = DateTime(
        now.year,
        1,
        1,
      );
      endDate = DateTime(
        now.year + 1,
        1,
        1,
      );
    }
    final data =
        await DatabaseHelper.instance.getWorkoutStats(
      startDate,
      endDate,
    );
    if (!mounted) return;
    setState(() {
      workouts = data.map((item) {
  return Workout(
    exercise: item['exercise'] as String,
    setNo: (item['setNo'] as num?)?.toInt() ?? 0,
    weight:
        (item['weight'] as num?)?.toDouble() ?? 0,
    reps:
        (item['reps'] as num?)?.toInt() ?? 0,
    workoutDate:
        item['workoutDate'] as String? ?? '',
    duration:
        (item['duration'] as num?)?.toDouble(),
    elevation:
        (item['elevation'] as num?)?.toDouble(),
    distance: (item['distance'] as num?)?.toDouble(),
    calories: (item['calories'] as num?)?.toDouble(),
    bodyArea:
        item['bodyArea'] as String?,
  );
}).toList();
      isLoading = false;
    });
  }

  Future<void> loadBodyMetrics() async {
  final profile =
      await DatabaseHelper.instance.getBodyProfile();

  final latestWeight =
      await DatabaseHelper.instance.getLatestWeight();

  final userName =
    await DatabaseHelper.instance.getUserName();

  if (!mounted) return;

  setState(() {

    _userName = userName;

    if (profile != null && profile['height'] is num) {
      _heightCm =
          (profile['height'] as num).toDouble();
    } else {
      _heightCm = null;
    }

    if (latestWeight != null &&
        latestWeight['weight'] is num) {
      _currentWeight =
          (latestWeight['weight'] as num).toDouble();
    } else {
      _currentWeight = null;
    }
  });
}

double? get bmi {
  if (_heightCm == null ||
      _currentWeight == null ||
      _heightCm! <= 0 ||
      _currentWeight! <= 0) {
    return null;
  }

  final heightInMetres = _heightCm! / 100;

  return _currentWeight! /
      (heightInMetres * heightInMetres);
}

String get bmiLabel {
  final value = bmi;

  if (value == null) {
    return "Set height & weight";
  }

  if (value < 18.5) {
    return "Underweight";
  } else if (value < 25) {
    return "Normal";
  } else if (value < 30) {
    return "Overweight";
  } else {
    return "Obese";
  }
}

  int get exerciseCount {
    return workouts
        .map((workout) => workout.exercise)
        .toSet()
        .length;
  }
  int get totalSets {
    return workouts
        .where((workout) => workout.duration == null)
        .length;
  }
  double get totalVolume {
    double volume = 0;
    for (final workout in workouts) {
      if (workout.duration == null) {
        volume += workout.weight * workout.reps;
      }
    }
    return volume;
  }
  double get totalCardioMinutes {
    double minutes = 0;
    for (final workout in workouts) {
      if (workout.duration != null) {
        minutes += workout.duration!;
      }
    }
    return minutes;
  }
  double get totalCardioDistance {
  return workouts
      .where((w) => w.duration != null)
      .fold(0, (sum, w) => sum + (w.distance ?? 0));
}
double get totalCardioCalories {
  return workouts
      .where((w) => w.duration != null)
      .fold(0, (sum, w) => sum + (w.calories ?? 0));
}
  int get workoutDays {
    final uniqueDates = <String>{};

    for (final workout in workouts) {
      final date = DateTime.tryParse(workout.workoutDate);

      if (date == null) {
        continue;
      }

      uniqueDates.add(
        "${date.year}-${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}",
      );
    }

    return uniqueDates.length;
  }

  int get periodDaysElapsed {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    late DateTime startDate;
    late DateTime endDate;

    if (selectedPeriod == 0) {
      startDate = today;
      endDate = today.add(const Duration(days: 1));
    } else if (selectedPeriod == 1) {
      final daysFromMonday =
          today.weekday - DateTime.monday;

      startDate = today.subtract(
        Duration(days: daysFromMonday),
      );

      endDate = startDate.add(
        const Duration(days: 7),
      );
    } else if (selectedPeriod == 2) {
      startDate = DateTime(
        today.year,
        today.month,
        1,
      );

      endDate = DateTime(
        today.year,
        today.month + 1,
        1,
      );
    } else {
      startDate = DateTime(
        today.year,
        1,
        1,
      );

      endDate = DateTime(
        today.year + 1,
        1,
        1,
      );
    }

    // Do not count future dates in the current period as rest days.
    final tomorrow = today.add(const Duration(days: 1));
    final effectiveEndDate =
        endDate.isAfter(tomorrow) ? tomorrow : endDate;

    return effectiveEndDate.difference(startDate).inDays;
  }

  int get restDays {
    final value = periodDaysElapsed - workoutDays;
    return value < 0 ? 0 : value;
  }

  Map<String, int> get bodyAreaCount {
  final Map<String, int> result = {};
  for (final workout in workouts) {
    final bodyArea = workout.bodyArea;
    if (bodyArea == null || bodyArea.isEmpty) {
      continue;
    }
    result[bodyArea] = (result[bodyArea] ?? 0) + 1;
  }
  return result;
}
  String get periodTitle {
    switch (selectedPeriod) {
      case 0:
        return "Today's Summary";
      case 1:
        return "This Week";
      case 2:
        return "This Month";
      case 3:
        return "This Year";
      default:
        return "Summary";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        title: Text(
  _userName.isEmpty
      ? 'Welcome'
      : 'Welcome $_userName',
),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadStats();
          await loadBodyMetrics();
        },
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    // ==================================
// PERIOD TABS
// ==================================
SizedBox(
  width: double.infinity,
  height: 48,
  child: SegmentedButton<int>(
    style: ButtonStyle(
      visualDensity: VisualDensity.compact,
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 6),
      ),
      minimumSize: WidgetStateProperty.all(
        const Size(0, 48),
      ),
      maximumSize: WidgetStateProperty.all(
        const Size(double.infinity, 48),
      ),
    ),
   segments: const [
  ButtonSegment<int>(
    value: 0,
    label: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        "Daily",
        maxLines: 1,
        softWrap: false,
      ),
    ),
  ),
  ButtonSegment<int>(
    value: 1,
    label: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        "Weekly",
        maxLines: 1,
        softWrap: false,
      ),
    ),
  ),
  ButtonSegment<int>(
    value: 2,
    label: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        "Monthly",
        maxLines: 1,
        softWrap: false,
      ),
    ),
  ),
  ButtonSegment<int>(
    value: 3,
    label: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        "Yearly",
        maxLines: 1,
        softWrap: false,
      ),
    ),
  ),
],
    selected: {
      selectedPeriod,
    },
    onSelectionChanged: (Set<int> value) {
      setState(() {
        selectedPeriod = value.first;
      });
      loadStats();
    },
  ),
),
                    const SizedBox(height: 25),
                    // ==================================
                    // SUMMARY
                    // ==================================
                    Text(
                      periodTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // ==================================
// STAT CARDS
// ==================================
Row(
  children: [
    Expanded(
      child: buildStatCard(
        Icons.fitness_center,
        "Exercises",
        "$exerciseCount",
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: buildStatCard(
        Icons.monitor_heart,
        "BMI",
        bmi == null
            ? "--"
            : bmi!.toStringAsFixed(1),
      ),
    ),
  ],
),

const SizedBox(height: 10),

Row(
  children: [
    Expanded(
      child: buildStatCard(
        Icons.repeat,
        "Sets",
        "$totalSets",
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: buildStatCard(
        Icons.timer,
        "Cardio",
        "${totalCardioMinutes.toStringAsFixed(0)} min",
      ),
    ),
  ],
),

const SizedBox(height: 10),

Row(
  children: [
    Expanded(
      child: buildStatCard(
        Icons.event_available,
        "Workout Days",
        "$workoutDays",
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: buildStatCard(
        Icons.event_busy,
        "Rest Days",
        "$restDays",
      ),
    ),
  ],
),

                    const SizedBox(height: 30),
// ==================================
// BODY MAP
// ==================================
BodyMap(
  muscleActivity: bodyAreaCount,
  workouts: workouts,
),
const SizedBox(height: 25),
                    
                    // ==================================
                    // BODY AREA SUMMARY
                    // ==================================
                    const Text(
                      "Muscle Groups",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (bodyAreaCount.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              "No workouts recorded for this period",
                            ),
                          ),
                        ),
                      )
                    else
                      ...bodyAreaCount.entries.map(
                        (entry) {
                          return Card(
                            margin:
                                const EdgeInsets.only(
                              bottom: 8,
                            ),
                            child: ListTile(
  leading: const Icon(
    Icons.accessibility_new,
  ),
  title: Text(
    entry.key,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "${entry.value}",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 8),
      const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
    ],
  ),
  subtitle: const Text(
    "Tap to view details",
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MuscleDetailScreen(
          bodyArea: entry.key,
          workouts: workouts,
        ),
      ),
    );
  },
),
                          );
                        },
                      ),
                    const SizedBox(height: 25),
                    // ==================================
                    // WORKOUT COUNT
                    // ==================================
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.history,
                        ),
                        title: Text(
                          "${workouts.length} workout record(s)",
                        ),
                        subtitle: const Text(
                          "Data loaded from SQLite",
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WorkoutHistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
  Widget buildStatCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
  accountName: Text(
    _userName.isEmpty
        ? 'Gym User'
        : _userName,
    style: const TextStyle(
      fontSize: 20,
    ),
  ),
            accountEmail: Text(
              "Gym Tracker",
            ),
            currentAccountPicture:
                CircleAvatar(
              child: Icon(
                Icons.person,
                size: 40,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
            ),
            title: const Text(
              "Dashboard",
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add_circle,
            ),
            title: const Text(
              "Add Workout",
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AddWorkoutScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.history,
            ),
            title: const Text(
              "Workout History",
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const WorkoutHistoryScreen(),
                ),
              );
            },
          ),

          ListTile(
  leading: const Icon(
    Icons.person_outline,
  ),
  title: const Text(
    "Body Profile",
  ),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const BodyProfileScreen(),
      ),
    );
  },
),
          ListTile(
            leading: const Icon(
              Icons.bar_chart,
            ),
            title: const Text(
              "Progress",
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProgressScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.settings,
            ),
            title: const Text(
              "Settings",
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
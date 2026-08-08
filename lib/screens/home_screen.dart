import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../models/workout.dart';
import 'add_workout_screen.dart';
import 'workout_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    final data = await DatabaseHelper.instance.getAllWorkouts();

    if (!mounted) return;

    setState(() {
      workouts = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text(
                "Devendra",
                style: TextStyle(fontSize: 20),
              ),
              accountEmail: Text("Gym Tracker"),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text("Add Workout"),
              onTap: () async {
                Navigator.pop(context);

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddWorkoutScreen(),
                  ),
                );

                // Reload workouts after returning
                loadWorkouts();
              },
            ),

            ListTile(
  leading: const Icon(Icons.history),
  title: const Text("Workout History"),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutHistoryScreen(),
      ),
    );
  },
),

            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Progress"),
              onTap: () {},
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text("Welcome Devendra"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            const Text(
              "Today's Workout",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(
                  workouts.isEmpty
                      ? "No workout added today"
                      : "${workouts.length} workout(s) recorded",
                ),
                subtitle: const Text("Your workout data is saved in SQLite"),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Recent Workouts",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: workouts.isEmpty
                  ? const Center(
                      child: Text(
                        "No workouts found",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];

                        return Card(
                          child: ListTile(

                            leading: Icon(
                  workout.duration != null
                      ? Icons.directions_run
                      : Icons.fitness_center,
                ),

                            title: Text(
                              workout.exercise,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                           subtitle: Text(
  workout.duration != null
      ? "${workout.duration} min • "
        "Elevation ${workout.elevation}"
      : "Set ${workout.setNo} • "
        "${workout.weight} Kg • "
        "${workout.reps} reps",
),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
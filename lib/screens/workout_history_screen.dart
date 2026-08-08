import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../models/workout.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState
    extends State<WorkoutHistoryScreen> {
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    final data =
        await DatabaseHelper.instance.getAllWorkouts();

    if (!mounted) return;

    setState(() {
      workouts = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History"),
        centerTitle: true,
      ),

      body: workouts.isEmpty
          ? const Center(
              child: Text(
                "No workout history found",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];

                final isCardio =
                    workout.duration != null;

                return Card(
                  margin:
                      const EdgeInsets.only(bottom: 10),

                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        isCardio
                            ? Icons.directions_run
                            : Icons.fitness_center,
                      ),
                    ),

                    title: Text(
                      workout.exercise,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Text(
                      isCardio
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
    );
  }
}
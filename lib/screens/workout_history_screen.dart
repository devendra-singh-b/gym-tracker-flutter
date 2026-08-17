import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../models/workout.dart';
import 'edit_workout_screen.dart';

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

  String _formatWorkoutDate(String date) {
    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) {
      return date;
    }

    return "${parsedDate.day.toString().padLeft(2, '0')}-"
        "${parsedDate.month.toString().padLeft(2, '0')}-"
        "${parsedDate.year}";
  }

  bool canEditWorkout(Workout workout) {
    final workoutDate =
        DateTime.tryParse(workout.workoutDate);

    if (workoutDate == null) {
      return false;
    }

    final difference =
        DateTime.now().difference(workoutDate);

    return difference.inHours <= 72;
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

                final isPlank =
    workout.exercise == 'Plank';

final isCardio =
    workout.duration != null && !isPlank;

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
  "${_formatWorkoutDate(workout.workoutDate)}\n"
  "${isCardio
      ? "${workout.duration} min • "
        "${workout.distance} km • "
        "${workout.calories} kcal • "
        "Elevation ${workout.elevation}"
      : isPlank
          ? "Set ${workout.setNo} • "
            "${workout.duration?.toStringAsFixed(0)} sec"
          : "Set ${workout.setNo} • "
            "${workout.weight} Kg • "
            "${workout.reps} reps"}",
),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canEditWorkout(workout))
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                            tooltip: "Edit workout",
                            onPressed: () async {
                              final updated =
                                  await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditWorkoutScreen(
                                    workout: workout,
                                  ),
                                ),
                              );

                              if (updated == true) {
                                loadWorkouts();
                              }
                            },
                          ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: "Delete workout",
                          onPressed: () async {
                            final confirm =
                                await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    "Delete Workout?",
                                  ),
                                  content: Text(
                                    "Delete ${workout.exercise}, "
                                    "Set ${workout.setNo}?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          false,
                                        );
                                      },
                                      child:
                                          const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          true,
                                        );
                                      },
                                      child: const Text(
                                        "DELETE",
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              await DatabaseHelper.instance
                                  .deleteWorkout(
                                workout.id!,
                              );

                              await loadWorkouts();

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Workout deleted"),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
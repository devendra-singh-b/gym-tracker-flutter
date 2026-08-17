import 'package:flutter/material.dart';

import '../models/workout.dart';

class MuscleDetailScreen extends StatelessWidget {
  final String bodyArea;
  final List<Workout> workouts;

  const MuscleDetailScreen({
    super.key,
    required this.bodyArea,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final areaWorkouts = workouts
        .where(
          (workout) => workout.bodyArea == bodyArea,
        )
        .toList();

    final exerciseNames = areaWorkouts
        .map((workout) => workout.exercise)
        .toSet()
        .toList();

    // Plank is duration-based but it is NOT cardio.
    // Cardio exercises use duration in minutes.
    final totalSets = areaWorkouts
        .where(
          (workout) =>
              workout.duration == null ||
              workout.exercise == 'Plank',
        )
        .length;

    double totalVolume = 0;

    for (final workout in areaWorkouts) {
      // Plank has no weight-based volume.
      if (workout.duration == null &&
          workout.exercise != 'Plank') {
        totalVolume +=
            workout.weight * workout.reps;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(bodyArea),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================
            // SUMMARY
            // ==================================

            Row(
              children: [
                Expanded(
                  child: buildSummaryCard(
                    "Exercises",
                    "${exerciseNames.length}",
                    Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: buildSummaryCard(
                    "Sets",
                    "$totalSets",
                    Icons.repeat,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: buildSummaryCard(
                    "Volume",
                    "${totalVolume.toStringAsFixed(0)} Kg",
                    Icons.monitor_weight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ==================================
            // EXERCISES
            // ==================================

            Text(
              "$bodyArea Exercises",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (areaWorkouts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "No workouts found",
                    ),
                  ),
                ),
              )
            else
              ...exerciseNames.map(
                (exerciseName) {
                  final exerciseWorkouts =
                      areaWorkouts
                          .where(
                            (workout) =>
                                workout.exercise ==
                                exerciseName,
                          )
                          .toList();

                  // Plank uses duration in seconds,
                  // but it is not a cardio exercise.
                  final isPlank =
                      exerciseName == 'Plank';

                  final isCardio =
                      exerciseWorkouts.first.duration !=
                              null &&
                          !isPlank;

                  if (isCardio) {
                    final totalMinutes =
                        exerciseWorkouts.fold<double>(
                      0,
                      (sum, workout) =>
                          sum +
                          (workout.duration ?? 0),
                    );

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.directions_run,
                        ),
                        title: Text(
                          exerciseName,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${totalMinutes.toStringAsFixed(0)} min cardio",
                        ),
                      ),
                    );
                  }

                  if (isPlank) {
                    final totalSeconds =
                        exerciseWorkouts.fold<double>(
                      0,
                      (sum, workout) =>
                          sum +
                          (workout.duration ?? 0),
                    );

                    final sets =
                        exerciseWorkouts.length;

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.fitness_center,
                        ),
                        title: Text(
                          exerciseName,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "$sets Sets • "
                          "${totalSeconds.toStringAsFixed(0)} sec",
                        ),
                      ),
                    );
                  }

                  final sets =
                      exerciseWorkouts.length;

                  double volume = 0;

                  for (final workout
                      in exerciseWorkouts) {
                    volume +=
                        workout.weight *
                            workout.reps;
                  }

                  return Card(
                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      leading:
                          const Icon(
                        Icons.fitness_center,
                      ),
                      title: Text(
                        exerciseName,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "$sets Sets • "
                        "${volume.toStringAsFixed(0)} Kg Volume",
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

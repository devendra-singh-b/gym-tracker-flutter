import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  // Exercise list from database
  List<Exercise> exercises = [];

  // Selected exercise
  Exercise? selectedExercise;

  // Multiple set controllers
  final List<TextEditingController> weightControllers = [];
  final List<TextEditingController> repsControllers = [];

  // Cardio controllers
  final TextEditingController durationController =
      TextEditingController();

  final TextEditingController elevationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    loadExercises();

    // Start with Set 1
    addSet();
  }

  Future<void> loadExercises() async {
    final data = await DatabaseHelper.instance.getAllExercises();

    if (!mounted) return;

    setState(() {
      exercises = data;
    });
  }

  void addSet() {
    if (weightControllers.length >= 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 7 sets allowed"),
        ),
      );
      return;
    }

    setState(() {
      weightControllers.add(
        TextEditingController(),
      );

      repsControllers.add(
        TextEditingController(),
      );
    });
  }

  void removeAllSets() {
    for (final controller in weightControllers) {
      controller.dispose();
    }

    for (final controller in repsControllers) {
      controller.dispose();
    }

    weightControllers.clear();
    repsControllers.clear();

    addSet();
  }

  @override
  void dispose() {
    for (final controller in weightControllers) {
      controller.dispose();
    }

    for (final controller in repsControllers) {
      controller.dispose();
    }

    durationController.dispose();
    elevationController.dispose();

    super.dispose();
  }

void showMessage(String message) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}


  Future<void> saveWorkout() async {
    if (selectedExercise == null) {
      showMessage("Please select an exercise");
      return;
    }

    final isCardio =
        selectedExercise!.bodyArea == 'Cardio';

    // ==========================================
    // CARDIO
    // ==========================================

    if (isCardio) {
      if (durationController.text.isEmpty) {
        showMessage("Please enter time");
        return;
      }

      if (elevationController.text.isEmpty) {
        showMessage("Please enter elevation");
        return;
      }

      final workout = Workout(
        exercise: selectedExercise!.exercise,
        setNo: 0,
        weight: 0,
        reps: 0,
        workoutDate:
            DateTime.now().toIso8601String(),
        duration:
            double.parse(durationController.text),
        elevation:
            double.parse(elevationController.text),
      );

      await DatabaseHelper.instance
          .insertWorkout(workout);
    }

    // ==========================================
    // NORMAL EXERCISE
    // ==========================================

    else {
      for (int i = 0;
          i < weightControllers.length;
          i++) {
        final setNumber = i + 1;

        final weightText =
            weightControllers[i].text.trim();

        final repsText =
            repsControllers[i].text.trim();

        // Weight validation
        if (selectedExercise!.weightEnabled &&
            weightText.isEmpty) {
          showMessage("Please enter weight for Set $setNumber");
          return;
        }

        // Reps validation
        if (selectedExercise!.repsEnabled &&
            repsText.isEmpty) {
          showMessage("Please enter reps for Set $setNumber");
          return;
        }

        final workout = Workout(
          exercise: selectedExercise!.exercise,

          setNo: setNumber,

          weight: selectedExercise!.weightEnabled
              ? double.parse(weightText)
              : 0,

          reps: selectedExercise!.repsEnabled
              ? int.parse(repsText)
              : 0,

          workoutDate:
              DateTime.now().toIso8601String(),

          duration: null,
          elevation: null,
        );

        await DatabaseHelper.instance
            .insertWorkout(workout);
      }
    }

    if (!mounted) return;

    showMessage("Workout saved successfully!");

    // Reset screen
    setState(() {
      selectedExercise = null;
    });

    durationController.clear();
    elevationController.clear();

    removeAllSets();
  }

  @override
  Widget build(BuildContext context) {
    final isCardio =
        selectedExercise?.bodyArea == 'Cardio';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==========================================
              // EXERCISE
              // ==========================================

              DropdownButtonFormField<Exercise>(
                initialValue: selectedExercise,

                decoration: const InputDecoration(
                  labelText: "Exercise",
                  border: OutlineInputBorder(),
                ),

                items: exercises.map((exercise) {
                  return DropdownMenuItem<Exercise>(
                    value: exercise,
                    child: Text(exercise.exercise),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedExercise = value;

                    durationController.clear();
                    elevationController.clear();

                    for (final controller
                        in weightControllers) {
                      controller.clear();
                    }

                    for (final controller
                        in repsControllers) {
                      controller.clear();
                    }
                  });
                },
              ),

              const SizedBox(height: 20),

              // ==========================================
              // CARDIO
              // ==========================================

              if (isCardio) ...[
                TextField(
                  controller: durationController,

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: const InputDecoration(
                    labelText: "Time (Minutes)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: elevationController,

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: const InputDecoration(
                    labelText: "Elevation",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              // ==========================================
              // NORMAL EXERCISE
              // ==========================================

              if (!isCardio) ...[
                for (int i = 0;
                    i < weightControllers.length;
                    i++) ...[
                  Row(
                    children: [
                      // SET NUMBER
                      SizedBox(
                        width: 60,

                        child: Text(
                          "Set ${i + 1}",
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // WEIGHT
                      if (selectedExercise
                              ?.weightEnabled ==
                          true)
                        Expanded(
                          child: TextField(
                            controller:
                                weightControllers[i],

                            keyboardType:
                                const TextInputType
                                    .numberWithOptions(
                              decimal: true,
                            ),

                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Weight (Kg)",
                              border:
                                  OutlineInputBorder(),
                            ),
                          ),
                        ),

                      if (selectedExercise
                              ?.weightEnabled ==
                          true)
                        const SizedBox(width: 10),

                      // REPS
                      if (selectedExercise
                              ?.repsEnabled ==
                          true)
                        Expanded(
                          child: TextField(
                            controller:
                                repsControllers[i],

                            keyboardType:
                                TextInputType.number,

                            decoration:
                                const InputDecoration(
                              labelText: "Reps",
                              border:
                                  OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 15),
                ],

                // ADD SET BUTTON
                OutlinedButton.icon(
                  onPressed:
                      weightControllers.length < 7
                          ? addSet
                          : null,

                  icon: const Icon(
                    Icons.add,
                  ),

                  label: Text(
                    weightControllers.length < 7
                        ? "Add Set"
                        : "Maximum 7 Sets",
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // ==========================================
              // SAVE
              // ==========================================

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: saveWorkout,

                  child: const Text(
                    "SAVE WORKOUT",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
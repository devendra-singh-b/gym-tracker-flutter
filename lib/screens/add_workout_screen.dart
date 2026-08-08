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
  // Controllers
  final TextEditingController setController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController elevationController = TextEditingController();

  // Exercise list from database
  List<Exercise> exercises = [];

  // Selected exercise
  Exercise? selectedExercise;

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> loadExercises() async {
    final data = await DatabaseHelper.instance.getAllExercises();

    if (!mounted) return;

    setState(() {
      exercises = data;
    });
  }

  @override
  void dispose() {
    setController.dispose();
    weightController.dispose();
    repsController.dispose();
    durationController.dispose();
    elevationController.dispose();

    super.dispose();
  }

  Future<void> saveWorkout() async {
    if (selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an exercise"),
        ),
      );
      return;
    }

    final isCardio = selectedExercise!.bodyArea == 'Cardio';

    // -----------------------------
    // CARDIO VALIDATION
    // -----------------------------
    if (isCardio) {
      if (durationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter time"),
          ),
        );
        return;
      }

      if (elevationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter elevation"),
          ),
        );
        return;
      }
    }

    // -----------------------------
    // NORMAL EXERCISE VALIDATION
    // -----------------------------
    if (!isCardio) {
      if (selectedExercise!.setEnabled &&
          setController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select set number"),
          ),
        );
        return;
      }

      if (selectedExercise!.weightEnabled &&
          weightController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter weight"),
          ),
        );
        return;
      }

      if (selectedExercise!.repsEnabled &&
          repsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter reps"),
          ),
        );
        return;
      }
    }

    // -----------------------------
    // CREATE WORKOUT OBJECT
    // -----------------------------
    final workout = Workout(
      exercise: selectedExercise!.exercise,

      // For cardio these values are not applicable,
      // so we store 0.
      setNo: isCardio
          ? 0
          : int.parse(setController.text),

      weight: isCardio
          ? 0
          : double.parse(weightController.text),

      reps: isCardio
          ? 0
          : int.parse(repsController.text),

      workoutDate: DateTime.now().toIso8601String(),

      duration: isCardio
          ? double.parse(durationController.text)
          : null,

      elevation: isCardio
          ? double.parse(elevationController.text)
          : null,
    );

    // Save to SQLite
    await DatabaseHelper.instance.insertWorkout(workout);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Workout saved successfully!"),
      ),
    );

    // Clear everything
    setState(() {
      selectedExercise = null;
    });

    setController.clear();
    weightController.clear();
    repsController.clear();
    durationController.clear();
    elevationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isCardio = selectedExercise?.bodyArea == 'Cardio';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

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

                  // Clear old values
                  setController.clear();
                  weightController.clear();
                  repsController.clear();
                  durationController.clear();
                  elevationController.clear();
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
              // SET
              if (selectedExercise?.setEnabled == true)
                DropdownButtonFormField<int>(
                  initialValue: setController.text.isEmpty
                      ? null
                      : int.tryParse(setController.text),

                  decoration: const InputDecoration(
                    labelText: "Set",
                    border: OutlineInputBorder(),
                  ),

                  items: List.generate(7, (index) {
                    final setNumber = index + 1;

                    return DropdownMenuItem<int>(
                      value: setNumber,
                      child: Text("Set $setNumber"),
                    );
                  }),

                  onChanged: (value) {
                    if (value != null) {
                      setController.text = value.toString();

                      setState(() {});
                    }
                  },
                ),

              if (selectedExercise?.setEnabled == true)
                const SizedBox(height: 20),

              // WEIGHT
              if (selectedExercise?.weightEnabled == true)
                TextField(
                  controller: weightController,

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: const InputDecoration(
                    labelText: "Weight (Kg)",
                    border: OutlineInputBorder(),
                  ),
                ),

              if (selectedExercise?.weightEnabled == true)
                const SizedBox(height: 20),

              // REPS
              if (selectedExercise?.repsEnabled == true)
                TextField(
                  controller: repsController,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(
                    labelText: "Reps",
                    border: OutlineInputBorder(),
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

                child: const Text("SAVE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
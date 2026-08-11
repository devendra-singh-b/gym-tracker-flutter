import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../models/workout.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const EditWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<EditWorkoutScreen> createState() =>
      _EditWorkoutScreenState();
}

class _EditWorkoutScreenState
    extends State<EditWorkoutScreen> {
  late TextEditingController weightController;
  late TextEditingController repsController;
  late TextEditingController durationController;
  late TextEditingController elevationController;
  late TextEditingController distanceController;
  late TextEditingController caloriesController;

  String selectedWeightUnit = 'Kg';

  @override
  void initState() {
    super.initState();

    weightController = TextEditingController(
      text: widget.workout.weight.toString(),
    );

    repsController = TextEditingController(
      text: widget.workout.reps.toString(),
    );

    durationController = TextEditingController(
      text: widget.workout.duration?.toString() ?? '',
    );

    elevationController = TextEditingController(
      text: widget.workout.elevation?.toString() ?? '',
    );

    distanceController = TextEditingController(
      text: widget.workout.distance?.toString() ?? '',
    );

    caloriesController = TextEditingController(
      text: widget.workout.calories?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    durationController.dispose();
    elevationController.dispose();
    distanceController.dispose();
    caloriesController.dispose();

    super.dispose();
  }

  bool get isCardio =>
      widget.workout.duration != null;

  Future<void> saveChanges() async {
    if (isCardio) {
      if (durationController.text.trim().isEmpty) {
        showMessage("Please enter time");
        return;
      }

      if (elevationController.text.trim().isEmpty) {
        showMessage("Please enter elevation");
        return;
      }

      if (distanceController.text.trim().isEmpty) {
        showMessage("Please enter distance");
        return;
      }

      if (caloriesController.text.trim().isEmpty) {
        showMessage("Please enter calories burned");
        return;
      }

      final updatedWorkout = Workout(
        id: widget.workout.id,
        exercise: widget.workout.exercise,
        setNo: widget.workout.setNo,
        weight: 0,
        reps: 0,
        workoutDate: widget.workout.workoutDate,
        duration: double.tryParse(
          durationController.text.trim(),
        ),
        elevation: double.tryParse(
          elevationController.text.trim(),
        ),
        distance: double.tryParse(
          distanceController.text.trim(),
        ),
        calories: double.tryParse(
          caloriesController.text.trim(),
        ),
        bodyArea: widget.workout.bodyArea,
      );

      if (updatedWorkout.duration == null ||
          updatedWorkout.elevation == null ||
          updatedWorkout.distance == null ||
          updatedWorkout.calories == null) {
        showMessage("Please enter valid values");
        return;
      }

      await DatabaseHelper.instance
          .updateWorkout(updatedWorkout);
    } else {
      if (weightController.text.trim().isEmpty) {
        showMessage("Please enter weight");
        return;
      }

      if (repsController.text.trim().isEmpty) {
        showMessage("Please enter reps");
        return;
      }

      double? weight = double.tryParse(
        weightController.text.trim(),
      );

      final reps = int.tryParse(
        repsController.text.trim(),
      );

      if (weight == null || reps == null) {
        showMessage(
          "Please enter valid weight and reps",
        );
        return;
      }

      // Database always stores weight in KG.
      if (selectedWeightUnit == 'Lb') {
        weight = weight * 0.45359237;
        weight = double.parse(
          weight.toStringAsFixed(2),
        );
      }

      final updatedWorkout = Workout(
        id: widget.workout.id,
        exercise: widget.workout.exercise,
        setNo: widget.workout.setNo,
        weight: weight,
        reps: reps,
        workoutDate: widget.workout.workoutDate,
        duration: widget.workout.duration,
        elevation: widget.workout.elevation,
        distance: widget.workout.distance,
        calories: widget.workout.calories,
        bodyArea: widget.workout.bodyArea,
      );

      await DatabaseHelper.instance
          .updateWorkout(updatedWorkout);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Workout updated successfully!",
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Workout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ---------------------------------------
            // EXERCISE
            // ---------------------------------------

            Text(
              widget.workout.exercise,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Set ${widget.workout.setNo}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // ---------------------------------------
            // NORMAL WORKOUT
            // ---------------------------------------

            if (!isCardio) ...[
              Row(
                children: [
                  const Text(
                    "Weight Unit:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: selectedWeightUnit,
                    items: const [
                      DropdownMenuItem(
                        value: 'Kg',
                        child: Text('Kg'),
                      ),
                      DropdownMenuItem(
                        value: 'Lb',
                        child: Text('Lb'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null ||
                          value == selectedWeightUnit) {
                        return;
                      }

                      final currentWeight =
                          double.tryParse(
                        weightController.text.trim(),
                      );

                      if (currentWeight != null) {
                        double convertedWeight;

                        if (selectedWeightUnit == 'Kg' &&
                            value == 'Lb') {
                          convertedWeight =
                              currentWeight * 2.2046226218;
                        } else if (selectedWeightUnit == 'Lb' &&
                            value == 'Kg') {
                          convertedWeight =
                              currentWeight * 0.45359237;
                        } else {
                          convertedWeight = currentWeight;
                        }

                        weightController.text =
                            convertedWeight.toStringAsFixed(2);
                      }

                      setState(() {
                        selectedWeightUnit = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 15),

              TextField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText:
                      "Weight ($selectedWeightUnit)",
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Reps",
                  border: OutlineInputBorder(),
                ),
              ),
            ]

            // ---------------------------------------
            // CARDIO
            // ---------------------------------------

            else ...[
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

              const SizedBox(height: 20),

              TextField(
                controller: distanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Distance (Km)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: caloriesController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Calories Burned (kcal)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 35),

            // ---------------------------------------
            // SAVE
            // ---------------------------------------

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveChanges,
                icon: const Icon(Icons.save),
                label: const Text(
                  "SAVE CHANGES",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

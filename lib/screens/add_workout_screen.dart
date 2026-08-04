import 'package:flutter/material.dart';

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

  // Selected Exercise
  String? selectedExercise;

  @override
  void dispose() {
    setController.dispose();
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedExercise,
              decoration: const InputDecoration(
                labelText: "Exercise",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Bench Press",
                  child: Text("Bench Press"),
                ),
                DropdownMenuItem(
                  value: "Incline Press",
                  child: Text("Incline Press"),
                ),
                DropdownMenuItem(
                  value: "Shoulder Press",
                  child: Text("Shoulder Press"),
                ),
                DropdownMenuItem(
                  value: "Squat",
                  child: Text("Squat"),
                ),
                DropdownMenuItem(
                  value: "Deadlift",
                  child: Text("Deadlift"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedExercise = value;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: setController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Set",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (Kg)",
                border: OutlineInputBorder(),
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

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Workout Saved (Demo)"),
                    ),
                  );
                },
                child: const Text("SAVE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
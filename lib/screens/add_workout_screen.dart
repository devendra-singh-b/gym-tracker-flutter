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

  String selectedWeightUnit = 'Kg';

  // Multiple set controllers
  final List<TextEditingController> weightControllers = [];
  final List<TextEditingController> repsControllers = [];

  // Cardio controllers
  final TextEditingController durationController =
      TextEditingController();

  final TextEditingController elevationController =
      TextEditingController();

  final TextEditingController distanceController =
    TextEditingController();

  final TextEditingController caloriesController =
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

  Future<void> _showExercisePicker() async {
  String searchText = '';
  String selectedArea = 'All';

  final bodyAreas = <String>[
    'All',
    'Chest',
    'Back',
    'Shoulder',
    'Leg',
    'Bicep',
    'Tricep',
    'Core',
    'Cardio',
  ];

  final result = await showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final filteredExercises = exercises.where((exercise) {
            final matchesArea =
                selectedArea == 'All' ||
                exercise.bodyArea == selectedArea;

            final matchesSearch = searchText.isEmpty ||
                exercise.exercise
                    .toLowerCase()
                    .contains(searchText.toLowerCase());

            return matchesArea && matchesSearch;
          }).toList();

          final groupedExercises =
              <String, List<Exercise>>{};

          for (final exercise in filteredExercises) {
            groupedExercises
                .putIfAbsent(exercise.bodyArea, () => [])
                .add(exercise);
          }

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      8,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Select Exercise',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Search exercise...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          searchText = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Body area filter
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: bodyAreas.length,
                      itemBuilder: (context, index) {
                        final area = bodyAreas[index];
                        final isSelected =
                            selectedArea == area;

                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: ChoiceChip(
                            label: Text(area),
                            selected: isSelected,
                            onSelected: (_) {
                              setSheetState(() {
                                selectedArea = area;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Exercise list
                  Expanded(
                    child: filteredExercises.isEmpty
                        ? const Center(
                            child: Text(
                              'No exercises found',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            children: groupedExercises.entries
                                .map((entry) {
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      top: 12,
                                      bottom: 6,
                                    ),
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  ...entry.value.map(
                                    (exercise) {
                                      return ListTile(
                                        contentPadding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 8,
                                        ),
                                        title: Text(
                                          exercise.exercise,
                                        ),
                                        trailing:
                                            selectedExercise ==
                                                    exercise
                                                ? const Icon(
                                                    Icons.check,
                                                  )
                                                : null,
                                        onTap: () {
                                          Navigator.pop(
                                            sheetContext,
                                            exercise,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (result == null || !mounted) return;

  setState(() {
    selectedExercise = result;
    selectedWeightUnit = 'Kg';
    durationController.clear();
    elevationController.clear();
    distanceController.clear();
    caloriesController.clear();

    for (final controller in weightControllers) {
      controller.clear();
    }

    for (final controller in repsControllers) {
      controller.clear();
    }
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

void removeSet(int index) {
  if (weightControllers.length <= 1) {
    showMessage("At least one set is required");
    return;
  }

  weightControllers[index].dispose();
  repsControllers[index].dispose();

  setState(() {
    weightControllers.removeAt(index);
    repsControllers.removeAt(index);
  });
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
    distanceController.dispose();
    caloriesController.dispose();

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
      if (distanceController.text.isEmpty) {
        showMessage("Please enter distance");
        return;
      }

      if (caloriesController.text.isEmpty) {
        showMessage("Please enter calories burned");
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
        distance:
            double.parse(distanceController.text),
        calories:
            double.parse(caloriesController.text),
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

        // Convert weight to KG before saving.
        double weight = selectedExercise!.weightEnabled
            ? double.parse(weightText)
            : 0;

        if (selectedWeightUnit == 'Lb') {
          weight = weight * 0.45359237;
          weight = double.parse(weight.toStringAsFixed(2));
        }

        final workout = Workout(
          exercise: selectedExercise!.exercise,

          setNo: setNumber,

          weight: weight,

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
      selectedWeightUnit = 'Kg';
    });

    durationController.clear();
    elevationController.clear();
    distanceController.clear();
    caloriesController.clear();

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

             InkWell(
  onTap: _showExercisePicker,
  borderRadius: BorderRadius.circular(4),
  child: InputDecorator(
    decoration: const InputDecoration(
      labelText: "Exercise",
      border: OutlineInputBorder(),
      suffixIcon: Icon(Icons.arrow_drop_down),
    ),
    child: Text(
      selectedExercise?.exercise ?? "Select Exercise",
      style: TextStyle(
        color: selectedExercise == null
            ? Colors.grey[600]
            : null,
        fontSize: 16,
      ),
    ),
  ),
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
  controller: distanceController,
  keyboardType: const TextInputType.numberWithOptions(
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
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,
  ),
  decoration: const InputDecoration(
    labelText: "Calories Burned (kcal)",
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
                    labelText: "Elevation/Level",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              // ==========================================
              // NORMAL EXERCISE
              // ==========================================

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
        if (value == null) return;

        setState(() {
          selectedWeightUnit = value;
        });
      },
    ),
  ],
),

const SizedBox(height: 15),

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

                            decoration: InputDecoration(
  labelText: "Weight ($selectedWeightUnit)",
  border: const OutlineInputBorder(),
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
                        
                        const SizedBox(width: 4),

IconButton(
  icon: const Icon(
    Icons.delete_outline,
    color: Colors.red,
  ),
  tooltip: "Remove Set",
  onPressed: weightControllers.length > 1
      ? () => removeSet(i)
      : null,
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
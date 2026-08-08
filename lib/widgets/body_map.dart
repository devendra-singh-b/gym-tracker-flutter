import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../screens/muscle_detail_screen.dart';
import 'dart:math' as math;

class BodyMap extends StatefulWidget {
  final Map<String, int> muscleActivity;
  final List<Workout> workouts;

  const BodyMap({
    super.key,
    required this.muscleActivity,
    required this.workouts,
  });

  @override
  State<BodyMap> createState() => _BodyMapState();
}

class _BodyMapState extends State<BodyMap> {
  bool showFront = true;

  String? selectedMuscle;

  List<Workout> get selectedWorkouts {
    if (selectedMuscle == null) {
      return [];
    }

    return widget.workouts
        .where(
          (workout) =>
              workout.bodyArea == selectedMuscle,
        )
        .toList();
  }

  int get selectedExerciseCount {
    return selectedWorkouts
        .map((workout) => workout.exercise)
        .toSet()
        .length;
  }

  int get selectedSetCount {
    return selectedWorkouts
        .where(
          (workout) => workout.duration == null,
        )
        .length;
  }

  double get selectedVolume {
    double volume = 0;

    for (final workout in selectedWorkouts) {
      if (workout.duration == null) {
        volume += workout.weight * workout.reps;
      }
    }

    return volume;
  }

  void selectMuscle(String muscle) {
    if (!widget.muscleActivity.containsKey(muscle)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No $muscle workout in this period",
          ),
        ),
      );

      return;
    }

    setState(() {
      selectedMuscle = muscle;
    });
  }

  void openMuscleDetails() {
    if (selectedMuscle == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuscleDetailScreen(
          bodyArea: selectedMuscle!,
          workouts: selectedWorkouts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [
            const Text(
              "Muscle Activity",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text("FRONT"),
                  icon: Icon(Icons.person),
                ),

                ButtonSegment<bool>(
                  value: false,
                  label: Text("BACK"),
                  icon: Icon(
                    Icons.accessibility_new,
                  ),
                ),
              ],

              selected: {showFront},

              onSelectionChanged: (value) {
                setState(() {
                  showFront = value.first;
                  selectedMuscle = null;
                });
              },
            ),

            const SizedBox(height: 15),

            SizedBox(
  width: double.infinity,
  height: 500,

  child: Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          showFront
              ? 'assets/images/muscle_front.png'
              : 'assets/images/muscle_back.png',
          fit: BoxFit.contain,
        ),
      ),

      if (showFront)
        buildFrontZones()
      else
        buildBackZones(),

      if (selectedMuscle != null)
        buildFloatingSummary(),
        
    ],
  ),
),
            const SizedBox(height: 12),

            const Text(
              "Tap a muscle group to view summary",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            buildLegend(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FRONT TAP ZONES
  // ==========================================
Widget buildFrontZones() {
  const imageWidth = 510.0;
  const imageHeight = 1016.0;

  return Positioned.fill(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / imageWidth,
          constraints.maxHeight / imageHeight,
        );

        final displayedWidth =
            imageWidth * scale;

        final displayedHeight =
            imageHeight * scale;

        final offsetX =
            (constraints.maxWidth - displayedWidth) / 2;

        final offsetY =
            (constraints.maxHeight - displayedHeight) / 2;

        Widget zone(
          String muscle,
          double x,
          double y,
          double width,
          double height,
        ) {
          return Positioned(
            left: offsetX + x * scale,
            top: offsetY + y * scale,
            width: width * scale,
            height: height * scale,
            child: muscleZone(muscle),
          );
        }

        return Stack(
          children: [
            // SHOULDER - LEFT
            zone(
              "Shoulder",
              108,
  205,
  65,
  65,
            ),

            // SHOULDER - RIGHT
            zone(
              "Shoulder",
               337,
  205,
  65,
  65,
            ),

            // CHEST
            zone(
              "Chest",
              170,
              225,
              170,
              110,
            ),

            // BICEP - LEFT
            zone(
              "Bicep",
              112,
  285,
  62,
  105,
            ),

            // BICEP - RIGHT
            zone(
              "Bicep",
              336,
  285,
  62,
  105,
            ),

            // CORE
            zone(
              "Core",
              185,
              315,
              140,
              160,
            ),

            // LEG - LEFT
            zone(
              "Leg",
              125,
              480,
              110,
              285,
            ),

            // LEG - RIGHT
            zone(
              "Leg",
              275,
              480,
              110,
              285,
            ),
          ],
        );
      },
    ),
  );
}
  // ==========================================
  // BACK TAP ZONES
  // ==========================================

  Widget buildBackZones() {
  const imageWidth = 468.0;
  const imageHeight = 982.0;

  return Positioned.fill(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / imageWidth,
          constraints.maxHeight / imageHeight,
        );

        final displayedWidth =
            imageWidth * scale;

        final displayedHeight =
            imageHeight * scale;

        final offsetX =
            (constraints.maxWidth - displayedWidth) / 2;

        final offsetY =
            (constraints.maxHeight - displayedHeight) / 2;

        Widget zone(
          String muscle,
          double x,
          double y,
          double width,
          double height,
        ) {
          return Positioned(
            left: offsetX + x * scale,
            top: offsetY + y * scale,
            width: width * scale,
            height: height * scale,
            child: muscleZone(muscle),
          );
        }

        return Stack(
          children: [
            // SHOULDER - LEFT
            zone(
              "Shoulder",
              88,
  205,
  70,
  65,
            ),

            // SHOULDER - RIGHT
            zone(
              "Shoulder",
               310,
  205,
  70,
  65,
            ),

            // BACK
            zone(
              "Back",
              150,
              185,
              170,
              220,
            ),

            // TRICEP - LEFT
            zone(
              "Tricep",
              80,
              275,
              75,
              140,
            ),

            // TRICEP - RIGHT
            zone(
              "Tricep",
              313,
              275,
              75,
              140,
            ),

            // LEG - LEFT
            zone(
              "Leg",
              110,
              475,
              115,
              290,
            ),

            // LEG - RIGHT
            zone(
              "Leg",
              245,
              475,
              115,
              290,
            ),
          ],
        );
      },
    ),
  );
}
  // ==========================================
  // INVISIBLE TAP ZONE
  // ==========================================

  Widget muscleZone(String muscle) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,

    onTap: () {
      selectMuscle(muscle);
    },

    child: Container(
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.25),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),

      alignment: Alignment.center,

      child: Text(
        muscle,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    ),
  );
}

  // ==========================================
  // FLOATING SUMMARY
  // ==========================================

  Widget buildFloatingSummary() {
  if (selectedMuscle == null) {
    return const SizedBox.shrink();
  }

  final muscle = selectedMuscle!;

  // Upper-body muscles -> upper side
  final bool isUpperBody =
      muscle == "Chest" ||
      muscle == "Back" ||
      muscle == "Shoulder" ||
      muscle == "Bicep" ||
      muscle == "Tricep" ||
      muscle == "Core";

  // Left/right placement
  final bool placeLeft =
      muscle == "Back" ||
      muscle == "Chest" ||
      muscle == "Core";

  return Positioned.fill(
    child: Stack(
      children: [
        // ----------------------------------
        // DOTTED POINTER
        // ----------------------------------

        CustomPaint(
          painter: MusclePointerPainter(
            muscle: muscle,
            placeLeft: placeLeft,
            isUpperBody: isUpperBody,
          ),
        ),

        // ----------------------------------
        // SUMMARY CARD
        // ----------------------------------

        Positioned(
          top: isUpperBody ? 70 : 340,

          left: placeLeft ? 4 : null,
          right: placeLeft ? null : 4,

          child: GestureDetector(
            onTap: openMuscleDetails,

            child: Material(
              elevation: 8,

              borderRadius:
                  BorderRadius.circular(14),

              child: Container(
                width: 145,

                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface,

                  borderRadius:
                      BorderRadius.circular(14),

                  border: Border.all(
                    color: activityBorderColor(
                      muscle,
                    ),
                    width: 1.5,
                  ),

                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      color: Colors.black26,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            muscle,

                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons
                              .arrow_forward_ios,
                          size: 14,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "$selectedExerciseCount Exercises",
                    ),

                    Text(
                      "$selectedSetCount Sets",
                    ),

                    if (selectedVolume > 0)
                      Text(
                        "${selectedVolume.toStringAsFixed(0)} Kg",
                      ),

                    const SizedBox(height: 5),

                    const Text(
                      "Tap for details",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Color activityBorderColor(String muscle) {
  final count =
      widget.muscleActivity[muscle] ?? 0;

  if (count <= 3) {
    return Colors.green;
  }

  if (count <= 7) {
    return Colors.orange;
  }

  return Colors.red;
}
  // ==========================================
  // LEGEND
  // ==========================================

  Widget buildLegend() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        legendItem(
          Colors.green,
          "1-3",
        ),

        const SizedBox(width: 12),

        legendItem(
          Colors.orange,
          "4-7",
        ),

        const SizedBox(width: 12),

        legendItem(
          Colors.red,
          "8+",
        ),
      ],
    );
  }

  Widget legendItem(
    Color color,
    String text,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 4),

        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class MusclePointerPainter
    extends CustomPainter {
  final String muscle;
  final bool placeLeft;
  final bool isUpperBody;

  MusclePointerPainter({
    required this.muscle,
    required this.placeLeft,
    required this.isUpperBody,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    Offset target;

    // Approximate muscle points
    // based on the current body image.

    switch (muscle) {
      case "Shoulder":
        target = Offset(
          size.width * 0.68,
          size.height * 0.29,
        );
        break;

      case "Chest":
        target = Offset(
          size.width * 0.50,
          size.height * 0.31,
        );
        break;

      case "Back":
        target = Offset(
          size.width * 0.38,
          size.height * 0.34,
        );
        break;

      case "Bicep":
      case "Tricep":
        target = Offset(
          size.width * 0.68,
          size.height * 0.39,
        );
        break;

      case "Core":
        target = Offset(
          size.width * 0.50,
          size.height * 0.47,
        );
        break;

      case "Leg":
        target = Offset(
          size.width * 0.65,
          size.height * 0.75,
        );
        break;

      default:
        target = Offset(
          size.width * 0.50,
          size.height * 0.40,
        );
    }

    final double cardX =
        placeLeft
            ? size.width * 0.30
            : size.width * 0.70;

    final double cardY =
        isUpperBody
            ? size.height * 0.22
            : size.height * 0.72;

    final start = Offset(
      cardX,
      cardY,
    );

    final paint = Paint()
      ..color = activityPointerColor()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dashed line
    drawDashedLine(
      canvas,
      start,
      target,
      paint,
    );

    // Target circle
    final dotPaint = Paint()
      ..color = activityPointerColor()
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      target,
      5,
      dotPaint,
    );
  }

  Color activityPointerColor() {
    return muscle == "Leg"
        ? Colors.green
        : muscle == "Shoulder"
            ? Colors.orange
            : Colors.red;
  }

  void drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const dashLength = 6.0;
    const gapLength = 5.0;

    final distance =
        (end - start).distance;

    final direction =
        (end - start) / distance;

    double current = 0;

    while (current < distance) {
      final dashStart =
          start + direction * current;

      final dashEnd =
          start +
              direction *
                  (current + dashLength)
                      .clamp(0, distance);

      canvas.drawLine(
        dashStart,
        dashEnd,
        paint,
      );

      current +=
          dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(
    covariant MusclePointerPainter oldDelegate,
  ) {
    return oldDelegate.muscle != muscle ||
        oldDelegate.placeLeft != placeLeft ||
        oldDelegate.isUpperBody !=
            isUpperBody;
  }
}
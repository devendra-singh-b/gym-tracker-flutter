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

  List<Workout> _selectedWorkouts = [];

  int _selectedExerciseCount = 0;
  int _selectedSetCount = 0;
  double _selectedVolume = 0;

  int get selectedExerciseCount =>
      _selectedExerciseCount;

  int get selectedSetCount =>
      _selectedSetCount;

  double get selectedVolume =>
      _selectedVolume;

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

    final workouts = widget.workouts
        .where(
          (workout) =>
              workout.bodyArea == muscle,
        )
        .toList();

    final exercises = workouts
        .map((workout) => workout.exercise)
        .toSet();

    int sets = 0;
    double volume = 0;

    for (final workout in workouts) {
      if (workout.duration == null) {
        sets++;
        volume +=
            workout.weight * workout.reps;
      }
    }

    setState(() {
      selectedMuscle = muscle;

      _selectedWorkouts = workouts;
      _selectedExerciseCount =
          exercises.length;
      _selectedSetCount = sets;
      _selectedVolume = volume;
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
          workouts: _selectedWorkouts,
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
  _selectedWorkouts = [];
  _selectedExerciseCount = 0;
  _selectedSetCount = 0;
  _selectedVolume = 0;
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

      // Summary FIRST
  if (selectedMuscle != null)
    buildFloatingSummary(),

  // Tap zones LAST
  if (showFront)
    buildFrontZones()
  else
    buildBackZones(),
]
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
              100,
            ),

            // BICEP - LEFT
            zone(
              "Bicep",
              102,
              280,
               62,
               105,
            ),

            // BICEP - RIGHT
            zone(
              "Bicep",
              356,
              280,
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
              490,
              120,
              370,
            ),

            // LEG - RIGHT
            zone(
              "Leg",
              285,
              490,
              120,
              370,
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
              200,
              170,
              230,
            ),

            // TRICEP - LEFT
            zone(
              "Tricep",
              70,
              280,
              65,
              125,
            ),

            // TRICEP - RIGHT
            zone(
              "Tricep",
              330,
              280,
              65,
              125,
            ),

            // LEG - LEFT
            zone(
              "Leg",
              110,
              485,
              115,
              370,
            ),

            // LEG - RIGHT
            zone(
              "Leg",
              245,
              485,
              115,
              370,
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

    child: const SizedBox.expand(),
  );
}


// ==========================================
  // VISIBLE TAP ZONE
  // ==========================================
//   Widget muscleZone(String muscle) {
//   return GestureDetector(
//     behavior: HitTestBehavior.translucent,

//     onTap: () {
//       selectMuscle(muscle);
//     },

//     child: Container(
//       decoration: BoxDecoration(
//         color: Colors.blue.withValues(alpha: 0.25),
//         border: Border.all(
//           color: Colors.blue,
//           width: 2,
//         ),
//         borderRadius:
//             BorderRadius.circular(12),
//       ),

//       alignment: Alignment.center,

//       child: Text(
//         muscle,
//         style: const TextStyle(
//           color: Colors.blue,
//           fontWeight: FontWeight.bold,
//           fontSize: 11,
//         ),
//       ),
//     ),
//   );
// }



  // ==========================================
  // FLOATING SUMMARY
  // ==========================================

  Widget buildFloatingSummary() {
  if (selectedMuscle == null) {
    return const SizedBox.shrink();
  }

  final muscle = selectedMuscle!;

  // Card stays in the blank area beside the body.
  // Body image and tap zones remain untouched.
  final bool cardOnLeft =
    muscle == "Shoulder" ||
    muscle == "Bicep" ||
    muscle == "Chest" ||
    muscle == "Back" ||
    muscle == "Core";

  double cardTop;

  switch (muscle) {
    case "Shoulder":
      cardTop = 120;
      break;

    case "Bicep":
    case "Tricep":
      cardTop = 220;
      break;

    case "Chest":
    case "Back":
      cardTop = 145;
      break;

    case "Core":
      cardTop = 285;
      break;

    case "Leg":
      cardTop = 385;
      break;

    default:
      cardTop = 145;
  }

  const double cardWidth = 108;

  return Positioned.fill(
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // ==================================
            // DOTTED CONNECTOR
            // ==================================
            Positioned.fill(
              child: CustomPaint(
                painter: MusclePointerPainter(
                  muscle: muscle,
                  cardOnLeft: cardOnLeft,
                  cardTop: cardTop,
                  cardWidth: cardWidth,
                  showFront: showFront,
                ),
              ),
            ),

            // ==================================
            // SUMMARY CARD
            // ==================================
            Positioned(
              top: cardTop,
              left: cardOnLeft ? 2 : null,
              right: cardOnLeft ? null : 2,

              child: GestureDetector(
                onTap: openMuscleDetails,

                child: Material(
                  elevation: 8,
                  borderRadius:
                      BorderRadius.circular(14),

                  child: Container(
                    width: cardWidth,

                    padding:
                        const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface,

                      borderRadius:
                          BorderRadius.circular(14),

                      border: Border.all(
                        color:
                            activityBorderColor(
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
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons
                                  .arrow_forward_ios,
                              size: 13,
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Text(
                          "$selectedExerciseCount Exercises",
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),

                        Text(
                          "$selectedSetCount Sets",
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),

                        if (selectedVolume > 0)
                          Text(
                            "${selectedVolume.toStringAsFixed(0)} Kg",
                            style:
                                const TextStyle(
                              fontSize: 13,
                            ),
                          ),

                        const SizedBox(height: 4),

                        const Text(
                          "Tap for details",
                          style: TextStyle(
                            fontSize: 10,
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
        );
      },
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

class MusclePointerPainter extends CustomPainter {
  final String muscle;
  final bool cardOnLeft;
  final double cardTop;
  final double cardWidth;
  final bool showFront;

  MusclePointerPainter({
    required this.muscle,
    required this.cardOnLeft,
    required this.cardTop,
    required this.cardWidth,
    required this.showFront,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // ----------------------------------
    // ORIGINAL IMAGE DIMENSIONS
    // ----------------------------------

    final double imageWidth =
        showFront ? 510.0 : 468.0;

    final double imageHeight =
        showFront ? 1016.0 : 982.0;

    // ----------------------------------
    // SAME SCALE AS BoxFit.contain
    // ----------------------------------

    final scale = math.min(
      size.width / imageWidth,
      size.height / imageHeight,
    );

    final displayedWidth =
        imageWidth * scale;

    final displayedHeight =
        imageHeight * scale;

    final offsetX =
        (size.width - displayedWidth) / 2;

    final offsetY =
        (size.height - displayedHeight) / 2;

    // ----------------------------------
    // TARGET IN ORIGINAL IMAGE PIXELS
    // ----------------------------------

    Offset imageTarget;

    if (showFront) {
      switch (muscle) {
        case "Shoulder":
          imageTarget = cardOnLeft
              ? const Offset(140, 238)
              : const Offset(370, 238);
          break;

        case "Chest":
          imageTarget =
              const Offset(255, 275);
          break;

        case "Bicep":
          imageTarget = cardOnLeft
              ? const Offset(133, 333)
              : const Offset(387, 333);
          break;

        case "Core":
          imageTarget =
              const Offset(255, 395);
          break;

        case "Leg":
          imageTarget = cardOnLeft
              ? const Offset(185, 675)
              : const Offset(345, 675);
          break;

        default:
          imageTarget =
              const Offset(255, 400);
      }
    } else {
      switch (muscle) {
        case "Shoulder":
          imageTarget = cardOnLeft
              ? const Offset(127, 252)
              : const Offset(341, 252);
          break;

        case "Back":
          imageTarget =
              const Offset(234, 290);
          break;

        case "Tricep":
          imageTarget = cardOnLeft
              ? const Offset(118, 345)
              : const Offset(350, 345);
          break;

        case "Leg":
          imageTarget = cardOnLeft
              ? const Offset(167, 630)
              : const Offset(303, 630);
          break;

        default:
          imageTarget =
              const Offset(234, 350);
      }
    }

    // ----------------------------------
    // CONVERT IMAGE PIXELS -> SCREEN
    // ----------------------------------

    final target = Offset(
      offsetX + imageTarget.dx * scale,
      offsetY + imageTarget.dy * scale,
    );

    // ----------------------------------
    // CARD CONNECTION POINT
    // ----------------------------------

    final cardCenterY =
        cardTop + 55;

    final start = Offset(
      cardOnLeft
          ? cardWidth + 2
          : size.width - cardWidth - 2,

      cardCenterY,
    );

    // ----------------------------------
    // POINTER
    // ----------------------------------

    final paint = Paint()
      ..color = activityPointerColor()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    drawDashedLine(
      canvas,
      start,
      target,
      paint,
    );

    // ----------------------------------
    // TARGET DOT
    // ----------------------------------

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

    if (distance == 0) {
      return;
    }

    final direction =
        (end - start) / distance;

    double current = 0;

    while (current < distance) {
      final dashStart =
          start + direction * current;

      final dashEnd =
          start +
              direction *
                  math.min(
                    current + dashLength,
                    distance,
                  );

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
    covariant MusclePointerPainter
        oldDelegate,
  ) {
    return oldDelegate.muscle != muscle ||
        oldDelegate.cardOnLeft !=
            cardOnLeft ||
        oldDelegate.cardTop != cardTop ||
        oldDelegate.cardWidth != cardWidth ||
        oldDelegate.showFront != showFront;
  }
}
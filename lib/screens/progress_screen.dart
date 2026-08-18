import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Exercise> _exercises = [];
  List<Workout> _workouts = [];

  Exercise? _selectedExercise;
  int _weeks = 4;
  bool _showVolume = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final exercises =
        await DatabaseHelper.instance.getAllExercises();
    final workouts =
        await DatabaseHelper.instance.getAllWorkouts();

    if (!mounted) return;

    final usableExercises = exercises
        .where((exercise) =>
            exercise.bodyArea != 'Cardio' &&
            exercise.setEnabled)
        .toList();

    setState(() {
      _exercises = usableExercises;
      _workouts = workouts;
      _selectedExercise =
          usableExercises.isNotEmpty ? usableExercises.first : null;
      _loading = false;
    });
  }

  List<Workout> get _selectedWorkouts {
    if (_selectedExercise == null) return [];

    final cutoff = DateTime.now().subtract(
      Duration(days: _weeks * 7),
    );

    return _workouts
        .where((workout) {
          final date = DateTime.tryParse(workout.workoutDate);

          if (date == null) return false;

          return workout.exercise ==
                  _selectedExercise!.exercise &&
              !date.isBefore(cutoff);
        })
        .toList()
      ..sort((a, b) {
        final dateCompare = a.workoutDate.compareTo(b.workoutDate);

        if (dateCompare != 0) return dateCompare;

        return a.setNo.compareTo(b.setNo);
      });
  }

  bool get _isDurationExercise =>
      _selectedExercise?.measurementType == 'duration_sec';

  bool get _hasWeight =>
      _selectedExercise?.weightEnabled == true;

  double get _bestWeight {
    if (!_hasWeight) return 0;

    return _selectedWorkouts.fold<double>(
      0,
      (best, workout) =>
          workout.weight > best ? workout.weight : best,
    );
  }

  int get _totalSets => _selectedWorkouts.length;

  int get _totalReps => _selectedWorkouts.fold<int>(
        0,
        (sum, workout) => sum + workout.reps,
      );

  double get _totalVolume => _selectedWorkouts.fold<double>(
        0,
        (sum, workout) => sum + workout.weight * workout.reps,
      );

  double get _bestDuration => _selectedWorkouts.fold<double>(
        0,
        (best, workout) =>
            (workout.duration ?? 0) > best
                ? (workout.duration ?? 0)
                : best,
      );

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthName(date.month)}";
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  Color _repColor(int reps) {
    if (reps >= 4 && reps <= 6) {
      return Colors.green;
    }

    if (reps >= 7 && reps <= 10) {
      return Colors.orange;
    }

    if (reps >= 11 && reps <= 12) {
      return Colors.red;
    }

    if (reps >= 13 && reps <= 15) {
      return Colors.blue;
    }

    return Colors.grey;
  }

  Future<void> _selectExercise() async {
    if (_exercises.isEmpty) return;

    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        String search = '';
        String category = 'All';

        final categories = <String>{
          'All',
          ..._exercises.map((exercise) => exercise.bodyArea),
        }.toList();

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _exercises.where((exercise) {
              final matchesCategory =
                  category == 'All' ||
                  exercise.bodyArea == category;

              final matchesSearch = search.isEmpty ||
                  exercise.exercise
                      .toLowerCase()
                      .contains(search.toLowerCase());

              return matchesCategory && matchesSearch;
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.82,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    4,
                    12,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Text(
                          'Select Exercise',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search exercise...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setSheetState(() {
                            search = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final item = categories[index];

                            return ChoiceChip(
                              label: Text(item),
                              selected: category == item,
                              onSelected: (_) {
                                setSheetState(() {
                                  category = item;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final exercise = filtered[index];

                            return ListTile(
                              leading: const Icon(
                                Icons.fitness_center,
                              ),
                              title: Text(exercise.exercise),
                              subtitle: Text(
                                exercise.bodyArea,
                              ),
                              onTap: () {
                                Navigator.pop(
                                  context,
                                  exercise,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedExercise = selected;
        _showVolume = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _selectedExercise == null
              ? const Center(
                  child: Text(
                    'No exercises available',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildExerciseSelector(),
                        const SizedBox(height: 12),
                        _buildMetricToggle(),
                        const SizedBox(height: 12),
                        _buildChartCard(),
                        const SizedBox(height: 12),
                        _buildRepLegend(),
                        const SizedBox(height: 12),
                        _buildSetDetails(),
                        const SizedBox(height: 12),
                        _buildSummary(),
                        const SizedBox(height: 12),
                        if (!_isDurationExercise)
                          const Text(
                            'Volume = Weight (kg) × Reps',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildExerciseSelector() {
    return InkWell(
      onTap: _selectExercise,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Select Exercise',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.keyboard_arrow_down),
        ),
        child: Text(
          _selectedExercise!.exercise,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricToggle() {
    if (_isDurationExercise) {
      return const SizedBox.shrink();
    }

    final canShowVolume = _hasWeight;

    return Row(
      children: [
        Expanded(
          child: _metricButton(
            title: _hasWeight ? 'Weight' : 'Reps',
            selected: !_showVolume,
            onTap: () {
              setState(() {
                _showVolume = false;
              });
            },
          ),
        ),
        if (canShowVolume) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _metricButton(
              title: 'Volume (kg)',
              selected: _showVolume,
              onTap: () {
                setState(() {
                  _showVolume = true;
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _metricButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          foregroundColor:
              selected ? Colors.white : Colors.black87,
        ),
        onPressed: onTap,
        child: Text(title),
      ),
    );
  }

  Widget _buildChartCard() {
    final data = _selectedWorkouts;

    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.show_chart,
                size: 48,
              ),
              const SizedBox(height: 10),
              Text(
                'No progress data for '
                '$_weeks weeks',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add this exercise in a workout to '
                'start tracking progress.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    String title;

    if (_isDurationExercise) {
      title = 'Duration Progress';
    } else if (_showVolume) {
      title = 'Volume Progress';
    } else if (_hasWeight) {
      title = 'Weight Progress';
    } else {
      title = 'Reps Progress';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          14,
          12,
          10,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildRangeSelector(),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: CustomPaint(
                painter: _ProgressChartPainter(
                  workouts: data,
                  showVolume: _showVolume,
                  isDuration: _isDurationExercise,
                  hasWeight: _hasWeight,
                  primaryColor:
                      Theme.of(context).colorScheme.primary,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 10),
            _buildSetLegend(data),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    const ranges = [2, 4, 8, 12];

    return SizedBox(
      height: 38,
      child: Row(
        children: ranges.map((range) {
          final selected = _weeks == range;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
              ),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: selected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                      : null,
                  foregroundColor: selected
                      ? Colors.white
                      : Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    _weeks = range;
                  });
                },
                child: Text('${range}W'),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSetLegend(List<Workout> workouts) {
    final setNumbers = workouts
        .map((workout) => workout.setNo)
        .where((setNo) => setNo > 0)
        .toSet()
        .toList()
      ..sort();

    if (setNumbers.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = _ProgressChartPainter.seriesColors;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: setNumbers.map((setNo) {
        final color = colors[
            (setNo - 1) % colors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 3,
              color: color,
            ),
            const SizedBox(width: 6),
            Text('Set $setNo'),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRepLegend() {
    if (_isDurationExercise) {
      return const SizedBox.shrink();
    }

    final items = [
      ('4–6 reps', 'Heavy', Colors.green),
      ('7–10 reps', 'Moderate-Heavy', Colors.orange),
      ('11–12 reps', 'Moderate', Colors.red),
      ('13–15 reps', 'High Rep', Colors.blue),
      ('>15 reps', 'Very High Rep', Colors.grey),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Reps Range (Dot Color)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: items.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: item.$3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetDetails() {
    final data = _selectedWorkouts.reversed.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          14,
          12,
          8,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'No set details available.',
                ),
              )
            else
              ...data.map(
                (workout) {
                  final isDuration =
                      _isDurationExercise;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: Text(
                            _formatDate(
                              workout.workoutDate,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Set ${workout.setNo}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isDuration)
                          Text(
                            '${(workout.duration ?? 0).toStringAsFixed(0)} sec',
                          )
                        else ...[
                          Text(
                            '${workout.weight.toStringAsFixed(1)} kg',
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${workout.reps} reps',
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _repColor(
                                workout.reps,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    if (_isDurationExercise) {
      return Row(
        children: [
          Expanded(
            child: _summaryCard(
              'Best Duration',
              '${_bestDuration.toStringAsFixed(0)} sec',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryCard(
              'Total Sets',
              '$_totalSets',
            ),
          ),
        ],
      );
    }

    final cards = <Widget>[];

    if (_hasWeight) {
      cards.add(
        _summaryCard(
          'Best Weight',
          '${_bestWeight.toStringAsFixed(1)} kg',
        ),
      );
    }

    cards.add(
      _summaryCard(
        'Total Sets',
        '$_totalSets',
      ),
    );

    cards.add(
      _summaryCard(
        'Total Reps',
        '$_totalReps',
      ),
    );

    if (_hasWeight) {
      cards.add(
        _summaryCard(
          'Total Volume',
          '${_totalVolume.toStringAsFixed(0)} kg',
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.05,
      children: cards,
    );
  }

  Widget _summaryCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  final List<Workout> workouts;
  final bool showVolume;
  final bool isDuration;
  final bool hasWeight;
  final Color primaryColor;

  static const List<Color> seriesColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.brown,
  ];

  _ProgressChartPainter({
    required this.workouts,
    required this.showVolume,
    required this.isDuration,
    required this.hasWeight,
    required this.primaryColor,
  });

  double _value(Workout workout) {
    if (isDuration) {
      return workout.duration ?? 0;
    }

    if (showVolume) {
      return workout.weight * workout.reps;
    }

    if (hasWeight) {
      return workout.weight;
    }

    return workout.reps.toDouble();
  }

  String _valueLabel(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  Color _dotColor(Workout workout) {
    final reps = workout.reps;

    if (reps >= 4 && reps <= 6) {
      return Colors.green;
    }
    if (reps >= 7 && reps <= 10) {
      return Colors.orange;
    }
    if (reps >= 11 && reps <= 12) {
      return Colors.red;
    }
    if (reps >= 13 && reps <= 15) {
      return Colors.blue;
    }

    return Colors.grey;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const left = 48.0;
    const right = 12.0;
    const top = 16.0;
    const bottom = 38.0;

    final chartWidth =
        size.width - left - right;
    final chartHeight =
        size.height - top - bottom;

    final values =
        workouts.map(_value).toList();

    double minValue =
        values.reduce((a, b) => a < b ? a : b);
    double maxValue =
        values.reduce((a, b) => a > b ? a : b);

    if (minValue == maxValue) {
      minValue = minValue > 0
          ? minValue - 1
          : 0;
      maxValue += 1;
    }

    final range = maxValue - minValue;
    minValue = (minValue - range * 0.12)
        .clamp(0, double.infinity)
        .toDouble();
    maxValue += range * 0.12;

    final dates = workouts
        .map((workout) =>
            DateTime.tryParse(workout.workoutDate))
        .whereType<DateTime>()
        .toList();

    final minDate = dates.reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );
    final maxDate = dates.reduce(
      (a, b) => a.isAfter(b) ? a : b,
    );

    final dateRange =
        maxDate.difference(minDate).inSeconds;

    final gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1;

    final textStyle = const TextStyle(
      fontSize: 10,
      color: Colors.black54,
    );

    for (int i = 0; i <= 4; i++) {
      final y =
          top + chartHeight * i / 4;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );

      final value =
          maxValue -
          (maxValue - minValue) * i / 4;

      final tp = TextPainter(
        text: TextSpan(
          text: _valueLabel(value),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          left - tp.width - 7,
          y - tp.height / 2,
        ),
      );
    }

    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(left, top + chartHeight),
      Offset(size.width - right, top + chartHeight),
      axisPaint,
    );

    final groupedBySet =
        <int, List<Workout>>{};

    for (final workout in workouts) {
      groupedBySet
          .putIfAbsent(workout.setNo, () => [])
          .add(workout);
    }

    for (final entry in groupedBySet.entries) {
      final setNo = entry.key;

      if (setNo <= 0) continue;

      final series = entry.value;
      final linePaint = Paint()
        ..color = seriesColors[
            (setNo - 1) % seriesColors.length]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final points = <Offset>[];

      for (final workout in series) {
        final date =
            DateTime.tryParse(workout.workoutDate);

        if (date == null) continue;

        final x = dateRange == 0
            ? left + chartWidth / 2
            : left +
                (date
                        .difference(minDate)
                        .inSeconds /
                    dateRange) *
                    chartWidth;

        final value = _value(workout);

        final y = top +
            (maxValue - value) /
                (maxValue - minValue) *
                chartHeight;

        points.add(Offset(x, y));
      }

      if (points.length >= 2) {
        final path = Path()
          ..moveTo(
            points.first.dx,
            points.first.dy,
          );

        for (final point in points.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }

        canvas.drawPath(path, linePaint);
      }

      for (int i = 0; i < series.length; i++) {
        final workout = series[i];
        final date =
            DateTime.tryParse(workout.workoutDate);

        if (date == null) continue;

        final x = dateRange == 0
            ? left + chartWidth / 2
            : left +
                (date
                        .difference(minDate)
                        .inSeconds /
                    dateRange) *
                    chartWidth;

        final value = _value(workout);

        final y = top +
            (maxValue - value) /
                (maxValue - minValue) *
                chartHeight;

        final dotPaint = Paint()
          ..color = isDuration
              ? primaryColor
              : _dotColor(workout)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(x, y),
          6,
          dotPaint,
        );

        final borderPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        canvas.drawCircle(
          Offset(x, y),
          6,
          borderPaint,
        );
      }
    }

    final labelDates = <DateTime>[];

    if (dates.length == 1) {
      labelDates.add(dates.first);
    } else {
      final count = dates.length < 2
          ? dates.length
          : (dates.length > 5 ? 5 : dates.length);

      for (int i = 0; i < count; i++) {
        final index =
            ((dates.length - 1) * i / (count - 1))
                .round();

        labelDates.add(dates[index]);
      }
    }

    for (final date in labelDates) {
      final x = dateRange == 0
          ? left + chartWidth / 2
          : left +
              (date
                      .difference(minDate)
                      .inSeconds /
                  dateRange) *
                  chartWidth;

      final label =
          '${date.day} ${_monthName(date.month)}';

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          x - tp.width / 2,
          top + chartHeight + 8,
        ),
      );
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  @override
  bool shouldRepaint(
    covariant _ProgressChartPainter oldDelegate,
  ) {
    return oldDelegate.workouts != workouts ||
        oldDelegate.showVolume != showVolume ||
        oldDelegate.isDuration != isDuration ||
        oldDelegate.hasWeight != hasWeight ||
        oldDelegate.primaryColor != primaryColor;
  }
}

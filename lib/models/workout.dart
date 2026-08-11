class Workout {
  int? id;
  String exercise;
  int setNo;
  double weight;
  int reps;
  String workoutDate;
  double? duration;
  double? elevation;
  double? distance;
  double? calories;
  String? bodyArea;

  Workout({
    this.id,
    required this.exercise,
    required this.setNo,
    required this.weight,
    required this.reps,
    required this.workoutDate,
    this.duration,
    this.elevation,
    this.distance,
    this.calories,
    this.bodyArea,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise': exercise,
      'setNo': setNo,
      'weight': weight,
      'reps': reps,
      'workoutDate': workoutDate,
      'duration': duration,
      'elevation': elevation,
       'distance': distance,
      'calories': calories,
    };
  }

  factory Workout.fromMap(
    Map<String, dynamic> map,
  ) {
    return Workout(
      id: map['id'],
      exercise: map['exercise'],
      setNo: map['setNo'] ?? 0,
      weight: (map['weight'] ?? 0).toDouble(),
      reps: map['reps'] ?? 0,
      workoutDate: map['workoutDate'] ?? '',
      duration: map['duration']?.toDouble(),
elevation: map['elevation']?.toDouble(),
distance: map['distance']?.toDouble(),
calories: map['calories']?.toDouble(),
bodyArea: map['bodyArea'],
    );
  }
}
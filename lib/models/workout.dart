class Workout {
  int? id;
  String exercise;
  int setNo;
  double weight;
  int reps;
  String workoutDate;

  Workout({
    this.id,
    required this.exercise,
    required this.setNo,
    required this.weight,
    required this.reps,
    required this.workoutDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise': exercise,
      'setNo': setNo,
      'weight': weight,
      'reps': reps,
      'workoutDate': workoutDate,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      exercise: map['exercise'],
      setNo: map['setNo'],
      weight: map['weight'],
      reps: map['reps'],
      workoutDate: map['workoutDate'],
    );
  }
}
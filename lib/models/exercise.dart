class Exercise {
  int? id;
  String bodyArea;
  String exercise;
  bool setEnabled;
  bool weightEnabled;
  bool repsEnabled;
  String measurementType;

  Exercise({
    this.id,
    required this.bodyArea,
    required this.exercise,
    required this.setEnabled,
    required this.weightEnabled,
    required this.repsEnabled,
    this.measurementType = 'reps',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bodyArea': bodyArea,
      'exercise': exercise,
      'setEnabled': setEnabled ? 1 : 0,
      'weightEnabled': weightEnabled ? 1 : 0,
      'repsEnabled': repsEnabled ? 1 : 0,
      'measurementType': measurementType,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      bodyArea: map['bodyArea'],
      exercise: map['exercise'],
      setEnabled: map['setEnabled'] == 1,
      weightEnabled: map['weightEnabled'] == 1,
      repsEnabled: map['repsEnabled'] == 1,
      measurementType:
          map['measurementType'] ?? 'reps',
    );
  }
}
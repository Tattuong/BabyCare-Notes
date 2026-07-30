class Baby {
  final String id;
  String name;
  DateTime birthDate;
  String? photoPath;
  String gender;

  Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.photoPath,
    this.gender = 'unknown',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'photoPath': photoPath,
        'gender': gender,
      };

  factory Baby.fromJson(Map<String, dynamic> json) => Baby(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        photoPath: json['photoPath'] as String?,
        gender: json['gender'] as String? ?? 'unknown',
      );

  Baby copyWith({
    String? name,
    DateTime? birthDate,
    String? photoPath,
    String? gender,
  }) =>
      Baby(
        id: id,
        name: name ?? this.name,
        birthDate: birthDate ?? this.birthDate,
        photoPath: photoPath ?? this.photoPath,
        gender: gender ?? this.gender,
      );

  String ageLabel({bool vi = false}) {
    final now = DateTime.now();
    final days = now.difference(birthDate).inDays;
    if (days < 0) return vi ? 'Sắp sinh' : 'Due soon';
    if (days < 30) return vi ? '$days ngày' : '$days days';
    final months = ((days / 30.44).floor());
    if (months < 24) return vi ? '$months tháng' : '${months}mos';
    final years = (months / 12).floor();
    final remMonths = months % 12;
    if (remMonths == 0) return vi ? '$years tuổi' : '${years}y';
    return vi ? '$years tuổi $remMonths tháng' : '${years}y ${remMonths}m';
  }
}

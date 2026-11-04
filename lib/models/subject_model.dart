class SubjectModel {
  final String id;
  final String name;
  final int cuatrimestre;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.cuatrimestre,
  });

  SubjectModel copyWith({String? name, int? cuatrimestre}) {
    return SubjectModel(
      id: id,
      name: name ?? this.name,
      cuatrimestre: cuatrimestre ?? this.cuatrimestre,
    );
  }
}

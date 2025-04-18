class FacultyItem {
  final String name;
  final String sigla;
  final String imageAsset;
  final double? latitude;
  final double? longitude;

  FacultyItem({
    required this.name,
    required this.sigla,
    required this.imageAsset,
    this.latitude,
    this.longitude,
  });
}
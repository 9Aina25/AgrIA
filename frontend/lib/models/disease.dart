class Disease {
  final String id;
  final String name;
  final String scientificName;
  final List<String> symptoms;
  final List<Treatment> treatments;
  final String wateringAdvice;
  final String fertilizationAdvice;
  final List<String> prevention;
  final String severity;

  Disease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.symptoms,
    required this.treatments,
    required this.wateringAdvice,
    required this.fertilizationAdvice,
    required this.prevention,
    required this.severity,
  });
}

class Treatment {
  final String type;
  final String title;
  final String description;
  final String icon;

  Treatment({required this.type, required this.title, required this.description, required this.icon});
}
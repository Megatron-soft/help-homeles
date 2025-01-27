class Need {
  String need;
  bool isActive;

  Need({required this.need, required this.isActive});
}

class Needs {
  static List<Need> needs = [
      Need(need: "Food", isActive: false),
      Need(need: "Shelter", isActive: false),
      Need(need: "Water", isActive: false),
      Need(need: "Clothes", isActive: false),
      Need(need: "Blanket", isActive: false),
      Need(need: "Financial", isActive: false),
      Need(need: "Medical care", isActive: false)
    ];

  static Map<String,String> arabic = {
    "Food" : "طعام",
    "Shelter" : "مأوي",
    "Water" : "مياه",
    "Blanket": "غطاء",
    "Clothes": "ملابس",
    "Financial":"مساعدة مادية",
    "Medical care": "رعاية صحية",
    "All": "الكل"
  };
  static List<int> distances = [1000, 2000, 3000, 4000, 5000];
}

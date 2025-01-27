import 'package:shelter/models/homeless_data.dart';

class Response {
  final bool isLoading;
  final bool loaded;
  final bool isFailed;
  List<CardData> homelessData;
  List<CardData> filteredData;
  String need = "";
  int distance = -1;

  Response(
      {required this.isLoading,
      required this.loaded,
      required this.isFailed,
      required this.homelessData,
      required this.filteredData,
      required this.need,
      required this.distance});
}

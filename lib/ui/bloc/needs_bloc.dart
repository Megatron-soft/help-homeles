import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter/models/needs.dart';

class NeedsCubit extends Cubit<List<Need>> {
  NeedsCubit() : super(List<Need>.from(Needs.needs));

  void alterNeed(int index) {
    final needs = List<Need>.from(state);
    needs[index].isActive = !needs[index].isActive;
    emit(needs);
  }

  bool isEmpty() {
    for (var need in state) {
      if (need.isActive) {
        return false;
      }
    }
    return true;
  }

  void updateState(List<Need> activeNeeds,BuildContext context) {
    List<Need> newNeeds = List<Need>.from(Needs.needs);
    for (var need in newNeeds) {
      need.isActive = false;
      for (var activeNeed in activeNeeds) {
        if (need.need == activeNeed.need) {
          need.isActive = true;
        }
      }
    }
    emit(newNeeds);
  }

  List<Need> getActive() {
    List<Need> needs = [];
    for (var need in state) {
      if (need.isActive) {
        needs.add(need);
      }
    }
    return needs;
  }
}

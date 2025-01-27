import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter/models/needs.dart';
import 'package:shelter/ui/bloc/language_bloc.dart';
import 'package:shelter/ui/bloc/needs_bloc.dart';

class NeedsButton extends StatelessWidget {
  final Need need;
  final bool isEditable;
  final int index;
  const NeedsButton(
      {super.key,
      required this.need,
      required this.index,
      required this.isEditable});

  @override
  Widget build(BuildContext context) {
    if (need.isActive) {
      return InkWell(
        onTap: () {
          if (isEditable) {
            print(need.need);
            context.read<NeedsCubit>().alterNeed(index);
          }
        },
        child: Container(
          width: need.need.length * 11.0,
          margin: const EdgeInsets.all(2.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<LanguageBloc, String>(builder: (context, state) {
              if (state == "en") {
                return Text(
                  need.need,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              } else {
                return Text(
                  Needs.arabic[need.need] ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              }
            }),
          ),
        ),
      );
    }
    return InkWell(
      onTap: () {
        if (isEditable) {
          context.read<NeedsCubit>().alterNeed(index);
        }
      },
      child: Container(
        width: need.need.length * 11.0,
        margin: const EdgeInsets.all(2.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<LanguageBloc, String>(builder: (context, state) {
              if (state == "en") {
                return Text(
                  need.need,
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 10),
                );
              } else {
                return Text(
                  Needs.arabic[need.need] ?? "",
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 10),
                );
              }
            }),
          ),
        ),
      );
  }
}

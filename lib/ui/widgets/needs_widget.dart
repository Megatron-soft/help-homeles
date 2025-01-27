import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter/models/needs.dart';
import 'package:shelter/ui/bloc/needs_bloc.dart';
import 'package:shelter/ui/widgets/needs_button.dart';

class NeedsWidget extends StatelessWidget {
  final List<Need> activeNeeds;
  const NeedsWidget({super.key, required this.activeNeeds});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NeedsCubit, List<Need>>(
      builder: (context, needs) {
        return Container(
          margin: const EdgeInsets.all(4.0),
          child: Wrap(
            runSpacing: 4.0,
            spacing: 8.0,
            runAlignment: WrapAlignment.start,
            children: List.generate(needs.length, (index){
              return NeedsButton(need: needs[index],isEditable: true,index: index,);
            }),
          ),
        );
      },
    );
  }
}

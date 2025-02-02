import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/ui/add_card/logic/cubit/add_card_cubit.dart';
import 'package:shelter/ui/search_results/ui/screen/search_results_screen.dart';
import 'package:shelter/ui/widgets/layout_widget.dart';
import 'package:shelter/ui/widgets/multy_selection_widget.dart';

import '../../../add_card/data/model/show_all_categories.dart';

class SearchScreen extends StatelessWidget {
   SearchScreen({super.key});
  List<Data> data = [];
   List<String> selectedNames = [];

// Store selected category IDs to send to the API
  List<int> selectedIds = [];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      AddCardCubit()..fetchCategories('https://shelter.megatron-soft.com/api/v1'),
      child: AuthLayout(
        children: [
          BlocConsumer<AddCardCubit, AddCardState>(
            listener: (context, state) {
              if (state is CategoriesLoaded) {
                data = state.categories.data!;
              }
            },
            builder: (context, state) {
              return CustomMultiSelectDropdownField<String>(
                label: CacheHelper.getData(key: "lang") == "ar"
                    ? "list of needed"
                    : "قاثمه الاحتياجات",
                hintText: CacheHelper.getData(key: "lang") == "ar"
                    ? "list of needed"
                    : "قاثمه الاحتياجات",
                selectedValues: selectedNames,
                // Display category names in the UI
                items: data.isNotEmpty
                    ? data
                    .map((category) => category.name ?? '')
                    .where((element) => element.isNotEmpty)
                    .toList()
                    : [],
                onChanged: (selectedItems) {
                  // Update selected names list for display
                  selectedNames = List<String>.from(selectedItems);

                  // Safely map selected names to their corresponding IDs
                  selectedIds = selectedItems
                      .map((selectedName) =>
                  data
                      .firstWhere((cat) => cat.name == selectedName)
                      .id ??
                      0) // Use ?? 0 to handle null cases
                      .where((id) =>
                  id != 0) // Ensure no default values are included
                      .toList();

                  print("Selected names: $selectedNames");
                  print("Selected IDs: $selectedIds");
                },
              );
            },
          ),
SizedBox(height: 20.h,),
          BlocConsumer<AddCardCubit, AddCardState>(
            listener: (context, state) {
              if (state is CategoriesLoaded) {
                data = state.categories.data!;
              }
            },
            builder: (context, state) {
              return CustomMultiSelectDropdownField<String>(
                label: CacheHelper.getData(key: "lang") == "ar"
                    ? "list of needed"
                    : "قاثمه الاحتياجات",
                hintText: CacheHelper.getData(key: "lang") == "ar"
                    ? "list of needed"
                    : "قاثمه الاحتياجات",
                selectedValues: selectedNames,
                // Display category names in the UI
                items: data.isNotEmpty
                    ? data
                    .map((category) => category.name ?? '')
                    .where((element) => element.isNotEmpty)
                    .toList()
                    : [],
                onChanged: (selectedItems) {
                  // Update selected names list for display
                  selectedNames = List<String>.from(selectedItems);

                  // Safely map selected names to their corresponding IDs
                  selectedIds = selectedItems
                      .map((selectedName) =>
                  data
                      .firstWhere((cat) => cat.name == selectedName)
                      .id ??
                      0) // Use ?? 0 to handle null cases
                      .where((id) =>
                  id != 0) // Ensure no default values are included
                      .toList();

                  print("Selected names: $selectedNames");
                  print("Selected IDs: $selectedIds");
                },
              );
            },
          ),
          SizedBox(height: 20.h,),
          DefaultButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResultsScreen(

                  ),
                ),
              );
            },
            label: CacheHelper.getData(key: "lang") == "ar"?"Search":"البحث",
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

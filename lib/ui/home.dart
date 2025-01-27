import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter/models/homeless_data.dart';
import 'package:shelter/models/needs.dart';
import 'package:shelter/models/response.dart';
import 'package:shelter/ui/add_card/presention/screen/add_screen.dart';
import 'package:shelter/ui/bloc/homeless_bloc.dart';
import 'package:shelter/ui/bloc/language_bloc.dart';
import 'package:shelter/ui/homeless_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 239, 244),
      body: BlocBuilder<HomelessCubit, Response>(
        builder: (context, response) {
          if (response.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (response.homelessData.isEmpty && !response.loaded) {
            context.read<HomelessCubit>().getHomelessData();
            return Center(
              child: Text(AppLocalizations.of(context)!.noHomelessPeople),
            );
          } else if (response.isFailed) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<HomelessCubit>().getHomelessData();
                },
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.deepPurple)),
                child: Text(
                  AppLocalizations.of(context)!.tryAgain,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            response.need = "";
                            response.distance = -1;
                            context.read<HomelessCubit>().getHomelessData();
                          },
                          style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.deepPurple)),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      BlocBuilder<LanguageBloc, String>(
                          builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<LanguageBloc>().changeLang();
                            },
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    state == "en"
                                        ? Colors.deepPurple
                                        : Colors.white)),
                            child: Text(
                              state,
                              style: TextStyle(
                                  color: state == "en"
                                      ? Colors.white
                                      : Colors.deepPurple),
                            ),
                          ),
                        );
                      }),
                      BlocBuilder<LanguageBloc, String>(
                          builder: (context, lang) {
                        if (lang == "ar") {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              hint: Text(AppLocalizations.of(context)!.need),

                              value: response.need.isNotEmpty
                                  ? response.need
                                  : null, // Ensure it’s not null
                              items: Needs.needs.map((Need value) {
                                return DropdownMenuItem<String>(
                                  value: value.need,
                                  child: Text(Needs.arabic[value.need] ?? ""),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<HomelessCubit>().setNeed(value);
                                }
                              },
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            hint: Text(AppLocalizations.of(context)!.need),
                            value: response.need.isNotEmpty
                                ? response.need
                                : null, // Ensure it’s not null
                            items: Needs.needs.map((Need value) {
                              return DropdownMenuItem<String>(
                                value: value.need,
                                child: Text(value.need),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                context.read<HomelessCubit>().setNeed(value);
                              }
                            },
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<int>(
                          hint: Text(AppLocalizations.of(context)!.distance),
                          value: response.distance > 0
                              ? response.distance
                              : null, // Ensure it’s not null
                          items: <int>[-1, 1000, 2000, 3000, 4000, 5000]
                              .map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value == -1
                                  ? AppLocalizations.of(context)!.any
                                  : "$value ${AppLocalizations.of(context)!.meter}"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<HomelessCubit>().setDistance(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(builder: (anotherContext) {
                  if (response.filteredData.isEmpty) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(40.0),
                        width: 300,
                        child: Text(
                            AppLocalizations.of(context)!.cannotFindPeople),
                      ),
                    );
                  }
                  return Column(
                    children:
                        List.generate(response.filteredData.length, (index) {
                      CardData card = response.filteredData[index];
                      return HomelessCard(card: card);
                    }),
                  );
                }),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          BlocBuilder<HomelessCubit, Response>(builder: (context, cards) {
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<
                      HomelessCubit>(), // Use value if the cubit is already created
                  child: AddCardScreen(),
                ),
              ),
            );
          },
          tooltip: AppLocalizations.of(context)!.addNewPerson,
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}

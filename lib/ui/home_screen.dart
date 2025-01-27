import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter/ui/bloc/language_bloc.dart';
import 'package:shelter/ui/home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shelter/ui/map_screen/presentation/screen/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<LanguageBloc, String>(
                builder: (context, state) {
                  return InkWell(
                      onTap: () {
                        context.read<LanguageBloc>().changeLang();
                      },
                      child: Text(
                        state == "en" ? "عربي" : "english",
                        style: TextStyle(color: Colors.white),
                      ));
                },
              ),
            ),
          ],
        ),
        // appBar: AppBar(
        //   title: Align(
        //     alignment: Alignment.center,
        //     child: Row(
        //       children: [
        //         Text(
        //           AppLocalizations.of(context)!.title,
        //           style: const TextStyle(
        //             fontSize: 26,
        //             fontWeight: FontWeight.w600,
        //             color: Colors.white,
        //           ),
        //         ),

        //       ],
        //     ),
        //   ),
        //   flexibleSpace: Container(
        //     decoration: const BoxDecoration(
        //       gradient: LinearGradient(
        //           end: Alignment.bottomLeft,
        //           begin: Alignment.topRight,
        //           colors: [Colors.deepPurple, Colors.purple]),
        //     ),
        //   ),
        //   bottom: TabBar(
        //     indicatorColor: Colors.white,
        //     indicatorSize: TabBarIndicatorSize.label,
        //     tabs: [
        //       Tab(
        //         child: Text(
        //           AppLocalizations.of(context)!.homelessAngels,
        //           style: const TextStyle(
        //               fontWeight: FontWeight.w600,
        //               fontSize: 16,
        //               color: Colors.white),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        body: MapScreen(isVisible: true,),

        ),

    );
  }
}

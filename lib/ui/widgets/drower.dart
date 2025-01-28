import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/ui/bloc/language_bloc.dart';
import 'package:shelter/ui/select_languages/presentation/screen/select_languages.dart';
import 'package:shelter/ui/widgets/about_us.dart';

class AppDrawer extends StatefulWidget {


  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0.w, vertical: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Row(
                children: [
                  SvgPicture.asset("lib/res/person.svg"),
                  SizedBox(width: 8.w),
                  Text(
                    CacheHelper.getData(key: "lang")=="ar"? "About Us":"نبذه عنا",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AboutUsScreen(

                          ),
                    ),
                  );
              },
            ),
            Divider(thickness: 2, height: 0),
            ListTile(
              title: Row(
                children: [
                 // SvgPicture.asset("lib/res/languages.svg"),
                  SizedBox(width: 8.w),
                  Text(
                    CacheHelper.getData(key: "lang")=="ar"? "languages:":"اللغه:",
                    style: TextStyle(color: Colors.black),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: BlocBuilder<LanguageBloc, String>(
                      builder: (context, state) {
                        return InkWell(
                            onTap: () {
                              context.read<LanguageBloc>().changeLang();
                              CacheHelper.saveData(key: "lang",value:state );
                              CacheHelper.getData(key: "lang");
                            },
                            child: Text(
                              state == "en" ? "عربي" : "English",
                              style: TextStyle(color: Colors.black),
                            ));
                      },
                    ),
                  ),
                ],
              ),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) =>
              //           BlocProvider(
              //             create: (context) => LanguageBloc(),
              //             child: LanguageSelectionPage(
              //
              //             ),
              //           ),
              //     ),
              //   );
              // },
            ),
            Divider(thickness: 2, height: 0),
          ],
        ),
      ),
    );
  }
}
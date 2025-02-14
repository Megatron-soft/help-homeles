import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/ui/show_user_data/data/logic/get_data_cubit.dart';
import 'package:shelter/ui/widgets/layout_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/model/show_data_response.dart';

class ShowUserData extends StatefulWidget {
  ShowUserData({super.key, required this.id});

  final int id;
  Data? data;

  @override
  State<ShowUserData> createState() => _ShowUserDataState();
}

class _ShowUserDataState extends State<ShowUserData> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetDataCubit()..fetchHomelessData(widget.id),
      child: BlocConsumer<GetDataCubit, GetDataState>(
        listener: (context, state) {
          if (state is HomelessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
          if (state is HomelessLoaded) {
            widget.data = state.data.data;
          }
        },
        builder: (context, state) {
          if(state is HomelessLoading){
            return Center(child: CircularProgressIndicator());
          }
          if(state is HomelessLoaded){
            return Directionality(
              textDirection: CacheHelper.getData(key: "lang") == "en"
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: AuthLayout(children: [
                Center(
                  child: Text(
                    CacheHelper.getData(key: "lang")=="ar"?  "User Need":"الاحتياجات الشخصيه",
                    style: TextStyle(color: Colors.black, fontSize: 30.sp),
                  ),
                ),
                Divider(),
                Image.network(
                  widget.data?.image?.toString() ?? '',  // Safe null check for image URL
                  width: double.infinity,  // Take up the full width of the parent container
                  fit: BoxFit.cover,  // Maintain aspect ratio while covering the area
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  CacheHelper.getData(key: "lang")=="ar"?  "Needs":"الاحتياجات",
                  style: TextStyle(color: Colors.black, fontSize: 30.sp),
                ),
                Divider(),
                SizedBox(
                  height: 10.h,
                ),
                Wrap(
                  spacing: 10.w, // Space between items
                  runSpacing: 5.h, // Space between rows
                  children: List.generate(
                    widget.data!.categories!.length,
                        (index1) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.data!.categories![index1].name!,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Divider(),
                InkWell(
                  onTap: () async {
                    final latitude =
                        widget.data!.latitude;
                    final longitude =
                        widget.data!.longitude;

                    final Uri googleMapsUri =
                    Uri.parse(
                        "google.navigation:q=$latitude,$longitude"); // "d" means driving mode

                    if (await canLaunchUrl(
                        googleMapsUri)) {
                      await launchUrl(
                          googleMapsUri);
                    } else {
                      throw 'Could not launch Google Maps';
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 50, // Adjust size as needed
                          height: 50,
                          decoration:  BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300], // Background color (change if needed)

                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'lib/res/track.svg',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        // const Icon(
                        //   Icons.location_on,
                        //   color: Colors.deepPurple,
                        //   size: 33.0,
                        // ),
                        Padding(
                          padding:
                          const EdgeInsets.all(
                              2.0),
                          child: Text(
                            " ${widget.data!.country} ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Text(
                //   widget.data!.country.toString(),
                //   style: TextStyle(color: Colors.black, fontSize: 20.sp),
                // ),
                SizedBox(
                  height: 10.h,
                ),
                Divider(),
                Text(
                  CacheHelper.getData(key: "lang")=="ar"?  "notes:${widget.data!.note==null?"not found notes":widget.data!.note}":"ملاحظات:${widget.data!.note==null?"لا يوجد ملاحظات":widget.data!.note}",
                  style: TextStyle(color: Colors.black, fontSize: 20.sp),
                ),
                Divider(),
                SizedBox(
                  height: 10.h,
                ),
              ]),
            );
          }
          return Center(child: Text("no data found"));


        },
      ),
    );
  }
}

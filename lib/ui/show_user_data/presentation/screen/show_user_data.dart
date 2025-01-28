import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/ui/show_user_data/data/logic/get_data_cubit.dart';
import 'package:shelter/ui/widgets/layout_widget.dart';

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
          return AuthLayout(children: [
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
              CacheHelper.getData(key: "lang")=="ar"?  "Need":"الاحتياجات",
              style: TextStyle(color: Colors.black, fontSize: 30.sp),
            ),
            Divider(),
            SizedBox(
              height: 10.h,
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(
                height: 5.h,
              ),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      widget.data!.categories![index].name!,
                      style: TextStyle(color: Colors.black, fontSize: 20.sp),
                    ),
                  ],
                );
              },
              itemCount: widget.data!.categories!.length,
            ),
            SizedBox(
              height: 10.h,
            ),
            Divider(),
            Text(
              CacheHelper.getData(key: "lang")=="ar"? "address:${widget.data!.address.toString()}":"العنوان:${widget.data!.address.toString()}",
              style: TextStyle(color: Colors.black, fontSize: 20.sp),
            ),
            SizedBox(
              height: 10.h,
            ),
            Divider(),
            Text(
              CacheHelper.getData(key: "lang")=="ar"?  "note:${widget.data!.note==null?"":widget.data!.note}":"ملاحظات:${widget.data!.note==null?"":widget.data!.note}",
              style: TextStyle(color: Colors.black, fontSize: 20.sp),
            ),
            Divider(),
            SizedBox(
              height: 10.h,
            ),
          ]);
        },
      ),
    );
  }
}

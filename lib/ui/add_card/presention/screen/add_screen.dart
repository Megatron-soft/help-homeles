import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/models/geolocator_response.dart';
import 'package:shelter/models/homeless_data.dart';
import 'package:shelter/models/response.dart';
import 'package:shelter/repository/location_helper.dart';
import 'package:shelter/ui/add_card/data/model/show_all_categories.dart';
import 'package:shelter/ui/add_card/logic/cubit/add_card_cubit.dart';
import 'package:shelter/ui/bloc/homeless_bloc.dart';
import 'package:shelter/ui/bloc/language_bloc.dart';
import 'package:shelter/ui/bloc/needs_bloc.dart';
import 'package:shelter/ui/camera.dart';
import 'package:shelter/ui/helpers/helper.dart';
import 'package:shelter/ui/widgets/multy_selection_widget.dart';
import 'package:shelter/ui/widgets/needs_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../widgets/layout_widget.dart';

class AddCardScreen extends StatefulWidget {
  AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  double lat = -1.0;

  double long = -1.0;
  File? selectedLogo;
  List<String> selectedValue = [];
  TextEditingController addDataController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  List<String> selectedNames = [];

// Store selected category IDs to send to the API
  List<int> selectedIds = [];
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedLogo = File(pickedFile.path);
      });
    }
  }

  List<Data> data = []; // Ensure it's initialized with an empty list

  @override
  void initState() {
    // TODO: implement initState
    AddCardCubit().fetchCategories('https://test.ysk-comics.com/api/v1');
  print(CacheHelper.getData(key: "lang"))  ;
  print(CacheHelper.getData(key: "lang"))  ;
  print(CacheHelper.getData(key: "lang"))  ;
  print(CacheHelper.getData(key: "lang"))  ;
  print(CacheHelper.getData(key: "lang"))  ;
  print(CacheHelper.getData(key: "lang"))  ;
    CacheHelper.getData(key: "lang");
    CacheHelper.getData(key: "lang");
    CacheHelper.getData(key: "lang");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<File?> imageFileNotifier = ValueNotifier(null);
    final ValueNotifier<String> imagePathNotifier = ValueNotifier("");
    final ValueNotifier<String?> imageUrlNotifier = ValueNotifier(null);

    return BlocProvider(
      create: (context) =>
      AddCardCubit()
        ..fetchCategories('https://test.ysk-comics.com/api/v1'),
      child: AuthLayout(
        children: [
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 20),
          //   child: BlocBuilder<LanguageBloc, String>(
          //     builder: (context, state) {
          //       return InkWell(
          //           onTap: () {
          //             context.read<LanguageBloc>().changeLang();
          //           },
          //           child: Text(
          //             state == "en" ? "عربي" : "english",
          //             style: TextStyle(color: Colors.black,fontSize: 20),
          //           ));
          //     },
          //   ),
          // ),
          InkWell(
            onTap: () async {
              await _pickImage();
            },
            child: selectedLogo == null
                ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "lib/res/upload.svg",
                    width: 80,
                    height: 40,
                  ),
                  SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)!.pickImage,
                  ),
                ],
              ),
            )
                : Image.file(
              selectedLogo!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(
            height: 40,
          ),

          BlocConsumer<AddCardCubit, AddCardState>(
            listener: (context, state) {
              if (state is CategoriesLoaded) {
                data = state.categories.data!;
              }
            },
            builder: (context, state) {
              return CustomMultiSelectDropdownField<String>(
                label: CacheHelper.getData(key: "lang")=="ar"?"list of needed":"قاثمه الاحتياجات",
                hintText: CacheHelper.getData(key: "lang")=="ar"?"list of needed":"قاثمه الاحتياجات",
                selectedValues: selectedNames,  // Display category names in the UI
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
                      .map((selectedName) => data.firstWhere((cat) => cat.name == selectedName).id ?? 0)  // Use ?? 0 to handle null cases
                      .where((id) => id != 0)  // Ensure no default values are included
                      .toList();

                  print("Selected names: $selectedNames");
                  print("Selected IDs: $selectedIds");
                },
              );
            },
          ),

          const SizedBox(
            height: 40,
          ),

          InkWell(
            onTap: () async {
              final permissionStatus = await Permission.location.status;
              print(permissionStatus);

              if (permissionStatus.isGranted) {
                // Fetch the location
                GeolocatorResponse geoResponse =
                await LocationHelper.determinePosition();
                Helper.showToast(
                    AppLocalizations.of(context)!.pleaseWaitLocation);

                if (geoResponse.isSuccess) {
                  lat = geoResponse.lat;
                  long = geoResponse.long;
                  Helper.showToast(
                      AppLocalizations.of(context)!.locationFetchedSucc);
                } else {
                  Helper.showToast(AppLocalizations.of(context)!.checkLocation);
                }
              } else {
                // Request location permission
                final requestStatus = await Permission.location.request();

                if (requestStatus.isDenied) {
                  Helper.showToast(
                      AppLocalizations.of(context)!.locationPermission);
                  return;
                }

                // Once permission is granted, fetch location again
                if (requestStatus.isGranted) {
                  Helper.showToast(
                      AppLocalizations.of(context)!.pleaseWaitLocation);
                  GeolocatorResponse geoResponse =
                  await LocationHelper.determinePosition();

                  if (geoResponse.isSuccess) {
                    lat = geoResponse.lat;
                    long = geoResponse.long;
                    Helper.showToast(
                        AppLocalizations.of(context)!.locationFetchedSucc);
                  } else {
                    Helper.showToast(
                        AppLocalizations.of(context)!.checkLocation);
                  }
                }
              }
            },
            child: Column(
              children: [
                Image.asset(
                  "lib/res/sss.jpeg",
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                ),
                Text(
                  AppLocalizations.of(context)!.locateMe,
                  style: const TextStyle(color: Colors.black),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),

          CustomTextFormFieldWithLabel(
            label:CacheHelper.getData(key: "lang")=="ar"? "Other Data":"اضافه بيانات اخري",
            hintText: CacheHelper.getData(key: "lang")=="ar"?" Enter Other Data":"اضافه بيانات اخري",
            controller: addDataController,
          ),

          const SizedBox(height: 40),

          CustomTextFormFieldWithLabel(
            label:CacheHelper.getData(key: "lang")=="ar"? "Address":"العنوان",
            hintText: CacheHelper.getData(key: "lang")=="ar"? "enter Address":" ادخل العنوان",
            controller: addressController,
          ),
          const SizedBox(height: 40),
          BlocConsumer<AddCardCubit, AddCardState>(
            listener: (context, state) {
              if(state is AddCardError)
                {
                  Helper.showToast(AppLocalizations.of(context)!.enterAllData);
                }
              if(state is AddCardSuccess)
                {
                  Helper.showToast(CacheHelper.getData(key: "lang")=="ar"?"The data has been added successfully wait until it is approved":"تم اضافه البيانات بنجاج انتظر حتي يم الموافقه عليها");
                }
              // TODO: implement listener
            },
            builder: (context, state) {
              return DefaultButton(
                onPressed: () {
                  if (lat == -1.0) {
                    Helper.showToast(
                        AppLocalizations.of(context)!.checkLocation);
                    return;
                  }

                  if ( selectedLogo == null) {
                    Helper.showToast(AppLocalizations.of(context)!.takePicture);
                    return;
                  }
                  // final cardData = CardData(
                  //   imageUrl: imageUrlNotifier.value,
                  //   needs: needs,
                  //   lat: lat,
                  //   long: long,
                  // );
                  print(selectedLogo!);
                  print(lat);
                  print(long);
                  print(selectedIds);
                  print(addDataController.text.trim());
                  print(addressController.text.trim());
                  context.read<AddCardCubit>().submitForm(
                      imagePath: selectedLogo!,
                      latitude: lat,
                      longitude: long,
                      categories: selectedIds,
                      note: addDataController.text.trim(),
                  address: addressController.text.trim()
                  );

                  // blocContext.read<HomelessCubit>().addPerson(cardData,
                  //     imageFileNotifier.value, imagePathNotifier.value);
                  // Navigator.pop(context);
                },
                label: AppLocalizations.of(context)!.submit,
                backgroundColor: Colors.black,
                textColor: Colors.white,
              );
            },
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     if (lat == -1.0) {
          //       Helper.showToast(
          //           AppLocalizations.of(context)!.checkLocation);
          //       return;
          //     }
          //     final needs = context.read<NeedsCubit>().getActive();
          //     if (needs.isEmpty || imageFileNotifier.value == null) {
          //       Helper.showToast(AppLocalizations.of(context)!.enterAllData);
          //       return;
          //     }
          //     final cardData = CardData(
          //       imageUrl: imageUrlNotifier.value,
          //       needs: needs,
          //       lat: lat,
          //       long: long,
          //     );
          //     // blocContext.read<HomelessCubit>().addPerson(cardData,
          //     //     imageFileNotifier.value, imagePathNotifier.value);
          //     Navigator.pop(context);
          //   },
          //   child: Text(AppLocalizations.of(context)!.submit),
          // ),
          // BlocBuilder<HomelessCubit, Response>(builder: (blocContext, cards) {
          //   return Center(
          //     child: Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Column(
          //         children: [
          //
          //         ],
          //       ),
          //     ),
          //   );
          // }),
        ],
      ),
    );
  }
}

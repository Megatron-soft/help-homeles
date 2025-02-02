import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
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
import 'package:shelter/ui/widgets/needs_button.dart';
import 'package:shelter/ui/widgets/needs_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
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
  File? selectedLogo2;
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
  String ?country;
  @override
  void initState() {
    // TODO: implement initState
    AddCardCubit().fetchCategories('https://shelter.megatron-soft.com/api/v1');
    print(CacheHelper.getData(key: "lang"));
    print(CacheHelper.getData(key: "lang"));
    print(CacheHelper.getData(key: "lang"));
    print(CacheHelper.getData(key: "lang"));
    print(CacheHelper.getData(key: "lang"));
    print(CacheHelper.getData(key: "lang"));
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
          AddCardCubit()..fetchCategories('https://shelter.megatron-soft.com/api/v1'),
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

          selectedLogo2==null? ElevatedButton(
            onPressed: () async {
              final cameras = await availableCameras();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<
                        HomelessCubit>(), // Use value if the cubit is already created
                    child: CameraScreen(
                      camera: cameras.first,
                      onPictureTaken: (path) {
                        // Handle the picture path (e.g., show the image, upload it, etc.)
                       setState(() {
                         selectedLogo2 = File(path);
                         print(selectedLogo2);
                       });


                        imagePathNotifier.value = path;
                      },
                    ),
                  ),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.takePicture),
          ):Image.file(
            selectedLogo2!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
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
              return Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: data.map((item) {
                    bool isSelected = selectedIds.contains(item.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedIds.remove(item.id);
                          } else {
                            selectedIds.add(int.parse(item.id.toString()));
                          }
                        });
                        print("Selected IDs: $selectedIds");
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Text(
                          item.name.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
                GeolocatorResponse geoResponse = await LocationHelper.determinePosition();
                Helper.showToast(AppLocalizations.of(context)!.pleaseWaitLocation);

                if (geoResponse.isSuccess) {
                  lat = geoResponse.lat;
                  long = geoResponse.long;

                  // Reverse geocoding to get country
                  List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
                  Placemark placemark = placemarks.first; // Get the first placemark
                  country = placemark.country ?? "Unknown country"; // Get country name

                  Helper.showToast(AppLocalizations.of(context)!.locationFetchedSucc);
                  print("Country: $country");  // Print the country
                } else {
                  Helper.showToast(AppLocalizations.of(context)!.checkLocation);
                }
              } else {
                // Request location permission
                final requestStatus = await Permission.location.request();

                if (requestStatus.isDenied) {
                  Helper.showToast(AppLocalizations.of(context)!.locationPermission);
                  return;
                }

                // Once permission is granted, fetch location again
                if (requestStatus.isGranted) {
                  Helper.showToast(AppLocalizations.of(context)!.pleaseWaitLocation);
                  dynamic geoResponse = await LocationHelper.determinePosition();

                  if (geoResponse.isSuccess) {
                    lat = geoResponse.lat;
                    long = geoResponse.long;

                    // Reverse geocoding to get country
                    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
                    Placemark placemark = placemarks.first; // Get the first placemark
                    country = placemark.country ?? "Unknown country"; // Get country name

                    Helper.showToast(AppLocalizations.of(context)!.locationFetchedSucc);
                    print("Country: $country");  // Print the country
                  } else {
                    Helper.showToast(AppLocalizations.of(context)!.checkLocation);
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
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          CustomTextFormFieldWithLabel(
            label: CacheHelper.getData(key: "lang") == "ar"
                ? "Other Data"
                : "اضافه بيانات اخري",
            hintText: CacheHelper.getData(key: "lang") == "ar"
                ? " Enter Other Data"
                : "اضافه بيانات اخري",
            controller: addDataController,
          ),

          // const SizedBox(height: 40),
          //
          // CustomTextFormFieldWithLabel(
          //   label: CacheHelper.getData(key: "lang") == "ar"
          //       ? "Address"
          //       : "العنوان",
          //   hintText: CacheHelper.getData(key: "lang") == "ar"
          //       ? "enter Address"
          //       : " ادخل العنوان",
          //   controller: addressController,
          // ),
          const SizedBox(height: 40),
          BlocConsumer<AddCardCubit, AddCardState>(
            listener: (context, state) {
              if (state is AddCardError) {
                Helper.showToast(AppLocalizations.of(context)!.enterAllData);
              }
              if (state is AddCardSuccess) {
                Helper.showToast(CacheHelper.getData(key: "lang") == "ar"
                        ? "The data has been added successfully wait until it is approved"
                        : "تم اضافه البيانات بنجاج انتظر حتي يم الموافقه عليها")
                    ;
                Navigator.pop(context);
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

                  if (selectedLogo2==null&& selectedLogo==null) {
                    Helper.showToast(AppLocalizations.of(context)!.takePicture);
                    return;
                  }

                  // final cardData = CardData(
                  //   imageUrl: imageUrlNotifier.value,
                  //   needs: needs,
                  //   lat: lat,
                  //   long: long,
                  // );
                //  print(selectedLogo!);
                //  print(selectedLogo2!);
                  print(lat);
                  print(long);
                  print(selectedIds);
                  print(country);
                  print(addDataController.text.trim());
                  print(addressController.text.trim());
                  context.read<AddCardCubit>().submitForm(
                      imagePath: selectedLogo==null?selectedLogo2!:selectedLogo!,
                      latitude: lat,
                      longitude: long,
                      categories: selectedIds,
                      note: addDataController.text.trim(),
                      country: country.toString()
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

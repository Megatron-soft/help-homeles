import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shelter/models/geolocator_response.dart';
import 'package:shelter/models/homeless_data.dart';
import 'package:shelter/models/response.dart';
import 'package:shelter/repository/location_helper.dart';
import 'package:shelter/ui/bloc/homeless_bloc.dart';
import 'package:shelter/ui/bloc/needs_bloc.dart';
import 'package:shelter/ui/helpers/helper.dart';
import 'package:shelter/ui/widgets/needs_widget.dart';

class EditCardScreen extends StatelessWidget {
  final CardData person;
  const EditCardScreen({super.key, required this.person});


  @override
  Widget build(BuildContext context) {
    print(person.needs.first.need);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title:  Text(
         AppLocalizations.of(context)!.updatePerson,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<HomelessCubit, Response>(builder: (blocContext, cards) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 300,
                  margin: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(person.imageUrl ??
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/1200px-Default_pfp.svg"),
                        fit: BoxFit.fitHeight,
                      ),
                      borderRadius: BorderRadius.circular(10).copyWith(
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      )),
                ),
                NeedsWidget(
                  activeNeeds: person.needs,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Check for location permission
                    final permissionStatus = await Permission.location.status;

                    if (permissionStatus.isGranted) {
                      // Fetch the location
                      GeolocatorResponse geoResponse =
                          await LocationHelper.determinePosition();
                      Helper.showToast(AppLocalizations.of(context)!.pleaseWaitLocation);

                      if (geoResponse.isSuccess) {
                        person.lat = geoResponse.lat;
                        person.long = geoResponse.long;
                        Helper.showToast(AppLocalizations.of(context)!.locationFetchedSucc);
                      } else {
                        Helper.showToast(
                            AppLocalizations.of(context)!.checkLocation);
                      }
                    } else if (permissionStatus.isDenied) {
                      // Request location permission
                      final requestStatus = await Permission.location.request();

                      if (requestStatus.isDenied) {
                        Helper.showToast(
                            AppLocalizations.of(context)!.locationPermission);
                        return;
                      }

                      // Once permission is granted, fetch location again
                      if (requestStatus.isGranted) {
                        GeolocatorResponse geoResponse =
                            await LocationHelper.determinePosition();
                        Helper.showToast(
                            AppLocalizations.of(context)!.pleaseWaitLocation);

                        if (geoResponse.isSuccess) {
                          person.lat = geoResponse.lat;
                          person.long = geoResponse.long;
                          Helper.showToast(AppLocalizations.of(context)!.locationFetchedSucc);
                        } else {
                          Helper.showToast(
                              AppLocalizations.of(context)!.checkLocation);
                        }
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.updateLocation,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (person.lat == -1.0) {
                      Helper.showToast(
                          AppLocalizations.of(context)!.checkLocation);
                      return;
                    }
                    final needs = context.read<NeedsCubit>().getActive();
                    if (needs.isEmpty) {
                      Helper.showToast(AppLocalizations.of(context)!.enterAllData);
                      return;
                    }
                    final cardData = CardData(
                        imageUrl: person.imageUrl,
                        needs: needs,
                        lat: person.lat,
                        long: person.long,
                        );

                    blocContext.read<HomelessCubit>().updatePerson(cardData);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

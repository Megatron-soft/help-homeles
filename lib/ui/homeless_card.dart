import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter/models/homeless_data.dart';
import 'package:shelter/ui/bloc/homeless_bloc.dart';
import 'package:shelter/ui/bloc/needs_bloc.dart';
import 'package:shelter/ui/edit_screen.dart';
import 'package:shelter/ui/widgets/needs_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomelessCard extends StatelessWidget {
  final CardData card;
  const HomelessCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color.fromARGB(255, 255, 252, 253),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(card.imageUrl ??
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/1200px-Default_pfp.svg"),
                        fit: BoxFit.fitHeight,
                      ),
                      borderRadius: BorderRadius.circular(10).copyWith(
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      )),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(4.0),
                height: 35,
                child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.purple)),
                  onPressed: () {
                    context.read<NeedsCubit>().updateState(card.needs, context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<
                              HomelessCubit>(), // Use value if the cubit is already created
                          child: EditCardScreen(
                            person: card,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Center(
                      child: Icon(
                    Icons.edit,
                    size: 18.0,
                    color: Colors.white,
                  )),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.deepPurple,
                    size: 18.0,
                  ),
                  InkWell(
                    onTap: () async {
                      final link = Uri(
                          scheme: "google.navigation",
                          // host: '"0,0"',  {here we can put host}
                          queryParameters: {'q': '${card.lat}, ${card.long}'});

                      if (await canLaunchUrl(link)) {
                        await launchUrl(link);
                      } else {
                        throw 'Could not launch Google Maps';
                      }
                      // MapsLauncher.launchCoordinates(card.lat, card.long);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        card.city ??  AppLocalizations.of(context)!.openLocation,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 90, 47, 163),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: List.generate(card.needs.length, (index) {
                  return NeedsButton(
                    need: card.needs[index],
                  isEditable: false,
                  index: index,
                );
              })),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:yorimichi/const.dart';
import 'package:yorimichi/main.dart';
import 'package:yorimichi/place.dart';

class SearchLocationWidget extends ConsumerStatefulWidget {
  const SearchLocationWidget({super.key});

  @override
  ConsumerState<SearchLocationWidget> createState() =>
      _SearchLocationWidgetState();
}

class _SearchLocationWidgetState extends ConsumerState<SearchLocationWidget> {
  final apiKey = Const.apiKey;
  // Place? place;
  // Place place0;
  // Place? place1;
  // Place? place2;
  // bool? isExist;
  // Uri? mapURL;
  // Uri? mapURL0;
  // Uri? mapURL1;
  // Uri? mapURL2;

  List<Place> places = [];

  // final placeName = ref.watch(placeNameProvider);
  // String keyword = placeName;

  @override
  void initState() {
    final placeName = ref.read(placeNameProvider);
    super.initState();
    _searchLocation(placeName);
    // _searchLocation();
  }

  @override
  Widget build(BuildContext context) {
    final placeName = ref.watch(placeNameProvider);
    String keyword = placeName;

    if (isExist == false) {
      return const Scaffold(
        body: Center(
          child: Text('近くに候補がありません！'),
        ),
      );
    }

    if (places[0] == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(keyword),
      ),
      body: ListView(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                height: 240,
                width: double.infinity,
                child: Image.network(place0!.photo!, fit: BoxFit.contain)),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                place0!.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
              onPressed: () async {
                if (mapURL0 != null) {
                  await launchUrl(mapURL0!);
                }
              },
              child: const Text('Google Map へ'),
            ),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                height: 240,
                width: double.infinity,
                child: Image.network(place1!.photo!, fit: BoxFit.contain)),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                place1!.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
              onPressed: () async {
                if (mapURL1 != null) {
                  await launchUrl(mapURL1!);
                }
              },
              child: const Text('Google Map へ'),
            ),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                height: 240,
                width: double.infinity,
                child: Image.network(place2!.photo!, fit: BoxFit.contain)),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                place2!.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
              onPressed: () async {
                if (mapURL2 != null) {
                  await launchUrl(mapURL2!);
                }
              },
              child: const Text('Google Map へ'),
            ),
          ])
        ],
      ),

      // ListView.builder(
      // itemCount: places.length,
      // itemBuilder: (c, i) {
      //   return Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         SizedBox(
      //             height: 240,
      //             width: double.infinity,
      //             child: Image.network(places[i].Place!.photo!,
      //                 fit: BoxFit.contain)),
      //         const SizedBox(
      //           height: 8,
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: Text(
      //             place!.name!,
      //             style: const TextStyle(
      //               fontWeight: FontWeight.bold,
      //               fontSize: 24,
      //             ),
      //           ),
      //         ),
      //         const SizedBox(
      //           height: 8,
      //         ),
      //         ElevatedButton(
      //           onPressed: () async {
      //             if (mapURL0 != null) {
      //               await launchUrl(mapURL0!);
      //             }

      //             // if (mapURL != null) {
      //             //   await launchUrl(mapURL!);
      //             // }
      //           },
      //           child: const Text('Google Map へ'),
      //         ),
      //       ]);
      // }),

      // body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      //   SizedBox(
      //       height: 240,
      //       width: double.infinity,
      //       child: Image.network(place!.photo!, fit: BoxFit.contain)),
      //   const SizedBox(
      //     height: 8,
      //   ),
      //   Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Text(
      //       place!.name!,
      //       style: const TextStyle(
      //         fontWeight: FontWeight.bold,
      //         fontSize: 24,
      //       ),
      //     ),
      //   ),
      //   const SizedBox(
      //     height: 8,
      //   ),
      //   ElevatedButton(
      //     onPressed: () async {
      //       if (mapURL0 != null) {
      //         await launchUrl(mapURL0!);
      //       }

      //       // if (mapURL != null) {
      //       //   await launchUrl(mapURL!);
      //       // }
      //     },
      //     child: const Text('Google Map へ'),
      //   ),
      // ]),
    );
  }

  Future _searchLocation([String? placeName = 'コンビニ']) async {
    final currentPosition = await _determinePosition();
    final currentLatitude = currentPosition.latitude;
    final currentLongitude = currentPosition.longitude;

    final googlePlace = GooglePlace(apiKey);
    final responce = await googlePlace.search.getNearBySearch(
      Location(lat: currentLatitude, lng: currentLongitude),
      1500,
      language: 'ja',
      keyword: placeName,
      rankby: RankBy.Distance,
    );

    final results = responce?.results ?? [];
    places = results
        .map(
          (result) => Place(
              name: result.name,
              photo: (result.photos ?? []).isEmpty
                  ? null
                  : (result.photos ?? []).first.photoReference,
              location: result.geometry?.location,
              mapURL: Uri.parse(Platform.isAndroid
                  ? 'https://www.google.com/maps/dir/$currentLatitude,$currentLongitude/${result.geometry?.location?.lat},${result.geometry?.location?.lng}'
                  : 'comgooglemaps://?saddr=$currentLatitude,$currentLongitude&daddr=${result.geometry?.location?.lat},${result.geometry?.location?.lng}&directionsmode=walking')),
        )
        .toList();
    setState(() {});
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('設定から位置情報を許可してください');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('設定から位置情報を許可してください');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('設定から位置情報を許可してください');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}

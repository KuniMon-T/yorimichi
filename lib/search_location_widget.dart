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
  Place? place;
  Uri? mapURL;
  bool? isExist;

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

    if (place == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(keyword), //ここから一番近いトイレ
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            height: 240,
            width: double.infinity,
            child: Image.network(place!.photo!, fit: BoxFit.contain)),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            place!.name!,
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
            if (mapURL != null) {
              await launchUrl(mapURL!);
            }
          },
          child: const Text('Google Map へ'),
        ),
      ]),
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

    final results = responce?.results;
    final isExist = results?.isNotEmpty ?? false;
    setState(() {
      this.isExist = isExist;
    });
    if (!isExist) {
      return;
    }
    final firstResult = results?.first;
    // final secondResult = results?.elementAt(1);
    final placeLocation = firstResult?.geometry?.location;
    final placeLatitude = placeLocation?.lat;
    final placeLongitude = placeLocation?.lng;

    //googlemapに飛ぶURLの作成
    String urlString = '';
    if (Platform.isAndroid) {
      urlString =
          'https://www.google.com/maps/dir/$currentLatitude,$currentLongitude/$placeLatitude,$placeLongitude';
    } else if (Platform.isIOS) {
      urlString =
          'comgooglemaps://?saddr=$currentLatitude,$currentLongitude&daddr=$placeLatitude,$placeLongitude&directionsmode=walking';
    }
    mapURL = Uri.parse(urlString);

    if (firstResult != null && mounted) {
      final photoReference = firstResult.photos?.first.photoReference;
      final String photoURL;
      if (photoReference != null) {
        photoURL =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReference&key=$apiKey';
      } else {
        photoURL =
            'https://4.bp.blogspot.com/-O0Pur3sjarQ/UP06O9klHeI/AAAAAAAAK6A/HTglhQkjMWk/s1600/place_boy.png';
      }
      // setState(() {
      place = Place(
        firstResult.name,
        photoURL,
        placeLocation,
      );
      // });
      // place = Place(
      //   firstResult.name,
      //   photoURL,
      //   placeLocation,
      // );

      // Place(secondResult.name, photo, location),
    }
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

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
  bool? isExist;
  List<Place> places = [];

  @override
  void initState() {
    final placeName = ref.read(placeNameProvider);
    final index = ref.read(indexProvider);
    super.initState();
    _searchLocation(placeName, index);
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

    if (places.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(keyword),
      ),
      body: ListView.builder(
          itemCount: places.length,
          itemBuilder: (c, i) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: Image.network(places.elementAt(i).photo!,
                          fit: BoxFit.contain)),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      places.elementAt(i).name!,
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
                      if (places.elementAt(i).mapURL != null) {
                        await launchUrl(places.elementAt(i).mapURL!);
                      }
                    },
                    child: const Text('Google Map へ'),
                  ),
                ]);
          }),
    );
  }

  Future _searchLocation(String placeName, int index) async {
    final currentPosition = await _determinePosition();
    final currentLatitude = currentPosition.latitude;
    final currentLongitude = currentPosition.longitude;
    String? notExistPhotoURL;

    switch (index) {
      case 0:
        notExistPhotoURL =
            "https://free-icons.net/wp-content/uploads/2020/02/build004.png";
        break;
      case 1:
        notExistPhotoURL =
            "https://free-icons.net/wp-content/uploads/2020/09/build015.png";
        break;
      case 2:
        notExistPhotoURL =
            "https://free-icons.net/wp-content/uploads/2020/01/build002.png";
        break;
    }

    final googlePlace = GooglePlace(apiKey);
    final responce = await googlePlace.search.getNearBySearch(
      Location(lat: currentLatitude, lng: currentLongitude),
      1500,
      language: 'ja',
      keyword: placeName,
      rankby: RankBy.Distance,
    );

    final results = responce?.results ?? [];
    results.isEmpty ? isExist = false : isExist = true;
    places = results
        .map(
          (result) => Place(
              name: result.name,
              photo: (result.photos ?? []).isEmpty
                  ? notExistPhotoURL
                  : "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${(result.photos ?? []).first.photoReference}&key=$apiKey",
              location: result.geometry?.location,
              mapURL: Uri.parse(Platform.isAndroid
                  ? 'https://www.google.com/maps/dir/$currentLatitude,$currentLongitude/${result.geometry?.location?.lat},${result.geometry?.location?.lng}'
                  : 'comgooglemaps://?saddr=$currentLatitude,$currentLongitude&daddr=${result.geometry?.location?.lat},${result.geometry?.location?.lng}&directionsmode=walking')),
        )
        .toList();
    setState(() {});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('設定から位置情報を許可してください');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('設定から位置情報を許可してください');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('設定から位置情報を許可してください');
    }

    return await Geolocator.getCurrentPosition();
  }
}

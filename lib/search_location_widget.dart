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
  String? errorMessage;

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
    final index = ref.watch(indexProvider);
    String keyword = placeName;

    if (isExist == false) {
      return Scaffold(
        body: const Center(
          child: Text(
            '近くに候補がありません！',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            places = [];
            setState(() {});
            _searchLocation(placeName, index);
          },
          child: const Icon(Icons.refresh),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            places = [];
            setState(() {});
            _searchLocation(placeName, index);
          },
          child: const Icon(Icons.refresh),
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
            return Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 5),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                Text(
                                  '${places.elementAt(i).rating} (${places.elementAt(i).userRatingTotal}件の評価)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            businessStatus(places.elementAt(i).openNow),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  unitConversion(places.elementAt(i).distance!),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (places.elementAt(i).mapURL != null) {
                                  await launchUrl(places.elementAt(i).mapURL!,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: const Text('Google Map へ'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ]),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          places = [];
          setState(() {});
          _searchLocation(placeName, index);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget unitConversion(int meterDistance) {
    if (meterDistance < 1000) {
      return Text(
        '現在地から${meterDistance}m',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    } else {
      double kilometerDistance;
      kilometerDistance = meterDistance.toDouble() / 1000;
      return Text(
        '現在地から${kilometerDistance}km',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }
  }

  Widget businessStatus(bool? openNow) {
    if (openNow == true) {
      return const Row(
        children: [
          Icon(
            Icons.circle_outlined,
            color: Colors.red,
          ),
          Text(
            "現在営業中",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else if (openNow == false) {
      return const Row(
        children: [
          Icon(
            Icons.close,
            color: Colors.deepPurple,
          ),
          Text(
            "営業時間外",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else {
      return const Row(
        children: [
          Icon(
            Icons.question_mark_rounded,
            color: Colors.black,
          ),
          Text(
            "営業状態不明",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
  }

  Future _searchLocation(String placeName, int index) async {
    try {
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
              "https://free-icons.net/wp-content/uploads/2020/09/build017.png";
          break;
        case 3:
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
                    ? index == 2 || index == 3
                        ? 'https://www.google.com/maps/search/?api=1&query=${result.name}'
                        : 'https://www.google.com/maps/search/?api=1&query=${result.name}'
                    // : 'https://www.google.com/maps/dir/$currentLatitude,$currentLongitude/${result.geometry?.location?.lat},${result.geometry?.location?.lng}'
                    : 'comgooglemaps://?saddr=$currentLatitude,$currentLongitude&daddr=${result.geometry?.location?.lat},${result.geometry?.location?.lng}&directionsmode=walking'),
                distance: getDistance(
                    currentLatitude,
                    currentLongitude,
                    result.geometry!.location!.lat!,
                    result.geometry!.location!.lng!),
                openNow: result.openingHours?.openNow,
                rating: result.rating,
                userRatingTotal: result.userRatingsTotal),
          )
          .toList();
      errorMessage = null;
    } catch (e) {
      final message = e.toString();
      errorMessage = message;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
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

int getDistance(double currentLatitude, double currentLongitude,
    double targetLatitude, double targetLongitude) {
  double distanceInMeters = Geolocator.distanceBetween(
      currentLatitude, currentLongitude, targetLatitude, targetLongitude);
  return distanceInMeters.round();
}

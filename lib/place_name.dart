import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'place_name.g.dart';

@riverpod
class PlaceNameNotifier extends _$PlaceNameNotifier {
  @override
  String build() {
    return '候補がありません';
  }
}

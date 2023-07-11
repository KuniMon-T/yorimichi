import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yorimichi/search_location_widget.dart';
// import 'package:yorimichi/place_name.dart';

void main() {
  const app = MyApp();
  const scope = ProviderScope(child: app);
  runApp(scope);
}

// プロバイダー
final indexProvider = StateProvider((ref) {
  // 変化するデータ 0, 1, 2...
  return 0;
});

final placeNameProvider = StateProvider<String>((ref) {
  return "コンビニ";
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // インデックス
    final index = ref.watch(indexProvider);
    // final index2 = ref.watch(placeNameProvider);

    // アイテムたち
    const items = [
      BottomNavigationBarItem(
        icon: Icon(Icons.local_convenience_store_rounded),
        label: 'コンビニ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_gas_station_rounded),
        label: 'ガソスタ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_rounded),
        label: '飲食店',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.store_mall_directory_rounded),
        label: '道の駅',
      ),
    ];

    // 下のバー
    final bar = BottomNavigationBar(
      items: items, // アイテムたち
      backgroundColor: Colors.blue, // バーの色
      selectedItemColor: Colors.yellow, // 選ばれたアイテムの色
      unselectedItemColor: Colors.black, // 選ばれていないアイテムの色
      type: BottomNavigationBarType.fixed, //itemが４つ以上の時に表示が崩れるのを防止
      currentIndex: index, // インデックス
      onTap: (index) {
        // タップされたとき インデックスを変更する
        ref.read(indexProvider.notifier).state = index;
        switch (index) {
          case 0: // PlaceName ノティファイアを呼ぶ\assets-for-api-docs\assets\material\Colors.orange.png
            final notifier = ref.read(placeNameProvider.notifier);
            // PlaceName データを変更
            notifier.state = 'コンビニ';
          case 1: // PlaceName ノティファイアを呼ぶ
            final notifier = ref.read(placeNameProvider.notifier);
            // PlaceName データを変更
            notifier.state = 'ガソリンスタンド';
          case 2: // PlaceName ノティファイアを呼ぶ
            final notifier = ref.read(placeNameProvider.notifier);
            // PlaceName データを変更
            notifier.state = '飲食店';
          case 3: // PlaceName ノティファイアを呼ぶ
            final notifier = ref.read(placeNameProvider.notifier);
            // PlaceName データを変更
            notifier.state = '道の駅';
        }
      },
    );

    // 画面たち
    const pages = [
      SearchLocationWidget(
        key: ValueKey('コンビニ'),
      ),
      SearchLocationWidget(
        key: ValueKey('ガソリンスタンド'),
      ),
      SearchLocationWidget(
        key: ValueKey('飲食店'),
      ),
      SearchLocationWidget(
        key: ValueKey('道の駅'),
      ),
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: pages[index]),
        bottomNavigationBar: bar,
      ),
    );
  }
}

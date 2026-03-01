import 'package:get/get.dart';
import 'package:life_line/data/models/line_data.dart';
import 'package:life_line/data/models/metadata.dart';
import 'package:life_line/data/repo.dart';

class MainPageController extends GetxController {
  final Repo repo = Repo();

  Rx<Metadata?> metadata = Rx<Metadata?>(null);
  RxList<LineData?> linedata = RxList<LineData?>();

  // @override
  // void onInit() {
  //   super.onInit();
  //   loadMetadata();
  //   loadLineData();
  //   update();
  // }

  Future<void> init(String password) async {
    await _loadMetadata();
    await _loadLineData(password);
  }

  Future<void> _loadMetadata() async {
    try {
      Metadata data = await repo.loadMetadata();
      metadata.value = data;
    } catch (e) {
      print("Błąd podczas ładowania metadanych: $e");
    }
  }

  Future<void> _loadLineData(String password) async {
    try {
      linedata.value = await repo.loadLineData(password);
    } catch (e) {
      print('Błąd line data: $e');
    }
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:life_line/data/models/line_data.dart';
import 'package:life_line/page/controller.dart';
import 'package:life_line/widgets/line.dart';

class MainPage extends GetView<MainPageController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final metadata = controller.metadata.value;
      if (metadata == null) return const Scaffold();

      final int half = metadata.age ~/ 2;
      final List<LineData> data = controller.linedata
          .whereType<LineData>()
          .toList();

      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              Expanded(
                child: Line(
                  ageStart: 0,
                  ageEnd: half,
                  lineData: data.where((e) => e.age <= half).toList(),
                ),
              ),
              Expanded(
                child: Line(
                  ageStart: half,
                  ageEnd: metadata.age,
                  lineData: data.where((e) => e.age > half).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

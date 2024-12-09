import 'package:flutter/material.dart';

const SampleData = [
  {
    "plant": "tomato",
    "plantName": "টমেটো",
    "count": 14,
  },
  {
    "plant": "potato",
    "plantName": "আলু",
    "count": 8,
  },
  {
    "plant": "corn",
    "plantName": "ভুট্টা",
    "count": 8,
  },
];

class ImageTakingTips extends StatelessWidget {
  final int plantIndx;
  final bool forNonLeaf;
  const ImageTakingTips({
    super.key,
    required this.plantIndx,
    required this.forNonLeaf,
  });

  List<int> getImageList(int n, int k) {
    List<int> numbers = List.generate(n, (index) => index + 1);
    numbers.shuffle();
    return numbers.sublist(0, k);
  }

  @override
  Widget build(BuildContext context) {
    var data = SampleData[plantIndx];
    String plant = data['plant'] as String;
    List<int> imageList = getImageList(data['count'] as int, 5);

    return SizedBox(
      height: 100,
      child: ListView.builder(
        itemCount: imageList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              "assets/sample/${plant}_${imageList[index]}.jpg",
            ),
          );
        },
      ),
    );
  }
}

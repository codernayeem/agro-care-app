import 'package:agro_care_app/screens/scan/camera_page.dart';
import 'package:flutter/material.dart';

class PredictCropSelectWidget extends StatefulWidget {
  final void Function(int indx) onChange;
  final int selected;
  final List<PredictCrop> availableCrops;
  const PredictCropSelectWidget(
      {super.key,
      required this.onChange,
      required this.selected,
      required this.availableCrops});

  @override
  State<PredictCropSelectWidget> createState() =>
      _PredictCropSelectWidgetState();
}

final List<Color?> customColor = [
  Colors.red[200]!.withOpacity(.8),
  const Color.fromARGB(175, 223, 137, 24),
  Colors.green[400]!.withOpacity(.8),
];

class _PredictCropSelectWidgetState extends State<PredictCropSelectWidget> {
  int selectedIndx = 0;

  void onClick(idx) {
    if (selectedIndx == idx) return;
    selectedIndx = idx;
    widget.onChange(selectedIndx);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    selectedIndx = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black45,
      child: Row(
        children: [
          getCropItemView(0),
          getCropItemView(1),
          getCropItemView(2),
        ],
      ),
    );
  }

  Widget getCropItemView(int index) {
    bool selected = index == selectedIndx;

    return Expanded(
      child: Container(
        height: 70,
        // duration: const Duration(milliseconds: 200),
        // curve: Curves.ease,
        color: selected ? customColor[index] : Colors.transparent,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              onClick(index);
            },
            child: FittedBox(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      widget.availableCrops[index].icon,
                      width: 50,
                    ),
                  ),
                  Text(
                    widget.availableCrops[index].bdName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Hind Siliguri",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'sample_image_row.dart';
import 'scan_help_page.dart';
import 'tts_button.dart';

class APIResponse {
  final String plant;
  final String className;
  final int classIndex;
  final bool isHealthy;
  final String diseaseName;
  final bool isIdentified;
  final double confidence;
  final String details;

  APIResponse(
      {required this.plant,
      required this.isHealthy,
      required this.diseaseName,
      required this.isIdentified,
      required this.className,
      required this.classIndex,
      required this.confidence,
      required this.details});

  factory APIResponse.fromJson(Map<String, dynamic> json, double threshold) {
    return APIResponse(
      plant: json['plant'],
      isHealthy: json['details']['isHealthy'],
      diseaseName: json['details']['diseaseName'],
      isIdentified:
          json['confidence'] >= threshold && json['class'] != 'non_leaf',
      className: json['class'],
      classIndex: json['class_index'],
      confidence: json['confidence'],
      details: json['details']['details'],
    );
  }
}

class PredictionPage extends StatefulWidget {
  final File imageFile;
  final double cropWidth;
  final String imageUid;
  final int plantIndex; // 0 - tomato, 1 - potato, 2 - corn\
  final bool srcCamera;
  const PredictionPage(this.imageFile, this.cropWidth, this.imageUid,
      this.plantIndex, this.srcCamera,
      {super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  late File outputImageFile;

  bool isReady = false;
  bool isError = false;
  String errorMsg = "";

  late String plantName;

  // prediction result
  late APIResponse apiResponse;

  Future<dynamic> fetchAPIandParseJson(String apiLink) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiLink));
      request.files.add(
          await http.MultipartFile.fromPath('file', widget.imageFile.path));
      request.fields['model_index'] = widget.plantIndex.toString();
      request.fields['src'] = widget.srcCamera ? "camera" : "gallery";
      request.fields['cropWidth'] = widget.cropWidth.toString();
      StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        return jsonDecode(body);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  void startPredicting() async {
    /// Try to predict and sets the predictionModel
    /// 4 states:
    ///  - notLeaf == true
    ///  - identified == false (low confidence)
    ///  - isHealthy == true
    ///  - isHealthy == false

    Directory filesDir = await getApplicationCacheDirectory();
    var saveDir = Directory('${filesDir.path}/store');
    if (!await saveDir.exists()) {
      await saveDir.create();
    }

    // call the apilink as get request
    try {
      var res = await FireStoreServices.settingRef().get();
      var apiLink = res.data()!['predict_link'];
      var thresConf = res.data()!['thres_conf'] as double;

      var response = await fetchAPIandParseJson(apiLink);
      if (response != null) {
        apiResponse = APIResponse.fromJson(response, thresConf);
        setState(() {
          isReady = true;
          isError = false;
          errorMsg = "None";
        });
      } else {
        setState(() {
          isReady = true;
          isError = true;
          errorMsg = "The Server is not responding";
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isReady = true;
        isError = true;
        errorMsg = "Data Parsing Error";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    plantName = widget.plantIndex == 0
        ? "টমেটো"
        : widget.plantIndex == 1
            ? "আলু"
            : "ভুট্টা";
    startPredicting();
  }

  void showSnackBar(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }

  void _showDialog() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: (widget.srcCamera) ? widget.cropWidth : null,
            child: Hero(
              tag: "selectedImage",
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: buttonArrow(context),
          ),
          scroll(),
        ],
      ),
    ));
  }

  buttonArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);

          // testReset();
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.close,
                size: 30,
                color: Colors.white.withOpacity(.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  scroll() {
    return DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 1.0,
        minChildSize: 0.7,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 5,
                          width: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  !isReady
                      ? predictLoding()
                      : !isError
                          ? getMainView()
                          : getErrorView(),
                ],
              ),
            ),
          );
        });
  }

  Widget getErrorView() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          LottieBuilder.asset("assets/anim/no_item.json", width: 200),
          const SizedBox(height: 20),
          Text(
            errorMsg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.fromARGB(255, 14, 49, 6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget predictLoding() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          LottieBuilder.asset("assets/anim/leaf_scan.json", width: 200),
          const SizedBox(height: 20),
          const Text(
            'সমস্যা খোজা হচ্ছে',
            style: TextStyle(
              color: Color.fromARGB(255, 14, 49, 6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget getMainView() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Top Row With cropped image & plantName & status
          Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(image: FileImage(widget.imageFile)),
                ),
              ),
              const SizedBox(width: 22),
              apiResponse.isIdentified
                  ? Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            plantName,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            getChipView(
                              apiResponse.isHealthy
                                  ? "Healthy"
                                  : "Disease Identified",
                              apiResponse.isHealthy,
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ))
                  : Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              getChipView("Identification Failed", false),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 20),
          // bottom Main Part
          (apiResponse.isIdentified)
              ? (apiResponse.isHealthy ? getHealthyView() : getDiseaseDetails())
              : diseaseNotIdentifiedView(
                  notLeaf: apiResponse.className == "non_leaf"),
        ],
      ),
    );
  }

  Widget diseaseNotIdentifiedView({required bool notLeaf}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 0),
          LottieBuilder.asset(
            "assets/anim/no_item.json",
            repeat: false,
            width: 140,
          ),
          const SizedBox(height: 6),
          Text(
            notLeaf
                ? "ছবিতে $plantName পাতা সঠিকভাবে চিহ্নিত করা যায়নি।"
                : "ছবিতে $plantName পাতার সমস্যা চিহ্নিত করা যায়নি।",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade900,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "দয়া করে আবার একটি পরিষ্কার ছবি তুলুন।",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade900,
              fontSize: 18,
              fontFamily: 'Hind Siliguri',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 6),
          const Text(
            "নিচের ছবিগুলোর মত ছবি তোলার ট্রাই করুন",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryDarkColor,
              fontSize: 14,
              fontFamily: 'Hind Siliguri',
              fontWeight: FontWeight.w500,
            ),
          ),
          ImageTakingTips(
            key: const ValueKey("ImageTakingTips"),
            forNonLeaf: notLeaf,
            plantIndx: widget.plantIndex,
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ScanHelpPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.question_mark_rounded),
                label: const Text(
                  "স্ক্যানিং গাইড",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF09051C),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget getHealthyView() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          LottieBuilder.asset("assets/anim/done.json", repeat: false),
          const SizedBox(height: 20),
          const Text(
            "আপনার গাছটি সুস্থ",
            style: TextStyle(
              color: Color.fromARGB(255, 37, 93, 24),
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget getChipView(String txt, bool green) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color:
            green ? Colors.green.withOpacity(.2) : Colors.pink.withOpacity(.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.50),
        ),
      ),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              txt,
              style: TextStyle(
                color: green
                    ? const Color(0xFF285F1B)
                    : const Color.fromARGB(255, 105, 2, 37).withOpacity(.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
                onPressed: _showDialog, icon: const Icon(Icons.info_outline)),
          ],
        ),
      ),
    );
  }

  Widget getDiseaseDetails() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 112,
              height: 34,
              decoration: ShapeDecoration(
                color: Colors.green.withOpacity(.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.50),
                ),
              ),
              child: const Center(
                child: Text(
                  'সম্ভাব্য সমস্যা',
                  style: TextStyle(
                    color: Color(0xFF285F1B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                apiResponse.diseaseName,
                style: const TextStyle(
                  color: Color(0xFF09051C),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TTSButton(
                key: const ValueKey("TTSButton"), text: apiResponse.details),
          ],
        ),
        const SizedBox(height: 10),
        HtmlWidget(
          apiResponse.details,
        ),
        const SizedBox(height: 30),
        const SizedBox(height: 50),
      ],
    );
  }
}

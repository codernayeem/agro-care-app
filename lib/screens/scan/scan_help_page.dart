import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'camera_page.dart';
import 'predict_crop_select_widget.dart';
import 'sample_image_row.dart';

class ScanHelpPage extends StatelessWidget {
  const ScanHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "স্ক্যানিং গাইড",
          style: TextStyle(
            color: Color(0xFF09051C),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              getStepView(
                "১",
                "গাছ নির্বাচন",
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        color: const Color.fromARGB(106, 11, 93, 11),
                        child: PredictCropSelectWidget(
                          selected: 1,
                          onChange: (indx) {},
                          availableCrops: availableCrops,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    getPointView(
                        "আপনি যে গাছের পাতা স্ক্যান করতে চান তা নির্বাচন করুন।"),
                  ],
                ),
              ),
              getStepView(
                "২",
                "সঠিক পাতার ছবি নির্বাচন",
                Column(
                  children: [
                    getPointView("টমেটো পাতার কিছু উদাহরণ"),
                    const ImageTakingTips(plantIndx: 0, forNonLeaf: false),
                    getPointView("আলু পাতার কিছু উদাহরণ"),
                    const ImageTakingTips(plantIndx: 1, forNonLeaf: false),
                    getPointView("ভুট্টা পাতার কিছু উদাহরণ"),
                    const ImageTakingTips(plantIndx: 2, forNonLeaf: false),
                    const SizedBox(height: 16),
                    getPointView("একটি সমতল পৃষ্ঠে পাতাটি রাখুন"),
                    getPointView(
                        "পাতাটি পর্যাপ্ত প্রাকৃতিক আলো পাচ্ছে কিনা তা নিশ্চিত করুন।"),
                  ],
                ),
              ),
              getStepView(
                "৩",
                "বাক্সের ভিতরে পাতার ছবি বসানো",
                Column(
                  children: [
                    Image.asset(
                      "assets/images/guide_2.jpg",
                      height: 180,
                    ),
                    const SizedBox(height: 16),
                    getPointView(
                        "পাতার ছবি বাক্সের ভিতরে আছে তা নিশ্চিত করুন।"),
                  ],
                ),
              ),
              getStepView(
                "৪",
                "ছবি তোলার পর অপেক্ষা",
                Column(
                  children: [
                    LottieBuilder.asset("assets/anim/leaf_scan.json",
                        width: 180),
                    const SizedBox(height: 16),
                    getPointView(
                        "অ্যাপটি ছবি স্ক্যান করার সময় অনুগ্রহ করে অপেক্ষা করুন।"),
                  ],
                ),
              ),
              getStepView(
                "৫",
                "রোগের বিরুদ্ধে ব্যবস্থা",
                Column(
                  children: [
                    getPointView(
                        "লক্ষণগুলি মিলিয়ে নিন এবং রোগ সনাক্তকরণ নিশ্চিত করুন।"),
                    getPointView("প্রয়োজনে রোগের বিরুদ্ধে ব্যবস্থা নিন।"),
                    getPointView(
                        "আপনি যদি কোনো ভুল তথ্য পান তাহলে নির্দ্বিধায় আমাদের রিপোর্ট করুন।"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "রোগ শনাক্তকরণে আমাদের অ্যাপকে আরও ভালো করার জন্য আমরা সবসময় কাজ করে যাচ্ছি। আমাদের সাথে থাকার জন্য আপনাকে ধন্যবাদ।",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF09051C),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPointView(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        const Text("⬤"),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget getStepView(String number, String title, Widget content) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Divider(),
        Container(
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              NumberedRoundContainer(number: number),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF09051C),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
        content,
        const SizedBox(height: 8),
      ],
    );
  }
}

class NumberedRoundContainer extends StatelessWidget {
  final String number;

  const NumberedRoundContainer({super.key, required this.number});
  // ১২৩৪৫৬৭৮৯০
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 8, 55, 20),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Jolchobi',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

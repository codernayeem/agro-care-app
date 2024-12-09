import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';

class TTSButton extends StatefulWidget {
  final String text;
  const TTSButton({super.key, required this.text});

  @override
  State<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends State<TTSButton> {
  String? text;
  late FlutterTts flutterTts;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.awaitSpeakCompletion(true);
  }

  Future onSpeakClick() async {
    if (isPlaying) {
      _stopTts();
      setState(() {}); // to effect isPlaying = false
      return;
    }

    text ??= parse(HtmlUnescape().convert(widget.text)).body!.text;

    setState(() {
      isPlaying = true;
    });
    await flutterTts.speak(text!);
    setState(() {
      isPlaying = false;
    });
  }

  Future _stopTts() async {
    if (!isPlaying) return;
    await flutterTts.stop();
    isPlaying = false;
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: isPlaying
            ? const Color.fromARGB(255, 155, 202, 27).withOpacity(.9)
            : const Color.fromARGB(255, 64, 159, 91).withOpacity(.9),
      ),
      child: IconButton(
        onPressed: () {
          onSpeakClick();
        },
        icon: const Icon(
          Icons.volume_up_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}

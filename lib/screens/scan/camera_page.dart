import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'predict_crop_select_widget.dart';
import 'prediction_page.dart';
import 'scan_help_page.dart';

class CameraSettings {
  String cameraRes = "high";
}

class PredictCrop {
  final String bdName;
  final String enName;
  final String icon;

  const PredictCrop(this.bdName, this.enName, this.icon);
}

// tomato, potato, corn
List<PredictCrop> availableCrops = [
  const PredictCrop("টমেটো", "tomato", "assets/icons/tomato.png"),
  const PredictCrop("আলু", "potato", "assets/icons/potato.png"),
  const PredictCrop("ভুট্টা", "corn", "assets/icons/corn.png"),
];

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() {
    return _CameraPageState();
  }
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  Uuid uuid = const Uuid();
  File? imageFile;
  String imageFileId = "";
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;

  int selectedPredictCrop = 0;

  late BoxConstraints imageArea;
  late double imageAreaWidth;

  bool imageShowing = false;

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final CameraSettings p = CameraSettings();

    ResolutionPreset RP = ResolutionPreset.high;
    switch (p.cameraRes) {
      case "high":
        RP = ResolutionPreset.high;
        break;

      case "low":
        RP = ResolutionPreset.low;
        break;

      case "medium":
        RP = ResolutionPreset.medium;
        break;

      case "ultraHigh":
        RP = ResolutionPreset.ultraHigh;
        break;

      case "veryHigh":
        RP = ResolutionPreset.veryHigh;
        break;

      case "max":
        RP = ResolutionPreset.max;
        break;
    }

    controller = CameraController(
      firstCamera,
      enableAudio: false,
      RP,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<File?> _pickAndCropImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      cropStyle: CropStyle.rectangle,
      maxHeight: 256,
      maxWidth: 256,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: '${availableCrops[selectedPredictCrop].bdName} পাতা',
            toolbarColor: const Color.fromARGB(255, 59, 92, 39),
            hideBottomControls: true,
            showCropGrid: false,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        IOSUiSettings(
          title: '${availableCrops[selectedPredictCrop].bdName} পাতা',
        ),
      ],
    );

    File(pickedFile.path).delete();
    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  Future<bool> checkAndRequestPermissions() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    } else {
      PermissionStatus status =
          await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }

  void _onGalleryBtClick() async {
    await checkAndRequestPermissions();
    File? img = await _pickAndCropImage();
    if (img == null) return;

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionPage(
            key: const ValueKey("PredictPage"),
            img,
            0,
            uuid.v4(),
            selectedPredictCrop,
            false,
          ),
        ));
  }

  void onPredictCropClick(int indx) {
    selectedPredictCrop = indx;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _initializeCamera();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    if (imageFile != null) {
      imageFile!.delete();
    }
    controller?.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: statusBarHeight,
            width: double.infinity,
            color: Colors.black.withOpacity(.95),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.black),
              child: Center(
                child: imageShowing && imageFile != null
                    // ? Hero(tag: "selectedImage", child: Image.file(imageFile!))
                    ? _takenImageShowView()
                    : _cameraPreviewWidget(),
              ),
            ),
          ),
          _captureControlRowWidget(),
        ],
      ),
    );
  }

  Widget _takenImageShowView() {
    return Stack(
      alignment: Alignment.bottomCenter,
      fit: StackFit.passthrough,
      children: [
        // Hero(tag: "selectedImage", child: Image.file(imageFile!)),
        Positioned(
          child: Center(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Hero(
                        tag: "selectedImage",
                        child: Image.file(imageFile!, fit: BoxFit.cover)),
                  ),
                ),
                LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  imageArea = constraints;
                  return Center(
                    child: Container(
                      width: constraints.maxWidth - 40,
                      height: constraints.maxWidth - 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color.fromARGB(255, 161, 252, 164),
                            width: 4),
                      ),
                    ),
                  );
                }),
                _takenImageTopView(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Icon(Icons.camera_alt_outlined, color: Colors.grey);
    } else {
      return Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.passthrough,
        children: [
          Positioned(
            child: Center(
              child: CameraPreview(
                controller!,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  imageArea = constraints;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (TapDownDetails details) =>
                        onViewFinderTap(details, constraints),
                    child:
                        // // test
                        // Container(
                        //   decoration: BoxDecoration(
                        //       image: DecorationImage(
                        //         image: AssetImage('assets/nw1.png'),
                        //         fit: BoxFit.cover,
                        //       ),
                        //       ),
                        //   child:
                        Center(
                      child: Container(
                        width: constraints.maxWidth - 40,
                        height: constraints.maxWidth - 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                    ),
                    // ),
                  );
                }),
              ),
            ),
          ),
          PredictCropSelectWidget(
            key: const ValueKey("PredictCropSelectWidget"),
            onChange: onPredictCropClick,
            selected: selectedPredictCrop,
            availableCrops: availableCrops,
          ),
          _modeControlRowWidget(),
        ],
      );
    }
  }

  IconData getFlashIcon(FlashMode? md) {
    switch (md) {
      case FlashMode.auto:
        return Icons.flash_auto;

      case FlashMode.always:
        return Icons.flash_on;

      case FlashMode.torch:
        return Icons.highlight;

      default:
        return Icons.flash_off;
    }
  }

  Widget _takenImageTopView() {
    return Column(
      children: [
        Container(
          color: Colors.black45,
          padding: const EdgeInsets.all(8),
          child: Center(
            child: AutoSizeText(
              "${availableCrops[selectedPredictCrop].bdName} পাতাটি বাক্সের ভিতরে রয়েছে কিনা নিশ্চিত করুন",
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Hind Siliguri",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Display a bar with buttons to change the flash
  Widget _modeControlRowWidget() {
    FlashMode? md = controller?.value.flashMode;
    return Column(
      children: <Widget>[
        Container(
          color: Colors.black45,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.question_mark_rounded),
                color: const Color.fromARGB(255, 255, 255, 255),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ScanHelpPage(),
                    ),
                  );
                },
              ),
              const Spacer(),
              const Text(
                "রোগাক্রান্ত পাতার ছবি তুলুন",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Hind Siliguri",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(getFlashIcon(md)),
                color: const Color.fromARGB(255, 255, 255, 255),
                onPressed: controller != null ? onFlashModeButtonPressed : null,
              ),
            ],
          ),
        ),
        _flashModeControlRowWidget(),
      ],
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      axis: Axis.vertical,
      child: FadeTransition(
        opacity: _flashModeControlRowAnimation,
        child: ClipRect(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.flash_off),
                color: controller?.value.flashMode == FlashMode.off
                    ? Colors.orange[200]
                    : const Color.fromARGB(255, 255, 255, 255),
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.off)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.flash_auto),
                color: controller?.value.flashMode == FlashMode.auto
                    ? Colors.orange[200]
                    : const Color.fromARGB(255, 255, 255, 255),
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.flash_on),
                color: controller?.value.flashMode == FlashMode.always
                    ? Colors.orange[200]
                    : const Color.fromARGB(255, 255, 255, 255),
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.always)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.highlight),
                color: controller?.value.flashMode == FlashMode.torch
                    ? Colors.orange[200]
                    : const Color.fromARGB(255, 255, 255, 255),
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return Container(
      padding: const EdgeInsets.all(28),
      width: double.infinity,
      color: Colors.black,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: imageShowing
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.spaceBetween,
          children: [
            ...imageShowing
                ? [
                    FloatingActionButton(
                      heroTag: null,
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      onPressed: onConfirmingImage,
                      child: const Icon(
                        Icons.done,
                        color: Colors.green,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      onPressed: () {
                        if (imageFile != null) {
                          imageFile?.delete();
                          imageFile = null;
                        }
                        setState(() {
                          imageShowing = false;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ]
                : [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.withOpacity(.5))),
                      clipBehavior: Clip.hardEdge,
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: _onGalleryBtClick,
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "scanBT",
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      onPressed: cameraController != null &&
                              cameraController.value.isInitialized
                          ? onTakePictureButtonPressed
                          : null,
                      child: const Icon(Icons.camera_alt),
                    ),
                    const SizedBox(width: 54),
                  ],
          ],
        ),
      ),
    );
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      enableAudio: false,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted && file != null) {
        FirebaseAnalytics.instance.logEvent(
          name: "picture_taken",
        );
        setState(() {
          imageAreaWidth = imageArea.maxWidth - 40;
          imageFile = File(file.path);
          imageFileId = uuid.v4(); // generate new id
          imageShowing = true;
        });
      }
    });
  }

  void onConfirmingImage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionPage(
            key: const ValueKey("PredictPage"),
            imageFile!,
            imageAreaWidth,
            imageFileId,
            selectedPredictCrop,
            true,
          ),
        ));
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      _flashModeControlRowAnimationController.reverse();
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: Camera not Found');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button_upload_image.dart';
import '../../widgets/big_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class TakePictureScreen extends StatefulWidget {
  final String category;
  final String title;
  final String description;
  final String location;

  const TakePictureScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
  }) : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  final ImagePicker imagePicker = ImagePicker();

  List<XFile>? imageFileList = [];

  Future<void> selectImagesFromGallery() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
      setState(() {});
    }
  }

  Future<void> takePicture() async {
    final XFile? picture =
    await imagePicker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      imageFileList!.add(picture);
      setState(() {});
    }
  }

  void removeImage(int index) {
    setState(() {
      imageFileList!.removeAt(index);
    });
  }

  Future<List<int>> compressImage(
      String imagePath, int targetWidth, int targetHeight, int quality) async {
    List<int> imageBytes = await File(imagePath).readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;
    img.Image resizedImage =
    img.copyResize(image, width: targetWidth, height: targetHeight);
    return img.encodeJpg(resizedImage, quality: quality);
  }

  Future<void> compressAndCreateItem() async {
    List<String> compressedImagePaths = [];
    for (var imageFile in imageFileList!) {
      List<int> compressedImage = await compressImage(
          imageFile.path, 800, 600, 80); // Adjust parameters as needed
      // Save or upload the compressed image and get the new path
      // Example: saveToDisk(compressedImage, 'compressed_image.jpg');
      // String compressedImagePath = 'path/to/compressed_image.jpg';
      String compressedImagePath =
      await saveToDisk(compressedImage, 'compressed_image.jpg');
      compressedImagePaths.add(compressedImagePath);
    }

    // Now you can use compressedImagePaths to create the item
    await ItemController().createItem(
      widget.title,
      widget.description,
      widget.category,
      widget.location,
      compressedImagePaths,
    );
  }

  Future<String> saveToDisk(List<int> data, String fileName) async {
    final File file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsBytes(data);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(AppLayout.getHeight(20)),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                BigText(
                  text: "Create Items",
                  size: 20,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: AppLayout.getWidth(30), top: AppLayout.getHeight(10)),
              child: Text(
                'Create Items',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Gap(AppLayout.getHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButtonUpLoadImage(
                    boxColor: AppColors.primaryColor,
                    textButton: "Take photo",
                    onTap: () {
                      takePicture();
                    }),
                AppButtonUpLoadImage(
                    boxColor: AppColors.secondPrimaryColor,
                    textButton: "Upload a photo",
                    onTap: () {
                      selectImagesFromGallery();
                    }),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: imageFileList!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: AppLayout.getWidth(10),
                    mainAxisSpacing: AppLayout.getHeight(10),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            File(imageFileList![index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.xmark,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              removeImage(index);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: AppButton(
                  boxColor: AppColors.primaryColor,
                  textButton: "Create",
                  onTap: () async {
                    if (imageFileList!.isNotEmpty) {
                      await compressAndCreateItem();
                    } else {
                      SnackbarUtils().showError(
                          title: "Image", message: "You must add image");
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';

import '../../data/api/user/user_controller.dart';
import '../../widgets/app_button_upload_image.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<EditUserPage> {
  bool _isMounted = false;
  Map<String, dynamic> userList = {};

  final UserController userController = Get.put(UserController());
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  XFile? selectedImage;

  List<String> genderOptions = ['Male', 'Female'];

  Future<void> selectImageFromGallery() async {
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Call the API to upload the selected image
      final String newAvatarUrl = await userController.putAvatarUser(image.path);

      // Update the avatar URL in userList and the UI
      setState(() {
        userList['avatar'] = newAvatarUrl;
      });
    }
  }

  Future<void> takePicture() async {
    final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Call the API to upload the taken image
      final String newAvatarUrl = await userController.putAvatarUser(image.path);

      // Update the avatar URL in userList and the UI
      setState(() {
        userList['avatar'] = newAvatarUrl;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      await userController.getUserByUid().then((result) {
        if (_isMounted) {
          print("API Response: $result");
          setState(() {
            userList = result;
          });
        }
      });
    });
    firstNameController.text = userList['firstName']?? '';
    lastNameController.text = userList['lastName']?? '';
    genderController.text = userList['gender']?? '';
    phoneController.text = userList['phone']?? '';
  }

  @override
  Widget build(BuildContext context) {
    String userGender = userList['gender'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: userList != null && userList!.isNotEmpty
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: NetworkImage(userList['avatar']),
                          ),
                          Positioned(
                            bottom: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 4,
                                    color: Colors.white
                                  ),
                                  color: AppColors.primaryColor
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          // Make the content size fit its children
                                          children: [
                                            AppButtonUpLoadImage(
                                              boxColor: AppColors.primaryColor,
                                              textButton: "Take a photo",
                                              onTap: () {
                                                takePicture();
                                                Navigator.pop(
                                                    context); // Close the dialog after taking a photo
                                              },
                                            ),
                                            Gap(AppLayout.getHeight(20)),
                                            // Add a gap between the buttons
                                            AppButtonUpLoadImage(
                                              boxColor: AppColors.secondPrimaryColor,
                                              textButton: "Upload photo",
                                              onTap: () {
                                                selectImageFromGallery();
                                                Navigator.pop(
                                                    context); // Close the dialog after selecting an image
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  },
                                    child: Icon(Icons.edit, color: Colors.white,)),
                              )
                          ),
                        ],
                      ),
                    ),
                    Gap(AppLayout.getHeight(50)),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "First Name",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        hintText: userList['firstName'],
                      ),
                    ),
                    Gap(AppLayout.getHeight(20)),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Last Name",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        hintText: userList['lastName'],
                      ),
                    ),
                    Gap(AppLayout.getHeight(20)),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Gender",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                    DropdownButtonFormField<String>(
                      value: userGender, // Set the user's gender as the default value
                      items: genderOptions.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? selectedGender) {
                        setState(() {
                          genderController.text = selectedGender ?? '';
                        });
                      },
                      decoration: InputDecoration(
                        hintText: userGender, // Display the user's gender as the hint text
                      ),),
                    Gap(AppLayout.getHeight(20)),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Phone",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),

                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(hintText: userList['phone']),
                    ),
                    Gap(AppLayout.getHeight(100)),
                    AppButton(boxColor: AppColors.primaryColor, textButton: "Update", onTap: (){
                      userController.putUserByPostId(
                          firstNameController.text.isNotEmpty ? firstNameController.text : userList['firstName'],
                          lastNameController.text.isNotEmpty ? lastNameController.text : userList['lastName'],
                          genderController.text.isNotEmpty ? genderController.text : userList['gender'],
                          phoneController.text.isNotEmpty ? phoneController.text : userList['phone']
                      );
                      Navigator.pop(context);
                      })
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

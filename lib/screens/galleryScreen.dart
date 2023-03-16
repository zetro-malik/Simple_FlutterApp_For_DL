import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_training_1/widgets/SignInButton.dart';

class Model extends StatefulWidget {
  @override
  State<Model> createState() => _ModelState();
}

class _ModelState extends State<Model> {
  String url = "";
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Classroom Assistant"),
      ),
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Center(
            child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  )),
                  builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      maxChildSize: 0.9,
                      minChildSize: 0.32,
                      expand: false,
                      builder: (context, scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: widgetsInBottomSheet(),
                        );
                      }),
                );
              },
              child: _image == null
                  ? Container(child: Image.asset("assets/stock_imgs/user.png"))
                  : url == ""
                      ? Container(child: Image.file(_image!))
                      : Container(
                          child: Image.network(
                          url,
                          width: 500,
                          height: 500,
                        )),
            ),
            SizedBox(
              height: 50,
            ),
            Transform.scale(
              scale: 2,
              child: ElevatedButton(
                  onPressed: (() async {
                    if (_image != null) {
                      await sendPic(_image!);
                    }
                  }),
                  child: Text("Detect")),
            )
          ],
        )),
      ),
    );
  }

  Future getImage(bool FromCamera) async {
    url = "";
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(
        source: FromCamera ? ImageSource.camera : ImageSource.gallery);
    if (image == null) {
      return;
    }
    final tempImg = File(image.path);
    setState(() {
      _image = tempImg;
    });
  }

  Widget widgetsInBottomSheet() {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      clipBehavior: Clip.none,
      children: [
        tipOnBottomSheet(),
        Column(children: [
          const SizedBox(
            height: 100,
          ),
          SignInButton(
            onTap: () {
              getImage(true);
              Navigator.pop(context);
            },
            iconPath: 'assets/logos/camera.png',
            textLabel: 'Take from camera',
            backgroundColor: Colors.grey.shade300,
            elevation: 0.0,
          ),
          const SizedBox(
            height: 40,
          ),
          SignInButton(
            onTap: () {
              getImage(false);
              Navigator.pop(context);
            },
            iconPath: 'assets/logos/gallery.png',
            textLabel: 'Take from gallery',
            backgroundColor: Colors.grey.shade300,
            elevation: 0.0,
          ),
        ])
      ],
    );
  }

  Widget tipOnBottomSheet() {
    return Positioned(
      top: -15,
      child: Container(
        width: 60,
        height: 7,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      ),
    );
  }

  //http://127.0.0.1:8009/uploads\\aa.jpg
  Future<void> sendPic(File file) async {
    var postUri = Uri.parse("http://192.168.127.52:8009/getmodel");

    var request = http.MultipartRequest('GET', postUri);
    request.files.add(await http.MultipartFile.fromPath('img', file.path));
    request.headers.addAll({'Content-type': 'multipart/formdata'});

    var res = await request.send();

    if (res.statusCode == 200) {
      var respStr = await res.stream.bytesToString();
      url = "http://192.168.127.52:8009" + respStr.toString();
      setState(() {});
    } else {
      print('failed to upload...');
    }
  }
}

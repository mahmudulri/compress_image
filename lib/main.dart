import 'dart:typed_data';
import 'dart:io';
import 'package:compressimage/controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Compressor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MyimageController myimageController = Get.put(MyimageController());

  File? _selectedImage;
  String? originalFileSize;
  String? compressedFileSize;
  img.Image? compressedImage;

  bool compressing = false;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        originalFileSize = getFileSize(_selectedImage!);
      });
    }
  }

  Future<void> _compressImage80() async {
    final MyimageController myimageController = Get.put(MyimageController());
    if (_selectedImage == null) return;

    setState(() {
      compressing = true; // Set compressing to true when compression starts
    });

    final originalBytes = await _selectedImage!.readAsBytes();
    final List<int> compressedBytes =
        await FlutterImageCompress.compressWithList(
      originalBytes,
      minHeight: 1920,
      minWidth: 1080,
      quality: 80,
      rotate: 0,
    );

    final compressedImage =
        img.decodeImage(Uint8List.fromList(compressedBytes));

    setState(() {
      // this.compressedImage = compressedImage;
      myimageController.mycompressedImage = compressedImage;
      compressedFileSize = getFileSizeBytes(compressedBytes.length);
      compressing = false;
    });
  }

  Future<void> _compressImage70() async {
    if (_selectedImage == null) return;
    setState(() {
      compressing = true; // Set compressing to true when compression starts
    });

    final originalBytes = await _selectedImage!.readAsBytes();
    final List<int> compressedBytes =
        await FlutterImageCompress.compressWithList(
      originalBytes,
      minHeight: 1920,
      minWidth: 1080,
      quality: 70,
      rotate: 0,
    );

    final compressedImage =
        img.decodeImage(Uint8List.fromList(compressedBytes));

    setState(() {
      this.compressedImage = compressedImage;
      compressedFileSize = getFileSizeBytes(compressedBytes.length);
      compressing = false;
    });
  }

  Future<void> _compressImage60() async {
    if (_selectedImage == null) return;
    setState(() {
      compressing = true; // Set compressing to true when compression starts
    });

    final originalBytes = await _selectedImage!.readAsBytes();
    final List<int> compressedBytes =
        await FlutterImageCompress.compressWithList(
      originalBytes,
      minHeight: 1920,
      minWidth: 1080,
      quality: 60,
      rotate: 0,
    );

    final compressedImage =
        img.decodeImage(Uint8List.fromList(compressedBytes));

    setState(() {
      this.compressedImage = compressedImage;
      compressedFileSize = getFileSizeBytes(compressedBytes.length);
      compressing = false;
    });
  }

  String getFileSize(File file) {
    int fileSizeInBytes = file.lengthSync();
    return getFileSizeBytes(fileSizeInBytes);
  }

  String getFileSizeBytes(int fileSizeInBytes) {
    const int KB = 1024;
    const int MB = KB * 1024;

    if (fileSizeInBytes >= MB) {
      return '${(fileSizeInBytes / MB).toStringAsFixed(2)} MB';
    } else if (fileSizeInBytes >= KB) {
      return '${(fileSizeInBytes / KB).toStringAsFixed(2)} KB';
    } else {
      return '$fileSizeInBytes Bytes';
    }
  }

  Future<void> _saveCompressedImage() async {
    if (compressedImage != null) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/compressed_image.jpg';
      await File(filePath).writeAsBytes(img.encodeJpg(compressedImage!));

      // Save to gallery using image_gallery_saver
      await ImageGallerySaver.saveFile(filePath);

      // Display a message to indicate successful saving
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to gallery')),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Visibility(
      visible: compressing,
      child: Center(child: Text("Compressing....")),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Quick Image Compressor',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _selectedImage != null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    height: 150,
                    width: double.infinity,
                    child: Image.file(_selectedImage!))
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    height: 200,
                    child: Center(child: Text("Upload an Image")),
                  ),
            SizedBox(height: 5),
            originalFileSize == null
                ? Center(child: Text('Original File Size: ...'))
                : Center(child: Text('Original File Size: $originalFileSize')),
            SizedBox(height: 5),
            Container(height: 30, child: _buildProgressIndicator()),
            SizedBox(height: 5),
            Container(
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/icons/upload.png",
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _compressImage80,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "80%",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _compressImage70,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "70%",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _compressImage60,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "60%",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                myimageController.mycompressedImage != null
                    ? Container(
                        height: 230,
                        child: Image.memory(
                          Uint8List.fromList(
                            img.encodeJpg(myimageController.mycompressedImage!),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        height: 230,
                        child: Center(child: Text("Upload an Image")),
                      ),
                SizedBox(height: 5),
                compressedFileSize == null
                    ? Text("Compressed File Size: 0.00 KB")
                    : Text('Compressed File Size: $compressedFileSize'),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: _saveCompressedImage,
                  child: Text('Save to Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_disease_prediction/enums/plant_type.dart';
import 'package:plant_disease_prediction/service/api_service.dart';
import 'package:plant_disease_prediction/service/file_picker_service.dart';

import '../service/api_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PlantType? _plantType;
  File? _image;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  void onPlantTypeChanged(PlantType? val) {
    setState(() {
      _plantType = val;
    });
  }

  void onPickImage(ImageSource source) async {
    var res = await FilePicker.instance.pickImage(source);
    if (res != null) {
      setState(() {
        _image = File(res.path);
      });
    }
  }

  Future _onPredict() async {
    //validate if user has selected a plant type and image
    if (_image != null) {
      if (_plantType == null) {
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a plant type'),
          duration: Duration(seconds: 3),
        ));
      }
      setState(() {
        _isLoading = true;
      });
      var res = await ApiService.instance
          .getPrediction(file: _image!, plantType: _plantType!);
      setState(() {
        _isLoading = false;
      });
      if (res == null) {
        return showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  title: Text('Error'),
                  content: Text('Error getting prediction'),
                ));
      }
      String confidence = '${(res.confidence * 100).toStringAsFixed(2)}%';
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Results'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: 'Result: ',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                          children: [
                            TextSpan(
                                text: res.className,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400))
                          ]),
                    ),
                    RichText(
                      text: TextSpan(
                          text: 'Confidence: ',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                          children: [
                            TextSpan(
                                text: confidence,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400))
                          ]),
                    )
                  ],
                ),
              ));
      return;
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Please select an image'),
      duration: Duration(seconds: 3),
    ));
  }

  void _onSelectImage() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              // title: const Text('SELECT'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onPickImage(ImageSource.gallery);
                      },
                      child: const Text('GALLERY')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onPickImage(ImageSource.camera);
                      },
                      child: const Text('CAMERA'))
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final devSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLANT DISEASE DETECTION'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<PlantType>(
                hint: const Text('Select a plant type'),
                value: _plantType,
                items: PlantType.values
                    .map((e) => DropdownMenuItem<PlantType>(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: onPlantTypeChanged),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: devSize.height * .3,
              color: Colors.black12,
              child: Center(
                child: _image == null
                    ? const Text('Please select an image')
                    : Image.file(
                        _image!,
                        height: devSize.height * .3,
                        width: double.infinity,
                      ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: _onSelectImage, child: const Text('SELECT IMAGE')),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: _onPredict,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('MAKE A PREDICTION'))
          ],
        ),
      ),
    );
  }
}

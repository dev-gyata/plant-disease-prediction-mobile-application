import 'package:image_picker/image_picker.dart';

class FilePicker {
  static FilePicker instance = FilePicker._();
  FilePicker._();

  Future<XFile?> pickImage(ImageSource imageSource) async {
    var res =
        await ImagePicker.platform.getImageFromSource(source: imageSource);
    return res;
  }
}

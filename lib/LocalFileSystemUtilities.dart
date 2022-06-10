import 'package:path_provider/path_provider.dart';
import 'package:android_external_storage/android_external_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as pth;
import 'package:permission_handler/permission_handler.dart';



Future<String>  localPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String>  externalStorage() async {

  Permission.manageExternalStorage.request();

  var paths = await getExternalStorageDirectories();

  print(paths.length);

  paths.map((e) {print(e.path);});

  return  (await getExternalStorageDirectory()).path;

}


Future<Directory>  downloadsDirectory() async {
  final directory = await AndroidExternalStorage.getExternalStoragePublicDirectory(DirType.downloadDirectory);

  return Directory(directory);
}

Future<String>externalDirectory() async{
  Directory dir = await downloadsDirectory();
  return dir.parent.path;

}

Future<String>rootDirectory() async{
  return AndroidExternalStorage.getRootDirectory();

}

Future<String>_xtremDirectory() async{

  var path = pth.join(await externalDirectory(), 'Xtrem');
  var dir = Directory(path);
  if(!dir.existsSync()){
    dir.create(recursive:true);
  }
  return path;

}

Future<String>labelPath() async{
  var path = pth.join((await _xtremDirectory()), 'Labels');
  var dir = Directory(path);
  if(!dir.existsSync()){
    dir.create(recursive:true);
  }
  return path;

}

Future<String>dataPath() async{
  var path = pth.join((await _xtremDirectory()), 'Data');
  var dir = Directory(path);
  if(!dir.existsSync()){
    dir.create(recursive:true);
  }
  return path;

}

Future<String>settingsPath() async{
  var path = pth.join((await _xtremDirectory()), 'Settings');
  var dir = Directory(path);
  if(!dir.existsSync()){
    dir.create(recursive:true);
  }
  return path;

}




Future<File>  localFile (name ) async {
  final path = await localPath();
  return File('$path/name');
}

Future<String> readContent(File file) async {
  try {
    String contents = await file.readAsString();
    // Returning the contents of the file
    return contents;
  } catch (e) {
    // If encountering an error, return
    return 'Error!';
  }
}

Future<void> writeContent(name, data ) async {
  try {
    final file = await localFile(name);
    // Write the file
    return file.writeAsString(data);
  }catch (e){
    print("Error: $e");
  }
}

Future<List<String>> getFiles(String path,{ bool directories: true, bool files: true}) async{

  print("Getting files for $path");

  List<String> listFiles = [];
  Directory dir = Directory(path);

  dir.listSync().forEach((element) {
    String pth = element.path;
    if (directories && FileSystemEntity.isDirectorySync(pth)){
      listFiles.add(pth);
    }else if(files && FileSystemEntity.isFileSync(pth)){
      listFiles.add(pth);
    }
  });

  print("Found $listFiles");
  return (listFiles);
}

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getAppDocumentPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> getNotesFilePath() async {
  final appDocPath = await getAppDocumentPath();
  return join(appDocPath, 'notes.json');
}

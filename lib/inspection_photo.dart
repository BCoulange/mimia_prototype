// Notre modèle de données qui va correspondre à la base de données
import 'package:hive/hive.dart';
// Ceci génère automatiquement du code
part 'inspection_photo.g.dart';

// Le modèle ensuite parle pas mal de lui même...
@HiveType(typeId: 0)
class InspectionPhoto extends HiveObject {
  @HiveField(0)
  final String path;

  InspectionPhoto(this.path);
}

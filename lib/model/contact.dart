import 'package:hive/hive.dart';
part 'contact.g.dart';

@HiveType(typeId: 0)
class Contacts extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String contact;
 

  Contacts({ this.name = '', this.contact = ''});
}
import 'package:simpnot/simpnot.dart';

main() async {
  var o = Simplenote('hemish04082005@gmail.com', 'securenotesimple2005\$H');
  Note? k = await o.getNote("176ec3dc-31ff-49fd-90fc-c65fb6413b24");
  print(k?.content);
}

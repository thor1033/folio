import 'package:folio/app/app.dart';
import 'package:folio/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}

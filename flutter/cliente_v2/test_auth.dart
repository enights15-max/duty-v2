import 'package:local_auth/local_auth.dart';

void main() async {
  final auth = LocalAuthentication();
  print(auth.authenticate.toString());
}

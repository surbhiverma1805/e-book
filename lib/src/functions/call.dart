import 'package:url_launcher/url_launcher.dart';

call(phone) => launchUrl(Uri.parse('tel://$phone'));
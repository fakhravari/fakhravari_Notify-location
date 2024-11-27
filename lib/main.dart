import 'package:app_links/app_links.dart';
import 'package:fakhravari/Config/TokenService.dart';
import 'package:fakhravari/Config/Tools.dart';
import 'package:fakhravari/Config/themes.dart';
import 'package:fakhravari/Pages/SplashScreen.dart';
import 'package:fakhravari/ServiceControlScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final appLinks = AppLinks();
BuildContext? globalContext;
String Idunique = '';
Future<void> initUniLinks() async {
  try {
    appLinks.uriLinkStream.listen((uri) async {
      var fil = Uri.parse(uri.toString().toLowerCase());
      await OpenDeteils(fil);
    }, onError: (err) {
      print(err.toString());
    });
  } catch (ee) {}
}

Future<void> OpenDeteils(Uri Url) async {
  final isLoggedIn = await TokenService().getTokens();
  if (isLoggedIn != null && isLoggedIn.mobileActive == false) {
    return;
  }
  if (Url.queryParameters['timer'] == null ||
      Url.queryParameters['status'] == null ||
      Url.queryParameters['num'] == null) {
    return;
  }

  if (Idunique != Url.queryParameters['num'].toString()) {
    Idunique = Url.queryParameters['num'].toString();

    Tools.SetTimer(int.parse((Url.queryParameters['timer'].toString())), false);
    Tools.statusService(bool.parse(Url.queryParameters['status'].toString()));

    await Get.offAll(ServiceControlScreen());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initUniLinks();

  Tools.SetTimer(10, true);
  Get.put(ServiceController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return GetMaterialApp(
      theme: AppThemes.light(),
      locale: Locale('fa', 'IR'),
      builder: (context, widget) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: widget!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: SplashScreen(),
    );
  }
}

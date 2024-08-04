import 'dart:ui';

import 'package:arche/arche.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:superuser/superuser.dart';
import 'package:system_fonts/system_fonts.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/models/config.dart';
import 'package:wslconfigurer/models/key.dart';
import 'package:wslconfigurer/views/pages/doctor.dart';
import 'package:wslconfigurer/views/pages/manage.dart';
import 'package:wslconfigurer/views/pages/settings.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/pages/install.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeRust(assignRustSignal);
  // Init Config
  var config = ArcheBus.bus
      .provideof(instance: AppConfigs(ArcheConfig.path("app.config.json")));

  config.distroInfoUrl.getOrWrite(AppConfigs.defaultDistroInfoUrl);

  if (config.font.has()) {
    var font = await SystemFonts().loadFont(config.font.get());
    if (font == null) {
      config.font.delete();
    }
  }

  // Init I18n
  var i18n = I18n();
  await i18n.init(config.locale.tryGet());
  ArcheBus.bus.provide(i18n);
  // Start Launch App
  appWindow.size = const Size(750, 550);
  runApp(MyApp(key: appKey));
  appWindow.show();
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(750, 550);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    if (Superuser.isSuperuser) {
      win.title = "WSL Configurer (Admin)";
    } else {
      win.title = "WSL Configurer (User)";
    }

    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with RefreshMountedStateMixin {
  @override
  Widget build(BuildContext context) {
    var configs = ArcheBus.bus.of<AppConfigs>();
    var locale = context.i18n.locale.split("_");
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic,
          typography: Typography.material2021(),
          fontFamily: configs.font.tryGet(),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: darkDynamic,
          typography: Typography.material2021(),
          fontFamily: configs.font.tryGet(),
        ),
        home: WindowTitleBarBox(
          child: HomePage(
            key: rootKey,
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("en", "US"),
          Locale("zh", "CN"),
        ],
        locale: Locale(locale.first, locale.last),
        debugShowCheckedModeBanner: false,
        themeMode: configs.themeMode.getOrWrite(ThemeMode.system),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with RefreshMountedStateMixin {
  late AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onExitRequested: () async {
        finalizeRust();
        return AppExitResponse.exit;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _lifecycleListener.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: NavigationView(
          builder: (context, vertical, horizontal, state) => Column(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: WindowTitleBarBox(
                      child: Row(
                        children: [
                          Expanded(child: MoveWindow()),
                          const WindowButtons()
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: horizontal(),
                          onPanStart: (details) {
                            appWindow.startDragging();
                          },
                        ),
                        state.content,
                      ],
                    ),
                  )
                ],
              ),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          items: [
            PageContainer(
              key: UniqueKey(),
              title: context.i18n.getOrKey("home"),
              child: const Center(
                child: Text("TODO"),
              ),
            ).toItem(icon: const Icon(Icons.home)),
            PageContainer(
              key: UniqueKey(),
              title: context.i18n.getOrKey("install"),
              child: const InstallPage(),
            ).toItem(icon: const Icon(Icons.install_desktop)),
            PageContainer(
              key: UniqueKey(),
              title: context.i18n.getOrKey("manage"),
              child: const DistributionManagePage(),
            ).toItem(icon: const Icon(Icons.apps)),
            PageContainer(
              key: UniqueKey(),
              title: context.i18n.getOrKey("doctor"),
              child: const DoctorPage(),
            ).toItem(icon: const Icon(FontAwesomeIcons.userDoctor)),
            PageContainer(
              key: UniqueKey(),
              title: context.i18n.getOrKey("settings"),
              child: const SettingsPage(),
            ).toItem(icon: const Icon(Icons.settings)),
          ]),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    final closeButtonColors = WindowButtonColors(
        mouseOver: const Color(0xFFD32F2F),
        mouseDown: const Color(0xFFB71C1C),
        iconNormal: colorScheme.primary,
        iconMouseOver: Colors.white);

    final buttonColors = WindowButtonColors(
      iconNormal: colorScheme.primary,
      mouseOver: colorScheme.surfaceContainerHigh,
      mouseDown: colorScheme.surfaceContainerHighest,
    );
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

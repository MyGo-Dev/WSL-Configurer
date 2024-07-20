import 'dart:ui';

import 'package:arche/arche.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/models/config.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/pages/install.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';

void main() async {
  await initializeRust(assignRustSignal);
  WidgetsFlutterBinding.ensureInitialized();
  // Init Config
  var config = ArcheBus.bus
      .provideof(instance: AppConfigs(ArcheConfig.path("app.config.json")));
  // Init I18n
  var i18n = I18n();
  await i18n.init(config.locale.tryGet());
  ArcheBus.bus.provide(i18n);
  // Start Launch App
  appWindow.size = const Size(750, 550);
  runApp(const MyApp());
  appWindow.show();
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(750, 550);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "WSL Configurer";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic,
          typography: Typography.material2021(),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: darkDynamic,
          typography: Typography.material2021(),
        ),
        home: WindowTitleBarBox(
          child: const HomePage(),
        ),
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return NavigationView(
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
                      state.content
                    ],
                  ),
                )
              ],
            ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        items: [
          PageContainer(
            title: context.i18n.getOrKey("home"),
          ).toItem(icon: const Icon(Icons.home)),
          PageContainer(
            title: context.i18n.getOrKey("install"),
            child: const InstallPage(),
          ).toItem(icon: const Icon(Icons.install_desktop)),
          PageContainer(
            title: context.i18n.getOrKey("settings"),
          ).toItem(icon: const Icon(Icons.settings)),
        ]);
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

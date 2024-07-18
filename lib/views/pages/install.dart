import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/divider.dart';

class InstallPage extends StatefulWidget {
  const InstallPage({super.key});

  @override
  State<StatefulWidget> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  @override
  Widget build(BuildContext context) {
    return ScrollableContainer(
      children: [
        ListTile(
          leading: const Icon(FontAwesomeIcons.section),
          title: context.i18nText("install.prepare"),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card.filled(
            child: Column(
              children: [
                ListTile(
                  title: const Text("HyperV"),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_right_rounded)),
                ),
                const ListTile(
                  title: Text("WSL"),
                  trailing: Icon(Icons.check),
                )
              ],
            ),
          ),
        ),
        divider8,
        ListTile(
          leading: const Icon(FontAwesomeIcons.section),
          title: context.i18nText("Install Linux Distribution"),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card.filled(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Ubuntu"),
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.open_in_new)),
                ),
                ListTile(
                  title: const Text("ArchLinux"),
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.open_in_new)),
                )
              ],
            ),
          ),
        ),
        divider8,
        ListTile(
          leading: const Icon(FontAwesomeIcons.section),
          title: context.i18nText("Install Essential Packages(Optional)"),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card.filled(
            child: Column(
              children: [
                ListTile(
                  title: const Text("C (GCC)"),
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.copy)),
                ),
                ListTile(
                  title: const Text("C (Clang)"),
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.copy)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

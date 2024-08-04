import 'package:flutter/material.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/optional_features.dart';
import 'package:wslconfigurer/views/widgets/update_kernel.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<StatefulWidget> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        Widget Function(BuildContext context) builder;
        var route = settings.name ?? "/";
        if (route == "/optional_features") {
          builder = (context) => Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                ),
                body: const CheckOptionalFeatureWidget(),
              );
        } else {
          builder = (context) =>
              ScrollableContainer(padding: const EdgeInsets.all(8), children: [
                const DoctorFetaure(
                  descriptionKey: "0x800701bc",
                  solution: UpdateKernel(),
                ),
                DoctorFetaure(
                  descriptionKey: "optional_feature",
                  solution: ListTile(
                    title: context.i18nText("optional_features"),
                    trailing: FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed("/optional_features"),
                      child: context.i18nText("open"),
                    ),
                  ),
                ),
              ]);
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(opacity: animation, child: builder(context)),
        );
      },
    );
  }
}

class DoctorFetaure extends StatelessWidget {
  final String descriptionKey;
  final Widget? solution;
  const DoctorFetaure({super.key, required this.descriptionKey, this.solution});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: WidthInfCenterWidget(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              context.i18nMarkdown("doctor/$descriptionKey"),
              const Divider(),
              solution ?? const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}

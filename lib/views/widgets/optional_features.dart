import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:rinf/rinf.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/messages/windows.pb.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/process.dart';
import 'package:wslconfigurer/windows/ms_open.dart';
import 'package:wslconfigurer/windows/sh.dart';

class CheckOptionalFeatureWidget extends StatefulWidget {
  final Widget? nextWidget;

  const CheckOptionalFeatureWidget({super.key, this.nextWidget});

  @override
  State<StatefulWidget> createState() => _CheckOptionalFeatureWidgetState();
}

class _CheckOptionalFeatureWidgetState
    extends State<CheckOptionalFeatureWidget> {
  @override
  void initState() {
    super.initState();
    QueryOptionalFeature().sendSignalToRust();
  }

  Widget buildWidget(BuildContext context,
      AsyncSnapshot<RustSignal<OptionFeatures>> snapshot) {
    var signal = snapshot.data;
    if (signal == null) {
      return const SizedBox.expand(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var feats = signal.message.features;
    var featscount = feats.fold(0, (count, feat) => count + feat.installState);

    if (featscount == 2 && widget.nextWidget != null) {
      return widget.nextWidget!;
    }

    return ScrollableContainer(
      key: const ValueKey(false),
      children: [
        ListTile(
          leading: IconButton(
            onPressed: () {
              ComplexDialog.instance.text(
                context: context,
                content: Wrap(
                  spacing: 8,
                  direction: Axis.vertical,
                  children: [
                    context.i18nMarkdown("optional_features", true),
                    FilledButton(
                      onPressed: () => openMSSetting("optionalfeatures"),
                      child: context.i18nText("optional_features"),
                    )
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help),
          ),
          title: Row(
            children: [
              Text(
                  "${context.i18n.getOrKey("configure")} ${context.i18n.getOrKey("optional_features")}"),
            ],
          ),
          trailing: IconButton(
            onPressed: QueryOptionalFeature().sendSignalToRust,
            icon: const Icon(Icons.refresh),
          ),
        ),
        ...feats.map(
          (feat) => ListTile(
            title: Text(feat.caption),
            subtitle: Text(feat.name),
            trailing: feat.installState == 1
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      su(
                        context,
                        () => enableFeature(feat.name).then(
                          (process) => ComplexDialog.instance
                              .text(
                                context: context,
                                title: context.i18nText("output"),
                                content: SingleChildScrollView(
                                  child: ProcessText(
                                    process: process,
                                    latest: true,
                                  ),
                                ),
                              )
                              .then(
                                (_) =>
                                    QueryOptionalFeature().sendSignalToRust(),
                              ),
                        ),
                      );
                    },
                  ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: OptionFeatures.rustSignalStream,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: Durations.medium4,
          child: buildWidget(context, snapshot),
        );
      },
    );
  }
}

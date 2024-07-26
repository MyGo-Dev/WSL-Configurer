import 'package:arche/extensions/iter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:wslconfigurer/views/pages/manage_distro.dart';
import 'package:wslconfigurer/windows/wsl.dart';

class DistributionManagePage extends StatefulWidget {
  const DistributionManagePage({super.key});

  @override
  State<StatefulWidget> createState() => _DistributionManagePageState();
}

class _DistributionManagePageState extends State<DistributionManagePage> {
  String? current;
  Widget buildWidget() {
    if (current != null) {
      return DistroManagePage(distro: current!);
    }

    return FutureBuilder(
        future: WindowsSubSystemLinux.getAvailableDistro(),
        builder: (context, snapshot) {
          var data = snapshot.data;

          if (data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AnimationLimiter(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  children: data.enumerate(
                    (index, distro) {
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: (data.length ~/ 5) + 1,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: Card.filled(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => setState(() {
                                  current = distro;
                                }),
                                child: SizedBox.square(
                                  dimension: 80,
                                  child: Center(
                                    child: Text(distro),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Durations.medium4,
      child: buildWidget(),
    );
  }
}

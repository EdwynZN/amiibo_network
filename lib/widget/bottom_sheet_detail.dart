import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/widget/amiibo_button_toggle.dart';
import 'package:amiibo_network/widget/amiibo_info.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BottomSheetDetail extends ConsumerWidget {
  const BottomSheetDetail({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(keyAmiiboProvider);
    final Size size = MediaQuery.of(context).size;
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    int flex = 4;
    if (size.longestSide >= 800)
      padding = EdgeInsets.symmetric(
          horizontal: (size.width / 2 - 250).clamp(0.0, double.infinity));
    if (size.width >= 400) flex = 6;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: padding,
          child: Material(
            type: MaterialType.card,
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: LimitedBox(
                maxHeight: 250,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, left: 4.0),
                              child: Hero(
                                transitionOnUserGestures: true,
                                tag: key,
                                child: Image.asset(
                                  'assets/collection/icon_$key.png',
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                            ),
                            flex: 7,
                          ),
                          Expanded(
                            child: const Buttons(),
                            flex: 2,
                          ),
                        ],
                      ),
                      flex: flex,
                    ),
                    const VerticalDivider(indent: 10, endIndent: 10),
                    Expanded(
                      child: const AmiiboDetailInfo(),
                      flex: 7,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
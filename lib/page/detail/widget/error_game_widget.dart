import 'dart:io';

import 'package:amiibo_network/app/configuration/amiibo_info_configuration/configuration.dart';
import 'package:amiibo_network/entity/game/infrastructure/game_provider.dart';
import 'package:amiibo_network/page/detail/widget/empty_game.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class const ErrorGameWidget(final Object error, {super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(keyAmiiboProvider);
    final translate = S.of(context);
    final Widget child;
    final error = this.error;
    if (error is DioException) {
      if (error.response != null)
        switch (error.response!.statusCode) {
          case 404:
            child = const EmptyGames();
            break;
          default:
            child = Text(
              error.response!.statusMessage ?? translate.no_games_found,
              textAlign: .center,
            );
            break;
        }
      else if (error.error is SocketException &&
          (error.error as SocketException).osError != null) {
        child = TextButton(
          onPressed: () => ref.invalidate(gameProvider(id)),
          child: Text(translate.socket_exception),
        );
      } else
        child = Text(error.message ?? error.type.name);
    } else if (error is ArgumentError) {
      child = Text(translate.no_games_found, textAlign: .center);
    } else if (error is SocketException) {
      child = TextButton(
        onPressed: () => ref.invalidate(gameProvider(id)),
        child: Text(translate.socket_exception),
      );
    } else
      child = Text(error.toString());
    return Center(
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.headlineMedium,
        child: child,
      ),
    );
  }
}

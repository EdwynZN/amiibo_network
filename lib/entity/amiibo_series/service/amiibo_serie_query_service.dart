import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';

abstract interface class AmiiboSerieQueryService {
  Future<List<String>> category({required AmiiboCategory category});
}

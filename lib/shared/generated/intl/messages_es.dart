// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static String m0(count) =>
      "${Intl.plural(count, one: '+ 1 más', two: '+ 2 más', few: '+ ${count} más', other: '+ muchos más')}";

  static String m1(choice) =>
      "${Intl.select(choice, {'All': 'Todos', 'Owned': 'Adquiridos', 'Wishlist': 'Lista de deseos', 'Name': 'Nombre', 'Game': 'Juego', 'Figures': 'Todas las Figuras', 'Cards': 'Todas las Tarjetas', 'AmiiboSeries': 'Personal', 'other': '${choice}'})}";

  static String m2(character) => "Personaje: ${character}";

  static String m3(url) => "No se pudo ejecutar ${url}";

  static String m4(choice) =>
      "${Intl.select(choice, {'pokemon': 'Tengo que atraparlos!', 'pokeball': 'Tengo que atraparlos!', 'mario': 'Lo lamento, pero tu colección parece estar en otro castillo', 'mushroom': '1 colección extra aquí', 'pacman': 'Habmre por amiibos', 'pacmanGhost': '¿Hambre por amiibos?', 'link': 'Hyaaa!! (No hay amiibos aquí)', 'other': 'No hay nada que mostrar . . . aún'})}";

  static String m5(game) => "Juego: ${game}";

  static String m6(choice) =>
      "${Intl.select(choice, {'en': 'Inglés', 'es': 'Español', 'fr': 'Francés', 'other': 'Desconocido'})}";

  static String m7(choice) =>
      "${Intl.select(choice, {'true': 'Bloqueado', 'false': 'Desbloqueado', 'other': 'Desconocido'})}";

  static String m8(name) => "Nombre: ${name}";

  static String m9(choice) =>
      "${Intl.select(choice, {'Game': 'Juego', 'Name': 'Nombre', 'AmiiboSeries': 'Serie', 'other': '${choice}'})}";

  static String m10(serie) => "Serie: ${serie}";

  static String m11(choice) =>
      "${Intl.select(choice, {'true': 'Porcentaje', 'false': 'Fracción', 'other': 'Unknown'})}";

  static String m12(choice) =>
      "${Intl.select(choice, {'granted': 'Almacenamiento concedido', 'denied': 'Almacenamiento denegado', 'permanentlyDenied': 'Almacenamiento denegado', 'restricted': 'Almacenamiento restringido', 'other': 'Permiso de almacenamiento en estado desconocido'})}";

  static String m13(choice) =>
      "${Intl.select(choice, {'system': 'Sistema', 'light': 'Claro', 'dark': 'Oscuro', 'other': 'Autom.'})}";

  static String m14(type) => "Tipo: ${type}";

  static String m15(choice) =>
      "${Intl.select(choice, {'Figure': 'Figura', 'Card': 'Tarjeta', 'Yarn': 'Lana', 'Band': 'Type: Pulsera', 'other': 'Otro'})}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "actionText": MessageLookupByLibrary.simpleMessage("Compartir"),
    "all": MessageLookupByLibrary.simpleMessage("Todos"),
    "amazon_link_setting": MessageLookupByLibrary.simpleMessage(
      "Sitio de Amazon",
    ),
    "amazon_link_setting_subtitle": MessageLookupByLibrary.simpleMessage(
      "Escoge la tienda Amazon de tu país",
    ),
    "amiibo_type": MessageLookupByLibrary.simpleMessage("Tipo de Amiibo"),
    "amiibo_usage_count": m0,
    "appearance": MessageLookupByLibrary.simpleMessage("Apariencia"),
    "appearanceSubtitle": MessageLookupByLibrary.simpleMessage(
      "Más personalización",
    ),
    "asc": MessageLookupByLibrary.simpleMessage("Ascendente (A-Z)"),
    "au": MessageLookupByLibrary.simpleMessage("Australia"),
    "auto": MessageLookupByLibrary.simpleMessage("Sistema"),
    "boxed": MessageLookupByLibrary.simpleMessage("En caja"),
    "cancel": MessageLookupByLibrary.simpleMessage("¡Espera no!"),
    "cardNumber": MessageLookupByLibrary.simpleMessage("N° de tarjeta"),
    "cards": MessageLookupByLibrary.simpleMessage("Tarjetas"),
    "category": m1,
    "changelog": MessageLookupByLibrary.simpleMessage("Cambios"),
    "changelogSubtitle": MessageLookupByLibrary.simpleMessage("Novedades"),
    "character": m2,
    "collectionReset": MessageLookupByLibrary.simpleMessage(
      "Colleccción borrada",
    ),
    "color_mode": MessageLookupByLibrary.simpleMessage("Aspecto"),
    "console_3DS_platform": MessageLookupByLibrary.simpleMessage("3DS"),
    "couldNotLaunchUrl": m3,
    "createdOn": MessageLookupByLibrary.simpleMessage("Creado el"),
    "credits": MessageLookupByLibrary.simpleMessage("Créditos"),
    "creditsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Los que hicieron todo posible",
    ),
    "dark": MessageLookupByLibrary.simpleMessage("Oscuro"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Tema Oscuro"),
    "desc": MessageLookupByLibrary.simpleMessage("Descendente (Z-A)"),
    "donate": MessageLookupByLibrary.simpleMessage("Donaciones"),
    "done": MessageLookupByLibrary.simpleMessage("Listo"),
    "emptyMessageType": m4,
    "emptyPage": MessageLookupByLibrary.simpleMessage(
      "No hay nada que mostrar . . . aún",
    ),
    "emptyPageAction": MessageLookupByLibrary.simpleMessage(
      "Crea tu colección",
    ),
    "errorImporting": MessageLookupByLibrary.simpleMessage(
      "Este archivo no contiene una colección",
    ),
    "eu": MessageLookupByLibrary.simpleMessage("Europa"),
    "export": MessageLookupByLibrary.simpleMessage("Exportar"),
    "export_complete": MessageLookupByLibrary.simpleMessage("Archivo guardado"),
    "export_subtitle": MessageLookupByLibrary.simpleMessage(
      "Guarda un archivo de tu colección",
    ),
    "features": MessageLookupByLibrary.simpleMessage("Funcionalidades"),
    "figures": MessageLookupByLibrary.simpleMessage("Figuras"),
    "game": m5,
    "hide_caution": MessageLookupByLibrary.simpleMessage(
      "Precaución, deshabilitar una funcionalidad la escondera en toda la app",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Importar"),
    "import_subtitle": MessageLookupByLibrary.simpleMessage(
      "Restaura tu colección a partir de un archivo",
    ),
    "invalid_amiibo": MessageLookupByLibrary.simpleMessage(
      "Información no válida",
    ),
    "jp": MessageLookupByLibrary.simpleMessage("Japón"),
    "language": MessageLookupByLibrary.simpleMessage("Idioma"),
    "languageSubtitle": MessageLookupByLibrary.simpleMessage(
      "Escoja un idioma o use el del sistema",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Claro"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("Tema Claro"),
    "localization": m6,
    "lockTooltip": m7,
    "markdownError": MessageLookupByLibrary.simpleMessage(
      "Hubo un error al cargar el archivo",
    ),
    "mode": MessageLookupByLibrary.simpleMessage("Modo"),
    "na": MessageLookupByLibrary.simpleMessage("Norteamérica"),
    "name": m8,
    "no_date": MessageLookupByLibrary.simpleMessage("Próximamente"),
    "no_games_found": MessageLookupByLibrary.simpleMessage(
      "No existe una lista de juegos para este amiibo aún",
    ),
    "no_link_selected": MessageLookupByLibrary.simpleMessage("Sin preferencia"),
    "no_link_selected_subtitle": MessageLookupByLibrary.simpleMessage(
      "Se preguntará cuando se necesite",
    ),
    "notificationTitle": MessageLookupByLibrary.simpleMessage(
      "Archivo generado",
    ),
    "openAppSettings": MessageLookupByLibrary.simpleMessage("Cambiar"),
    "ownTooltip": MessageLookupByLibrary.simpleMessage("Adquirir"),
    "owned": MessageLookupByLibrary.simpleMessage("Adquiridos"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Política de Privacidad",
    ),
    "privacySubtitle": MessageLookupByLibrary.simpleMessage(
      "Términos y condiciones",
    ),
    "rate": MessageLookupByLibrary.simpleMessage("Califícame"),
    "recordMessage": MessageLookupByLibrary.simpleMessage(
      "Espera por favor, aún se está procesando tu petición anterior",
    ),
    "remaining": MessageLookupByLibrary.simpleMessage("Restante"),
    "removeTooltip": MessageLookupByLibrary.simpleMessage("Remover"),
    "reportBug": MessageLookupByLibrary.simpleMessage("Reportar error"),
    "reset": MessageLookupByLibrary.simpleMessage("Restablecer"),
    "resetContent": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro? Esta acción no se puede deshacer",
    ),
    "resetSubtitle": MessageLookupByLibrary.simpleMessage(
      "borrar tu colección y lista de deseos",
    ),
    "resetTitleDialog": MessageLookupByLibrary.simpleMessage(
      "Borrar tu colección",
    ),
    "saveCollection": MessageLookupByLibrary.simpleMessage("Guardar Colección"),
    "saveCollectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Guarda una imagen de tu colección",
    ),
    "saveCollectionTitleDialog": MessageLookupByLibrary.simpleMessage(
      "Selecciona tu colección",
    ),
    "saveStatsTooltip": MessageLookupByLibrary.simpleMessage(
      "Guardar Estadísticas",
    ),
    "savingCollectionMessage": MessageLookupByLibrary.simpleMessage(
      "Guardando tu colección, esto podría demorar dependiendo de tu dispositivo",
    ),
    "searchCategory": m9,
    "select_user_attribute": MessageLookupByLibrary.simpleMessage(
      "Seleccione una categoría",
    ),
    "serie": m10,
    "settings": MessageLookupByLibrary.simpleMessage("Opciones"),
    "showGrid": MessageLookupByLibrary.simpleMessage("Cuadrícula"),
    "showOwnerCategories": MessageLookupByLibrary.simpleMessage(
      "Mostrar categorías de propietario",
    ),
    "showOwnerCategoriesDetails": MessageLookupByLibrary.simpleMessage(
      "Permite visualizar los amiibos adquiridos en caja y sin caja",
    ),
    "showPercentage": MessageLookupByLibrary.simpleMessage(
      "Mostrar porcentaje",
    ),
    "socket_exception": MessageLookupByLibrary.simpleMessage(
      "Revisa tu conexión",
    ),
    "sort": MessageLookupByLibrary.simpleMessage("Ordenar por"),
    "sortName": MessageLookupByLibrary.simpleMessage("Nombre"),
    "splashError": MessageLookupByLibrary.simpleMessage(
      "Error al actualizar ☹",
    ),
    "splashMessage": MessageLookupByLibrary.simpleMessage(
      "Espere un momento...",
    ),
    "splashWelcome": MessageLookupByLibrary.simpleMessage("Bienvenido"),
    "statTooltip": m11,
    "stats": MessageLookupByLibrary.simpleMessage("Estadísticas"),
    "storagePermission": m12,
    "successImport": MessageLookupByLibrary.simpleMessage(
      "Colección actualizada",
    ),
    "support": MessageLookupByLibrary.simpleMessage("Soporte"),
    "sure": MessageLookupByLibrary.simpleMessage("Seguro"),
    "switch_platform": MessageLookupByLibrary.simpleMessage("Switch"),
    "system": MessageLookupByLibrary.simpleMessage("Sistema"),
    "themeMode": m13,
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "type": m14,
    "types": m15,
    "unboxed": MessageLookupByLibrary.simpleMessage("Abiertos"),
    "upToolTip": MessageLookupByLibrary.simpleMessage("Arriba"),
    "use_in_app_browser": MessageLookupByLibrary.simpleMessage(
      "Abrir links de afiliación dentro de la app",
    ),
    "use_in_app_browser_subtitle": MessageLookupByLibrary.simpleMessage(
      "Los links se abriran de manera interna",
    ),
    "use_wallpaper": MessageLookupByLibrary.simpleMessage("Color dinámico"),
    "use_wallpaper_subtitle": MessageLookupByLibrary.simpleMessage(
      "Use tu fondo de pantalla como tema de color",
    ),
    "wiiu_platform": MessageLookupByLibrary.simpleMessage("WiiU"),
    "wishTooltip": MessageLookupByLibrary.simpleMessage("Desear"),
    "wished": MessageLookupByLibrary.simpleMessage("Deseados"),
  };
}

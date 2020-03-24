// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static m0(choice) => "${Intl.select(choice, {'All': 'Todos', 'Owned': 'Adquiridos', 'Wishlist': 'Lista de deseos', 'Name': 'Nombre', 'Game': 'Juego', 'AmiiboSeries': 'Serie', 'Figures': 'Todas las Figuras', 'Cards': 'Todas las Tarjetas', 'other': '${choice}', })}";

  static m1(character) => "Personaje: ${character}";

  static m2(url) => "No se pudo ejecutar ${url}";

  static m3(game) => "Juego: ${game}";

  static m4(name) => "Nombre: ${name}";

  static m5(serie) => "Serie: ${serie}";

  static m6(choice) => "${Intl.select(choice, {'granted': 'Almacenamiento concedido', 'denied': 'Almacenamiento denegado', 'neverAskAgain': 'Almacenamiento deshabilitado', 'restricted': 'Almacenamiento restringido', 'other': 'Permiso de almacenamiento en estado desconocido', })}";

  static m7(choice) => "${Intl.select(choice, {'system': 'Autom.', 'light': 'Claro', 'dark': 'Oscuro', 'other': 'Autom.', })}";

  static m8(type) => "Tipo: ${type}";

  static m9(choice) => "${Intl.select(choice, {'Figure': 'Tipo: Figura', 'Card': 'Tipo: Tarjeta', 'Yarn': 'Tipo: Lana', 'other': 'Tipo: Otro', })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "all" : MessageLookupByLibrary.simpleMessage("Todos"),
    "appearance" : MessageLookupByLibrary.simpleMessage("Apariencia"),
    "appearanceSubtitle" : MessageLookupByLibrary.simpleMessage("Más personalización"),
    "asc" : MessageLookupByLibrary.simpleMessage("Ascendente (A-Z)"),
    "au" : MessageLookupByLibrary.simpleMessage("Australia"),
    "auto" : MessageLookupByLibrary.simpleMessage("Automático"),
    "cancel" : MessageLookupByLibrary.simpleMessage("¡Espera no!"),
    "cards" : MessageLookupByLibrary.simpleMessage("Tarjetas"),
    "category" : m0,
    "changelog" : MessageLookupByLibrary.simpleMessage("Cambios"),
    "changelogSubtitle" : MessageLookupByLibrary.simpleMessage("Novedades"),
    "character" : m1,
    "collectionReset" : MessageLookupByLibrary.simpleMessage("Colleccción borrada"),
    "couldNotLaunchUrl" : m2,
    "createdOn" : MessageLookupByLibrary.simpleMessage("Creado el"),
    "credits" : MessageLookupByLibrary.simpleMessage("Créditos"),
    "creditsSubtitle" : MessageLookupByLibrary.simpleMessage("Los que hicieron todo posible"),
    "dark" : MessageLookupByLibrary.simpleMessage("Oscuro"),
    "darkTheme" : MessageLookupByLibrary.simpleMessage("Tema Oscuro"),
    "desc" : MessageLookupByLibrary.simpleMessage("Descendente (Z-A)"),
    "done" : MessageLookupByLibrary.simpleMessage("Listo"),
    "emptyPage" : MessageLookupByLibrary.simpleMessage("No hay nada que mostrar . . . aún"),
    "errorImporting" : MessageLookupByLibrary.simpleMessage("Este archivo no contiene una colección"),
    "eu" : MessageLookupByLibrary.simpleMessage("Europa"),
    "export" : MessageLookupByLibrary.simpleMessage("Exportar"),
    "figures" : MessageLookupByLibrary.simpleMessage("Figuras"),
    "fileSaved" : MessageLookupByLibrary.simpleMessage("Tú archivo ha sido"),
    "game" : m3,
    "import" : MessageLookupByLibrary.simpleMessage("Importar"),
    "jp" : MessageLookupByLibrary.simpleMessage("Japón"),
    "light" : MessageLookupByLibrary.simpleMessage("Claro"),
    "lightTheme" : MessageLookupByLibrary.simpleMessage("Tema Claro"),
    "markdownError" : MessageLookupByLibrary.simpleMessage("Hubo un error al cargar el archivo"),
    "mode" : MessageLookupByLibrary.simpleMessage("Modo"),
    "na" : MessageLookupByLibrary.simpleMessage("Norteamérica"),
    "name" : m4,
    "openAppSettings" : MessageLookupByLibrary.simpleMessage("cambiar"),
    "overwritten" : MessageLookupByLibrary.simpleMessage("sobreescrito"),
    "ownTooltip" : MessageLookupByLibrary.simpleMessage("Adquirir"),
    "owned" : MessageLookupByLibrary.simpleMessage("Adquiridos"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Política de Privacidad"),
    "privacySubtitle" : MessageLookupByLibrary.simpleMessage("Términos y condiciones"),
    "rate" : MessageLookupByLibrary.simpleMessage("Califícame"),
    "recordMessage" : MessageLookupByLibrary.simpleMessage("Espera por favor, aún se está procesando tu petición anterior"),
    "removeTooltip" : MessageLookupByLibrary.simpleMessage("Remover"),
    "reportBug" : MessageLookupByLibrary.simpleMessage("Reportar error"),
    "reset" : MessageLookupByLibrary.simpleMessage("Restablecer"),
    "resetContent" : MessageLookupByLibrary.simpleMessage("¿Estás seguro? Esta acción no se puede deshacer"),
    "resetSubtitle" : MessageLookupByLibrary.simpleMessage("borrar tu colección y lista de deseos"),
    "resetTitleDialog" : MessageLookupByLibrary.simpleMessage("Borrar tu colección"),
    "saveCollection" : MessageLookupByLibrary.simpleMessage("Guardar Colección"),
    "saveCollectionSubtitle" : MessageLookupByLibrary.simpleMessage("Guarda una imagen de tu colección"),
    "saveCollectionTitleDialog" : MessageLookupByLibrary.simpleMessage("Selecciona tu colección"),
    "saveStatsTooltip" : MessageLookupByLibrary.simpleMessage("Guardar Estadísticas"),
    "saved" : MessageLookupByLibrary.simpleMessage("guardado"),
    "savingCollectionMessage" : MessageLookupByLibrary.simpleMessage("Guardando tu colección, esto podría demorar dependiendo de tu dispositivo"),
    "serie" : m5,
    "settings" : MessageLookupByLibrary.simpleMessage("Opciones"),
    "showPercentage" : MessageLookupByLibrary.simpleMessage("Mostrar porcentaje"),
    "sort" : MessageLookupByLibrary.simpleMessage("Ordenar por"),
    "sortName" : MessageLookupByLibrary.simpleMessage("Nombre"),
    "splashError" : MessageLookupByLibrary.simpleMessage("Error al actualizar ☹"),
    "splashMessage" : MessageLookupByLibrary.simpleMessage("Espere un momento..."),
    "splashWelcome" : MessageLookupByLibrary.simpleMessage("Bienvenido"),
    "stats" : MessageLookupByLibrary.simpleMessage("Estadísticas"),
    "storagePermission" : m6,
    "successImport" : MessageLookupByLibrary.simpleMessage("Colección actualizada"),
    "sure" : MessageLookupByLibrary.simpleMessage("Seguro"),
    "themeMode" : m7,
    "type" : m8,
    "types" : m9,
    "upToolTip" : MessageLookupByLibrary.simpleMessage("Arriba"),
    "wishTooltip" : MessageLookupByLibrary.simpleMessage("Desear"),
    "wished" : MessageLookupByLibrary.simpleMessage("Deseados")
  };
}

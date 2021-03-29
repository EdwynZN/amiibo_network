import 'dart:typed_data';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/riverpod/stat_provider.dart' as stat;
import 'package:flutter/rendering.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amiibo_network/model/amiibo.dart';

class Screenshot {
  ThemeData theme;
  stat.StatProvider statProvider;
  MaterialLocalizations materialLocalizations;
  String owned;
  String wished;
  String createdOn;

  final S _translate = S.current;
  final Service _service = Service();
  final Paint ownedCardPaint = Paint()..color = colorOwned[100];
  final Paint wishedCardPaint = Paint()..color = colorWished[100];
  final double margin = 20.0;
  final double padding = 10.0;
  final double space = 0.25;
  final double banner = 100;

  static final Screenshot _instance = Screenshot._();
  factory Screenshot() => _instance;
  Screenshot._();

  Canvas _canvas;
  ui.PictureRecorder _recorder;
  bool get isRecording {
    final bool hasCanvas = _canvas != null;
    assert(() {
      if (hasCanvas) {
        assert(_recorder != null);
        assert(_canvas != null);
      } else {
        assert(_recorder == null);
        assert(_canvas == null);
      }
      return true;
    }());
    return hasCanvas;
  }

  void _startRecording([Rect rect = Rect.largest]) {
    assert(!isRecording);
    _recorder = ui.PictureRecorder();
    _canvas = Canvas(_recorder, rect);
  }

  void update(BuildContext context) {
    this..theme = Theme.of(context)
      ..statProvider = context.read(stat.statProvider)
      ..owned = _translate.owned
      ..wished = _translate.wished
      ..createdOn= _translate.createdOn
      ..materialLocalizations = MaterialLocalizations.of(context);
  }

  Future<Uint8List> saveCollection(Expression expression) async{
    List<Amiibo> amiibos = await _service.fetchByCategory(expression: expression,
        orderBy: 'CASE WHEN type = "Figure" THEN 1 ''WHEN type = "Yarn" THEN 2 ELSE 3 END, amiiboSeries DESC, na DESC');
    Map<String,dynamic> _listStat = Map<String, dynamic>.from(
        (await _service.fetchSum(expression: expression)).first);
    if(isRecording || (amiibos?.isEmpty ?? true) || _listStat == null) return null;

    final double maxSize = 60.0;
    final double width = (amiibos.length / 25.0).ceilToDouble().clamp(15.0, 30.0);
    final double maxX = (width * (1 + space) - space) * (maxSize + 2*padding) + 2*margin;
    final double maxY = ((amiibos.length / width).ceilToDouble()
        * (1 + 0.5*space) - 0.5*space) * (1.5*maxSize + 2*padding) + banner + 2*margin;
    double xOffset = margin;
    double yOffset = margin;
    _startRecording(Rect.fromPoints(Offset.zero, Offset(maxX, maxY)));

    final Paint paint = Paint()..color = theme.scaffoldBackgroundColor;
    _canvas.drawColor(paint.color, BlendMode.src);
    await _paintBanner(Size(maxX, maxY), _listStat);

    for(Amiibo amiibo in amiibos) {
      final String strImage = 'assets/collection/icon_${amiibo.key}.png';
      final Offset _offset = Offset(xOffset, yOffset);
      final RRect cardPath = RRect.fromRectAndRadius(
          Rect.fromPoints(
              _offset,
              _offset.translate(maxSize + 2*padding, 1.5*maxSize + 2*padding)
          ),
          Radius.circular(8.0)
      );
      final ByteData imageAsset = await rootBundle.load(strImage);

      if((amiibo?.owned ?? false) || (amiibo?.wishlist ?? false)){
        _canvas.drawRRect(cardPath,
            amiibo?.owned ?? false ? ownedCardPaint : wishedCardPaint);
      }

      ui.Image _image = await ui.instantiateImageCodec(
        imageAsset.buffer.asUint8List(),
        targetWidth: maxSize.toInt(),
      ).then((codec) => codec.getNextFrame()).then((frame) => frame.image);

      final bool taller = _image.width > 1.3*_image.height;
      _canvas.drawImageNine(_image,
          Rect.fromCenter(
              center: Offset.zero,
              width: _image.height.toDouble()*1.5,
              height: _image.width.toDouble()
          ),
          Rect.fromLTRB(
              _offset.dx + padding,
              (taller ? _offset.dy + 1.4 * maxSize - _image.height : _offset.dy) + padding,
              _offset.dx + maxSize + padding,
              _offset.dy + 1.5*maxSize + padding
          ),
          paint
      );
      _image.dispose();

      xOffset += (1 + space) * (maxSize + 2*padding);
      if(xOffset >= maxX - margin){
        xOffset = margin;
        yOffset += (1 + 0.5*space)*(1.5*maxSize + 2*padding);
      }
    }

    return await _saveFile(maxX.toInt(), maxY.toInt());
  }

  Future<Uint8List> saveStats(Expression expression) async{
    final List<Map<String, dynamic>> stats = await _service.fetchSum(group: true, expression: expression);
    final List<Map<String, dynamic>> general = await _service.fetchSum(expression: expression);

    if(isRecording || (stats?.isEmpty ?? true) || (general?.isEmpty ?? true)) return null;

    final String longestWord = owned.length > wished.length ? owned : wished;
    final bool fontFeatureStyle = !statProvider.isPercentage && stat.isFontFeatureEnable;
    /// Activate fontFeature only if StatMode is Ratio and isFontFeatureEnable is true for this device
    TextSpan longestParagraphTest = TextSpan(
      style: TextStyle(
        fontSize: fontFeatureStyle ? 35 : 30,
        height: fontFeatureStyle ? 1 : null,
        fontFeatures: [
          if(fontFeatureStyle) ui.FontFeature.enable('frac'),
          if(!fontFeatureStyle) ui.FontFeature.tabularFigures()
        ],
      ),
      text: statProvider.isPercentage ? '99.99%' : '99/100',
      children: [
        TextSpan(
          style: TextStyle(fontSize: 30),
          text: ' $longestWord'
        )
      ]
    );
    TextPainter _textPainter = TextPainter(text: longestParagraphTest, textDirection: TextDirection.ltr, maxLines: 1)
      ..layout(minWidth: 200, maxWidth: double.infinity);

    final double internalPadding = padding;
    final double cardSizeX = (2*internalPadding + 75 + _textPainter.width).clamp(300.0, double.infinity);
    final double cardSizeY = 240;
    final double width = (stats.length / 5.0).ceilToDouble().clamp(4.0, 10.0);
    final double maxX = (width * (1 + space) - space) * (cardSizeX + 2*padding) + 2*margin;
    final double maxY = ((stats.length / width).ceilToDouble()
        * (1 + 0.5*space) - 0.5*space) * (cardSizeY + 2*padding) + banner + 2*margin;
    double xOffset = margin;
    double yOffset = margin;
    _startRecording(Rect.fromPoints(Offset.zero, Offset(maxX, maxY)));

    final Paint paint = Paint()..color = theme.scaffoldBackgroundColor;
    final Paint cardColor = Paint()..color = theme.cardTheme.color;
    final Color textColor = theme.textTheme.headline6.color;
    final Paint divider = Paint()..color = theme.dividerColor..strokeWidth = 2;
    if(theme.scaffoldBackgroundColor == Colors.black)
      cardColor..color = const Color(0xFF2B2922)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

    _canvas.drawColor(paint.color, BlendMode.src);

    await _paintBanner(Size(maxX, maxY), general.first);

    final iconWhatsHot = Icons.whatshot;
    final TextSpan ownedIcon = TextSpan(
      style: TextStyle(color: colorOwned, fontFamily: iconOwnedDark.fontFamily, fontSize: 50,),
      text: String.fromCharCode(iconOwnedDark.codePoint),
    );
    final TextSpan wishedIcon = TextSpan(
      style: TextStyle(color: colorWished, fontFamily: iconWhatsHot.fontFamily, fontSize: 50,),
      text: String.fromCharCode(iconWhatsHot.codePoint),
    );

    for(Map<String,dynamic> singleStat in stats) {
      final Offset _offset = Offset(xOffset, yOffset);
      final RRect cardPath = RRect.fromRectAndRadius(
        Rect.fromPoints(_offset,
          _offset.translate(cardSizeX + 2*padding, cardSizeY + 2*padding)),
        Radius.circular(8.0)
      );
      final double ownedPercent = singleStat['Owned'].toDouble() / singleStat['Total'].toDouble();
      final double wishedPercent = singleStat['Wished'].toDouble() / singleStat['Total'].toDouble();
      final String ownedStat = statProvider.statLabel(singleStat['Owned'].toDouble(),
        singleStat['Total'].toDouble()
      );
      final String wishedStat = statProvider.statLabel(singleStat['Wished'].toDouble(),
        singleStat['Total'].toDouble()
      );
      _canvas.drawRRect(cardPath, cardColor);

      TextSpan title = TextSpan(
        style: TextStyle(color: textColor, fontSize: 25),
        text: singleStat['amiiboSeries'],
      );
      TextPainter(text: title, textDirection: TextDirection.ltr, ellipsis: '\u2026',
        textAlign: TextAlign.center, maxLines: 1)..layout(minWidth: cardSizeX, maxWidth: cardSizeX)
        ..paint(_canvas, Offset(xOffset + padding, yOffset + padding));

      _canvas..drawLine(_offset.translate(padding, 40 + padding),
          _offset.translate(cardSizeX + padding, 40 + padding), divider);

      TextSpan ownedText = TextSpan(
        style: TextStyle(color: textColor, fontSize: fontFeatureStyle ? 35 : 30,
          height: fontFeatureStyle ? 1 : null,
          fontFeatures: [
            if(fontFeatureStyle) ui.FontFeature.enable('frac'),
            if(!fontFeatureStyle) ui.FontFeature.tabularFigures()
          ],
        ),
        text: ownedStat,
          children: [
            TextSpan(
              style: TextStyle(color: textColor, fontSize: 30,),
              text: ' $owned'
            )
          ]
      );
      TextPainter(text: ownedText, textDirection: TextDirection.ltr, maxLines: 1)
        ..layout(minWidth: cardSizeX - 2* internalPadding - 75,
            maxWidth: cardSizeX - 2* internalPadding - 75)
        ..paint(_canvas, _offset.translate(padding + 75, 62.5 + padding + 25));

      TextSpan wishedText = TextSpan(
          style: TextStyle(color: textColor, fontSize: fontFeatureStyle ? 35 : 30,
            height: fontFeatureStyle ? 1 : null,
            fontFeatures: [
              if(fontFeatureStyle) ui.FontFeature.enable('frac'),
              if(!fontFeatureStyle) ui.FontFeature.tabularFigures()
            ],
          ),
          text: wishedStat,
        children: [
          TextSpan(
              style: TextStyle(color: textColor, fontSize: 30,),
              text: ' $wished'
          )
        ]
      );
      TextPainter(text: wishedText, textDirection: TextDirection.ltr, maxLines: 1)
        ..layout(minWidth: cardSizeX - 2* internalPadding - 75,
            maxWidth: cardSizeX - 2* internalPadding - 75)
        ..paint(_canvas, _offset.translate(padding + 75, 142.5 + padding + 25));

      _paintSquareStat(_offset.translate(padding, 50 + padding + 25),
          _offset.translate(cardSizeX + padding, 110 + padding + 25), ownedPercent, ownedIcon);
      _paintSquareStat(_offset.translate(padding, 130 + padding + 25),
          _offset.translate(cardSizeX + padding, 190 + padding + 25), wishedPercent, wishedIcon);

      xOffset += (1 + space) * (cardSizeX + 2*padding);
      if(xOffset >= maxX - margin){
        xOffset = margin;
        yOffset += (1 + 0.5*space)*(cardSizeY + 2*padding);
      }
    }

    return await _saveFile(maxX.toInt(), maxY.toInt());
  }

  void _paintSquareStat(Offset a, Offset b, double percent, TextSpan icon){
    final Paint progressLine = Paint()
      ..color =
      percent == 0 ? const Color(0xFF2B2922) :
      percent <= 0.25 ? Colors.red[300] :
      percent <= 0.50 ? Colors.yellow[300] :
      percent <= 0.75 ? Colors.amber[300] :
      percent <= 0.99 ? Colors.lightGreen[300] :
      Colors.green[800]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromPoints(a, b),
      Radius.circular(8.0)
    );

    _canvas..drawRRect(rect, progressLine);

    if(percent == 1)
      TextPainter(text: icon, textDirection: TextDirection.ltr, maxLines: 1)
      ..layout(minWidth: 50, maxWidth: 50)
      ..paint(_canvas, a.translate(5 , 5));
  }

  Future<void> _paintBanner(Size size, Map<String, dynamic> stats) async{
    final Color textColor = theme.textTheme.headline6.color;
    final Paint paint = Paint();
    String date = materialLocalizations.formatFullDate(DateTime.now());
    date = date.substring(date.indexOf(' ')+1);
    final double iconSize = banner * 0.8;
    final double iconMargin = (banner * 0.2) / 2.0;
    final double maxX = size.width;
    final double maxY = size.height;
    final bool fontFeatureStyle = !statProvider.isPercentage && stat.isFontFeatureEnable;
    /// Activate fontFeature only if StatMode is Ratio and isFontFeatureEnable is true for this device

    final TextSpan aNetwork = TextSpan(
      style: TextStyle(color: textColor, fontSize: 50),
      text: 'Amiibo Network',
      children: <InlineSpan>[
        TextSpan(
            style: TextStyle(color: textColor, fontSize: 15, wordSpacing: 35),
            text: '\u00A9 '
        ),
        TextSpan(
            style: TextStyle(color: Colors.black, fontSize: fontFeatureStyle ? 35 : 30,
              fontWeight: FontWeight.w300, background: ownedCardPaint,
              fontFeatures: [
                if(fontFeatureStyle) ui.FontFeature.enable('frac'),
                if(!fontFeatureStyle) ui.FontFeature.tabularFigures()
              ],
            ),
            text: ' ${statProvider.statLabel(stats['Owned'].toDouble(), stats['Total'].toDouble())} '
        ),
        TextSpan(
          style: TextStyle(color: textColor, fontSize: 35),
          text: ' $owned'
        ),
        TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 35, wordSpacing: 35),
            text: ' '
        ),
        TextSpan(
            style: TextStyle(color: Colors.black, fontSize: fontFeatureStyle ? 35 : 30,
              fontWeight: FontWeight.w300, background: wishedCardPaint,
              fontFeatures: [
                if(fontFeatureStyle) ui.FontFeature.enable('frac'),
                if(!fontFeatureStyle) ui.FontFeature.tabularFigures()
              ],
            ),
            text: ' ${statProvider.statLabel(stats['Wished'].toDouble(), stats['Total'].toDouble())} '
        ),
        TextSpan(
            style: TextStyle(color: textColor, fontSize: 35),
            text: ' $wished'
        ),
      ]
    );
    TextPainter(text: aNetwork,
        textDirection: TextDirection.ltr
    )..layout(minWidth: maxX-125-margin)
      ..paint(_canvas, Offset(125, maxY - margin - 75));

    TextSpan createdDate = TextSpan(
        style: TextStyle(color: textColor, fontSize: 25),
        text: '$createdOn $date'
    );
    TextPainter(text: createdDate, textDirection: TextDirection.rtl,)
      ..layout(minWidth: maxX-125-margin)
      ..paint(_canvas, Offset(125, maxY - margin - 30));

    final _ima = await rootBundle.load('assets/images/icon_app.png');
    final ui.Image appIcon = await ui.instantiateImageCodec(
        _ima.buffer.asUint8List(),
        targetWidth: iconSize.toInt(), targetHeight: iconSize.toInt()
    ).then((codec) => codec.getNextFrame())
        .then((frame) => frame.image).catchError((e) => null);

    if(theme.primaryColorBrightness == Brightness.dark)
      paint.colorFilter = ColorFilter.mode(Colors.white54, BlendMode.srcIn);

    _canvas.drawImage(appIcon, Offset(margin, maxY - margin - iconSize - iconMargin), paint);

    appIcon?.dispose();
  }

  Future<Uint8List> _saveFile(int maxX, int maxY) async{
    try{
      ui.Picture pic = _recorder.endRecording();
      if(pic == null) throw(AssertionError('The Canvas was empty'));
      ui.Image img = await pic.toImage(maxX, maxY);
      pic.dispose();
      ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      Uint8List buffer = byteData.buffer.asUint8List();
      return buffer;
    }on AssertionError catch(e){
      print(e);
      return null;
    } finally{
      _canvas = null;
      _recorder = null;
    }
  }
}
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'package:flutter/rendering.dart';

const String recordMessage = 'Still processing your last file';
const String permissionMessage = 'Saving your file. This could take a while depending on your device';
const String message = 'Your collection has been saved';

class Screenshot {
  bool _recording = false;
  bool get isRecording => _recording;
  ThemeData theme;
  StatProvider statProvider;

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

  Future<String> saveCollection(Set<String> select) async{
    AmiiboLocalDB amiibos = await _service.fetchByCategory(expression: InCond.inn('type', select.toList()),
      orderBy: 'CASE WHEN type = "Figure" THEN 1 ''WHEN type = "Yarn" THEN 2 ELSE 3 END, amiiboSeries DESC, na DESC');
    if(_recording || (amiibos?.amiibo?.isEmpty ?? true)) {
      return '';
    }
    _recording = true;

    Map<String,dynamic> _listStat = Map<String, dynamic>.from(
        (await _service.fetchSum(expression: InCond.inn('type', select.toList()))).first);
    final Map<String,dynamic> file = Map<String,dynamic>();
    final String time = DateTime.now().toString().substring(0,10);
    final Directory dir = await Directory('/storage/emulated/0/Download').create();
    final String path = '${dir.path}/My${
        select.containsAll(['Figure', 'Yarn', 'Card']) ? 'Amiibo' :
        select.containsAll(['Figure', 'Yarn']) ? 'Figure' : 'Card'
    }Collection_$time.png';
    final double maxSize = 60.0;
    final double width = (amiibos.amiibo.length / 25.0).ceilToDouble().clamp(15.0, 30.0);
    final double maxX = (width * (1 + space) - space) * (maxSize + 2*padding) + 2*margin;
    final double maxY = ((amiibos.amiibo.length / width).ceilToDouble()
      * (1 + 0.5*space) - 0.5*space) * (1.5*maxSize + 2*padding) + banner + 2*margin;
    double xOffset = margin;
    double yOffset = margin;
    ui.Picture pic;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = theme.scaffoldBackgroundColor;

    canvas.drawColor(paint.color, BlendMode.src);

    await _paintBanner(canvas, Size(maxX, maxY), _listStat);

    for(AmiiboDB amiibo in amiibos.amiibo) {
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

      if((amiibo?.owned?.isOdd ?? false) || (amiibo?.wishlist?.isOdd ?? false)){
        canvas.drawRRect(cardPath,
          amiibo?.owned?.isOdd ?? false ? ownedCardPaint : wishedCardPaint);
      }

      ui.Image _image = await ui.instantiateImageCodec(
        imageAsset.buffer.asUint8List(),
        targetWidth: maxSize.toInt(),
      ).then((codec) => codec.getNextFrame()).then((frame)=> frame.image);

      final bool taller = _image.width > 1.3*_image.height;
      canvas.drawImageNine(_image,
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

    pic = pictureRecorder.endRecording();
    try{
      ui.Image img = await pic.toImage(maxX.toInt(), maxY.toInt());
      pic.dispose();
      ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      List<int> buffer = byteData.buffer.asUint8List();
      file['path'] = path;
      file['buffer'] = buffer;
      await compute(writeCollectionFile, file);
    }catch(e){
      print(e);
      return 'There was a problem saving your collection';
    } finally{
      _recording = false;
    }
    return message;
  }

  Future<String> drawStats(Set<String> select) async{
    final List<Map<String, dynamic>> stats = await _service.fetchSum(group: true, expression: InCond.inn('type', select.toList()));
    final List<Map<String, dynamic>> general = await _service.fetchSum(expression: InCond.inn('type', select.toList()));

    if(_recording || (stats?.isEmpty ?? true) || (general?.isEmpty ?? true)) {
      return '';
    }
    _recording = true;

    final Map<String,dynamic> file = Map<String,dynamic>();
    final String time = DateTime.now().toString().substring(0,10);
    final Directory dir = await Directory('/storage/emulated/0/Download').create();
    final String path = '${dir.path}/My${
        select.isEmpty ? 'Amiibo' :
        select.containsAll(['Figure', 'Yarn']) ? 'Figure' : 'Card'
    }Stats_$time.png';
    final double maxSize = 300.0;
    final double width = (stats.length / 5.0).ceilToDouble().clamp(4.0, 10.0);
    final double maxX = (width * (1 + space) - space) * (maxSize + 2*padding) + 2*margin;
    final double maxY = ((stats.length / width).ceilToDouble()
        * (1 + 0.5*space) - 0.5*space) * (0.8*maxSize + 2*padding) + banner + 2*margin;
    double xOffset = margin;
    double yOffset = margin;
    ui.Picture pic;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = theme.scaffoldBackgroundColor;
    final Paint cardColor = Paint()..color = theme.cardTheme.color;
    final Color textColor = theme.textTheme.title.color;
    final Paint divider = Paint()..color = theme.dividerColor..strokeWidth = 2;
    if(theme.scaffoldBackgroundColor == Colors.black)
      cardColor..color = const Color(0xFF2B2922)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

    canvas.drawColor(paint.color, BlendMode.src);

    await _paintBanner(canvas, Size(maxX, maxY), general.first);

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
          _offset.translate(maxSize + 2*padding, 0.8*maxSize + 2*padding)),
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
      canvas.drawRRect(cardPath, cardColor);

      TextSpan title = TextSpan(
        style: TextStyle(color: textColor, fontSize: 25),
        text: singleStat['amiiboSeries'],
      );
      TextPainter(text: title, textDirection: TextDirection.ltr, ellipsis: '\u2026',
        textAlign: TextAlign.center, maxLines: 1)..layout(minWidth: maxSize, maxWidth: maxSize)
        ..paint(canvas, Offset(xOffset + padding, yOffset + padding));

      canvas..drawLine(_offset.translate(padding, 40 + padding),
          _offset.translate(maxSize + padding, 40 + padding), divider);

      TextSpan owned = TextSpan(
        style: TextStyle(color: textColor, fontSize: statProvider.prefStat ? 30 : 35,
          height: statProvider.prefStat ? null : 1,
          fontFeatures: [
            if(!statProvider.prefStat) ui.FontFeature.enable('frac'),
            if(statProvider.prefStat) ui.FontFeature.tabularFigures()
          ],
        ),
        text: ownedStat,
          children: [
            TextSpan(
              style: TextStyle(color: textColor, fontSize: 30,),
              text: ' Owned'
            )
          ]
      );
      TextPainter(text: owned, textDirection: TextDirection.ltr, maxLines: 1)
        ..layout(minWidth: maxSize - 2* padding - 75, maxWidth: maxSize - 2* padding - 75)
        ..paint(canvas, _offset.translate(padding + 75, 62.5 + padding + 25));

      TextSpan wished = TextSpan(
          style: TextStyle(color: textColor, fontSize: statProvider.prefStat ? 30 : 35,
            height: statProvider.prefStat ? null : 1,
            fontFeatures: [
              if(!statProvider.prefStat) ui.FontFeature.enable('frac'),
              if(statProvider.prefStat) ui.FontFeature.tabularFigures()
            ],
          ),
          text: wishedStat,
        children: [
          TextSpan(
              style: TextStyle(color: textColor, fontSize: 30,),
              text: ' Wished'
          )
        ]
      );
      TextPainter(text: wished, textDirection: TextDirection.ltr, maxLines: 1)
        ..layout(minWidth: maxSize - 2* padding - 75, maxWidth: maxSize - 2* padding - 75)
        ..paint(canvas, _offset.translate(padding + 75, 142.5 + padding + 25));

      _paintSquareStat(canvas, _offset.translate(padding, 50 + padding + 25),
          _offset.translate(maxSize + padding, 110 + padding + 25), ownedPercent, ownedIcon);
      _paintSquareStat(canvas, _offset.translate(padding, 130 + padding + 25),
          _offset.translate(maxSize + padding, 190 + padding + 25), wishedPercent, wishedIcon);

      xOffset += (1 + space) * (maxSize + 2*padding);
      if(xOffset >= maxX - margin){
        xOffset = margin;
        yOffset += (1 + 0.5*space)*(0.8*maxSize + 2*padding);
      }
    }

    pic = pictureRecorder.endRecording();
    try{
      ui.Image img = await pic.toImage(maxX.toInt(), maxY.toInt());
      pic.dispose();
      ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      List<int> buffer = byteData.buffer.asUint8List();
      file['path'] = path;
      file['buffer'] = buffer;
      await compute(writeCollectionFile, file);
    }catch(e){
      print(e);
      return 'There was a problem saving your collection';
    } finally{
      _recording = false;
    }
    return message;
  }

  void _paintSquareStat(Canvas canvas, Offset a, Offset b, double percent, TextSpan icon){
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

    canvas..drawRRect(rect, progressLine);

    if(percent == 1)
      TextPainter(text: icon, textDirection: TextDirection.ltr, maxLines: 1)
      ..layout(minWidth: 50, maxWidth: 50)
      ..paint(canvas, a.translate(5 , 5));
  }

  Future<void> _paintBanner(Canvas canvas, Size size, Map<String, dynamic> stat) async{
    final Color textColor = theme.textTheme.title.color;
    final Paint paint = Paint();
    final String time = DateTime.now().toString().substring(0,10);
    final double iconSize = banner * 0.8;
    final double iconMargin = (banner * 0.2) / 2.0;
    final double maxX = size.width;
    final double maxY = size.height;

    final TextSpan aNetwork = TextSpan(
        style: TextStyle(color: textColor, fontSize: 50),
        text: 'Amiibo Network',
        children: <InlineSpan>[
          TextSpan(
              style: TextStyle(color: textColor, fontSize: 15, wordSpacing: 60),
              text: '\u24C7 '
          ),
          TextSpan(
              style: TextStyle(color: Colors.black, fontSize: statProvider.prefStat ? 30 : 35,
                fontWeight: FontWeight.w300, background: ownedCardPaint,
                fontFeatures: [
                  if(!statProvider.prefStat) ui.FontFeature.enable('frac'),
                  if(statProvider.prefStat) ui.FontFeature.tabularFigures()
                ],
              ),
              text: ' ${statProvider.statLabel(stat['Owned'].toDouble(), stat['Total'].toDouble())} '
          ),
          TextSpan(
              style: TextStyle(color: textColor, fontSize: 35),
              text: ' Owned'
          ),
          TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 35, wordSpacing: 60),
              text: ' '
          ),
          TextSpan(
              style: TextStyle(color: Colors.black, fontSize: statProvider.prefStat ? 30 : 35,
                fontWeight: FontWeight.w300, background: wishedCardPaint,
                fontFeatures: [
                  if(!statProvider.prefStat) ui.FontFeature.enable('frac'),
                  if(statProvider.prefStat) ui.FontFeature.tabularFigures()
                ],
              ),
              text: ' ${statProvider.statLabel(stat['Wished'].toDouble(), stat['Total'].toDouble())} '
          ),
          TextSpan(
              style: TextStyle(color: textColor, fontSize: 35),
              text: ' Wished'
          ),
        ]
    );
    TextPainter(text: aNetwork,
        textDirection: TextDirection.ltr
    )..layout(minWidth: maxX-125-margin)
      ..paint(canvas, Offset(125, maxY - margin - 75));

    TextSpan createdDate = TextSpan(
        style: TextStyle(color: textColor, fontSize: 25),
        text: 'created on: $time'
    );
    TextPainter(text: createdDate, textDirection: TextDirection.rtl,)
      ..layout(minWidth: maxX-125-margin)
      ..paint(canvas, Offset(125, maxY - margin - 30));

    final _ima = await rootBundle.load('assets/images/icon_app.png');
    final ui.Image appIcon = await ui.instantiateImageCodec(
        _ima.buffer.asUint8List(),
        targetWidth: iconSize.toInt(), targetHeight: iconSize.toInt()
    ).then((codec) => codec.getNextFrame())
        .then((frame) => frame.image).catchError((e) => print(e));

    if(theme.brightness == Brightness.dark)
      paint.colorFilter = ColorFilter.mode(Colors.white54, BlendMode.srcIn);

    canvas.drawImage(appIcon, Offset(margin, maxY - margin - iconSize - iconMargin), paint);

    appIcon?.dispose();
  }
}
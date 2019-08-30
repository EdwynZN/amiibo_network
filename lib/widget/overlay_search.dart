import 'package:flutter/material.dart';

class CountriesField extends StatefulWidget {
  @override
  _CountriesFieldState createState() => _CountriesFieldState();
}

class _CountriesFieldState extends State<CountriesField> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener((){
      if (_focusNode.hasFocus){
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      }else{
        this._overlayEntry.remove();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5.0,
        width: size.width,
        child: Material(
          elevation: 4.0,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text('Syria'),
              ),
              ListTile(
                title: Text('Lebanon'),
              )
            ],
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: this._focusNode,
      style: Theme.of(context).textTheme.body2,
      //inputFormatters: [LengthLimitingTextInputFormatter(15)],
      textInputAction: TextInputAction.search,
      autofocus: true,
      onSubmitted: Navigator.of(context).pop,
      //onChanged: _search.searchValue,
      autocorrect: false,
      decoration: InputDecoration.collapsed(
        //hintText: Provider.of<AmiiboProvider>(context).strFilter,
        hintText:'All',
        hintStyle: Theme.of(context).textTheme.title.copyWith(
            color: Theme.of(context).textTheme.title.color.withOpacity(0.5)
        ),
      ),
    );
  }
}
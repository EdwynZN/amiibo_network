import 'package:amiibo_network/utils/format_date.dart';
import 'package:flutter/material.dart';

class RegionDetail extends StatelessWidget {
  final String asset;
  final String description;
  final FormatDate formatDate;

  RegionDetail(dateString, this.asset, this.description)
      : formatDate = FormatDate(dateString);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/images/$asset.png',
          height: 16,
          width: 25,
          fit: BoxFit.fill,
          semanticLabel: description,
        ),
        Flexible(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                formatDate.localizedDate(context),
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
                style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class TextCardDetail extends StatelessWidget {
  final String? text;

  TextCardDetail({
    Key? key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: TextAlign.start,
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
      style: Theme.of(context)
        .textTheme
        .bodyText2!
        .copyWith(fontWeight: FontWeight.bold),
    );
  }
}

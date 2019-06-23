import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[],
        title: Text('Settings'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              CardSettings(title: 'Changelog', subtitle: 'Changing for better . . .', icon: Icons.build,),
              CardSettings(title: 'Credits', subtitle: 'Those who make it possible', icon: Icons.theaters,),
              ],
            ),
          ),
        ],
      ),
      /*bottomNavigationBar: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(child: Text('Hola'),),
          Container(child: Text('Hola'),),
        ],
      ),*/
    );
  }
}

class CardSettings extends StatelessWidget{
  final String title;
  final String subtitle;
  final IconData icon;

  CardSettings({
    Key key,
    this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: ListTileTheme(
        iconColor: Theme.of(context).iconTheme.color,
        textColor: Theme.of(context).textTheme.body1.color,
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          onTap: () => Navigator.pushNamed(context, "/settingsdetail", arguments: title),
          trailing: const Icon(Icons.navigate_next),
          leading: Container(
            padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
            border: Border(right: BorderSide(width: 1, color: Theme.of(context).dividerColor))
            ),
            child: Icon(icon),
          )
        ),
      )
    );
  }
}
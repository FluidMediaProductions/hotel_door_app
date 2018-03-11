import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'utils.dart';
import 'graphql.dart';
import 'consts.dart';

class Booking {
  final int id;
  final DateTime start;
  final DateTime end;

  Booking({this.id, this.start, this.end});
}

class BookingPage extends StatefulWidget {
  final Booking booking;

  BookingPage({@required this.booking, key}) : super(key: key);

  @override
  BookingPageState createState() => new BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  Widget buildButtonColumn(IconData icon, String label, String data) {
    Color color = Theme.of(context).primaryColor;

    var descTextStyle = new TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontFamily: 'Roboto',
      letterSpacing: 0.5,
      height: 1.5,
    );

    return new Expanded(
      child: new Column(
        children: [
          new Icon(icon, color: color),
          new Text(label, style: descTextStyle),
          new Text(data),
        ],
      ),
    );
  }

  Widget _buildBody() {
    Widget image = new Hero(
      tag: 'booking_' + widget.booking.id.toString(),
      child: new Image.asset(
        "images/hotel.jpg",
        height: 240.0,
        fit: BoxFit.cover,
      ),
    );

    var titleTextStyle = new TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
    );

    Widget formatDate(DateTime start, DateTime end) {
      var format = new DateFormat("yMMMEd");
      var startText = format.format(start);
      var endText = format.format(end);

      return new Text(
        startText + " - " + endText,
        style: new TextStyle(
          color: Colors.grey[500],
        ),
      );
    }

    Widget bookingSummary = new Container(
      padding: const EdgeInsets.all(20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child:
                  new Text('Booking at random hotel', style: titleTextStyle)),
          formatDate(widget.booking.start, widget.booking.end),
        ],
      ),
    );

    Widget bookingInfo =
        new Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      buildButtonColumn(Icons.vpn_key, "ROOM:", "23"),
      buildButtonColumn(Icons.arrow_upward, "FLOOR:", "G"),
      buildButtonColumn(Icons.access_time, "CHECK IN:", "2pm"),
    ]);

    const loc = "13 Pen-y-Lan Terrace";
    Widget map = new Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: new GestureDetector(
        child: makeStaticMap(loc, MAPS_API_KEY),
        onTap: () {
          launchURL(makeMapURL(loc));
        },
      ),
    );

    return new ListView(
      children: [image, bookingSummary, bookingInfo, map],
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('View booking'),
      ),
      body: _buildBody(),
    );
  }
}

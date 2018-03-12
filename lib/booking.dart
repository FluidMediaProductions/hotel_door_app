import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'utils.dart';
import 'graphql.dart';
import 'consts.dart';
import 'data_types.dart';

class BookingPage extends StatefulWidget {
  final Booking booking;

  BookingPage({@required this.booking, key}) : super(key: key);

  @override
  BookingPageState createState() => new BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  final _graphqlClient = new GraphQLClient(GRAPHQL_SERVER_URL);

  Hotel _hotel;

  _getHotelDetails() async {
    String query = "query (\$id: Int!) {\n"
        "  hotel(id: \$id) {\n"
        "    checkIn\n"
        "    address\n"
        "  }\n"
        "}";
    _graphqlClient.runQuery(query, {
      "id": _hotel.id,
    }).then((resp) {
      setState(() {
        if (resp["data"]["hotel"] != null) {
          Map<String, dynamic> hotel = resp["data"]["hotel"];
          _hotel = new Hotel(
            id: _hotel.id,
            name: _hotel.name,
            checkIn: DateTime.parse(hotel["checkIn"]),
            address: hotel["address"],
          );
        }
      });
    });
  }

  @override
  initState() {
    super.initState();

    _hotel = widget.booking.hotel;
    _getHotelDetails();
  }

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
                  new Text('Booking at ' + _hotel.name, style: titleTextStyle)),
          formatDate(widget.booking.start, widget.booking.end),
        ],
      ),
    );

    var formatter = new DateFormat('j');
    Widget bookingInfo = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: (_hotel.address != null)
          ? [
              buildButtonColumn(Icons.vpn_key, "ROOM:", "23"),
              buildButtonColumn(Icons.arrow_upward, "FLOOR:", "G"),
              buildButtonColumn(Icons.access_time, "CHECK IN:", formatter.format(_hotel.checkIn)),
          ] : [
              new Expanded(
                child: new Center(
                  child: new CircularProgressIndicator(),
                ),
              )
            ],
    );

    Widget map = new Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: new GestureDetector(
        child: (_hotel.address != null)
            ? new FadeInImage(
                placeholder: new AssetImage("images/loading.png"),
                image: makeStaticMap(_hotel.address, MAPS_API_KEY),
                fit: BoxFit.contain,
              )
            : new Image(
                image: new AssetImage("images/loading.png"),
                fit: BoxFit.contain,
              ),
        onTap: (_hotel.address != null)
            ? () {
                launchURL(makeMapURL(_hotel.address));
              }
            : () {},
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

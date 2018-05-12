import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
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

class BookingPageState extends State<BookingPage>
    with TickerProviderStateMixin {
  final _graphqlClient = new GraphQLClient(GRAPHQL_SERVER_URL);
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  Hotel _hotel;
  Room _room;

  _getBookingDetails() async {
    try {
      String query = "query (\$hotelId: Int!, \$roomId: Int!) {\n"
          "  hotel(id: \$hotelId) {\n"
          "    checkIn\n"
          "    address\n"
          "  }\n"
          "  room(id: \$roomId) {\n"
          "    name\n"
          "    floor\n"
          "  }\n"
          "}";
      var resp = await _graphqlClient.runQuery(query, {
        "hotelId": _hotel.id,
        "roomId": _room.id,
      });
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
        if (resp["data"]["room"] != null) {
          Map<String, dynamic> room = resp["data"]["room"];
          _room = new Room(
            id: _room.id,
            name: room["name"],
            floor: room["floor"],
          );
        }
      });
    } catch (error, stack) {
      print(error);
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text("Something went wrong: " + error.toString()),
        ),
      );
      if (const bool.fromEnvironment("dart.vm.product")) {
        await sentry.captureException(
          exception: error,
          stackTrace: stack,
        );
      }
    }
  }

  _openRoom() {
    authenticateAction(context, () async {
      try {
        String jwt = await getJwt();
        if (jwt != null) {
          String query = "mutation (\$token: String!, \$roomId: Int!) {\n"
              "  auth(token: \$token) {\n"
              "    openRoom(id: \$roomId)\n"
              "  }\n"
              "}";
          _graphqlClient.runQuery(query, {
            "token": jwt,
            "roomId": _room.id,
          }).then((resp) {
            if (resp["data"]["auth"]["openRoom"]) {
              _scaffoldKey.currentState.showSnackBar(
                new SnackBar(
                  content: new Text("Door opened"),
                ),
              );
            } else {
              _scaffoldKey.currentState.showSnackBar(
                new SnackBar(
                  content: new Text("Something went wrong"),
                ),
              );
            }
          });
        }
      } catch (error, stack) {
        print(error);
        _scaffoldKey.currentState.showSnackBar(
          new SnackBar(
            content: new Text("Something went wrong: " + error.toString()),
          ),
        );
        await sentry.captureException(
          exception: error,
          stackTrace: stack,
        );
      }
    });
  }

  _openHotelDoor() {
    authenticateAction(context, () async {
      try {
        String jwt = await getJwt();
        if (jwt != null) {
          String query = "mutation (\$token: String!, \$hotelId: Int!) {\n"
              "  auth(token: \$token) {\n"
              "    openHotelDoor(id: \$hotelId)\n"
              "  }\n"
              "}";
          _graphqlClient.runQuery(query, {
            "token": jwt,
            "hotelId": _hotel.id,
          }).then((resp) {
            if (resp["data"]["auth"]["openHotelDoor"]) {
              _scaffoldKey.currentState.showSnackBar(
                new SnackBar(
                  content: new Text("Door opened"),
                ),
              );
            } else {
              _scaffoldKey.currentState.showSnackBar(
                new SnackBar(
                  content: new Text("Something went wrong"),
                ),
              );
            }
          });
        }
      } catch (error, stack) {
        print(error);
        _scaffoldKey.currentState.showSnackBar(
          new SnackBar(
            content: new Text("Something went wrong: " + error.toString()),
          ),
        );
        await sentry.captureException(
          exception: error,
          stackTrace: stack,
        );
      }
    });
  }

  @override
  initState() {
    super.initState();

    _hotel = widget.booking.hotel;
    _room = widget.booking.room;
    _getBookingDetails();
  }

  Widget buildButtonColumn(IconData icon, String label, String data) {
    Color color = Theme.of(context).primaryColor;

    var descTextStyle = const TextStyle(
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
    Orientation orientation = MediaQuery.of(context).orientation;
    Size screenSize = MediaQuery.of(context).size;

    Widget image = new Hero(
      tag: 'booking_' + widget.booking.id.toString(),
      child: new Image.asset(
        "images/hotel.jpg",
        height: screenSize.height / 3,
        fit: BoxFit.cover,
      ),
    );

    var titleTextStyle = const TextStyle(
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
            child: new Text(
              'Booking at ' + _hotel.name,
              style: titleTextStyle,
            ),
          ),
          formatDate(widget.booking.start, widget.booking.end),
        ],
      ),
    );

    var formatter = new DateFormat('j');
    Widget bookingInfo = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: (_hotel.address != null)
          ? [
              buildButtonColumn(Icons.vpn_key, "ROOM:", _room.name),
              buildButtonColumn(Icons.arrow_upward, "FLOOR:", _room.floor),
              buildButtonColumn(Icons.access_time, "CHECK IN:",
                  formatter.format(_hotel.checkIn)),
            ]
          : [
              const Expanded(
                child: const Center(
                  child: const CircularProgressIndicator(),
                ),
              )
            ],
    );

    Widget map = new Container(
      child: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return new GestureDetector(
            child: (_hotel.address != null)
                ? new FadeInImage(
                    placeholder: const AssetImage("images/loading.png"),
                    image: makeStaticMap(
                        _hotel.address,
                        MAPS_API_KEY,
                        screenSize.height ~/
                            3 *
                            ((orientation == Orientation.landscape) ? 2 : 1),
                        constraints.maxWidth.toInt()),
                    fit: BoxFit.contain,
                  )
                : const Image(
                    image: const AssetImage("images/loading.png"),
                    fit: BoxFit.contain,
                  ),
            onLongPress: (_hotel.address != null)
                ? () {
                    launchURL(makeMapURL(_hotel.address));
                  }
                : () {},
          );
        },
      ),
    );

    if (orientation == Orientation.portrait) {
      return new ListView(
        children: [
          image,
          bookingSummary,
          bookingInfo,
          new Container(
            height: 20.0,
          ),
          map,
        ],
      );
    } else {
      return new ListView(
        children: [
          image,
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Container(
                width: screenSize.width / 2,
                child: map,
              ),
              new Container(
                width: screenSize.width / 2,
                child: new SafeArea(
                  left: false,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bookingSummary,
                      bookingInfo,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildBottomBar() {
    List<BookingAction> actions = [
      new BookingAction(
        label: "Open Car Park",
        icon: Icons.directions_car,
        action: () {},
      ),
      new BookingAction(
        label: "Unlock Room",
        icon: Icons.hotel,
        action: () {
          _openRoom();
        },
      ),
      new BookingAction(
        label: "Unlock Front Door",
        icon: Icons.home,
        action: () {
          _openHotelDoor();
        },
      ),
    ];

    return new BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      items: actions.map((action) {
        return new BottomNavigationBarItem(
          icon: new Icon(action.icon),
          title: new Text(action.label),
        );
      }).toList(),
      onTap: (index) {
        actions[index].action();
      },
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('View booking'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}

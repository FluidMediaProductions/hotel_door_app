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
  AnimationController _fabController;
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
      _graphqlClient.runQuery(query, {
        "hotelId": _hotel.id,
        "roomId": _room.id,
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
          if (resp["data"]["room"] != null) {
            Map<String, dynamic> room = resp["data"]["room"];
            _room = new Room(
              id: _room.id,
              name: room["name"],
              floor: room["floor"],
            );
          }
        });
      });
    } catch (error, stack) {
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text("Something went wrong"),
        ),
      );
      await sentry.captureException(
        exception: error,
        stackTrace: stack,
      );
    }
  }

  _openRoom() async {
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
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text("Something went wrong"),
        ),
      );
      await sentry.captureException(
        exception: error,
        stackTrace: stack,
      );
    }
  }

  _openHotelDoor() async {
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
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text("Something went wrong"),
        ),
      );
      await sentry.captureException(
        exception: error,
        stackTrace: stack,
      );
    }
  }

  @override
  initState() {
    super.initState();

    _fabController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 500,
      ),
    );
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
    Widget image = new Hero(
      tag: 'booking_' + widget.booking.id.toString(),
      child: new Image.asset(
        "images/hotel.jpg",
        height: 240.0,
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

    Widget openButton = new Container(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: new RaisedButton(
        child: const Text(
          "Open door",
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        color: Colors.blueAccent,
        onPressed: () {},
      ),
    );

    Widget map = new Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: new GestureDetector(
        child: (_hotel.address != null)
            ? new FadeInImage(
                placeholder: const AssetImage("images/loading.png"),
                image: makeStaticMap(_hotel.address, MAPS_API_KEY),
                fit: BoxFit.contain,
              )
            : const Image(
                image: const AssetImage("images/loading.png"),
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
      children: [image, bookingSummary, bookingInfo, openButton, map],
    );
  }

  Widget _buildFab() {
    List<BookingAction> actions = [
      new BookingAction(
        label: "Car Park",
        icon: Icons.directions_car,
        action: () {},
      ),
      new BookingAction(
        label: "Front Door",
        icon: Icons.home,
        action: () {
          _openHotelDoor();
        },
      ),
      new BookingAction(
        label: "Room",
        icon: Icons.hotel,
        action: () {
          _openRoom();
        },
      ),
    ];
    Color backgroundColour = Theme.of(context).cardColor;
    Color forgroundColour = Theme.of(context).accentColor;
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: new List.generate(
        actions.length,
        (int i) {
          Widget child = new Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.center,
            child: new ScaleTransition(
              scale: new CurvedAnimation(
                parent: _fabController,
                curve: new Interval(0.0, 1.0 - i / actions.length / 2.0,
                    curve: Curves.easeOut),
              ),
              child: new FloatingActionButton(
                mini: true,
                backgroundColor: backgroundColour,
                child: new Icon(
                  actions[i].icon,
                  color: forgroundColour,
                ),
                tooltip: actions[i].label,
                onPressed: () {
                  _fabController.reverse();
                  actions[i].action();
                },
              ),
            ),
          );
          return child;
        },
      ).toList()
        ..add(new FloatingActionButton(
          child: new AnimatedBuilder(
            animation: _fabController,
            builder: (BuildContext context, Widget child) {
              return new Transform(
                transform:
                    new Matrix4.rotationZ(_fabController.value * 0.5 * PI),
                alignment: FractionalOffset.center,
                child: new Icon(
                  _fabController.isDismissed ? Icons.lock_open : Icons.close,
                ),
              );
            },
          ),
          onPressed: () {
            if (_fabController.isDismissed) {
              _fabController.forward();
            } else {
              _fabController.reverse();
            }
          },
        )),
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('View booking'),
      ),
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }
}

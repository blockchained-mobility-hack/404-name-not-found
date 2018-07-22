part of 'main.dart';

class _MyHomePageState extends State<MyHomePage> {
  int current_step = 0;
  var results;

  var coordsStart;
  var coordsEnd;

  Future<Null> displayPrediction(
      Prediction p, ScaffoldState scaffold, String type) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      if (type == "start") {
        this.coordsStart = [lat, lng];
      }
      if (type == "end") {
        this.coordsEnd = [lat, lng];

        setState(() async {
          this.results = await getResults(
              coordsStart[0], coordsStart[1], coordsEnd[0], coordsEnd[1]);
        });
      }

      scaffold.showSnackBar(
          new SnackBar(content: new Text("${p.description} - $lat/$lng")));
    }
  }

  FlatButton buildSearchButton(text, type) {
    return FlatButton(
        onPressed: () async {
          Prediction p = await showGooglePlacesAutocomplete(
              context: context,
              apiKey: secrets.googlePlacesApi,
              onError: (res) {
                homeScaffoldKey.currentState.showSnackBar(
                    new SnackBar(content: new Text(res.errorMessage)));
              },
              mode: Mode.fullscreen,
              language: "de",
              components: [new Component(Component.country, "de")]);

          displayPrediction(p, homeScaffoldKey.currentState, type);
        },
        child: new Text(text));
  }

  Column listRoutes() {
    print(this.results);
    if (this.results == null) {
      return Column();
    }
    List<Widget> tiles = [];
    this.results.forEach((result) => tiles.add(ListTile(
          leading: result.type == TravelType.plane
              ? Icon(Icons.airplanemode_active)
              : Icon(Icons.directions_car),
          title:
              Text(result.title + " " + result.price.round().toString() + "€"),
        )));
    return Column(
      children: tiles,
    );
  }

  @override
  void initState() {
    super.initState();
    getAccessTokenAmadeus();

    var channel = IOWebSocketChannel.connect("ws://localhost:8080");

    channel.stream.listen((message) {
      print(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Step> my_steps = [
      new Step(
          title: new Text("Step 1"),
          content: Column(children: [
            buildSearchButton("What is your start location?", "start"),
            buildSearchButton("What is your target location?", "end"),
          ]),
          isActive: true),
      new Step(
          title: new Text("Step 2"),
          content: listRoutes(),
          state: StepState.editing,
          isActive: true),
      new Step(
          title: new Text("Step 3"),
          content: new Text("Hello World!"),
          isActive: true),
    ];

    return new Scaffold(
      key: homeScaffoldKey,
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
          child: new Stepper(
        currentStep: this.current_step,
        steps: my_steps,
        type: StepperType.horizontal,
        onStepTapped: (step) {
          setState(() {
            current_step = step;
          });
          print("onStepTapped : " + step.toString());
        },
        onStepCancel: () {
          setState(() {
            if (current_step > 0) {
              current_step = current_step - 1;
            } else {
              current_step = 0;
            }
          });
          print("onStepCancel : " + current_step.toString());
        },
        onStepContinue: () {
          setState(() {
            if (current_step < my_steps.length - 1) {
              current_step = current_step + 1;
            } else {
              current_step = 0;
            }
          });
          print("onStepContinue : " + current_step.toString());
        },
      )),
    );
  }
}

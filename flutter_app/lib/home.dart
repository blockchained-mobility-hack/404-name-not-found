part of 'main.dart';

class _MyHomePageState extends State<MyHomePage> {
  int current_step = 0;
  var results;

  var coordsStart = [null, null];
  var coordsEnd = [null, null];

  Future<Null> displayPrediction(
      Prediction p, ScaffoldState scaffold, String type) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      if (type == "start") {
        coordsStart[0] = lat;
        coordsStart[1] = lng;
      }
      if (type == "end") {
        coordsEnd[0] = lat;
        coordsEnd[1] = lng;

        this.results = await getResults(
            coordsStart[0], coordsStart[1], coordsEnd[0], coordsEnd[1]);

        print(this.results);
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
              apiKey: kGoogleApiKey,
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
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.map),
          title: Text('Map'),
        ),
        ListTile(
          leading: Icon(Icons.photo_album),
          title: Text('Album'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Phone'),
        ),
      ],
    );
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

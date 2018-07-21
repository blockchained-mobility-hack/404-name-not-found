part of 'main.dart';

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
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

                displayPrediction(p, homeScaffoldKey.currentState);
              },
              child: new Text("Please enter your start location")),
            new FlatButton(
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

                displayPrediction(p, homeScaffoldKey.currentState);
              },
              child: new Text("Please enter your target location")),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
part of 'main.dart';

class _MyHomePageState extends State<MyHomePage> {

  FlatButton buildSearchButton(text) {
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

        displayPrediction(p, homeScaffoldKey.currentState);
      },
      child: new Text(text));
  }

  Widget titleSection = Container(
    padding: const EdgeInsets.all(32.0),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Oeschinen Lake Campground',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Kandersteg, Switzerland',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.star,
          color: Colors.red[500],
        ),
        Text('41'),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {


    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: ListView(
          children: [
            buildSearchButton('Please choose your start'),
            buildSearchButton('Please choose your target'),
          ],
        )
    );
  }
}
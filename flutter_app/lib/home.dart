part of 'main.dart';

class _MyHomePageState extends State<MyHomePage> {
  int current_step = 0;

  ListView buildSearchView() {
    return ListView(
          children: [
            buildSearchButton('Please choose your start'),
            buildSearchButton('Please choose your target'),
          ],
        );
  }

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
    List<Step> my_steps = [
      new Step(
          title: new Text("Step 1"),
          content: buildSearchView(),
          isActive: true),
      new Step(
          title: new Text("Step 2"),
          content: new Text("World!"),
          state: StepState.editing,
          isActive: true),
      new Step(
          title: new Text("Step 3"),
          content: new Text("Hello World!"),
          isActive: true),
    ];

    /*return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: ListView(
          children: [
            buildSearchButton('Please choose your start'),
            buildSearchButton('Please choose your target'),
          ],
        )
    );*/

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
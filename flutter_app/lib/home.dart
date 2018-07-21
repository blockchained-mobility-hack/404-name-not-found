part of 'main.dart';

class _MyHomePageState extends State<MyHomePage> {
  int current_step = 0;

  

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

  @override
  Widget build(BuildContext context) {
    List<Step> my_steps = [
      new Step(
          title: new Text("Step 1"),
          content: Column(children: [
            buildSearchButton("What is your start location?"),
            buildSearchButton("What is your target location?")]
          ),
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
import 'package:flutter/material.dart';

class VerificationForm extends StatefulWidget {
  const VerificationForm({Key? key}) : super(key: key);

  @override
  State<VerificationForm> createState() => _VerificationFormState();
}

class _VerificationFormState extends State<VerificationForm>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> mainAnimation;

  TextEditingController _appealController = TextEditingController();

  DateTime? _dateSelected;
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1400));
    mainAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
    _animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              height: kToolbarHeight,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BackButton(),
                  ),
                  Text("Apply For Verification"),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (_, child) {
                final topPosition = kToolbarHeight +
                    (size.height * 2) * (1 - mainAnimation.value);

                return Positioned(
                  top: topPosition,
                  left: 0,
                  height: size.height - kToolbarHeight,
                  width: size.width,
                  child: Container(
                    height: size.height - kToolbarHeight,
                    width: size.width,
                    child: Column(
                      children: [
                        Card(
                          elevation: 10.0,
                          shadowColor: Colors.grey.withOpacity(.6),
                          margin: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: TextField(
                            controller: _appealController,
                            minLines: 5,
                            maxLines: 5,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10.0),
                              hintText: "Please describe your business.",
                              label: Text("Description"),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Card(
                          elevation: 10.0,
                          shadowColor: Colors.grey.withOpacity(.6),
                          margin: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: InkWell(
                            onTap: () async {
                              _dateSelected = await showDatePicker(
                                context: context,
                                initialDate:
                                    DateTime.now().add(Duration(days: 2)),
                                firstDate:
                                    DateTime.now().add(Duration(days: 2)),
                                lastDate: DateTime.now().add(
                                  Duration(
                                    days: 30,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _dateSelected == null
                                  ? Text("Choose date for Verification")
                                  : Text(_dateSelected!
                                      .toIso8601String()
                                      .split("T")[0]),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

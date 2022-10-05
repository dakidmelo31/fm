import 'package:flutter/material.dart';
import '../global.dart';
import '../models/chats_model.dart';
import '../themes/light_theme.dart';

class Bubble extends StatefulWidget {
  Bubble({
    Key? key,
    required this.msg,
    required this.msg2,
    required this.mergeTimes,
    required this.separator,
    required this.separator2,
    required this.moment,
    required this.moment2,
  }) : super(key: key);
  final String separator, moment, moment2, separator2;
  final Chat msg, msg2;
  bool mergeTimes;
  @override
  State<Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> {
  late bool state;
  @override
  void initState() {
    state = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return widget.msg.sender != auth.currentUser!.uid
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.separator.isNotEmpty)
                Align(
                    alignment: Alignment.center,
                    child: Card(
                        elevation: 15.0,
                        shadowColor: Colors.grey,
                        color: Colors.black,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(widget.separator,
                                style: Primary.whiteText),
                          ),
                        ))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: SizedBox(
                        width: size.width * .9,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            child: Card(
                                elevation: 0,
                                shadowColor: Colors.grey.withOpacity(.3),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: !widget.mergeTimes &&
                                            widget.msg.sender ==
                                                widget.msg2.sender
                                        ? 0
                                        : 4),
                                color: Color.fromARGB(255, 255, 255, 255),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      state = !state;
                                    });
                                    debugPrint("show how this works");
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(widget.msg.lastmessage,
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 0, 0))),
                                  ),
                                )),
                          ),
                        )),
                  ),
                ],
              ),
              if (state)
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.moment,
                            style: TextStyle(
                                color: Color.fromARGB(255, 246, 255, 0),
                                fontSize: 12),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: ClipOval(
                              child: Container(
                                width: 5,
                                height: 5,
                                color: Color.fromARGB(255, 157, 101, 255),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              widget.msg.senderName,
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.separator.isNotEmpty)
                Align(
                    alignment: Alignment.center,
                    child: Card(
                        elevation: 15.0,
                        shadowColor: Colors.grey,
                        color: Colors.black,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(widget.separator,
                                style: Primary.whiteText),
                          ),
                        ))),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: SizedBox(
                      width: size.width * .9,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          child: Card(
                            elevation: 0,
                            margin: EdgeInsets.only(
                                right: 10,
                                top: widget.mergeTimes &&
                                        widget.msg.sender == widget.msg2.sender
                                    ? 4
                                    : 10),
                            color: Color.fromARGB(255, 10, 15, 255),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  state = !state;
                                });
                                debugPrint("show how this works");
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 10),
                                child: Text(widget.msg.lastmessage,
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (state)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.moment,
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 12),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: ClipOval(
                          child: Container(
                            width: 8,
                            height: 8,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                      Text(
                        "You",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 247, 255),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
  }
}

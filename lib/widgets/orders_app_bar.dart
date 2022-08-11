import 'package:flutter/material.dart';

class OrdersAppBar extends StatefulWidget {
  const OrdersAppBar(
      {Key? key,
      required this.color,
      required this.range,
      required this.callback})
      : super(key: key);
  final VoidCallback callback;
  final Color color;
  final Function(DateTimeRange?) range;

  @override
  State<OrdersAppBar> createState() => _OrdersAppBarState();
}

class _OrdersAppBarState extends State<OrdersAppBar> {
  DateTimeRange? _dateTimeRange;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: SizedBox(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(.15),
                    child: InkWell(
                      onTap: () {
                        widget.callback();
                      },
                      child: AbsorbPointer(
                        absorbing: true,
                        child: TextField(
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: BorderSide(
                                      color: Colors.orange, width: 2)),
                              enabled: true,
                              hintText: "Search",
                              border: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(00),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  color: widget.color,
                  shadowColor: Colors.black.withOpacity(.25),
                  child: IconButton(
                    onPressed: pickDate,
                    icon: Icon(
                      Icons.date_range_rounded,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (_dateTimeRange != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: pickDate,
                  child: Text(
                      "End: ${_dateTimeRange!.start.day}/${_dateTimeRange!.start.month}/${_dateTimeRange!.start.year}"),
                ),
                TextButton(
                  onPressed: pickDate,
                  child: Text(
                      "End: ${_dateTimeRange!.end.day}/${_dateTimeRange!.end.month}/${_dateTimeRange!.end.year}"),
                ),
                if (_dateTimeRange != null)
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _dateTimeRange = null;
                        });
                      },
                      icon: Icon(Icons.close))
              ],
            )
        ]),
        width: double.infinity,
      ),
    );
  }

  pickDate() async {
    _dateTimeRange = await showDateRangePicker(
      context: context,
      initialDateRange: _dateTimeRange,
      initialEntryMode: DatePickerEntryMode.input,
      firstDate: DateTime.now().subtract(
        Duration(
          days: 360,
        ),
      ),
      lastDate: DateTime.now(),
    );
    setState(() {
      widget.range(_dateTimeRange);
    });
  }
}

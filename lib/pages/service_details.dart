import 'package:flutter/material.dart';

class ServiceDetails extends StatefulWidget {
  const ServiceDetails({Key? key, required this.serviceId}) : super(key: key);
  final String serviceId;

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
    );
  }
}

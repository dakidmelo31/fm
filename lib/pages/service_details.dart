import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_grid/carousel_grid.dart';
import 'package:flutter/material.dart';
import 'package:merchants/models/service.dart';
import 'package:merchants/transitions/transitions.dart';
import 'package:merchants/widgets/upload_gallery.dart';

import '../global.dart';

class ServiceDetails extends StatefulWidget {
  ServiceDetails({Key? key, required this.service}) : super(key: key);
  final ServiceModel service;

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            actions: [
              Card(
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete_forever_outlined),
                    color: Colors.pink,
                  ),
                ),
              )
            ],
            expandedHeight: 250,
            leading: BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox(
                height: 250,
                width: size.width,
                child: CachedNetworkImage(
                  imageUrl: widget.service.image,
                  errorWidget: (context, url, error) => errorWidget,
                  placeholder: (context, url) => loadingWidget,
                  fadeInCurve: Curves.fastLinearToSlowEaseIn,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              collapseMode: CollapseMode.parallax,
              stretchModes: [
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
                StretchMode.zoomBackground
              ],
              title: Card(
                color: Colors.black54,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.service.name,
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                    subtitle: Text(
                      "how long it takes for you to deliver your service",
                    ),
                    title: Text(
                      widget.service.duration,
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    )),
                Card(
                  elevation: 15,
                  shadowColor: Colors.grey.withOpacity(.2),
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20.0),
                    child: Text(widget.service.description),
                  ),
                ),
                SwitchListTile.adaptive(
                  value: widget.service.negociable,
                  onChanged: (val) {
                    setState(() {
                      widget.service.negociable = val;
                    });
                  },
                  title: Text("Your Price is negociable"),
                  subtitle: Text("Switch on if your price is negociable."),
                  enableFeedback: true,
                  dense: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 50.0, left: 10, right: 10, bottom: 15.0),
                  child: ListTile(
                    onTap: () {
                      debugPrint("pick images");
                      Navigator.push(
                          context,
                          VerticalSizeTransition(
                              child: UploadGallery(
                            isService: true,
                            images: widget.service.gallery,
                            service: widget.service,
                          )));
                    },
                    leading: Icon(Icons.camera_outlined),
                    title: Text("Add photos to your gallery"),
                    subtitle: Text("Tap to upload more photos to your gallery"),
                    trailing: Icon(Icons.add_photo_alternate),
                  ),
                ),
                CarouselGrid(
                  height: 285,
                  width: 400,
                  listUrlImages: widget.service.gallery,
                  iconBack: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

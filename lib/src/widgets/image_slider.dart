import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget(
      {Key? key,
      required this.context,
      required this.imageList,
      this.controller})
      : super(key: key);
  final BuildContext context;
  final List<String> imageList;
  final GlobalKey<PageFlipWidgetState>? controller;

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  int current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.lightBlueAccent,
          child: CarouselSlider.builder(
            options: CarouselOptions(
                //autoPlay: widget.imageList.length == 1 ? false : true,
                autoPlayInterval: const Duration(seconds: 8),
                //autoPlayAnimationDuration: const Duration(seconds : 7),
                //autoPlayCurve: Curves.easeInOutCirc,
                enlargeFactor: 0.2,
                height: MediaQuery.of(context).size.height * 0.6,
                viewportFraction: 1,
                enableInfiniteScroll:
                    (widget.imageList.length ?? 0) > 1 ? true : false,
                enlargeCenterPage: true,
                autoPlay: true,
                // enlargeStrategy: CenterPageEnlargeStrategy.height
                onPageChanged: (index, reason) {
                  /*   setState(() {
                    current = index;
                  });*/
                }),
            itemCount: widget.imageList.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return GridView(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: [
                  Image.asset(widget.imageList[index]),
                  Image.asset(widget.imageList[index+1])
                ],
              );
              /*return PageFlipWidget(
                duration: const Duration(seconds: 6),
                //key: widget.controller,
                backgroundColor: Colors.black45,
                showDragCutoff: true,
                lastPage: const Center(child: Text('Last Page!')),
                children: [
                  Container(
                    color: index == 0 || index == 2 || index == 4
                        ? Colors.deepPurple
                        : Colors.yellow,
                    child: Image.asset(
                      widget.imageList[index],
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.6,
                    ),
                  ),
                  // SliderImage(imagePath: widget.imageList[i]),
                ],
              );*/
              /*   return Image.asset(
                widget.imageList[index],
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.6,
              );*/
/*            return CachedNetworkImage(
                fit: BoxFit.contain,
                imageUrl: widget.imageList[index],
                height: 299,
                progressIndicatorBuilder: (_, __, downloadProgress) =>
                    Container(
                  padding: const EdgeInsets.all(15),
                  child: ImageProgressIndicator(
                    progress: downloadProgress.progress,
                  ),
                ),

                errorWidget: (_, __, ___) => Icon(Icons.broken_image)
              );*/
            },
          ),
        ),
      ],
    );
  }
}

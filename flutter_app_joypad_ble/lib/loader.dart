import 'dart:math';

import 'package:flutter/material.dart';

class Loader extends StatefulWidget {
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation_rotation;
  Animation<double> animation_radius_in;
  Animation<double> animation_radius_out;

  final double initalRadius = 65.0;
  double radius = 0.0;

  double smallDotRad = 10.0;
  Color outerDotCol = Color(0xffeb6011);

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 4));

    animation_rotation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 1.0, curve: Curves.linear)));

    animation_radius_in = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Interval(0.55, 1.0, curve: Curves.elasticIn)));

    animation_radius_out = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.45, curve: Curves.elasticOut)));

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0) {
          radius = animation_radius_in.value * initalRadius;
        } else if (controller.value >= 0.0 && controller.value <= 0.25) {
          radius = animation_radius_out.value * initalRadius;
        }
      });
    });
    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Container(
            child: Image.asset('assets/images/white_logo.png'),
            height: 40.0,
            width: 105.0,
          ),
        ]),
        backgroundColor: Color(0xffeb6011),
      ),
      body: Center(
          child: Container(
              width: 100.0,
              height: 100.0,
              child: Center(
                child: Stack(children: <Widget>[
                  RotationTransition(
                    turns: animation_rotation,
                    child: Stack(
                      children: <Widget>[
                        Transform.translate(
                            offset: Offset(
                                radius * cos(pi / 4), radius * sin(pi / 4)),
                            child: Dot(
                              radius: smallDotRad,
                              color: outerDotCol,
                            )),
                        Transform.translate(
                            offset: Offset(radius * cos(2 * pi / 4),
                                radius * sin(2 * pi / 4)),
                            child: Dot(
                              radius: smallDotRad,
                              color: outerDotCol,
                            )),
                        Transform.translate(
                            offset: Offset(radius * cos(3 * pi / 4),
                                radius * sin(3 * pi / 4)),
                            child: Dot(
                              radius: smallDotRad,
                              color: outerDotCol,
                            )),
                        Transform.translate(
                            offset: Offset(radius * cos(4 * pi / 4),
                                radius * sin(4 * pi / 4)),
                            child: Dot(
                              radius: smallDotRad,
                              color: outerDotCol,
                            )),
                        Transform.translate(
                            offset: Offset(radius * cos(5 * pi / 4),
                                radius * sin(5 * pi / 4)),
                            child: Dot(
                              radius: smallDotRad,
                              color: outerDotCol,
                            )),
                        Transform.translate(
                            offset: Offset(radius * cos(6 * pi / 4),
                                radius * sin(6 * pi / 4)),
                            child: Dot(
                              radius: smallDotRad,
                              color: outerDotCol,
                            )),
                        Transform.translate(
                            offset: Offset(radius * cos(7 * pi / 4),
                                radius * sin(7 * pi / 4)),
                            child: Dot(
                              radius: smallDotRad,
                              color: outerDotCol,
                            )),
                        Transform.translate(
                            offset: Offset(radius * cos(8 * pi / 4),
                                radius * sin(8 * pi / 4)),
                            child: Dot(
                              radius: smallDotRad,
                              color: outerDotCol,
                            )),
                      ],
                    ),
                  ),
                  Logo(),
                ]),
              ))),
    );
  }
}

class Dot extends StatelessWidget {
  final double radius;
  final Color color;

  Dot({this.radius, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: this.radius,
        height: this.radius,
        decoration: BoxDecoration(color: this.color, shape: BoxShape.circle),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Image(
          image: AssetImage('assets/images/logo.png'),
        ),
      ),
    );
  }
}

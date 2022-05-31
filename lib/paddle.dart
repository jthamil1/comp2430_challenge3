import 'package:flutter/material.dart';
import 'package:untitled/movableObject.dart';

class Paddle extends StatelessWidget with Movable //Class that handles both paddles
{
  Paddle//constructor (all fields inherited from the Movable() class
  ({
    //position
    required double x,
    required double y,
    //Size
    required double width,
    required double height,
    //Velocity in the Y direction (for moving
    velocityY=0,
  }) {
    this.x=x;
    this.y=y;
    this.width=width;
    this.height=height;
    this.velocityY=velocityY;
  }

  @override
  Widget build(BuildContext context)
  {
    return Container(//Very simple, just a container with a white background
      alignment: Alignment(x,y),
      child: Container(
        color: Colors.white,
        height: height,
        width: width
        ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:untitled/movableObject.dart';

class Ball extends StatelessWidget with Movable //The ball that bounces around
{
   Ball({//Constructor. All fields are from the Movable class
     required double x,
     required double y,
     required double width,
     required double height,
     velocityX = 0,
     velocityY=0,
   }) {
     this.x=x;
     this.y=y;
     this.width=width;
     this.height=height;
     this.velocityX=velocityX;
     this.velocityY=velocityY;

   }

  @override
  Widget build(BuildContext context)
  {
    return Container(//Displays the actual ball. I've opted for a mint-green circle
      alignment: Alignment(x,y),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.greenAccent
        ),
        width: width,
        height: height,
      ),
    );
  }
}

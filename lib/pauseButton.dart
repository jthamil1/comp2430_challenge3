import 'package:flutter/material.dart';

//This is the class for the pause button
class PauseButton extends StatelessWidget
{
  ValueChanged<bool> buttonPressed;//Adds a listener type thing to let the homepage know when we've pressed the button
  final double x;//Co-ordinates
  final double y;
  PauseButton({required this.x, required this.y, required this.buttonPressed});//Constructor

  @override
  Widget build(BuildContext context)
  {
    return Container(//Container needed to place button
      alignment: Alignment(x,y),
      child: IconButton(
          iconSize: 72,
          icon:const Icon(Icons.pause_circle_filled),
          onPressed:(){buttonPressed(true);}//Calls the function that we pass to the button (pauses the game)
      ),
    );
  }







}
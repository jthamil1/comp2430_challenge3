import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';

class PauseScreen extends StatelessWidget //This class manages the overlay that happens when the game is paused
{
  final ValueChanged<bool> closePlease; //callback function to tell the homepage to stop drawing this screen. Asking politely is imperative to its functions
  int gameState; /*Used to determine what message(s) to display:
  0: Game hasn't started (newGame message)
  1: Game is in progress, and just paused
  2: Message that displays when you've won the game
  3: Message that displays when you've lost the game
  */
  //These strings are used in the widget build section (holds the strings to actually display)
  String mainString ='';
  String smallString='';

  //These strings are the possible messages to display
  final String newGame = 'Welcome to Pong! Control the paddle on the right with the touchscreen (or UP & DOWN arrows on a computer).\nFirst to 10 points wins!\n';
  final String gameWon = 'You Won! Congratulations\n';
  final String gameLost = 'Oh no, you lost!';
  final String playAgain = 'Play again? (tap anywhere to continue)';
  final String tapToContinue = 'Tap anywhere to continue (Or press Space)';
  final String isPaused = 'P A U S E D';

  PauseScreen({required this.gameState,required this.closePlease}){//Constructor
    switch(gameState)//Switch statement to determine which strings to display
    {
      case (0):{//New game
        mainString= newGame;
        smallString = tapToContinue;
        break;}
      case (1):{//Game Paused
        mainString= isPaused;
        smallString = tapToContinue;
        break;}
      case (2):{//Game Won
        mainString= gameWon;
        smallString = playAgain;
        break;}
      case (3):{//Game Lost
        mainString= gameLost;
        smallString = playAgain;
        break;}
      default:{//Shouldn't happen
        mainString= "Hmm, something's wrong";
        smallString = 'Oh well, tap to continue';
        break;}
    }
  }


  @override
  Widget build(BuildContext context)
  {
    return RawKeyboardListener(//Used to detect the 'space' key, which should unpause the game
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event){
      if(event.isKeyPressed(LogicalKeyboardKey.space)){
        print("In the pause screen");
        closePlease(true);//Should tell the homepage to close this menu
        }
      },
      child: GestureDetector(//Used to detect a tap, which should also close the menu
          onTap: (){closePlease(true);},
      child: Container(
        alignment: Alignment(0,0),
        //All of the below is just to display the text
        child: Container(
            color: Colors.grey[400],
            height: window.physicalSize.height*.75/(window.devicePixelRatio),
            width: window.physicalSize.width*.75/(window.devicePixelRatio),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[Text(
                    mainString,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black
                  )
              ),
                  SizedBox(height: 10),
                  Text(
                    smallString,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[900]
                        )
                      ),
                  ]
              ),
          ),
        )
      )
    )
    );
  }
}
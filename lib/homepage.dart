import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/ball.dart';
import 'package:untitled/paddle.dart';
import 'package:untitled/pauseButton.dart';
import 'package:untitled/pauseScreen.dart';
import 'scoreTxt.dart';

class HomePage extends StatefulWidget
{
  const HomePage({Key? key}) : super(key: key);
  //Creates the state for the homepage (see below)
  @override
  _HomePageState createState() => _HomePageState();
  Widget build(BuildContext context)
  {
    return Container(
    );
  }
}

class _HomePageState extends State<HomePage>
{
  //State variables
  final screenHeight = window.physicalSize.height/window.devicePixelRatio; //Used mostly to shorten the code in certain areas
  final screenWidth = window.physicalSize.width/window.devicePixelRatio;
  final maxAngle = 70; //Maximum angle I want the ball to leave the paddle
  final maxSpeed = 0.0075; //Not exactly the maximum speed of the ball, but acts as a constraint (represents how much of the screen the ball travels in 5ms)
  bool gameStarted = false; //Checks if the game has started yet (mostly used for pausing)
  bool gamePaused = true; //Checks if the game is paused. used for controlling game loop
  bool gameWon = false;//flags to check if either side has won
  bool gameLost=false;
  int playerScore=0;//variables to keep track of the score
  int aiScore=0;
  int countdownNum = 3;//Used for the countdown timer that triggers when the game is unpaused


  var playerPaddle = Paddle( //Declaration for the player's paddle object. See the Paddle class for details
      x: -0.9,
      y: 0,
      height: (window.physicalSize.height)/5,//I couldn't use variable 'screenHeight' in the initializer, so I did this instead
      width: window.physicalSize.width/window.devicePixelRatio/65);//Tries to keep the width of the paddle proportional to the screen
  var aiPaddle = Paddle(//AI's paddle object
      x: 0.9,
      y: 0,
      height: (window.physicalSize.height)/7, //I couldn't use variable 'screenHeight' in the initializer, so I did this instead
      width: window.physicalSize.width/window.devicePixelRatio/65);
  var ball = Ball( //Ball Object
      x: 0,//Starts in middle of the screen
      y: 0,
      height: (window.physicalSize.height/window.devicePixelRatio)/75,//Keeps the size of the ball proportional to the screen
      width: (window.physicalSize.height/window.devicePixelRatio)/75

  );


  //Functions that handle game states
  void gameStart() {//Used to start the game

    if(gameStarted==false) {//This if statement is here just in case, prevents things from restarting accidentally if I messed up somewhere

      setState(() {//Sets some initial variables
        gameStarted = true;//Marks the game as started
        //Sets the initial velocity of the ball to a random value, sending an value between 0 and 1 to calculate the velocity in the X and Y directions
        //See function below for more info
        var initVelo = velocityCalc(angleFactor: Random().nextInt(100)/100);
        //The values are multiplied by 0.9 so that the player hopefully has more time to react at the start of the game
        ball.velocityX = initVelo[0]*0.9;
        ball.velocityY = initVelo[1]*0.9;
      });
      //This is the timer that controls most of the game functions.
      //Ticks once every 5ms
      Timer.periodic(const Duration(milliseconds: 5), (mainTimer) {
        if (gamePaused == false) {//Only runs functions when the game isn't paused
          if(playerScore>=10){//Checks if a victory is achieved
            setState((){
              mainTimer.cancel();//stops this timer
              gameWon=true;//flags that you won the game
              gamePaused = true; //pauses the game (opens a menu)
            });
          }
          else if(aiScore>=10){//If the ai won (do mostly the same things as above)
            setState((){
              mainTimer.cancel();
              gameLost=true;
              gamePaused = true;
            });
          }
          else {//if no one has won yet
            collisionCheck();//Check for collisions
            aiThink();//Very simple logic to determine the direction the AI's paddle should move
            setState((){
              //These statements move the movable pieces
              aiPaddle.move();
              playerPaddle.move();
              ball.move();
            });
          }
        }
      });
      countdown();//Calls the countdown function to give you a chance to prepare
    }
  }
  void gameReset(){//This function resets all of the game values (used for when you're starting a new game once someone's won)
    setState((){
      playerScore=0;
      aiScore=0;
      gameStarted=false;
      gameWon=false;
      gameLost=false;
    });
    paddleReset();
    ballReset();
    gameStart();
  }

  void ballReset() { //Simple function to reset the ball position and give it a new set of velocities
    //This function executes when a goal is scored
    if(playerScore<10 && aiScore<10){//This if statement mostly just makes sure that the ball reset process doesn't execute if the game has been won
    gamePaused = true;//pauses the game
    ball.x = 0;//resets ball position
    ball.y = 0;
    var initVelo = velocityCalc(angleFactor: Random().nextInt(100)/100);//new ball velocity
    if(Random().nextBool()==true){//This if/else statement set determine the direction the ball will travel
      setState((){
        ball.velocityX = initVelo[0]*0.9;
        ball.velocityY=initVelo[1]*0.9;
      });
    }
    else
    {
      setState((){
        ball.velocityX = -initVelo[0]*0.9;
        ball.velocityY=initVelo[1]*0.9;
      });
    }
    countdown();//Starts the countdown to get things moving again
    }
  }
  void countdown(){
    setState((){//Initial value for the countdown to 3
      countdownNum=3;
    });

    Timer.periodic(const Duration(seconds: 1), (countdownTimer)//Timer that ticks once per second
    {
      setState((){
        countdownNum--;//Decrements the counter by 1
      });
      if(countdownNum<=0)//If the counter reaches 0
      {
        setState((){
          countdownTimer.cancel();//Cancels this timer
          gamePaused=false;//unpauses the game
        });
      }
    });
  }
  void pauseGame() {
    if(gamePaused==false) {//If the game isn't paused already
      setState(() {
        gamePaused = true;//marks the game as being paused
      });
    }
    else{
      countdown();//If the game is already paused, initiates the countdown proccess
    }
  }
  void paddleReset(){//Just resets both paddles to the center of the screen
    setState((){
      playerPaddle.y=0;
      aiPaddle.y=0;
    });
  }
  void aiThink(){//Used for determining the AI paddle movement
    //Just attempts to have the paddle follow the ball
    if(ball.y<=aiPaddle.y){
      setState((){
        aiPaddle.velocityY=-0.005;
      });
    }
    else if (ball.y>=aiPaddle.y){
      setState((){
        aiPaddle.velocityY=0.005;
      });
    }
  }

  //Functions that handle collision

  List<double> velocityCalc({required double angleFactor}){
    //Used for calculating the new direction/speed for the ball to travel
    double angle = angleFactor*maxAngle;//Calculates the angle the ball should leave the paddle at by taking the relative impact position and multiplying it by the maximum angle I'd like it to leave at
    //For example, Hitting right on the edge of the paddle would send this function 1 (or -1), and thus the angle it leaves would be 1*maxAngle
    return [maxSpeed*cos(angle*(pi/180)),-maxSpeed * sin(angle*(pi/180))];//uses trigonometry to calculate the x&y velocities. Passed back as a list for easier access
  }
  void collisionCheck(){//This function only contains the if/else statements for detecting collisions. There's a separate function below that handles what to do with the ball (or paddles) when the collision occurs
    //======BALL COLLISIONS===========
    //Player paddle
    if((ball.getLeft() <= playerPaddle.getRight() && ball.getRight() >= playerPaddle.getLeft())&&
        ((ball.getBottom()>=playerPaddle.getTop())&&(ball.getTop()<=playerPaddle.getBottom()))) {
      if(ball.velocityX<0) {//This is here to make sure the collision logic doesn't continue to mess up if the ball clips inside the paddle and can't escape before the next update
        collisionHandler(collider: 'playerPaddle', colPos: (ball.y-playerPaddle.getMid())/(playerPaddle.height/screenHeight));
      }
    }
    //AI paddle
    else if((ball.getRight() >= aiPaddle.getLeft()&&ball.getLeft()<=aiPaddle.getRight())&&
        ((ball.getBottom() >=aiPaddle.getTop())&&(ball.getBottom()<=aiPaddle.getBottom()))) {
      if(ball.velocityX>0)
      {
        collisionHandler(collider: 'aiPaddle',colPos: (ball.y-aiPaddle.getMid())/(aiPaddle.height/screenHeight));
      }
    }
    //Top wall
    else if(ball.getTop()<=-1){
      if(ball.velocityY<0) {
        collisionHandler(collider: 'wall');
      }
    }
    //bottom wall
    else if (ball.getBottom()>= 1){
      if(ball.velocityY>0) {
        collisionHandler(collider: 'wall');
      }
    }
    //Player Goal
    if(ball.x <= -1) {
      collisionHandler(collider: 'playerGoal');
    }
    //AI Goal
    if (ball.x >= 1) {
      collisionHandler(collider: 'aiGoal');
    }
    //========END OF BALL COLLISIONS=========
    //
    //=======PADDLE & WALL COLLISIONS========
    if(((aiPaddle.y<=-1)&&(aiPaddle.velocityY<0))||((aiPaddle.y>=1)&&(aiPaddle.velocityY>0))){
      collisionHandler(collider: 'aiAndWall');
    }
    if(((playerPaddle.y<=-1)&&(playerPaddle.velocityY<0))||((playerPaddle.y>=1)&&(playerPaddle.velocityY>0))){
      collisionHandler(collider: 'playerAndWall');
    }
    //====END OF PADDLE & WALL COLLISIONS====
  }
  void collisionHandler({required String collider,double colPos=0}) {
    //This function handles the collisions. The type of collision is passed as a string, as well as the relative position that the ball hit the paddle (-1 to 1)
    //This function also handles paddle & wall collisions, so the collision position (colPos) isn't required
    switch (collider) {
      case "playerPaddle"://Ball & player paddle
        {
             var temp = velocityCalc(angleFactor: colPos);//calculates the new velocity for the ball
            setState((){
              ball.velocityY=temp[1];
              ball.velocityX=temp[0];
            });
          break;
        }
      case "aiPaddle"://Ball & opponent paddle
        {
          var temp = velocityCalc(angleFactor: colPos);//almost identical as above, but the x velocity is negated (to send the ball in the correct direction)
          setState((){
            ball.velocityY=temp[1];
            ball.velocityX=-temp[0];
          });
          break;
        }
      case "wall": {//Ball & the Top or bottom wall (Just inverts the y direction)
          setState((){
            ball.velocityY = ball.velocityY * -1;
          });
          break;
        }
      case "playerGoal":{//Ball and the left edge of the screen
        setState((){
          aiScore++;//Increments the AI's score by 1
        });
        paddleReset();//resets the ball & paddles for the next round
        ballReset();
        break;
      }

      case "aiGoal":{//ball and right edge of screen
        setState((){
          playerScore++;//increments player's score
        });
        paddleReset();//resets ball & paddles
        ballReset();

        break;
      }
      case "aiAndWall":{//Stops the AI's paddle from moving through the walls
        setState((){
          aiPaddle.velocityY=0;
        });
        break;}

      case "playerAndWall":{//Stops the player's paddle from moving through the walls
        setState((){
          playerPaddle.velocityY=0;
        });
        break;}

      default://This should never execute. If for some reason it does, it just resets the game
        ballReset();
        paddleReset();
        break;
    }
  }




  //The actual building of the screen/widgets
  @override
  Widget build(BuildContext context){
    return RawKeyboardListener(//This section allows the app to be played/tested on the computer
      focusNode: FocusNode(),
      autofocus: false,
      onKey: (event)
      {
        if(event is RawKeyDownEvent){
          if(event.isKeyPressed(LogicalKeyboardKey.arrowDown)){//if the player pressed the down arrow, moves the paddle down
            setState((){
              playerPaddle.velocityY=0.005;
            });
          }
          else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)){//up arrow moves it up
            setState((){
              playerPaddle.velocityY=-0.005;
            });
          }
          else if (event.isKeyPressed(LogicalKeyboardKey.space))//space pauses the game
          {
            print("In the homepage");
            pauseGame();
          }
        }
        else if(event is RawKeyUpEvent){//This is to catch if the arrow is released, to stop the paddle from moving constantly
          if(event.logicalKey.keyLabel=='Arrow Up'||event.logicalKey.keyLabel=='Arrow Down'){
            setState((){
              playerPaddle.velocityY=0;
            });
          }
        }
      },
      child: GestureDetector(//Next, the gesturedetector allows for touchscreen control of the paddle
        onVerticalDragUpdate: (details)
        {
          if(details.delta.dy>0) {//Swiping down
            playerPaddle.velocityY=0.008;
          }
          else {//swiping up
            setState((){
              playerPaddle.velocityY=-0.008;
            });
          }
        },
        onVerticalDragEnd:(details)//Stops paddle from moving when the player stops dragging
        {
          setState((){
            playerPaddle.velocityY=0;
          });
        },
        child: Scaffold(//Main layout for visible widgets
          backgroundColor: Colors.grey[900],//BG colour
          body: Center(//Centers the children within the screen
            child: Stack(//A stack of widgets for easier handling
              children: [
                ScoreTxt(txt: "Player: $playerScore",x:-0.5,y:-0.2),//Displays the player's score
                ScoreTxt(txt: "Opponent: $aiScore",x:0.5,y:-0.2),//displays the AI's score
                PauseButton(x: 0.95, y: -0.99, buttonPressed: (temp)
                { if(countdownNum<=0&&gamePaused==false){//Stops the game from being paused when the countdown is taking place, also when the game is already paused
                  pauseGame();
                }
                }),//Creates a pause button
                ball.build(context),//shows the ball
                playerPaddle.build(context),//shows the paddles
                aiPaddle.build(context),
                if(countdownNum>0)//Only displays the countdown text if it is actively counting down
                  ScoreTxt(txt: '$countdownNum',x:0,y:0),
                if(gamePaused==true)//Handles the pause screen. There are 4 different types of text to be displayed on this screen, hence 4 different conditions
                  if(gameStarted==false)PauseScreen(gameState: 0,closePlease:(temp){gameStart();})//Game hasn't been started (initial screen)
                  else if(gameWon==true)PauseScreen(gameState:2,closePlease:(temp){gameReset();})//Displays a message when you win
                  else if(gameLost==true)PauseScreen(gameState: 3,closePlease:(temp){gameReset();})//Displays a message when you lose
                  else if(countdownNum<=0)PauseScreen(gameState: 1,closePlease:(temp){pauseGame();})//Generic pausing
                ],
            ),
          ),
        ),
      ),
    );
  }
}
/**
 * Mock Pac-Man Game
 * Proof of concept
 *
 * by Yahir March 2019
 * Processing 3.5.3
 *
 * Use SPACE to move through screens
 * Use 'i' for instruction screen or to pause game
 * Use ARROW KEYS to move Pac-man
 * If high score obtained enter name and press enter to save score
 **/

import java.util.*;
import processing.sound.*;

// Declare sound files for in game effects
SoundFile coinSound, moveSound, bigCoinSound, eatGhostSound, eatPacSound, gameOverSound, gameMusic;

// Declare mover object which represents pacman and ghosts
Mover pacman, redGhost, blueGhost, pinkGhost, greenGhost; 

// Declare A* path finding object
AStarPath redPath, bluePath, pinkPath, greenPath; 

// Game Declarations
boolean levelOver;  // Determine if player completed level
boolean captured;   // Determine if pacman has been captured by ghosts
boolean gameOver;   // Determin if player has lost the game
boolean playEatPacSound; // Determien when to play pacman eaten sound
int screen;         // Track which screen to display (intro, instructions, level, game over, and play)
int priorScreen;    // Tracks the prior screen before entering instruction screen
int capturedCounter;// Counts num cycles before reswapning pacman after capture
int restartCounter; // Counts num cycles to
int CaptureDelay;   // Delay time display before respawn
int levelScore;     // Track level point score
int numCoins;       // How many coins exist on grid. Used to check if all coins collected
int gameScore;      // Track overall game score
int numLives;       // Track number of pacman lives
int level;          // Track level number

boolean flee;       // Track ghost flee
int fleeCount;      // Counter for fleeTime
int fleeTime;       // Target value for fleeCount or how many cylces before flee time ends

String userName = "ENTER_NAME"; // User name for entering high scores
boolean newHighScore1; // For determing high score postion 1
boolean newHighScore2; // For determing high score postion 2
boolean newHighScore3; // For determing high score postion 3
Table table; // Declare table object for saving high scores
TableRow rowScores; // Read scores row in table scores
TableRow rowNames; // Read names row in table scores
int firstScore; // Holds high score 1 from table scores
int secondScore; // Holds high score 2 from table scores
int thirdScore; // Holds high score 3 from table scores
String firstName; // Holds name 1 from table scores
String secondName; // Holds name 2 from table scores
String thirdName; // Holds name 3 from table scores
boolean scoreUpdated; // Determine if score has been saved in table scores
boolean updateFinalScore; // Determine if final score has been updated

// Red Ghost Declarations
boolean redChase;  // Track whether redGhost is free to chase
boolean redCaptured; // redGhost was captured during flee mode
int redSpdCount;   // Counter for red ghost speed
int redSpeed;      // Target value for redSpdCount or How many cycles between red ghost movement
int redDlyCount;   // Counter for red ghost delay
int redDelay;      // Target value for redDlyCount or How many cycles before red ghost is free to move

// Blue Ghost Declarations
boolean blueChase;  // Track whether blueGhost is free to chase
boolean blueCaptured; // Blue Ghost was captured during flee mode
int blueSpdCount;   // Counter for blue ghost speed
int blueSpeed;      // Target value for blueSpdCount or How many cycles between blue ghost movement
int blueDlyCount;   // Counter for blue ghost delay
int blueDelay;      // Target value for blueDlyCount or How many cycles before blue ghost is free to move

// Pink Ghost Declarations
boolean pinkChase;  // Track whether pinkGhost is free to chase
boolean pinkCaptured; // Pink Ghost was captured during flee mode
int pinkSpdCount;   // Counter for pink ghost speed
int pinkSpeed;      // Target value for pinkSpdCount or How many cycles between pink ghost movement
int pinkDlyCount;   // Counter for pink ghost delay
int pinkDelay;      // Target value for pinkDlyCount or How many cycles before pink ghost is free to move

// Green Ghost Declarations
boolean greenChase;  // Track whether greenGhost is free to chase
boolean greenCaptured; // Red Ghost was captured during flee mode
int greenSpdCount;   // Counter for green ghost speed
int greenSpeed;      // Target value for greenSpdCount or How many cycles between green ghost movement
int greenDlyCount;   // Counter for green ghost delay
int greenDelay;      // Target value for greenDlyCount or How many cycles before green ghost is free to move


// Number of cols and rows for the grid
int cols = 23;
int rows = 23;

// Width and height of each cell of grid
float w, h;

// This is the Cell 2D array describing the grid
Cell[][] grid = new Cell[cols][rows];
int[][] gridMap = {                
// 0  1  2  3  4  5  6  7  8  8 10  11 12 13 14 15 16 17 18 19 20 21 22
  {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}, // 0
  {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}, // 1
  {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}, // 2
  {5, 5, 1, 2, 1, 1, 1, 1, 5, 5, 1, 5, 5, 5, 1, 1, 2, 5, 1, 1, 1, 5, 5}, // 3
  {5, 5, 1, 5, 5, 1, 5, 1, 5, 5, 1, 5, 5, 5, 1, 5, 1, 1, 1, 5, 1, 5, 5}, // 4
  {5, 5, 1, 5, 5, 1, 5, 1, 5, 5, 1, 5, 5, 5, 1, 5, 5, 5, 1, 5, 1, 5, 5}, // 5
  {5, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 1, 5, 5}, // 6
  {5, 5, 1, 5, 5, 1, 5, 5, 5, 5, 1, 5, 5, 5, 1, 5, 1, 5, 5, 5, 1, 5, 5}, // 7
  {5, 5, 1, 5, 5, 1, 1, 1, 5, 1, 1, 1, 1, 1, 1, 5, 1, 1, 1, 5, 1, 5, 5}, // 8
  {5, 5, 1, 5, 5, 1, 5, 1, 5, 1, 5, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 5}, // 9
  {5, 5, 1, 1, 1, 1, 5, 1, 1, 1, 5, 5, 1, 5, 1, 1, 1, 5, 1, 1, 1, 5, 5}, // 10
  {5, 5, 5, 5, 5, 1, 5, 5, 5, 1, 1, 1, 1, 5, 5, 5, 0, 5, 5, 5, 1, 5, 5}, // 11
  {5, 5, 1, 1, 1, 1, 5, 1, 1, 1, 5, 5, 1, 5, 1, 1, 1, 5, 1, 1, 1, 5, 5}, // 12
  {5, 5, 1, 5, 5, 1, 5, 1, 5, 1, 5, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 5}, // 13
  {5, 5, 1, 5, 5, 1, 1, 1, 5, 1, 1, 1, 1, 1, 1, 5, 1, 1, 1, 5, 1, 5, 5}, // 14
  {5, 5, 1, 5, 5, 1, 5, 5, 5, 5, 1, 5, 5, 5, 1, 5, 1, 5, 5, 5, 1, 5, 5}, // 15
  {5, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 1, 5, 5}, // 16
  {5, 5, 1, 5, 5, 1, 5, 1, 5, 5, 1, 5, 5, 5, 1, 5, 5, 5, 1, 5, 1, 5, 5}, // 17
  {5, 5, 1, 5, 5, 1, 5, 1, 5, 5, 1, 5, 5, 5, 1, 5, 1, 1, 1, 5, 1, 5, 5}, // 18
  {5, 5, 1, 2, 1, 1, 1, 1, 5, 5, 1, 5, 5, 5, 1, 1, 2, 5, 1, 1, 1, 5, 5}, // 19
  {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}, // 20
  {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}, // 21
  {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}, // 22
};

/**
 * Setup Method
 **/
void setup() {
  size(1610, 1610); // Game size for HD display

  // Grid cell size
  w = float(width) / cols; // 70px
  h = float(height) / rows; // 70px

  // Setup grid description
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j] = new Cell(i, j);
      switch(gridMap[i][j]) {
      case 1: // point in cell
        grid[i][j].hasPoint = true;
        break;
      case 2: // big point in cell
        grid[i][j].hasBigPoint = true;
        break;
      case 4:
        grid[i][j].hasFauxWall = true;
      case 5: // wall in cell
        grid[i][j].hasWall = true;
        break;
      default:
        break;
      }
    }
  }

  // Add all neighbors of cells
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].addNeighbors(grid, cols, rows);
    }
  }

  // Initialize sound files
  coinSound = new SoundFile(this, "350869__cabled-mess__coin-c-06__boost.wav");
  moveSound = new SoundFile(this, "463202__gamer127__one-beep__boost.wav");
  bigCoinSound = new SoundFile(this, "341695__projectsu012__coins-1.wav");
  eatGhostSound = new SoundFile(this, "258020__kodack__arcade-bleep-sound.wav");
  eatPacSound = new SoundFile(this, "350983__cabled-mess__lose-c-07.wav");
  gameOverSound = new SoundFile(this, "415079__harrietniamh__video-game-death-sound-effect.wav");
  gameMusic = new SoundFile(this, "172561__djgriffin__video-game-7.wav");
  // Adjust sound levels/properties
  bigCoinSound.amp(0.9);
  eatGhostSound.amp(0.6);
  gameMusic.amp(0.25);
  gameMusic.loop();


  // Initialize game variables
  levelOver = false;
  captured = false;
  gameOver = false;
  CaptureDelay = 3;
  screen = 0;
  redSpdCount = 0;
  levelScore = 0;
  gameScore = 0;
  numLives = 3;
  level = 1;
  fleeTime = 400;
  updateFinalScore = true;
  playEatPacSound = true;

  // Initialize  pacman 
  pacman = new Mover(11, 16, w, h);
  // Initialze red ghost mover and A* path objects
  redGhost = new Mover(9, 10, w, h);
  redGhost.setColor(color(255, 0, 0));
  redGhost.setMouthDirection(-1);
  redPath = new AStarPath();
  // Initialze blue ghost mover and A* path objects
  blueGhost = new Mover(13, 10, w, h);
  blueGhost.setColor(color(0, 0, 255));
  blueGhost.setMouthDirection(-1);
  bluePath = new AStarPath();
  // Initialze pink ghost mover and A* path objects
  pinkGhost = new Mover(10, 11, w, h);
  pinkGhost.setColor(color(250, 0, 255));
  pinkGhost.setMouthDirection(-1);
  pinkPath = new AStarPath();
  // Initialze green ghost mover and A* path objects
  greenGhost = new Mover(12, 11, w, h);
  greenGhost.setColor(color(0, 255, 0));
  greenGhost.setMouthDirection(-1);
  greenPath = new AStarPath();

  // Initialize red ghost variables
  redSpeed = 30;
  redSpdCount = 0;
  redDelay = int(random(100, 151));
  redDlyCount = 0;
  // Initialize blue gGhost variables
  blueSpeed = 30;
  blueSpdCount = 0;
  blueDelay = int(random(151, 201));
  blueDlyCount = 0;
  // Initialize pink ghost variables
  pinkSpeed = 30;
  pinkSpdCount = 0;
  pinkDelay = int(random(100, 151));
  pinkDlyCount = 0;
  // Initialize green ghost variables
  greenSpeed = 30;
  greenSpdCount = 0;
  greenDelay = int(random(100, 151));
  greenDlyCount = 0;
}

/**
 * Draw Method
 **/
void draw() {
  switch(screen) {
  case 1: 
    /**
     *
     * PLAY SCREEN
     *
     **/

    // INCREASE game music amp when playing
    gameMusic.amp(1);

    // DISPLAY the grid as described in gridMap initialization
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        grid[i][j].display(w, h);
      }
    }

    // IF red ghost is fleeing define flee path
    if (flee) {
      redPath.findPath(grid[redGhost.getI()][redGhost.getJ()], findFleeCell(pacman, 0));
    } else {
      // Define red ghost path when chasing pacman
      // MOVE to exact pacman position 
      redPath.findPath(grid[redGhost.getI()][redGhost.getJ()], grid[pacman.getI()][pacman.getJ()]);
    }

    // IF blue ghost is fleeing define flee path
    if (flee) {
      bluePath.findPath(grid[blueGhost.getI()][blueGhost.getJ()], findFleeCell(pacman, 1));
    } else {
      // Define blue ghost path when chasing pacman
      // MOVE one space ahead of pacman position 
      if (pacman.getMoveRight()) {
        if (pacman.getI() < 20) {
          bluePath.findPath(grid[blueGhost.getI()][blueGhost.getJ()], grid[pacman.getI() +1][pacman.getJ()]);
        } else {
          bluePath.findPath(grid[blueGhost.getI()][blueGhost.getJ()], grid[pacman.getI()][pacman.getJ()]);
        }
      } else if (pacman.getMoveLeft()) {
        if (pacman.getI() < 1) {
          bluePath.findPath(grid[blueGhost.getI()][blueGhost.getJ()], grid[pacman.getI() -1][pacman.getJ()]);
        } else {
          bluePath.findPath(grid[blueGhost.getI()][blueGhost.getJ()], grid[pacman.getI()][pacman.getJ()]);
        }
      } else if (pacman.getMoveUp()) {
        bluePath.findPath(grid[blueGhost.getI()][blueGhost.getJ()], grid[pacman.getI()][pacman.getJ()-1]);
      } else {
        bluePath.findPath(grid[blueGhost.getI()][blueGhost.getJ()], grid[pacman.getI()][pacman.getJ()+1]);
      }
    }

    // IF pink ghost is fleeing define flee path
    if (flee) {
      pinkPath.findPath(grid[pinkGhost.getI()][pinkGhost.getJ()], findFleeCell(pacman, 1));
    } else {
      // Define pink ghost path when chasing pacman
      // MOVE to the nearest pacman corner
      pinkPath.findPath(grid[pinkGhost.getI()][pinkGhost.getJ()], findNearestCorner(pacman));
    }

    // IF green ghost is fleeing define flee path
    if (flee) {
      greenPath.findPath(grid[greenGhost.getI()][greenGhost.getJ()], findFleeCell(pacman, 0));
    } else {
      // Define green ghost path when chasing pacman
      // MOVE between to arbitrary middle points
      greenPath.findPath(grid[greenGhost.getI()][greenGhost.getJ()], findNearestMid(pacman));
    }

    // Update red ghost location and state
    // IF red ghost NOT captured
    if (!redCaptured) {
      // CREATE delay counter before exiting home
      redDlyCount++;
      if (redDlyCount >= redDelay) {
        if (!redChase) {
          // MOVE red ghost out of home and into the grid and begin chasing
          redGhost.setI(9);
          redGhost.setJ(9);
          redChase = true;
        }
        redDlyCount = redDelay;
        // SET and FOLLOW red ghost move speed
        redSpdCount++;
        if (redSpdCount >= redSpeed) {
          redSpdCount = 0;
          // FOLLOW optimal path to target position by moving through
          // the path list and removing elements until empty
          if (!redPath.path.isEmpty() && !captured) {
            redPath.path.remove(redPath.path.size()-1);
            if (!redPath.path.isEmpty()) {
              redGhost.setI(redPath.path.get(redPath.path.size()-1).i);
              redGhost.setJ(redPath.path.get(redPath.path.size()-1).j);
            }
          }
          // Randomly SET eye look direction
          redGhost.setEyeDirection(int(random(0, 2)));
          redGhost.setMouthOpen(!redGhost.getMouthOpen());
        }
      }
    }

    // Update blue ghost location and state
    // IF blue ghost NOT captured
    if (!blueCaptured) {
      // CREATE delay counter before exiting home
      blueDlyCount++;
      if (blueDlyCount >= blueDelay) {
        if (!blueChase) {
          // MOVE blue ghost out of home and into the grid and begin chasing
          blueGhost.setI(13);
          blueGhost.setJ(9);
          blueChase = true;
        }
        blueDlyCount = blueDelay;
        // SET and FOLLOW blue ghost move speed
        blueSpdCount++;
        if (blueSpdCount >= blueSpeed) {
          blueSpdCount = 0;
          // FOLLOW optimal path to target position by moving through
          // the path list and removing elements until empty
          if (!bluePath.path.isEmpty() && !captured) {
            bluePath.path.remove(bluePath.path.size()-1);
            if (!bluePath.path.isEmpty()) {
              blueGhost.setI(bluePath.path.get(bluePath.path.size()-1).i);
              blueGhost.setJ(bluePath.path.get(bluePath.path.size()-1).j);
            }
          }
          // Randomly SET eye look direction
          blueGhost.setEyeDirection(int(random(0, 2)));
          blueGhost.setMouthOpen(!blueGhost.getMouthOpen());
        }
      }
    }

    // Update pink ghost location and state
    // IF pink ghost NOT captured
    if (!pinkCaptured) {
      // CREATE delay counter before exiting home
      pinkDlyCount++;
      if (pinkDlyCount >= pinkDelay) {
        if (!pinkChase) {
          // MOVE pink ghost out of home and into the grid and begin chasing
          pinkGhost.setI(10);
          pinkGhost.setJ(12);
          pinkChase = true;
        }
        pinkDlyCount = pinkDelay;
        // SET and FOLLOW pink ghost move speed
        pinkSpdCount++;
        if (pinkSpdCount >= pinkSpeed) {
          pinkSpdCount = 0;
          // FOLLOW optimal path to target position by moving through
          // the path list and removing elements until empty
          if (!pinkPath.path.isEmpty() && !captured) {
            pinkPath.path.remove(pinkPath.path.size()-1);
            if (!pinkPath.path.isEmpty()) {
              pinkGhost.setI(pinkPath.path.get(pinkPath.path.size()-1).i);
              pinkGhost.setJ(pinkPath.path.get(pinkPath.path.size()-1).j);
            }
          }
          // Randomly SET eye look direction
          pinkGhost.setEyeDirection(int(random(0, 2)));
          pinkGhost.setMouthOpen(!redGhost.getMouthOpen());
        }
      }
    }

    // Update green ghost location and state
    // IF green ghost NOT captured
    if (!greenCaptured) {
      // CREATE delay counter before exiting home
      greenDlyCount++;
      if (greenDlyCount >= greenDelay) {
        if (!greenChase) {
          // MOVE green ghost out of home and into the grid and begin chasing
          greenGhost.setI(12);
          greenGhost.setJ(12);
          greenChase = true;
        }
        greenDlyCount = greenDelay;
        // SET and FOLLOW green ghost move speed
        greenSpdCount++;
        if (greenSpdCount >= greenSpeed) {
          greenSpdCount = 0;
          // FOLLOW optimal path to target position by moving through
          // the path list and removing elements until empty
          if (!greenPath.path.isEmpty() && !captured) {
            greenPath.path.remove(greenPath.path.size()-1);
            if (!greenPath.path.isEmpty()) {
              greenGhost.setI(greenPath.path.get(greenPath.path.size()-1).i);
              greenGhost.setJ(greenPath.path.get(greenPath.path.size()-1).j);
            }
          }
          // Randomly SET eye look direction
          greenGhost.setEyeDirection(int(random(0, 2)));
          greenGhost.setMouthOpen(!greenGhost.getMouthOpen());
        }
      }
    }

    // DISPLAY game objects
    findOpenCells(pacman, false);
    pacman.display();
    collectPoints(pacman);
    redGhost.display();
    blueGhost.display();
    pinkGhost.display();
    greenGhost.display();

    // DISPLAY ghost paths for trouble shooting
    //redPath.displayPath(color(255, 0, 0));
    //bluePath.displayPath(color(0, 0, 255));
    //greenPath.displayPath(color(0, 255, 0));
    //pinkPath.displayPath(color(250, 0, 255));

    // DISPLAY number of pacman lives
    fill(240, 255, 0, 200);
    for (int i = 0; i < numLives; i++) {
      arc((i + 10) * w + w / 2.0, 1 * h + h / 2.0, 30, 30, radians(30), radians(310), PIE);
    }

    // CHECK game status
    if (flee) {
      // IF in flee mode SET ghosts to teal color
      redGhost.setColor(color(0, 255, 255));
      blueGhost.setColor(color(0, 255, 255));
      pinkGhost.setColor(color(0, 255, 255));
      greenGhost.setColor(color(0, 255, 255));
      // TRACK amout of time for flee mode
      fleeCount++;
      if (fleeCount > fleeTime) {
        // RESET variables once flee mode complete
        fleeCount = 0;
        flee = false;
        redCaptured = false;
        blueCaptured = false;
        pinkCaptured = false;
        greenCaptured = false;
      }
      // IF pacman eats red ghost send ghost home and play approiate sound
      if (pacman.getI() == redGhost.getI() && pacman.getJ() == redGhost.getJ()) {
        redGhost.setI(9);
        redGhost.setJ(10);
        redCaptured = true;
        if(eatGhostSound.isPlaying()) {
          eatGhostSound.stop();
        }
        eatGhostSound.stop();
        eatGhostSound.play();
      }
      // IF pacman eats blue ghost send ghost home and play approiate sound
      if (pacman.getI() == blueGhost.getI() && pacman.getJ() == blueGhost.getJ()) {
        blueGhost.setI(13);
        blueGhost.setJ(10);
        blueCaptured = true;
        if(eatGhostSound.isPlaying()) {
          eatGhostSound.stop();
        }
        eatGhostSound.stop();
        eatGhostSound.play();
      }
      // IF pacman eats pink ghost send ghost home and play approiate sound
      if (pacman.getI() == pinkGhost.getI() && pacman.getJ() == pinkGhost.getJ()) {
        pinkGhost.setI(10);
        pinkGhost.setJ(11);
        pinkCaptured = true;
        if(eatGhostSound.isPlaying()) {
          eatGhostSound.stop();
        }
        eatGhostSound.stop();
        eatGhostSound.play();
      }
      // IF pacman eats green ghost send ghost home and play approiate sound
      if (pacman.getI() == greenGhost.getI() && pacman.getJ() == greenGhost.getJ()) {
        greenGhost.setI(12);
        greenGhost.setJ(11);
        greenCaptured = true;
        if(eatGhostSound.isPlaying()) {
          eatGhostSound.stop();
        }
        eatGhostSound.stop();
        eatGhostSound.play();
      }
    } else { // In regular ghost chase mode
      // SET ghosts to appropriate color
      redGhost.setColor(color(255, 0, 0));
      blueGhost.setColor(color(0, 0, 255));
      pinkGhost.setColor(color(250, 0, 255));
      greenGhost.setColor(color(0, 255, 0));
      // IF pacman is eaten by any ghost
      if (pacman.getI() == redGhost.getI() && pacman.getJ() == redGhost.getJ() ||
        pacman.getI() == blueGhost.getI() && pacman.getJ() == blueGhost.getJ() ||
        pacman.getI() == pinkGhost.getI() && pacman.getJ() == pinkGhost.getJ() ||
        pacman.getI() == greenGhost.getI() && pacman.getJ() == greenGhost.getJ()) {
        // CHECK number of pacman lives
        // IF greater than one indicate capture and start restart counter
        if (numLives > 1) {
          captured = true;
          capturedCounter++;
          restartCounter++;
          if (restartCounter > 50) {
            restartCounter = 0;
            CaptureDelay--;
          }
          // PLAY pacman eaten sound
          if (playEatPacSound) {
            if(eatPacSound.isPlaying()) {
              eatPacSound.stop();
            }
            eatPacSound.stop();
            eatPacSound.play();
            playEatPacSound = false;
          }
          // DISPLAY countdown text after pacman is captured and before RESETTING
          fill(255, 0, 0);
          textSize(600);
          textAlign(CENTER, CENTER);
          text(CaptureDelay, width/2, 620);
          // After capture delay is over reset pacamn, ghost, and account for capture
          if (capturedCounter > 150) {
            restartCounter = 0;
            CaptureDelay = 3;
            capturedCounter = 0;
            captured = false;
            playEatPacSound = true;
            pacman.setMouthDirection(0);
            pacman.setMouthOpen(true);
            pacman.setI(11);
            pacman.setJ(16);
            numLives--;

            // Red ghost RESET home
            redChase = false;
            redDlyCount = 0;
            redDelay = int(random(100, 201));
            redSpdCount = 0;
            redGhost.setI(9);
            redGhost.setJ(10);

            // Blue ghost RESET home
            blueChase = false;
            blueDlyCount = 0;
            blueDelay = int(random(100, 201));
            blueSpdCount = 0;
            blueGhost.setI(13);
            blueGhost.setJ(10);

            // Pink ghost RESET home
            pinkChase = false;
            pinkDlyCount = 0;
            pinkDelay = int(random(100, 201));
            pinkSpdCount = 0;
            pinkGhost.setI(10);
            pinkGhost.setJ(11);

            // Green ghost RESET home
            greenChase = false;
            greenDlyCount = 0;
            greenDelay = int(random(100, 201));
            greenSpdCount = 0;
            greenGhost.setI(12);
            greenGhost.setJ(11);
          }
        } else { // If pacman lives is 0 indate game over by going to game over screen
          gameOver = true;
          if(gameOverSound.isPlaying()) {
            gameOverSound.stop();
          }
          gameOverSound.stop();
          gameOverSound.play();
          screen = 3;
        }
      }
    }
    // CHECK if pacman has eaten all coins and move to level screen
    if (numCoins == 182) { // win = 182
      levelOver = true;
      screen = 2;
    }

    // DISPLAY Game Info Text;
    textAlign(CENTER, CENTER);
    textSize(62);
    fill(240, 255, 0);
    text("PAC-MAN ", width/2, 35);
    fill(255);
    textSize(32);
    text("Level " + level, width/2 + 480, 35);
    text("Score: " + levelScore, width/2 - 480, 35);
    break;
  case 2:
    /**
     *
     * LEVEL SCREEN = 2
     *
     **/

    // UPDATE the game score
    if (updateFinalScore) {
      gameScore += levelScore;
      updateFinalScore = false;
    }

    // DECREASE game music
    gameMusic.amp(.25);
    // Display the grid as described in gridMap initialization
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        grid[i][j].display(w, h);
      }
    }

    // DISPLAY mover objects
    pacman.display();
    redGhost.display();
    blueGhost.display();
    pinkGhost.display();
    greenGhost.display();

    // DISPLAY level info text
    fill(120, 32, 188, 230);
    noStroke();
    rect(-1, -1, 1611, 1611);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(104);
    text("LEVEL " + level + " COMPLETE", width/2, 600);
    textSize(32);
    text("Level Score: " + levelScore, width/2, 800);
    text("Game Score: " + gameScore, width/2, 880);
    text("Hit 'space' for next level", width/2, 960);
    break;
  case 3: 
    /**
     * GAME OVER SCREEN = 3
     **/

    // UPDATE final score when game over
    if (updateFinalScore) {
      gameScore += levelScore;
      updateFinalScore = false;
    }

    // DECREASE game music
    gameMusic.amp(.25);

    // DISPLAY the grid as described in setup
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        grid[i][j].display(w, h);
      }
    }

    // DISPLAY mover objects
    pacman.display();
    redGhost.display();
    blueGhost.display();
    pinkGhost.display();
    greenGhost.display();

    // DISPLAY game over info text
    fill(120, 32, 188, 230);
    noStroke();
    rect(-1, -1, 1611, 1611);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(104);
    text("GAME OVER", width/2, 600);
    textSize(32);
    text("GAME STATS", width/2 - 400, 800);
    text("Level Reached: " + (level - 1), width/2 - 400, 880);
    text("Game Score: " + gameScore, width/2 - 400, 960);
    text("Hit 'space' to start new game", width/2, 1260);

    // COMPARE the new score to the scores in scores table
    if (!scoreUpdated) {
      checkScores();
    }
    // DISPLAY High scores
    text("HIGH SCORES", width/2 + 400, 800);
    // IF new high score 1, REQUEST user name 
    // ELSE DISPLAY high score 1 and name 1 from scores table
    if (newHighScore1) {
      textSize(56);
      text("NEW HIGH SCORE!", width/2, 400);
      textSize(32);
      text("1 " + userName + " " + gameScore, width/2 + 400, 880);
    } else {
      text("1 " + firstName + " " + firstScore, width/2 + 400, 880);
    }
    // IF new high score 2 REQUEST user name 
    // ELSE DISPLAY high score 2 and name 2 from scores table
    if (newHighScore2) {
      textSize(56);
      text("NEW HIGH SCORE!", width/2, 400);
      textSize(32);
      text("2 " + userName + " " + gameScore, width/2 + 400, 960);
    } else {
      text("2 " + secondName + " " + secondScore, width/2 + 400, 960);
    }
    // IF new high score 3 REQUEST user name 
    // ELSE display high score 3 and name 3 from scores table
    if (newHighScore3) {
      textSize(56);
      text("NEW HIGH SCORE!", width/2, 400);
      textSize(32);
      text("3 " + userName + " " + gameScore, width/2 + 400, 1040);
    } else {
      text("3 " + thirdName + " " + thirdScore, width/2 + 400, 1040);
    }
    break;
  case 4:
    /**
     *
     * INSTRUCTION SCREEN = 4
     *
     **/

    // DECREASE game music
    gameMusic.amp(.25);

    // DISPLAY the grid as described in gridMap initialization
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        grid[i][j].display(w, h);
      }
    }

    // DISPLAY mover objects
    pacman.display();
    redGhost.display();
    blueGhost.display();
    pinkGhost.display();
    greenGhost.display();

    // DISPLAY instruction text
    textAlign(CENTER, CENTER);
    fill(120, 32, 188, 230);
    noStroke();
    rect(-1, -1, 1611, 1611);
    fill(230);
    textSize(104);
    text("Instructions", width/2, 600);
    textSize(32);
    text("Move pac-man with arrow keys\nto collect points and avoid ghosts.\n\nCollect all the points in the grid\nto advance to the next level.", width/2, 950);
    text("Hit 'i' to return to game", width/2, 1200);
    break;
  default:
    /**
     *
     * INTRO SCREEN
     *
     **/

    // DISPLAY the grid as described in gridMap initialization
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        grid[i][j].display(w, h);
      }
    }

    // DISPLAY mover objects
    pacman.display();
    redGhost.display();
    blueGhost.display();
    pinkGhost.display();
    greenGhost.display();

    // DISPLAY Intro Text
    textAlign(CENTER, CENTER);
    fill(120, 32, 188, 230);
    noStroke();
    rect(-1, -1, 1611, 1611);
    fill(240, 255, 0);
    textSize(104);
    text("PAC-MAN", width/2, 600);
    fill(230);
    textSize(32);
    text("Hit 'space' to begin playing", width/2, 800);
    text("Hit 'i' for instructions", width/2, 880);

    // GET scores from scores tables and DSIPLAY
    getScores();
    textSize(35);
    text("HIGH SCORES", width/2 -450, 1150);
    textSize(32);
    text("1 " + firstName + " " + firstScore, width/2-150, 1150);
    text("2 " + secondName + " " + secondScore, width/2+150, 1150);
    text("3 " + thirdName + " " + thirdScore, width/2+450, 1150);

    textSize(24);
    text("by Yahir", width/2, 700);
    break;
  }
}

/**
 * Method for getting scores from scores tables
 * and updating scores and names variables
 **/
void getScores() {
  table = loadTable("scores.csv", "header");
  rowScores = table.getRow(0);
  rowNames = table.getRow(1);
  firstScore = rowScores.getInt("1");
  secondScore = rowScores.getInt("2");
  thirdScore = rowScores.getInt("3");
  firstName = rowNames.getString("1");
  secondName = rowNames.getString("2");
  thirdName = rowNames.getString("3");
}

/**
 * Method for comparing new score with high scores
 * in scores tables
 **/
void checkScores() {
  // load table
  table = loadTable("scores.csv", "header");
  rowScores = table.getRow(0);
  rowNames = table.getRow(1);
  firstScore = rowScores.getInt("1");
  secondScore = rowScores.getInt("2");
  thirdScore = rowScores.getInt("3");
  firstName = rowNames.getString("1");
  secondName = rowNames.getString("2");
  thirdName = rowNames.getString("3");
  if (gameScore > firstScore) {
    newHighScore1 = true;
    secondScore = rowScores.getInt("1");
    secondName = rowNames.getString("1");
    thirdScore = rowScores.getInt("2");
    thirdName = rowNames.getString("2");
  } else if (gameScore > secondScore) {
    newHighScore2 = true;
    thirdScore = rowScores.getInt("2");
    thirdName = rowNames.getString("2");
  } else if (gameScore > thirdScore) {
    newHighScore3 = true;
  }
}

/**
 * Method for updating scores in scores table
 **/
void updateScores() {
  firstScore = rowScores.getInt("1");
  secondScore = rowScores.getInt("2");
  thirdScore = rowScores.getInt("3");
  firstName = rowNames.getString("1");
  secondName = rowNames.getString("2");
  thirdName = rowNames.getString("3");
  if (newHighScore1) {
    //REPLACE third with second
    rowScores.setInt("3", secondScore);
    rowNames.setString("3", secondName);
    // REPLACE second with first
    rowScores.setInt("2", firstScore);
    rowNames.setString("2", firstName);
    // UPDATE first place score
    rowScores.setInt("1", gameScore);
    rowNames.setString("1", userName);
    newHighScore1 = false;
  } else if (newHighScore2) {
    // REPLACE third with second
    rowScores.setInt("3", secondScore);
    rowNames.setString("3", secondName);
    // UPDATE second place score
    rowScores.setInt("2", gameScore);
    rowNames.setString("2", userName);  
    newHighScore2 = false;
  } else if (newHighScore3) {
    // UPDATE third place score
    rowScores.setInt("3", gameScore);
    rowNames.setString("3", userName);
    newHighScore3 = false;
  }
  // SAVE table with new score changes
  saveTable(table, "data/scores.csv");
  table = loadTable("scores.csv", "header");
  rowScores = table.getRow(0);
  rowNames = table.getRow(1);
  firstScore = rowScores.getInt("1");
  secondScore = rowScores.getInt("2");
  thirdScore = rowScores.getInt("3");
  firstName = rowNames.getString("1");
  secondName = rowNames.getString("2");
  thirdName = rowNames.getString("3");
  scoreUpdated = true;
}

/**
 * Method for controlling key presses
 *
 * Keys: LEFT | RIGHT | UP | DOWN | SPACE | 'i' | ENTER
 **/
void keyPressed() {
  // MOVE pacman if level NOT over and pacman NOT captured
  if (key == CODED && !levelOver && !captured) {   
    if (keyCode == LEFT) {
      // If pacman can move left move pacman left and update mouth direction and open/close
      if (pacman.getMoveLeft()) {
        pacman.setI(pacman.getI() - 1);
        pacman.setMouthDirection(1);
        pacman.setMouthOpen(!pacman.getMouthOpen());
        // IF cell moving into is empty play normal move sound
        if (gridMap[pacman.i][pacman.j] == 0) {
          if(moveSound.isPlaying()) {
            moveSound.stop();
          }
          moveSound.stop();
          moveSound.play();
        }
      }
    }
    if (keyCode == RIGHT) {
      // IF pacman can move right MOVE pacman right and update mouth direction and open/close
      if (pacman.getMoveRight()) {
        pacman.setI(pacman.getI() + 1);
        pacman.setMouthDirection(0);
        pacman.setMouthOpen(!pacman.getMouthOpen());
        // IF cell moving into is empty play normal move sound
        if (gridMap[pacman.i][pacman.j] == 0) {
          if(moveSound.isPlaying()) {
            moveSound.stop();
          }
          moveSound.stop();
          moveSound.play();
        }
      }
    }
    if (keyCode == UP) {
      // IF pacman can move up MOVE pacman up and update mouth direction and open/close
      if (pacman.getMoveUp()) {
        pacman.setJ(pacman.getJ() - 1);
        pacman.setMouthDirection(2);
        pacman.setMouthOpen(!pacman.getMouthOpen());
        // IF cell moving into is empty play normal move sound
        if (gridMap[pacman.i][pacman.j] == 0) {
          if(moveSound.isPlaying()) {
            moveSound.stop();
          }
          moveSound.stop();
          moveSound.play();
        }
      }
    }
    if (keyCode == DOWN) {
      // IF pacman can move down MOVE pacman down and update mouth direction and open/close
      if (pacman.getMoveDown()) {
        pacman.setJ(pacman.getJ() + 1);
        pacman.setMouthDirection(3);
        pacman.setMouthOpen(!pacman.getMouthOpen());
        // IF cell moving into is empty play normal move sound
        if (gridMap[pacman.i][pacman.j] == 0) {
          if(moveSound.isPlaying()) {
            moveSound.stop();
          }
          moveSound.stop();
          moveSound.play();
        }
      }
    }
  }
  // IF on screen 3 (game over) let ENTER update scores
  if (screen == 3) {
    if (keyCode == ENTER) {
      updateScores();
    }
    // Control backspace, delete, shift for entering text
    if (keyCode == BACKSPACE) {
      if (userName.length() > 0) {
        userName = userName.substring(0, userName.length()-1);
      }
    } else if (keyCode == DELETE) {
      userName = "";
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
      userName = userName + key;
    }
  } else { // Not on game over screen allow 'i' to toggle instructions screen
    // Toggle instruction screen
    if (key == 'i' || key == 'I') {
      if (screen != 4) {
        priorScreen = screen;
        screen = 4;
      } else {
        screen = priorScreen;
      }
    }
  }

  // MOVE through game using SPACE
  // CHECK that user enters name if new score is SET before proceeding
  if (key == ' ' && !newHighScore1 && !newHighScore2 && !newHighScore3) { 
    if (screen == 0) {
      screen = 1;
    } else {
      if (levelOver) {
        // gameScore += (levelScore * numLives);
        newLevel();
      } else if (gameOver) {
        newGame();
      }
    }
  }
}

/**
 * Method for finding a cell for ghosts
 * to flee to
 *
 * @PARAM: a is a mover object
 * @PARAM: r is an int and changes the location fleeing 
 */
Cell findFleeCell(Mover a, int r) {
  int i_ = 0;
  int j_ = 0;
  // Get movers i and j
  a.getI();
  a.getJ();

  // update i depending on mover a position
  if (a.getI() > 11) {
    if (r == 0) {
      i_ = 3;
    } else {
      i_ = 19;
    }
  } else {
    i_ = 19;
  }
  if (a.getJ() > 11) {
    if (r == 0) {
      j_ = 2;
    } else {
      j_ = 20;
    }
  } else {
    j_ = 20;
  }
  return grid[i_][j_];
}

/**
 * Method for finding corner nearest pacman
 *
 * @PARAM: a is a mover object
 */
Cell findNearestCorner(Mover a) {
  int i_ = 0;
  int j_ = 0;
  a.getI();
  a.getJ();
  if (a.getI() > 11) {
    i_ = 19;
  } else {
    i_ = 3;
  } 
  if (a.getJ() > 11) {
    j_ = 20;
  } else {
    j_ = 2;
  }
  return grid[i_][j_];
}

/**
 * Method for finding mid-point nearest pacman
 *
 * @PARAM: a - Mover
 */
Cell findNearestMid(Mover a) {
  int i_ = 0;
  int j_ = 0;
  // Get mover i and j
  a.getI();
  a.getJ();
  // Update i and j based on mover position
  if (a.getJ() > 11) {
    i_ = 11;
    j_ = 20;
  } else {
    i_ = 11;
    j_ = 5;
  }
  return grid[i_][j_];
}

/**
 * Method for reseting and moving to the next level
 */
void newLevel() {
  // RESET level variables
  level++;
  screen = 1;
  numCoins = 0;
  levelScore = 0;
  levelOver = false;
  flee = false;
  fleeCount = 0;
  playEatPacSound = true;
  scoreUpdated = false;
  updateFinalScore = true;

  // RESET pacman
  pacman.setMouthDirection(0);
  pacman.setMouthOpen(true);
  pacman.setI(11);
  pacman.setJ(16);

  // RESET redGhost
  redCaptured = false;
  redGhost.setI(9);
  redGhost.setJ(10);
  redDlyCount = 0;
  redSpdCount = 0;
  redChase = false;
  redDelay = int(random(100, 151));
  redSpeed -= 5;
  if (redSpeed < 10) {
    redSpeed = 10;
  }

  // RESET blueGhost
  blueCaptured = false;
  blueGhost.setI(13);
  blueGhost.setJ(10);
  blueDlyCount = 0;
  blueSpdCount = 0;
  blueChase = false;
  blueDelay = int(random(151, 201));
  blueSpeed -= 5;
  if (blueSpeed < 10) {
    blueSpeed = 10;
  }

  // RESET pinkGhost
  pinkCaptured = false;
  pinkGhost.setI(10);
  pinkGhost.setJ(11);
  pinkDlyCount = 0;
  pinkSpdCount = 0;
  pinkChase = false;
  pinkDelay = int(random(120, 251));
  pinkSpeed -= 5;
  if (pinkSpeed < 10) {
    pinkSpeed = 10;
  }

  // RESET greenGhost
  greenCaptured = false;
  greenGhost.setI(12);
  greenGhost.setJ(11);
  greenDlyCount = 0;
  greenSpdCount = 0;
  greenChase = false;
  greenDelay = int(random(100, 151));
  greenSpeed -= 5;
  if (greenSpeed < 10) {
    greenSpeed = 10;
  }

  // RESET grid points/coins
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (gridMap[i][j] == 0) {
        gridMap[i][j] = 1;
        grid[i][j].hasPoint = true;
      }
    }
  }

  // REMOVE point/coin from pacman start position
  gridMap[11][16] = 0;
  grid[11][16].hasPoint = false;
  // UPDATE big point location in gridmap/grid
  gridMap[3][3] = 2;
  gridMap[19][3] = 2;
  gridMap[3][16] = 2;
  gridMap[19][16] = 2;
  grid[3][3].hasPoint = false;
  grid[19][3].hasPoint = false;
  grid[3][16].hasPoint = false;
  grid[19][16].hasPoint = false;
  grid[3][3].hasBigPoint = true;
  grid[19][3].hasBigPoint = true;
  grid[3][16].hasBigPoint = true;
  grid[19][16].hasBigPoint = true;
}

/**
 * Method for complete reset for new game
 */
void newGame() {
  newLevel();
  level = 1;
  redDelay = 150;
  redSpeed = 50;
  numLives = 3;
  gameScore = 0;
  gameOver = false;
}

/**
 * Method for determing if a Mover object can move
 * in the LEFT, RIGHT, UP, DOWN direction
 *
 * @PARAM: Mover object
 * @PARAM: showOptions is a boolean that toggles gird values for each possible move
 *         used for trouble shooting. 
 **/
void findOpenCells(Mover a, boolean showOptions) {
  if (showOptions) {
    textSize(12);
    fill(0, 150);
    ellipse((a.i -1) * w + w / 2.0, a.j * h + h / 2.0, w / 3.0, h / 3.0); // LEFT
    ellipse((a.i +1) * w + w / 2.0, a.j * h + h / 2.0, w / 3.0, h / 3.0); // RIGHT
    ellipse(a.i * w + w / 2.0, (a.j -1) * h + h / 2.0, w / 3.0, h / 3.0); // UP
    ellipse(a.i * w + w / 2.0, (a.j +1) * h + h / 2.0, w / 3.0, h / 3.0); // DOWN
    fill(255);
    textAlign(CENTER, CENTER);
    text(gridMap[a.i-1][a.j], (a.i -1) * w + w / 2.0, a.j * h + h / 2.0); // LEFT
    text(gridMap[a.i][a.j+1], a.i * w + w / 2.0, (a.j + 1) * h + h / 2.0); // DOWN
    text(gridMap[a.i][a.j-1], a.i * w + w / 2.0, (a.j - 1) * h + h / 2.0); // UP
    text(gridMap[a.i+1][a.j], (a.i +1) * w + w / 2.0, a.j * h + h / 2.0); // RIGHT
    textAlign(LEFT);
  }
  if (a.getI() < 3) {
    a.setI(19);
    a.setJ(10);
  } else {
    a.setMoveLeft(gridMap[a.i-1][a.j]);
  }
  if (a.getI() > 19) {
    a.setI(3);
    a.setJ(10);
  } else {
    a.setMoveRight(gridMap[a.i+1][a.j]);
  }
  a.setMoveUp(gridMap[a.i][a.j-1]);
  a.setMoveDown(gridMap[a.i][a.j+1]);
}

/**
 * Method for pacman to collect points
 *
 * @PARAM: a is a Mover object
 **/
void collectPoints(Mover a) {
  //Cell temp = grid[a.getI()][a.getJ()];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (grid[i][j] == grid[a.getI()][a.getJ()]) {
        if (gridMap[i][j] == 1) {
          grid[i][j].hasPoint = false;
          gridMap[i][j] = 0;
          levelScore+= numLives;
          numCoins++;
          if(coinSound.isPlaying()) {
            coinSound.stop();
          }
          coinSound.stop();
          coinSound.play();
        }
        if (gridMap[i][j] == 2) {
          grid[i][j].hasBigPoint = false;
          gridMap[i][j] = 0;
          flee = true;
          if(bigCoinSound.isPlaying()) {
            bigCoinSound.stop();
          }
          bigCoinSound.stop();
          bigCoinSound.play();
        }
      }
    }
  }
}

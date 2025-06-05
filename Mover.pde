/**
 * Class for describing pacman and ghost objects
 *
 **/
class Mover {
  int x, y;
  int i, j;

  int moverWidth;
  int moverHeight;
  float cellWidth;
  float cellHeight;

  boolean moveLeft;
  boolean moveRight;
  boolean moveUp;
  boolean moveDown;
  color moverColor;
  int mouthD;
  boolean mouthO;
  int eyeDirection;

  /**
   * Constructor Function
   *
   * @PARAM: i_ is an int and sets the start i location (col) within the grid
   * @PARAM: j_ is an int and sets the start j location (row) within the grid
   **/
  Mover(int i_, int j_, float w_, float h_) {
    // Location
    setI(i_);
    setJ(j_);
    cellWidth = w_;
    cellHeight = h_;
    setWidth(40);
    setHeight(40);
    // Default color is yellow
    setColor(color(240, 255, 0));
    setMouthOpen(true);
    setEyeDirection(1);
  }

  /**
   * Getter and Setter Methods
   **/
  void setI(int i_) {
    i = i_;
  }

  int getI() {
    return i;
  }

  void setJ(int j_) {
    j = j_;
  }

  int getJ() {
    return j;
  }

  void setColor(color c) {
    moverColor = c;
  }

  color getColor() {
    return moverColor;
  }

  void setWidth(int w) {
    moverWidth = w;
  }

  int getWidth() {
    return moverWidth;
  }

  void setHeight(int h) {
    moverHeight = h;
  }

  int getHeight() {
    return moverHeight;
  }

  void setMouthDirection(int m) {
    mouthD = m;
  }

  int getMouthDirection() {
    return mouthD;
  }

  void setMouthOpen(boolean m) {
    mouthO = m;
  }

  boolean getMouthOpen() {
    return mouthO;
  }

  void setEyeDirection(int e) {
    eyeDirection = e;
  }

  int getEyeDirection() {
    return eyeDirection;
  }

  void setMoveLeft(int v) {
    if (v != 5) {
      moveLeft = true;
    } else {
      moveLeft = false;
    }
  }

  boolean getMoveLeft() {
    return moveLeft;
  }

  void setMoveRight(int v) {
    if (v != 5) {
      moveRight = true;
    } else {
      moveRight = false;
    }
  }

  boolean getMoveRight() {
    return moveRight;
  }

  void setMoveUp(int v) {
    if (v != 5) {
      moveUp = true;
    } else {
      moveUp = false;
    }
  }

  boolean getMoveUp() {
    return moveUp;
  }

  void setMoveDown(int v) {
    if (v != 5) {
      moveDown = true;
    } else {
      moveDown = false;
    }
  }

  boolean getMoveDown() {
    return moveDown;
  }

  /** 
   * Display Function: Showing the mover with open and closing mouth
   **/
  void display() {
    stroke(0);
    fill(getColor());
    // Insure mouth is facing the correct direction
    switch(getMouthDirection()) {
    case 0: // Moving right
      if (getMouthOpen()) {
        // SET mouth open in right direction
        arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(30), radians(310), PIE);
      } else {
        // SET mouth closed
        arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(0), radians(360), PIE);
      }
      break;
    case 1: // Moving left
      if (getMouthOpen()) {
        // SET mouth open in left direction
        arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(230), radians(510), PIE);
      } else {
        // SET mouth closed
        arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(180), radians(540), PIE);
      }
      break;
    case 2: // Move up
      if (getMouthOpen()) {
        // SET mouth open in up direction
        arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(-60), radians(220), PIE);
      } else {
        // SET mouth closed
        arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(-90), radians(270), PIE);
      }
      break;
    case 3: // Move down
      if (getMouthOpen()) {
        // SET mouth open in down direction
        arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(120), radians(400), PIE);
      } else {
        // SET mouth closed
        arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(90), radians(450), PIE);
      }
      break;
    default: // Ghost      
      rect((getI() * cellWidth + cellWidth / 2.0) - 20, (getJ() * cellHeight + cellHeight / 2.0) - 2, 40, 20);
      arc(getI() * cellWidth + cellWidth / 2.0, getJ() * cellHeight + cellHeight / 2.0, 40, 40, radians(180), radians(360), OPEN);

      fill(255);
      ellipse((getI() * cellWidth + cellWidth / 2.0) - 8, (getJ() * cellHeight + cellHeight / 2.0) - 5, 8, 8); // left eye
      ellipse((getI() * cellWidth + cellWidth / 2.0) + 8, (getJ() * cellHeight + cellHeight / 2.0)- 5, 8, 8); // right eye
      if (getMouthOpen()) {
        rect((getI() * cellWidth + cellWidth / 2.0) - 10, (getJ() * cellHeight + cellHeight / 2.0)+ 8, 20, 2);
      } else {
        rect((getI() * cellWidth + cellWidth / 2.0) - 10, (getJ() * cellHeight + cellHeight / 2.0)+ 8, 20, 3);
      }
      fill(100);
      // SET eye direction
      if (getEyeDirection() == 0) {
        ellipse((getI() * cellWidth + cellWidth / 2.0) - 10, (getJ() * cellHeight + cellHeight / 2.0) - 5, 4, 4); // looking left
        ellipse((getI() * cellWidth + cellWidth / 2.0) + 6, (getJ() * cellHeight + cellHeight / 2.0)- 5, 4, 4); // looking left
      } else {
        ellipse((getI() * cellWidth + cellWidth / 2.0) - 6, (getJ() * cellHeight + cellHeight / 2.0) - 5, 4, 4); // looking right
        ellipse((getI() * cellWidth + cellWidth / 2.0) + 10, (getJ() * cellHeight + cellHeight / 2.0)- 5, 4, 4); // looking right
      }
      break;
    }
  }
}

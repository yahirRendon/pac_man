/**
 * A class of cell objects used to describe individual cell within a 2D array grid
 *
 **/
class Cell {
  int i; // instead of x it is the i location within a grid (col)
  int j; // instead of y thi sis the j locatino within a grid (row)

  // g, h and f values for A*
  float g = 0; // movement cost
  float heuristic = 0; // educated distance
  float f = 0; // movement cost + educated distance

  // Describes whether a cell will consist of a point, big point, or wall
  boolean hasPoint; // Set if cell has a point in it
  boolean hasBigPoint; // Set if cell has a big point in it
  boolean hasWall; // Set if cell is a wall
  boolean hasFauxWall;  // Set if cell has a faux wall
  int pointSize; // Size of point
  int bigPointSize; // Size of bigPoint

  // The width and heigh of each cell
  float cellWidth;
  float cellHeight;

  // A list describing the state of neighboring Cells
  List<Cell> neighbors = new ArrayList<Cell>();

  // Track where cell came from
  // Used in A* to trace back optimal path
  Cell previous = null;

  /**
   * Constructor function
   *
   * @PARAM: i_ is an int and is the i position (col) describing the cell location within a grid (int)
   * @PARAM: j_ is an int and is the j poistion (row) descirbin the cell location within a grid (int)
   **/
  Cell(int i_, int j_) {
    // Location of cell within grid
    i = i_;
    j = j_;
    pointSize = 15;
    bigPointSize = 25;
  }

  /**
   * Display function: Apporpriatly display the cell based on its state
   **/
  void display(float tempW, float tempH) {
    cellWidth = tempW;
    cellHeight = tempH;

    stroke(0);
    fill(0);
    rect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
    // Place point within cell
    if (hasPoint) {
      fill(230);
      ellipse(i * cellWidth + cellWidth / 2.0, j * cellHeight + cellHeight / 2.0, pointSize, pointSize);
      // Place big point within cell
    } else if (hasBigPoint) {
      fill(0, 255, 255, 200);
      ellipse(i * cellWidth + cellWidth / 2.0, j * cellHeight + cellHeight / 2.0, bigPointSize, bigPointSize);
      // Place wall within cell
    } else if (hasWall) {
      stroke(120, 32, 188);
      fill(120, 32, 188);
      rect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
      // Place faux wall within cell
    } else if (hasFauxWall) {
      stroke(120, 32, 188);
      fill(120, 32, 188);
      rect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
    }
  }

  /**
   * Add Neighbors to List Function: Check possible neighbors and add them to a list
   *
   * @PARAM: grid is a 2D Array of type Cell
   * @PARAM: numCols is an int for the number of cols in the grid
   * @PARAM: numRows is an int for the number of rows in the grid
   **/
  void addNeighbors(Cell[][] grid, int numCols, int numRows) {
    if (i < numCols - 1) {
      neighbors.add(grid[i + 1][j]); // down neighbor
    }
    if (i > 0) {
      neighbors.add(grid[i - 1][j]); // up neighbor
    }
    if (j < numRows - 1) {
      neighbors.add(grid[i][j + 1]); // right neighbor
    }
    if (j > 0) {
      neighbors.add(grid[i][j - 1]); // left neighbor
    }

    // For diagnol movment
    //if (i > 0 && j > 0) {
    //  neighbors.add(grid[i - 1][j - 1]);
    //}
    //if (i < numCols - 1 && j > 0) {
    //  neighbors.add(grid[i + 1][j - 1]);
    //}
    //if (i > 0 && j < numRows - 1) {
    //  neighbors.add(grid[i - 1][j + 1]);
    //}
    //if (i < numCols - 1 && j < numRows - 1) {
    //  neighbors.add(grid[i + 1][j + 1]);
    //}
  }
};

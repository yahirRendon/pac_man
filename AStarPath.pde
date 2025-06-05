/**
 * Class for fiding shortest path for a given location to a target
 * using A* algorithm and Manhattan distance
 *
 **/
class AStarPath {
  // Open and closed set
  List<Cell> openSet;
  List<Cell> closedSet;
  // The road taken
  List<Cell> path;
  List<Cell> winningPath;
  // Start, end, and current Cell
  Cell start;
  Cell end;
  Cell current;

  /**
   * Class Constructor
   **/
  AStarPath() {
    openSet = new ArrayList<Cell>();
    closedSet = new ArrayList<Cell>();
    path = new ArrayList<Cell>();
    winningPath = new ArrayList<Cell>();
  }

  /**
   * Find Path Method: used to get start and end locations 
   * in order to find optitmal path using Manhattan distance
   *
   * @PARAM: a is a Cell: the start location 
   * @PARAM: b is a Cell: the end or target location
   * ---------------------------------------------------------
   * ALTERNATE can use Mover a and Mover b as PARAMS
   **/
  //void findPath(Mover a, Mover b, boolean show) { // Alternate Params
  void findPath(Cell a, Cell b) {
    // RESET previous to null
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        grid[i][j].previous = null;
      }
    }
    // CLEAR array lists
    path.clear();
    openSet.clear();
    closedSet.clear();

    // ASSIGN start location to Mover a location
    // ASSIGN end location to Mover b location
    //start = grid[a.getI()][a.getJ()]; // For alternate params
    //end = grid[b.getI()][b.getJ()]; // For alternate params
    start = a;
    end = b;
    // ADD start to openSet list
    openSet.add(start);

    // LOOP through until openSet is empty
    while (!openSet.isEmpty()) {
      // FIND best next option
      int winner = 0;
      for (int i = 0; i < openSet.size(); i++) {
        if (openSet.get(i).f < openSet.get(winner).f) {
          winner = i;
        }
      }
      current = openSet.get(winner);

      // Finish when current cell is equal to end cell
      if (current == end) {
        // FIND optimal path by working backwards
        Cell temp = current;
        path.add(temp);
        while (temp.previous != null) {
          path.add(temp.previous);
          temp = temp.previous;
        }
        break;
      }

      // Best option MOVES from openSet to closedSet
      openSet.remove(current);
      closedSet.add(current);

      // CHECK all the neighbors
      List<Cell> neighbors = current.neighbors;
      for (int i = 0; i < neighbors.size(); i++) {
        Cell neighbor = neighbors.get(i);

        // Insure next cell is a valid cell to move into
        if (!closedSet.contains(neighbor) && !neighbor.hasWall) {
          float tempG = current.g + heuristic(neighbor, current);

          // COMPARE to see if this is a better path the prior path
          boolean newPath = false;
          if (openSet.contains(neighbor)) {
            if (tempG < neighbor.g) {
              neighbor.g = tempG;
              newPath = true;
            }
          } else {
            neighbor.g = tempG;
            newPath = true;
            openSet.add(neighbor);
          }

          // IF new path is better update
          if (newPath) {
            neighbor.heuristic = heuristic(neighbor, end);
            neighbor.f = neighbor.g + neighbor.heuristic;
            neighbor.previous = current;
          }
        }
      }
    }
  }

  /**
   * Method for displaying the optimal path
   **/
  void displayPath(color c) {
    noFill();
    stroke(c);
    strokeWeight(5);
    beginShape();
    for (int i = 0; i < path.size(); i++) {
      vertex(path.get(i).i * w + w / 2, path.get(i).j * h + h / 2);
    }
    endShape();
    strokeWeight(1);
  }

  /**
   * An educated guess of how far two cells are
   **/
  float heuristic(Cell a, Cell b) {
    float d = dist(a.i, a.j, b.i, b.j);
    return d;
  }
}

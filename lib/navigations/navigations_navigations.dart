import 'dart:collection';
import 'dart:math' as math;
import 'package:on_sight/backend/backend_database.dart';
import 'package:on_sight/navigations/navigations_a_star.dart';
import 'package:on_sight/navigations/navigations_a_star_2d.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

class GeneralizedTile extends Tile with Node<GeneralizedTile> {
  GeneralizedTile(int x, int y, {bool obstacle = false})
      : super(x, y, obstacle: obstacle);
}

class GeneralizedMaze implements Graph<GeneralizedTile> {
  List<List<GeneralizedTile>> tiles = [];
  late GeneralizedTile start;
  late GeneralizedTile goal;

  late int numColumns;
  late int numRows;

  GeneralizedMaze(String map) {
    final Maze maze =
        Maze.parse(map); // Lazy. Outsource parsing to the original.

    numRows = maze.tiles.length;
    numColumns = maze.tiles[0].length;

    for (int i = 0; i < numRows; i++) {
      final row = <GeneralizedTile>[];
      tiles.add(row);
      for (int j = 0; j < numColumns; j++) {
        final orig = maze.tiles[i][j];
        row.add(GeneralizedTile(orig.x, orig.y, obstacle: orig.obstacle));
      }
    }

    start = tiles[maze.start.y][maze.start.x];
    goal = tiles[maze.goal.y][maze.goal.x];
  }

  @override
  Iterable<GeneralizedTile> get allNodes => tiles.expand((row) => row);

  @override
  num getDistance(GeneralizedTile a, GeneralizedTile b) {
    if (b.obstacle) {
      return double.infinity;
    }
    return math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2));
  }

  @override
  num getHeuristicDistance(GeneralizedTile tile, GeneralizedTile goal) {
    final x = tile.x - goal.x;
    final y = tile.y - goal.y;
    return math.sqrt(x * x + y * y);
  }

  @override
  Iterable<GeneralizedTile> getNeighboursOf(GeneralizedTile currentTile) {
    final result = Queue<GeneralizedTile>();
    for (var newX = math.max(0, currentTile.x - 1);
        newX <= math.min(numColumns - 1, currentTile.x + 1);
        newX++) {
      for (var newY = math.max(0, currentTile.y - 1);
          newY <= math.min(numRows - 1, currentTile.y + 1);
          newY++) {
        result.add(tiles[newY][newX]);
      }
    }
    return result;
  }
}

class MyShortestPath {
  late GeneralizedMaze _maze;
  late AStar<GeneralizedTile> _aStar;
  late List<Map<String, AttributeValue>> _mapData = [];

  bool _isGenerated = false; // checks if map has been initialised

  /// Constructor. Initialise map with initial start and goal points
  /// and convert then into tiles to be used by the AStar algorithm.
  ///
  /// Inputs:
  /// 1) dbObj [MyDatabase] - database object.
  ///
  /// Return:
  /// 1) None.
  MyShortestPath({required MyDatabase dbObj}) {
    _mapData = dbObj.getMapData();
  }

  // ==== Private Methods ====
  /// Generates textMap based on start and end point.
  ///
  /// Inputs:
  /// 1) initialStart [List<double>] - initial start point (x,y).
  /// 2) initialGoal [List<double>] - initial goal point (x,y).
  ///
  /// Returns:
  /// 1) textMap [String]:
  ///     - x means obstacle
  ///     - o means path
  ///     - s means start point
  ///     - g means goal.
  String _generateTextMap(List<double> start, List<double> goal) {
    int count = 0;
    String temp = '';
    String textMap = '';

    // using linear O(1) array search for a 2d map
    Map<String, AttributeValue> startCell =
        _mapData[(start[1] ~/ 200) * 8 + start[0] ~/ 200];
    Map<String, AttributeValue> goalCell =
        _mapData[(goal[1] ~/ 200) * 8 + goal[0] ~/ 200];

    _mapData.forEach((cell) {
      if (cell['is_obstacle']!.boolValue == true) {
        String landmark = cell['is_landmark']!.s ?? '';
        if (landmark == 'None') {
          temp += 'x'; // if cell is not a landmark, then it is an obstacle
        } else {
          if (cell['tiles_id']!.n == goalCell['tiles_id']!.n) {
            temp += 'g'; // if cell is a landmark, and it is the end goal
          } else {
            temp +=
                'x'; // all other landmarks are treated as obstacles for simplicity's sake.
          }
        }
      } else {
        if (cell['tiles_id']!.n == startCell['tiles_id']!.n) {
          temp += 's'; // if cell is the starting point
        } else {
          temp += 'o'; // all other non-obstacle cells are paths
        }
      }

      count += 1; // update counter variable

      if (count == 8) {
        textMap += '$temp\n';
        // reset variables
        count = 0;
        temp = '';
      }
    });

    return textMap;
  }

  // ==== Public Methods ====
  /// Determines the shortest path from start point to goal.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) None.
  Queue<GeneralizedTile> determineShortestPath() {
    if (_isGenerated) {
      return _aStar.findPathSync(_maze.start, _maze.goal);
    } else {
      throw Exception('Text map is not generated');
    }
  }

  /// Setup algorithm for shortest path.
  /// To be called when either start or goal changes.
  ///
  /// Inputs:
  /// 1) start [List<double>] - initial start point (x,y).
  /// 2) goal [List<double>] - initial goal point (x,y).
  ///
  /// Returns:
  /// 1) None.
  void setup(List<double> start, List<double> goal) {
    String textMap = _generateTextMap(start, goal);
    print(textMap);
    _maze = GeneralizedMaze(textMap);
    _aStar = AStar(_maze);
    _isGenerated = true;
  }
}

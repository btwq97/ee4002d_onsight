/*
 Copyright 2012 Seth Ladd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

library a_star_2d;

import 'dart:math' as math;

class Maze {
  List<List<Tile>> tiles;
  Tile start;
  Tile goal;

  Maze(this.tiles, this.start, this.goal);

  factory Maze.random({int? width, int? height}) {
    if (width == null) {
      throw ArgumentError('width must not be null');
    }
    if (height == null) {
      throw ArgumentError('height must not be null');
    }

    final rand = math.Random();
    final tiles = <List<Tile>>[];

    for (var y = 0; y < height; y++) {
      final row = <Tile>[];
      for (var x = 0; x < width; x++) {
        row.add(Tile(x, y, obstacle: rand.nextBool()));
      }
      tiles.add(row);
    }

    return Maze(tiles, tiles[0][0], tiles[height - 1][width - 1]);
  }

  factory Maze.parse(String map) {
    final tiles = <List<Tile>>[];
    final rows = map.trim().split('\n');
    Tile? start;
    Tile? goal;

    for (var rowNum = 0; rowNum < rows.length; rowNum++) {
      final row = <Tile>[];
      final lineTiles = rows[rowNum].trim().split('');

      for (var colNum = 0; colNum < lineTiles.length; colNum++) {
        final t = lineTiles[colNum];
        final obstacle = t == 'x';
        final tile = Tile(colNum, rowNum, obstacle: obstacle);
        if (t == 's') {
          start = tile;
        }
        if (t == 'g') {
          goal = tile;
        }
        row.add(tile);
      }

      tiles.add(row);
    }

    // TODO: Error handling for invalid strings, including null start/goal.
    return Maze(tiles, start!, goal!);
  }
}

class Tile {
  final int x, y;
  final bool obstacle;
  final int _hashcode;
  final String _str;

  // for A*
  double _f = -1; // heuristic + cost
  double _g = -1; // cost
  double _h = -1; // heuristic estimate
  int _parentIndex = -1;

  Tile(this.x, this.y, {this.obstacle = false})
      : _hashcode = '$x,$y'.hashCode,
        _str = '[X:$x, Y:$y, Obs:$obstacle]';

  @override
  String toString() => _str;

  @override
  int get hashCode => _hashcode;

  @override
  bool operator ==(Object other) =>
      other is Tile && x == other.x && y == other.y;
}
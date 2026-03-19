import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MaterialApp(home: Minesweeper(), debugShowCheckedModeBanner: false));

class Minesweeper extends StatefulWidget {
  const Minesweeper({super.key});

  @override
  State<Minesweeper> createState() => _MinesweeperState();
}

class _MinesweeperState extends State<Minesweeper> {
  static const int rows = 10;
  static const int cols = 10;
  static const int totalMines = 12;

  late List<List<bool>> mineField; // Hol van akna
  late List<List<bool>> revealed; // Mi van felfedve
  late List<List<bool>> flagged;  // Hol van zászló
  bool gameOver = false;
  bool won = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    setState(() {
      gameOver = false;
      won = false;
      // Táblák inicializálása
      mineField = List.generate(rows, (_) => List.generate(cols, (_) => false));
      revealed = List.generate(rows, (_) => List.generate(cols, (_) => false));
      flagged = List.generate(rows, (_) => List.generate(cols, (_) => false));

      // Aknák elhelyezése véletlenszerűen
      int placedMines = 0;
      var random = Random();
      while (placedMines < totalMines) {
        int r = random.nextInt(rows);
        int c = random.nextInt(cols);
        if (!mineField[r][c]) {
          mineField[r][c] = true;
          placedMines++;
        }
      }
    });
  }

  // Szomszédos aknák számolása
  int _countMines(int r, int c) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int nr = r + i;
        int nc = c + j;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && mineField[nr][nc]) {
          count++;
        }
      }
    }
    return count;
  }

  // Rekurzív felfedés (ha 0 szomszédos akna van)
  void _reveal(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols || revealed[r][c] || flagged[r][c]) return;

    setState(() {
      revealed[r][c] = true;
      if (mineField[r][c]) {
        gameOver = true;
        _revealAllMines();
      } else if (_countMines(r, c) == 0) {
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            _reveal(r + i, c + j);
          }
        }
      }
    });
    _checkWin();
  }

  void _revealAllMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (mineField[r][c]) revealed[r][c] = true;
      }
    }
  }

  void _checkWin() {
    int unrevealedEmpty = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!mineField[r][c] && !revealed[r][c]) unrevealedEmpty++;
      }
    }
    if (unrevealedEmpty == 0 && !gameOver) {
      setState(() => won = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Aknakereső"),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: _setupGame, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              gameOver ? "BUMM! Vége a játéknak! 💣" : (won ? "NYERTÉL! 🎉" : "Vigyázz, $totalMines akna!"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.blueGrey, border: Border.all(width: 3)),
              child: SizedBox(
                width: 350,
                height: 350,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols),
                  itemCount: rows * cols,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    int r = index ~/ cols;
                    int c = index % cols;
                    return _buildCell(r, c);
                  },
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("Tipp: Hosszú nyomás = Zászló (🚩)"),
          )
        ],
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    Widget content = const Text("");
    Color color = Colors.grey[400]!;

    if (revealed[r][c]) {
      if (mineField[r][c]) {
        content = const Icon(Icons.brightness_7, color: Colors.black, size: 20); // Akna
        color = Colors.red;
      } else {
        int count = _countMines(r, c);
        color = Colors.grey[200]!;
        if (count > 0) {
          content = Text("$count", style: TextStyle(fontWeight: FontWeight.bold, color: _getNumberColor(count)));
        }
      }
    } else if (flagged[r][c]) {
      content = const Icon(Icons.flag, color: Colors.red, size: 20);
    }

    return GestureDetector(
      onTap: gameOver || won ? null : () => _reveal(r, c),
      onLongPress: gameOver || won ? null : () {
        setState(() => flagged[r][c] = !flagged[r][c]);
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey[600]!, width: 0.5),
          boxShadow: revealed[r][c] ? null : [const BoxShadow(color: Colors.white, offset: Offset(-1, -1), blurRadius: 1)],
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }

  Color _getNumberColor(int n) {
    switch (n) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.indigo;
      default: return Colors.brown;
    }
  }
}
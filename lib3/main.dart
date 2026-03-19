import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: SudokuGame(),
    debugShowCheckedModeBanner: false,
  ));
}

class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key});

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  // A teljes megoldás (példa pálya)
  final List<List<int>> solution = [
    [5, 3, 4, 6, 7, 8, 9, 1, 2],
    [6, 7, 2, 1, 9, 5, 3, 4, 8],
    [1, 9, 8, 3, 4, 2, 5, 6, 7],
    [8, 5, 9, 7, 6, 1, 4, 2, 3],
    [4, 2, 6, 8, 5, 3, 7, 9, 1],
    [7, 1, 3, 9, 2, 4, 8, 5, 6],
    [9, 6, 1, 5, 3, 7, 2, 8, 4],
    [2, 8, 7, 4, 1, 9, 6, 3, 5],
    [3, 4, 5, 2, 8, 6, 1, 7, 9],
  ];

  // A játékos táblája (0 = üres)
  late List<List<int>> board;
  // Eredeti fix számok (ezeket nem lehet módosítani)
  late List<List<bool>> isOriginal;

  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      selectedRow = null;
      selectedCol = null;
      // Létrehozunk egy pályát, ahol csak néhány szám látszik
      board = List.generate(9, (r) => List.generate(9, (c) {
        // Egyszerű maszkolás: csak minden második/harmadik számot hagyjuk meg
        if ((r + c) % 3 == 0 || (r * c) % 4 == 0) {
          return solution[r][c];
        }
        return 0;
      }));
      
      isOriginal = List.generate(9, (r) => List.generate(9, (c) => board[r][c] != 0));
    });
  }

  void _inputNumber(int n) {
    if (selectedRow != null && selectedCol != null) {
      if (!isOriginal[selectedRow!][selectedCol!]) {
        setState(() {
          board[selectedRow!][selectedCol!] = n;
        });
      }
    }
  }

  // Ellenőrzi, hogy a szám szabályos-e az adott helyen
  bool _isValid(int r, int c, int value) {
    if (value == 0) return true;
    // Sor és oszlop ellenőrzés
    for (int i = 0; i < 9; i++) {
      if (i != c && board[r][i] == value) return false;
      if (i != r && board[i][c] == value) return false;
    }
    // 3x3 blokk ellenőrzés
    int startRow = (r ~/ 3) * 3;
    int startCol = (c ~/ 3) * 3;
    for (int i = startRow; i < startRow + 3; i++) {
      for (int j = startCol; j < startCol + 3; j++) {
        if (i == r && j == c) continue;
        if (board[i][j] == value) return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Sudoku Master"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: _resetGame, icon: const Icon(Icons.refresh))],
      ),
      body: Center( // Centerbe rakjuk, hogy ne nyúljon el
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // JÁTÉKTÉR MÉRETEZÉSE
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // Képernyő 90%-a
                constraints: const BoxConstraints(maxWidth: 400), // De max 400 pixel
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black, // Ez adja a vastag külső keretet
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 81,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    int r = index ~/ 9;
                    int c = index % 9;
                    bool isSelected = (r == selectedRow && c == selectedCol);
                    bool isValid = _isValid(r, c, board[r][c]);
                    bool fixed = isOriginal[r][c];

                    return GestureDetector(
                      onTap: () => _onCellTap(r, c),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.yellow[200] : Colors.white,
                          border: Border(
                            right: BorderSide(width: (c % 3 == 2) ? 2 : 0.5, color: Colors.black),
                            bottom: BorderSide(width: (r % 3 == 2) ? 2 : 0.5, color: Colors.black),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          board[r][c] == 0 ? "" : board[r][c].toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: fixed ? FontWeight.bold : FontWeight.normal,
                            color: !isValid ? Colors.red : (fixed ? Colors.black : Colors.blue[800]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              // SZÁMBILLENTYŰZET
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ...List.generate(9, (i) => _buildNumButton(i + 1)),
                  _buildNumButton(0, label: "CLR"), // Törlés gomb
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumButton(int n, {String? label}) {
    return ElevatedButton(
      onPressed: () => _inputNumber(n),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        minimumSize: const Size(50, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label ?? n.toString(), style: const TextStyle(fontSize: 16)),
    );
  }

  void _onCellTap(int r, int c) {
    setState(() {
      selectedRow = r;
      selectedCol = c;
    });
  }
}
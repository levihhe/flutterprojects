import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const WordleClone());
}

class WordleClone extends StatelessWidget {
  const WordleClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wordle Clone',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const WordleGame(),
    );
  }
}

class WordleGame extends StatefulWidget {
  const WordleGame({super.key});

  @override
  State<WordleGame> createState() => _WordleGameState();
}

class _WordleGameState extends State<WordleGame> {
  // 1. Kibővített szólista
  final List<String> wordBank = [
    "ALMA", "KÖRE", "HAJÓ", "AUTÓ", "ERDŐ", "ADAT", "BABA", "DUNA", 
    "EGER", "FALU", "HIBA", "IGEN", "KAPA", "LÁNY", "MACI", "NÉGY", 
    "ÓRAI", "PÉNZ", "RAJZ", "SÜTI", "TETŐ", "UTCA", "VÁRÓ", "ZENE", 
    "ÁLOM", "ÉTEL", "ÍRÁS", "ÖREG", "ÜVEG", "TEKE", "BÉKA", "LÁDA",
    "KOCA", "MESE", "TÜKÖ", "KIFI", "SÁTO", "LAKÁ", "VÁRÓ", "FEJŐ"
  ];

  late String targetWord;
  final TextEditingController _controller = TextEditingController();
  List<String> guesses = [];
  String message = "Találd ki a szót!";
  
  // Ábécé a vizuális visszajelzéshez
  final String alphabet = "AÁBCDEÉFGHIÍJKLMNOÓÖŐPQRSTUÚÜŰVWXYZ";
  Map<String, Color> letterColors = {};

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      targetWord = wordBank[Random().nextInt(wordBank.length)].toUpperCase();
      guesses = [];
      _controller.clear();
      message = "Új játék! A szó ${targetWord.length} betűs.";
      // Reseteljük az ábécé színeit
      letterColors = {for (var char in alphabet.split('')) char: Colors.grey.shade300};
    });
  }

  // A javított szín-logika, ami figyelembe veszi a betűk számát
  Color _getLetterColor(String guess, int index) {
    String charAtGuess = guess[index];
    
    // 1. ZÖLD: Ha pontosan ott van
    if (charAtGuess == targetWord[index]) {
      return Colors.green;
    }

    // 2. SÁRGA: Ha benne van, de nem ott, ÉS még nem "használtuk el" a jelzést
    if (!targetWord.contains(charAtGuess)) return Colors.grey;

    int totalOccurrences = targetWord.split('').where((c) => c == charAtGuess).length;
    int greenMatches = 0;
    for (int i = 0; i < targetWord.length; i++) {
      if (guess[i] == targetWord[i] && guess[i] == charAtGuess) greenMatches++;
    }

    int previousYellows = 0;
    for (int i = 0; i < index; i++) {
      if (guess[i] == charAtGuess && guess[i] != targetWord[i]) previousYellows++;
    }

    if ((greenMatches + previousYellows) < totalOccurrences) {
      return Colors.orange;
    }

    return Colors.grey;
  }

  void _updateAlphabetColors(String guess) {
    for (int i = 0; i < guess.length; i++) {
      String char = guess[i];
      Color newColor = _getLetterColor(guess, i);

      // Prioritás: Zöld > Sárga > Szürke
      if (letterColors[char] != Colors.green) {
        if (letterColors[char] != Colors.orange || newColor == Colors.green) {
          letterColors[char] = newColor;
        }
      }
    }
  }

  void _submitGuess() {
    String guess = _controller.text.toUpperCase();

    if (guess.length != targetWord.length) {
      setState(() => message = "A szó ${targetWord.length} betűs!");
      return;
    }

    setState(() {
      guesses.add(guess);
      _updateAlphabetColors(guess);
      _controller.clear();

      if (guess == targetWord) {
        message = "Gratulálok! Nyertél! 🎉";
      } else if (guesses.length >= 6) {
        message = "Vége! A szó: $targetWord";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isGameOver = guesses.isNotEmpty && (guesses.last == targetWord || guesses.length >= 6);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wordle Clone"),
        actions: [IconButton(onPressed: _startNewGame, icon: const Icon(Icons.refresh))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(message, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Játékrács
            Column(
              children: guesses.map((guess) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(targetWord.length, (i) {
                    return Container(
                      margin: const EdgeInsets.all(3),
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: _getLetterColor(guess, i),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        guess[i],
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 30),
            
            // "Billentyűzet" (Kilőtt betűk)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: alphabet.split('').map((char) {
                return Container(
                  width: 28,
                  height: 38,
                  decoration: BoxDecoration(
                    color: letterColors[char],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(char, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 30),

            // Bevitel
            TextField(
              controller: _controller,
              maxLength: targetWord.length,
              enabled: !isGameOver,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "${targetWord.length} betűs szó...",
                counterText: "",
              ),
              onSubmitted: (_) => _submitGuess(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isGameOver ? null : _submitGuess,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                child: const Text("Tipp beküldése"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
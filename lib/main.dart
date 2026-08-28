import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameAudio {
  static const int sampleRate = 22050;

  static Uint8List get click => _generateTone(880.0, 0.08, 0.22);
  static Uint8List get match => _generateTone(660.0, 0.12, 0.35);
  static Uint8List get levelUp => _generateTone(420.0, 0.45, 0.5, from: 200.0);
  static Uint8List get gameOver => _generateTone(160.0, 0.7, 0.42, from: 80.0);
  static Uint8List get background => _generateLoop();

  static Uint8List _generateTone(
    double frequency,
    double duration,
    double volume, {
    double from = 0,
  }) {
    final totalSamples = (sampleRate * duration).round();
    final data = ByteData(totalSamples * 2 + 44);

    _writeHeader(data, totalSamples);

    var sampleIndex = 44;
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final frequencyAtTime = from == 0 ? frequency : from + (frequency - from) * (i / totalSamples);
      final wave = sin(2 * pi * frequencyAtTime * t);
      final attack = (t < 0.04) ? (t / 0.04) : 1.0;
      final release = (t > duration - 0.04) ? ((duration - t) / 0.04) : 1.0;
      final envelope = (attack < release ? attack : release).clamp(0.0, 1.0);
      final sample = (wave * volume * envelope * 32767).round();
      data.setInt16(sampleIndex, sample.clamp(-32768, 32767), Endian.little);
      sampleIndex += 2;
    }

    return data.buffer.asUint8List();
  }

  static Uint8List _generateLoop() {
    final totalSamples = sampleRate * 3;
    final data = ByteData(totalSamples * 2 + 44);
    _writeHeader(data, totalSamples);

    var sampleIndex = 44;
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final tri = 2 * (1 - (2 * ((t * 2.5) % 1) - 1).abs()) - 1;
      final envelope = 0.15 + (0.15 * sin(2 * pi * 0.25 * t));
      final sample = (tri * envelope * 0.18 * 32767).round();
      data.setInt16(sampleIndex, sample.clamp(-32768, 32767), Endian.little);
      sampleIndex += 2;
    }

    return data.buffer.asUint8List();
  }

  static void _writeHeader(ByteData data, int totalSamples) {
    final fileSize = 36 + totalSamples * 2;
    data.setUint8(0, 0x52); // R
    data.setUint8(1, 0x49); // I
    data.setUint8(2, 0x46); // F
    data.setUint8(3, 0x46); // F
    data.setUint32(4, fileSize, Endian.little);
    data.setUint8(8, 0x57); // W
    data.setUint8(9, 0x41); // A
    data.setUint8(10, 0x56); // V
    data.setUint8(11, 0x45); // E
    data.setUint8(12, 0x66); // f
    data.setUint8(13, 0x6d); // m
    data.setUint8(14, 0x74); // t
    data.setUint8(15, 0x20); // space
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, sampleRate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    data.setUint8(36, 0x64); // d
    data.setUint8(37, 0x61); // a
    data.setUint8(38, 0x74); // t
    data.setUint8(39, 0x61); // a
    data.setUint32(40, totalSamples * 2, Endian.little);
  }
}

void main() {
  runApp(const GemQuestApp());
}

class GemQuestApp extends StatelessWidget {
  const GemQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gem Quest',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF080C20),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int maxLevel = 8;
  int selectedLevel = 1;
  int bestScore = 0;
  final AudioPlayer _tapPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  @override
  void dispose() {
    _tapPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      bestScore = prefs.getInt('gem_quest_best_score') ?? 0;
    });
  }

  Future<void> _playTap() async {
    try {
      await _tapPlayer.play(BytesSource(GameAudio.click));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF16214E),
              Color(0xFF0A0E26),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7C5CFF),
                            Color(0xFFB76CFF),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                            blurRadius: 36,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.diamond, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'GEM QUEST',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'MATCH • BLAST • CONQUER',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFFFD84D)),
                          const SizedBox(width: 10),
                          const Text('BEST SCORE', style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.5)),
                          const SizedBox(width: 8),
                          Text('$bestScore', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Choose a level and start the run.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: maxLevel,
                      itemBuilder: (context, index) {
                        final level = index + 1;
                        final active = selectedLevel == level;
                        return GestureDetector(
                          onTap: () {
                            _playTap();
                            setState(() {
                              selectedLevel = level;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: active ? const Color(0xFFFFD84D).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
                              border: Border.all(
                                color: active ? const Color(0xFFFFD84D) : Colors.white.withValues(alpha: 0.12),
                                width: active ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('L$level', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 4),
                                Text('${level * 500} goal', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD84D),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 10,
                        ),
                        onPressed: () {
                          _playTap();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(initialLevel: selectedLevel),
                            ),
                          );
                        },
                        child: const Text(
                          'PLAY GAME',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FeatureItem(icon: '💎', title: 'MATCH'),
                        FeatureItem(icon: '💥', title: 'BLAST'),
                        FeatureItem(icon: '🔥', title: 'COMBO'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String icon;
  final String title;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

enum SpecialGem {
  normal,
  rowBomb,
  columnBomb,
  colorBomb,
}

class Gem {
  final Color color;
  SpecialGem special;

  Gem({
    required this.color,
    this.special = SpecialGem.normal,
  });
}

class GameScreen extends StatefulWidget {
  final int initialLevel;

  const GameScreen({
    super.key,
    this.initialLevel = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int rows = 8;
  static const int columns = 8;

  final Random random = Random();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  final List<Color> gemColors = [
    const Color(0xFFFF4B6E),
    const Color(0xFF4DA6FF),
    const Color(0xFF4CD97B),
    const Color(0xFFFFD84D),
    const Color(0xFFB56CFF),
    const Color(0xFFFF8C42),
  ];

  late List<List<Gem?>> board;

  int? selectedRow;
  int? selectedColumn;

  int score = 0;
  int bestScore = 0;
  int moves = 30;
  int level = 1;
  int combo = 0;

  bool isProcessing = false;
  bool gameOver = false;
  bool levelComplete = false;
  bool isPaused = false;

  String message = '';
  Timer? messageTimer;

  int get targetScore => level * 500;

  @override
  void initState() {
    super.initState();
    level = widget.initialLevel;
    _loadBestScore();
    _startBackgroundMusic();
    startGame();
  }

  @override
  void dispose() {
    messageTimer?.cancel();
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      bestScore = prefs.getInt('gem_quest_best_score') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('gem_quest_best_score') ?? 0;
    if (score > saved) {
      await prefs.setInt('gem_quest_best_score', score);
      bestScore = score;
    }
  }

  Future<void> _startBackgroundMusic() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.12);
      await _musicPlayer.play(BytesSource(GameAudio.background));
    } catch (_) {}
  }

  Future<void> _playSfx(String soundFile) async {
    try {
      switch (soundFile) {
        case 'click.wav':
          await _sfxPlayer.play(BytesSource(GameAudio.click));
          break;
        case 'match.wav':
          await _sfxPlayer.play(BytesSource(GameAudio.match));
          break;
        case 'level_up.wav':
          await _sfxPlayer.play(BytesSource(GameAudio.levelUp));
          break;
        case 'game_over.wav':
          await _sfxPlayer.play(BytesSource(GameAudio.gameOver));
          break;
      }
    } catch (_) {}
  }

  void startGame() {
    score = 0;
    moves = 30;
    combo = 0;
    selectedRow = null;
    selectedColumn = null;
    isProcessing = false;
    gameOver = false;
    levelComplete = false;
    isPaused = false;
    message = '';
    createBoard();
  }

  void createBoard() {
    do {
      board = List.generate(
        rows,
        (_) => List.generate(
          columns,
          (_) => Gem(color: randomGemColor()),
        ),
      );
    } while (findMatches().isNotEmpty);
  }

  Color randomGemColor() {
    return gemColors[random.nextInt(gemColors.length)];
  }

  void selectGem(int row, int column) {
    if (isProcessing || gameOver || levelComplete || moves <= 0 || isPaused) {
      return;
    }

    if (board[row][column] == null) return;

    if (selectedRow == null) {
      setState(() {
        selectedRow = row;
        selectedColumn = column;
      });
      return;
    }

    if (selectedRow == row && selectedColumn == column) {
      setState(() {
        selectedRow = null;
        selectedColumn = null;
      });
      return;
    }

    if (isAdjacent(row, column)) {
      final firstRow = selectedRow!;
      final firstColumn = selectedColumn!;

      swapGems(firstRow, firstColumn, row, column);

      setState(() {
        selectedRow = null;
        selectedColumn = null;
        moves--;
        isProcessing = true;
        combo = 0;
      });

      _playSfx('click.wav');
      processSwap(firstRow, firstColumn, row, column);
    } else {
      setState(() {
        selectedRow = row;
        selectedColumn = column;
      });
    }
  }

  bool isAdjacent(int row, int column) {
    final rowDifference = (selectedRow! - row).abs();
    final columnDifference = (selectedColumn! - column).abs();
    return rowDifference + columnDifference == 1;
  }

  void swapGems(int firstRow, int firstColumn, int secondRow, int secondColumn) {
    final temp = board[firstRow][firstColumn];
    board[firstRow][firstColumn] = board[secondRow][secondColumn];
    board[secondRow][secondColumn] = temp;
  }

  Future<void> processSwap(int firstRow, int firstColumn, int secondRow, int secondColumn) async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    final matches = findMatches();

    if (matches.isEmpty) {
      swapGems(firstRow, firstColumn, secondRow, secondColumn);
      setState(() {
        isProcessing = false;
        message = 'NO MATCH ↩';
      });
      clearMessageLater();
      return;
    }

    await processMatches();

    if (!mounted) return;

    if (score >= targetScore) {
      setState(() {
        levelComplete = true;
        isProcessing = false;
      });
      _playSfx('level_up.wav');
    } else if (moves <= 0) {
      setState(() {
        gameOver = true;
        isProcessing = false;
      });
      _playSfx('game_over.wav');
    } else {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Set<String> findMatches() {
    final Set<String> matches = {};

    for (int row = 0; row < rows; row++) {
      int start = 0;
      while (start < columns) {
        final gem = board[row][start];
        if (gem == null) {
          start++;
          continue;
        }

        int end = start + 1;
        while (
            end < columns &&
            board[row][end] != null &&
            board[row][end]!.color == gem.color) {
          end++;
        }

        if (end - start >= 3) {
          for (int column = start; column < end; column++) {
            matches.add('$row,$column');
          }
        }
        start = end;
      }
    }

    for (int column = 0; column < columns; column++) {
      int start = 0;
      while (start < rows) {
        final gem = board[start][column];
        if (gem == null) {
          start++;
          continue;
        }

        int end = start + 1;
        while (
            end < rows &&
            board[end][column] != null &&
            board[end][column]!.color == gem.color) {
          end++;
        }

        if (end - start >= 3) {
          for (int row = start; row < end; row++) {
            matches.add('$row,$column');
          }
        }
        start = end;
      }
    }

    return matches;
  }

  Future<void> processMatches() async {
    final matches = findMatches();
    if (matches.isEmpty) return;

    combo++;
    final multiplier = combo > 1 ? combo : 1;
    final points = matches.length * 10 * multiplier;

    setState(() {
      score += points;
      if (score > bestScore) {
        bestScore = score;
      }
      if (combo >= 2) {
        message = '🔥 COMBO x$combo +$points';
      } else {
        message = '+$points';
      }
    });

    _playSfx('match.wav');
    _saveBestScore();

    createSpecialGems(matches);
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    final specialMatches = activateSpecialGems(matches);
    final Set<String> allToRemove = {
      ...matches,
      ...specialMatches,
    };

    setState(() {
      for (final position in allToRemove) {
        final parts = position.split(',');
        final row = int.parse(parts[0]);
        final column = int.parse(parts[1]);
        board[row][column] = null;
      }
    });

    await Future.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    applyGravity();
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    fillEmptySpaces();
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    if (findMatches().isNotEmpty) {
      await processMatches();
    }
  }

  void createSpecialGems(Set<String> matches) {
    final Map<int, int> rowCounts = {};
    final Map<int, int> columnCounts = {};

    for (final position in matches) {
      final parts = position.split(',');
      final row = int.parse(parts[0]);
      final column = int.parse(parts[1]);
      rowCounts[row] = (rowCounts[row] ?? 0) + 1;
      columnCounts[column] = (columnCounts[column] ?? 0) + 1;
    }

    if (matches.length >= 5) {
      final position = matches.first;
      final parts = position.split(',');
      final row = int.parse(parts[0]);
      final column = int.parse(parts[1]);
      if (board[row][column] != null) {
        board[row][column]!.special = SpecialGem.colorBomb;
      }
      return;
    }

    for (final entry in rowCounts.entries) {
      if (entry.value >= 4) {
        for (int column = 0; column < columns; column++) {
          final position = '${entry.key},$column';
          if (matches.contains(position) && board[entry.key][column] != null) {
            board[entry.key][column]!.special = SpecialGem.rowBomb;
            return;
          }
        }
      }
    }

    for (final entry in columnCounts.entries) {
      if (entry.value >= 4) {
        for (int row = 0; row < rows; row++) {
          final position = '$row,${entry.key}';
          if (matches.contains(position) && board[row][entry.key] != null) {
            board[row][entry.key]!.special = SpecialGem.columnBomb;
            return;
          }
        }
      }
    }
  }

  Set<String> activateSpecialGems(Set<String> matches) {
    final Set<String> result = {};

    for (final position in matches) {
      final parts = position.split(',');
      final row = int.parse(parts[0]);
      final column = int.parse(parts[1]);
      final gem = board[row][column];

      if (gem == null) continue;

      if (gem.special == SpecialGem.rowBomb) {
        for (int c = 0; c < columns; c++) {
          result.add('$row,$c');
        }
      }

      if (gem.special == SpecialGem.columnBomb) {
        for (int r = 0; r < rows; r++) {
          result.add('$r,$column');
        }
      }

      if (gem.special == SpecialGem.colorBomb) {
        final targetColor = gem.color;
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < columns; c++) {
            if (board[r][c]?.color == targetColor) {
              result.add('$r,$c');
            }
          }
        }
      }
    }

    return result;
  }

  void applyGravity() {
    for (int column = 0; column < columns; column++) {
      int emptyRow = rows - 1;
      for (int row = rows - 1; row >= 0; row--) {
        if (board[row][column] != null) {
          board[emptyRow][column] = board[row][column];
          if (emptyRow != row) {
            board[row][column] = null;
          }
          emptyRow--;
        }
      }
    }
  }

  void fillEmptySpaces() {
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        if (board[row][column] == null) {
          board[row][column] = Gem(color: randomGemColor());
        }
      }
    }
  }

  void clearMessageLater() {
    messageTimer?.cancel();
    messageTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        message = '';
      });
    });
  }

  void nextLevel() {
    setState(() {
      level++;
      moves = 30;
      combo = 0;
      selectedRow = null;
      selectedColumn = null;
      levelComplete = false;
      gameOver = false;
      isProcessing = false;
      createBoard();
    });
    showTemporaryMessage('LEVEL $level! 🎉');
    _playSfx('level_up.wav');
  }

  void restart() {
    setState(() {
      startGame();
    });
  }

  void pauseGame() {
    setState(() {
      isPaused = true;
    });
  }

  void resumeGame() {
    setState(() {
      isPaused = false;
    });
  }

  void showTemporaryMessage(String text) {
    messageTimer?.cancel();
    setState(() {
      message = text;
    });
    messageTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        message = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (score / targetScore).clamp(0.0, 1.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF11183A),
              Color(0xFF090C1F),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('💎 GEM QUEST', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            Text('MATCH • BLAST • WIN', style: TextStyle(fontSize: 9, color: Colors.white54, letterSpacing: 1.5)),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD84D).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: const Color(0xFFFFD84D).withValues(alpha: 0.3)),
                              ),
                              child: Text('LEVEL $level', style: const TextStyle(color: Color(0xFFFFD84D), fontWeight: FontWeight.w900, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: isPaused ? resumeGame : pauseGame,
                              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                              tooltip: isPaused ? 'Resume' : 'Pause',
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: StatCard(icon: '⭐', title: 'SCORE', value: '$score')),
                        const SizedBox(width: 7),
                        Expanded(child: StatCard(icon: '🏆', title: 'BEST', value: '$bestScore')),
                        const SizedBox(width: 7),
                        Expanded(child: StatCard(icon: '🎯', title: 'MOVES', value: '$moves')),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TARGET', style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
                            Text('$score / $targetScore', style: const TextStyle(fontSize: 9, color: Colors.white54)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD84D)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: message.isEmpty
                            ? const Text('Match 3 or more gems!', key: ValueKey('hint'), style: TextStyle(color: Colors.white54, fontSize: 13))
                            : Text(message, key: ValueKey('message'), style: const TextStyle(color: Color(0xFFFFD84D), fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = constraints.maxWidth > 520 ? 520.0 : constraints.maxWidth * 0.92;
                          return SizedBox(
                            width: size,
                            height: size,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171D42),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 25),
                                ],
                              ),
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                                itemCount: rows * columns,
                                itemBuilder: (context, index) {
                                  final row = index ~/ columns;
                                  final column = index % columns;
                                  final Gem? gem = board[row][column];
                                  final bool selected = selectedRow == row && selectedColumn == column;

                                  return GemTile(
                                    gem: gem,
                                    selected: selected,
                                    onTap: () => selectGem(row, column),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 7, bottom: 12),
                    child: Text('Tap two neighboring gems to swap', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ),
                ],
              ),
              if (isPaused)
                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171D42),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('PAUSED', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: resumeGame,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Resume'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: restart,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Restart'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (gameOver || levelComplete)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171D42),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            levelComplete ? 'LEVEL CLEAR!' : 'GAME OVER',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            levelComplete ? 'You reached the target score.' : 'You ran out of moves.',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Score: $score',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: levelComplete ? nextLevel : restart,
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD84D), foregroundColor: Colors.black),
                                  icon: Icon(levelComplete ? Icons.arrow_forward : Icons.refresh),
                                  label: Text(levelComplete ? 'NEXT LEVEL' : 'PLAY AGAIN'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          Text(title, style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.45), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class GemTile extends StatelessWidget {
  final Gem? gem;
  final bool selected;
  final VoidCallback onTap;

  const GemTile({
    super.key,
    required this.gem,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (gem == null) {
      return const SizedBox();
    }

    final Gem currentGem = gem!;
    final Color gemColor = currentGem.color;
    final IconData icon = switch (currentGem.special) {
      SpecialGem.rowBomb => Icons.bolt,
      SpecialGem.columnBomb => Icons.vertical_align_center,
      SpecialGem.colorBomb => Icons.auto_awesome,
      SpecialGem.normal => Icons.diamond,
    };

    final BoxDecoration decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          gemColor.withValues(alpha: 1),
          gemColor.withValues(alpha: 0.72),
          gemColor.withValues(alpha: 0.9),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.18),
        width: selected ? 3 : 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: gemColor.withValues(alpha: selected ? 0.7 : 0.28),
          blurRadius: selected ? 16 : 8,
          spreadRadius: selected ? 2 : 0,
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.08 : 1,
        duration: const Duration(milliseconds: 160),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: decoration,
          child: Stack(
            children: [
              Positioned(
                top: 4,
                left: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: selected ? 25 : 22,
                  shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

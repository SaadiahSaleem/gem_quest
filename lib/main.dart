import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const GemQuestApp());
}

// ============================================================
// APP
// ============================================================

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

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C2455),
              Color(0xFF080C20),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7B5CFF),
                          Color(0xFFB56CFF),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6)
                              .withValues(alpha: 0.5),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diamond,
                      size: 65,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'GEM QUEST',
                    style: TextStyle(
                      fontSize: 42,
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

                  const SizedBox(height: 50),

                  // PLAY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD84D),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                      ),
                      child: const Text(
                        'PLAY GAME',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FeatureItem(
                        icon: '💎',
                        title: 'MATCH',
                      ),
                      FeatureItem(
                        icon: '💥',
                        title: 'BLAST',
                      ),
                      FeatureItem(
                        icon: '🔥',
                        title: 'COMBO',
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  const Text(
                    'Match 3 or more gems to score.\n'
                        'Create special gems with bigger matches!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FEATURE ITEM
// ============================================================

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
        Text(
          icon,
          style: const TextStyle(fontSize: 30),
        ),
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

// ============================================================
// SPECIAL GEM TYPES
// ============================================================

enum SpecialGem {
  normal,
  rowBomb,
  columnBomb,
  colorBomb,
}

// ============================================================
// GEM
// ============================================================

class Gem {
  final Color color;
  SpecialGem special;

  Gem({
    required this.color,
    this.special = SpecialGem.normal,
  });
}

// ============================================================
// GAME SCREEN
// ============================================================

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int rows = 8;
  static const int columns = 8;

  final Random random = Random();

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

  String message = '';

  Timer? messageTimer;

  int get targetScore => level * 500;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    messageTimer?.cancel();
    super.dispose();
  }

  // ==========================================================
  // START GAME
  // ==========================================================

  void startGame() {
    score = 0;
    moves = 30;
    level = 1;
    combo = 0;

    selectedRow = null;
    selectedColumn = null;

    isProcessing = false;
    gameOver = false;
    levelComplete = false;

    message = '';

    createBoard();
  }

  // ==========================================================
  // CREATE BOARD
  // ==========================================================

  void createBoard() {
    do {
      board = List.generate(
        rows,
            (_) => List.generate(
          columns,
              (_) => Gem(
            color: randomGemColor(),
          ),
        ),
      );
    } while (findMatches().isNotEmpty);
  }

  // ==========================================================
  // RANDOM GEM
  // ==========================================================

  Color randomGemColor() {
    return gemColors[random.nextInt(gemColors.length)];
  }

  // ==========================================================
  // SELECT GEM
  // ==========================================================

  void selectGem(int row, int column) {
    if (isProcessing ||
        gameOver ||
        levelComplete ||
        moves <= 0) {
      return;
    }

    if (board[row][column] == null) {
      return;
    }

    // First selection
    if (selectedRow == null) {
      setState(() {
        selectedRow = row;
        selectedColumn = column;
      });
      return;
    }

    // Same gem
    if (selectedRow == row && selectedColumn == column) {
      setState(() {
        selectedRow = null;
        selectedColumn = null;
      });
      return;
    }

    // Adjacent gem
    if (isAdjacent(row, column)) {
      final firstRow = selectedRow!;
      final firstColumn = selectedColumn!;

      swapGems(
        firstRow,
        firstColumn,
        row,
        column,
      );

      setState(() {
        selectedRow = null;
        selectedColumn = null;
        moves--;
        isProcessing = true;
        combo = 0;
      });

      processSwap(
        firstRow,
        firstColumn,
        row,
        column,
      );
    } else {
      setState(() {
        selectedRow = row;
        selectedColumn = column;
      });
    }
  }

  // ==========================================================
  // ADJACENCY
  // ==========================================================

  bool isAdjacent(int row, int column) {
    final rowDifference = (selectedRow! - row).abs();
    final columnDifference = (selectedColumn! - column).abs();

    return rowDifference + columnDifference == 1;
  }

  // ==========================================================
  // SWAP GEMS
  // ==========================================================

  void swapGems(
      int firstRow,
      int firstColumn,
      int secondRow,
      int secondColumn,
      ) {
    final temp = board[firstRow][firstColumn];

    board[firstRow][firstColumn] =
    board[secondRow][secondColumn];

    board[secondRow][secondColumn] = temp;
  }

  // ==========================================================
  // PROCESS SWAP
  // ==========================================================

  Future<void> processSwap(
      int firstRow,
      int firstColumn,
      int secondRow,
      int secondColumn,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 150),
    );

    if (!mounted) return;

    final matches = findMatches();

    // INVALID MOVE
    if (matches.isEmpty) {
      swapGems(
        firstRow,
        firstColumn,
        secondRow,
        secondColumn,
      );

      setState(() {
        isProcessing = false;
        message = 'NO MATCH ↩';
      });

      clearMessageLater();

      return;
    }

    // VALID MOVE
    await processMatches();

    if (!mounted) return;

    if (score >= targetScore) {
      setState(() {
        levelComplete = true;
        isProcessing = false;
      });
    } else if (moves <= 0) {
      setState(() {
        gameOver = true;
        isProcessing = false;
      });
    } else {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // ==========================================================
  // FIND MATCHES
  // ==========================================================

  Set<String> findMatches() {
    final Set<String> matches = {};

    // HORIZONTAL
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

    // VERTICAL
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

  // ==========================================================
  // PROCESS MATCHES
  // ==========================================================

  Future<void> processMatches() async {
    final matches = findMatches();

    if (matches.isEmpty) {
      return;
    }

    combo++;

    final multiplier = combo > 1 ? combo : 1;

    final points = matches.length * 10 * multiplier;

    setState(() {
      score += points;

      if (score > bestScore) {
        bestScore = score;
      }

      if (combo >= 2) {
        message = '🔥 COMBO x$combo  +$points';
      } else {
        message = '+$points';
      }
    });

    // Create special gems
    createSpecialGems(matches);

    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (!mounted) return;

    // Activate special gems
    final specialMatches = activateSpecialGems(matches);

    final Set<String> allToRemove = {
      ...matches,
      ...specialMatches,
    };

    // Remove gems
    setState(() {
      for (final position in allToRemove) {
        final parts = position.split(',');

        final row = int.parse(parts[0]);
        final column = int.parse(parts[1]);

        board[row][column] = null;
      }
    });

    await Future.delayed(
      const Duration(milliseconds: 180),
    );

    if (!mounted) return;

    // Gravity
    applyGravity();

    setState(() {});

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    if (!mounted) return;

    // New gems
    fillEmptySpaces();

    setState(() {});

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    // Chain reaction
    if (findMatches().isNotEmpty) {
      await processMatches();
    }
  }

  // ==========================================================
  // CREATE SPECIAL GEMS
  // ==========================================================

  void createSpecialGems(Set<String> matches) {
    final Map<int, int> rowCounts = {};
    final Map<int, int> columnCounts = {};

    for (final position in matches) {
      final parts = position.split(',');

      final row = int.parse(parts[0]);
      final column = int.parse(parts[1]);

      rowCounts[row] = (rowCounts[row] ?? 0) + 1;
      columnCounts[column] =
          (columnCounts[column] ?? 0) + 1;
    }

    // Five or more = color bomb
    if (matches.length >= 5) {
      final position = matches.first;
      final parts = position.split(',');

      final row = int.parse(parts[0]);
      final column = int.parse(parts[1]);

      if (board[row][column] != null) {
        board[row][column]!.special =
            SpecialGem.colorBomb;
      }

      return;
    }

    // Four horizontal
    for (final entry in rowCounts.entries) {
      if (entry.value >= 4) {
        for (int column = 0; column < columns; column++) {
          final position = '${entry.key},$column';

          if (matches.contains(position) &&
              board[entry.key][column] != null) {
            board[entry.key][column]!.special =
                SpecialGem.rowBomb;
            return;
          }
        }
      }
    }

    // Four vertical
    for (final entry in columnCounts.entries) {
      if (entry.value >= 4) {
        for (int row = 0; row < rows; row++) {
          final position = '$row,${entry.key}';

          if (matches.contains(position) &&
              board[row][entry.key] != null) {
            board[row][entry.key]!.special =
                SpecialGem.columnBomb;
            return;
          }
        }
      }
    }
  }

  // ==========================================================
  // SPECIAL GEM EFFECTS
  // ==========================================================

  Set<String> activateSpecialGems(
      Set<String> matches,
      ) {
    final Set<String> result = {};

    for (final position in matches) {
      final parts = position.split(',');

      final row = int.parse(parts[0]);
      final column = int.parse(parts[1]);

      final gem = board[row][column];

      if (gem == null) continue;

      // ROW BOMB
      if (gem.special == SpecialGem.rowBomb) {
        for (int c = 0; c < columns; c++) {
          result.add('$row,$c');
        }
      }

      // COLUMN BOMB
      if (gem.special == SpecialGem.columnBomb) {
        for (int r = 0; r < rows; r++) {
          result.add('$r,$column');
        }
      }

      // COLOR BOMB
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

  // ==========================================================
  // GRAVITY
  // ==========================================================

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

  // ==========================================================
  // FILL EMPTY SPACES
  // ==========================================================

  void fillEmptySpaces() {
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        if (board[row][column] == null) {
          board[row][column] = Gem(
            color: randomGemColor(),
          );
        }
      }
    }
  }

  // ==========================================================
  // CLEAR MESSAGE
  // ==========================================================

  void clearMessageLater() {
    messageTimer?.cancel();

    messageTimer = Timer(
      const Duration(milliseconds: 1000),
          () {
        if (!mounted) return;

        setState(() {
          message = '';
        });
      },
    );
  }

  // ==========================================================
  // NEXT LEVEL
  // ==========================================================

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
  }

  // ==========================================================
  // RESTART
  // ==========================================================

  void restart() {
    setState(() {
      startGame();
    });
  }

  // ==========================================================
  // TEMPORARY MESSAGE
  // ==========================================================

  void showTemporaryMessage(String text) {
    messageTimer?.cancel();

    setState(() {
      message = text;
    });

    messageTimer = Timer(
      const Duration(milliseconds: 1500),
          () {
        if (!mounted) return;

        setState(() {
          message = '';
        });
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final double progress =
    (score / targetScore).clamp(0.0, 1.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF11183A),
              Color(0xFF080C20),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // =================================================
              // HEADER
              // =================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  5,
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💎 GEM QUEST',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'MATCH • BLAST • WIN',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white54,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD84D)
                            .withValues(alpha: 0.12),
                        borderRadius:
                        BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFFFD84D)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'LEVEL $level',
                        style: const TextStyle(
                          color: Color(0xFFFFD84D),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // STATS
              // =================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    StatCard(
                      icon: '⭐',
                      title: 'SCORE',
                      value: '$score',
                    ),
                    const SizedBox(width: 7),
                    StatCard(
                      icon: '🏆',
                      title: 'BEST',
                      value: '$bestScore',
                    ),
                    const SizedBox(width: 7),
                    StatCard(
                      icon: '🎯',
                      title: 'MOVES',
                      value: '$moves',
                    ),
                  ],
                ),
              ),

              // =================================================
              // PROGRESS
              // =================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TARGET',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$score / $targetScore',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: Colors.white10,
                        valueColor:
                        const AlwaysStoppedAnimation(
                          Color(0xFFFFD84D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // MESSAGE
              // =================================================

              SizedBox(
                height: 38,
                child: Center(
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(milliseconds: 200),
                    child: message.isEmpty
                        ? const Text(
                      'Match 3 or more gems!',
                      key: ValueKey('hint'),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    )
                        : Text(
                      message,
                      key: ValueKey('message'),
                      style: const TextStyle(
                        color: Color(0xFFFFD84D),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),

              // =================================================
              // GAME BOARD
              // =================================================

              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171D42),
                        borderRadius:
                        BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white
                              .withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.5),
                            blurRadius: 25,
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        physics:
                        const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: rows * columns,
                        itemBuilder:
                            (context, index) {
                          final row =
                              index ~/ columns;

                          final column =
                              index % columns;

                          final Gem? gem =
                          board[row][column];

                          final bool selected =
                              selectedRow == row &&
                                  selectedColumn ==
                                      column;

                          return GemTile(
                            gem: gem,
                            selected: selected,
                            onTap: () {
                              selectGem(
                                row,
                                column,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // =================================================
              // FOOTER
              // =================================================

              const Padding(
                padding: EdgeInsets.only(
                  top: 7,
                  bottom: 12,
                ),
                child: Text(
                  'Tap two neighboring gems to swap',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ========================================================
      // GAME OVER / LEVEL COMPLETE BUTTON
      // ========================================================

      floatingActionButton:
      (gameOver || levelComplete)
          ? FloatingActionButton.extended(
        onPressed:
        levelComplete ? nextLevel : restart,
        backgroundColor:
        const Color(0xFFFFD84D),
        foregroundColor: Colors.black,
        icon: Icon(
          levelComplete
              ? Icons.arrow_forward
              : Icons.refresh,
        ),
        label: Text(
          levelComplete
              ? 'NEXT LEVEL'
              : 'PLAY AGAIN',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

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
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius:
          BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 8,
                color:
                Colors.white.withValues(alpha: 0.45),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// GEM TILE
// ============================================================

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

    // IMPORTANT:
    // Convert Gem? into a local non-null Gem.
    final Gem currentGem = gem!;

    final Color gemColor = currentGem.color;

    IconData icon;

    switch (currentGem.special) {
      case SpecialGem.rowBomb:
        icon = Icons.bolt;
        break;

      case SpecialGem.columnBomb:
        icon = Icons.bolt;
        break;

      case SpecialGem.colorBomb:
        icon = Icons.auto_awesome;
        break;

      case SpecialGem.normal:
        icon = Icons.diamond;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.10 : 1.0,
        duration:
        const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: gemColor,
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? Colors.white
                  : Colors.transparent,
              width: selected ? 3 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: gemColor.withValues(
                  alpha: selected ? 0.8 : 0.35,
                ),
                blurRadius:
                selected ? 14 : 5,
                spreadRadius:
                selected ? 2 : 0,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: selected ? 27 : 22,
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
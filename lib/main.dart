import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final channel = WebSocketChannel.connect(Uri.parse('wss://heros-gambit-backend.onrender.com/'));
  String player = ''; // This will hold the player's identity (A or B)
  Map<String, String> boardState = {}; // Holds the current game state
  String selectedCharacter = ''; // Holds the selected character
  List<String> validMoves = []; // Holds the valid moves for the selected character
  List<String> moveHistory = []; // Holds the move history

  @override
  void initState() {
    super.initState();
    // Listen to WebSocket messages from the server
    channel.stream.listen((message) {
      print("MESSAGE: $message");
      final decodedMessage = jsonDecode(message);
      setState(() {
        if (decodedMessage['type'] == 'player') {
          player = decodedMessage['player'];
        } else if (decodedMessage['type'] == 'gameState') {
          print("Game State: ${decodedMessage['gameState']}");
          boardState = parseGameState(decodedMessage['gameState']);
          validMoves.clear(); // Clear valid moves when the game state updates
        } else if (decodedMessage['type'] == 'invalidMove') {
          // Handle invalid move
          print("Invalid move!");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    int gridCrossAxisCount = 5;
    double gridSize = width * 0.8 / gridCrossAxisCount;
    double totalHeight = gridSize * 5 + (gridCrossAxisCount - 1) * 1;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Hero\'s Gambit - Player $player', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Row(
            children: [
              Container(
                width: width * 0.37,
                height: totalHeight, // Adjust the height to fit the grid
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(), // Disable scrolling
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCrossAxisCount,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                          childAspectRatio: 1,
                        ),
                        itemCount: 25, // Number of grid items
                        itemBuilder: (context, index) {
                          String position = "row${index ~/ gridCrossAxisCount}-col${index % gridCrossAxisCount}";
                          String character = boardState[position] ?? "";

                          return GestureDetector(
                            onTap: () {
                              if (selectedCharacter.isEmpty && character.isNotEmpty && character.startsWith(player)) {
                                setState(() {
                                  selectedCharacter = character;
                                  validMoves = calculateValidMoves(character, position);
                                });
                              } else if (validMoves.contains(position)) {
                                sendMoveToServer(position); // Send move to server on valid position click
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 2),
                                color: validMoves.contains(position)
                                    ? Colors.greenAccent
                                    : (selectedCharacter == character ? Colors.lightBlueAccent : Colors.black45),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                character,
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCharacter = '';
                          validMoves.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: Text("Deselect", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[900],
                  child: ListView.builder(
                    itemCount: moveHistory.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          moveHistory[index],
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendMoveToServer(String newPosition) {
    channel.sink.add(jsonEncode({
      'type': 'move',
      'character': selectedCharacter,
      'newPosition': newPosition,
    }));
    setState(() {
      moveHistory.add('$selectedCharacter to $newPosition');
      selectedCharacter = '';
      validMoves.clear();
    });
  }

  Map<String, String> parseGameState(String gameStateString) {
    Map<String, String> newBoardState = {};
    List<String> pairs = gameStateString.split(',');

    for (String pair in pairs) {
      List<String> splitPair = pair.split(':');
      newBoardState[splitPair[0]] = splitPair[1];
    }
    return newBoardState;
  }

  List<String> calculateValidMoves(String character, String currentPosition) {
    List<String> validMoves = [];
    List<int> rowCol = parsePosition(currentPosition);
    int row = rowCol[0];
    int col = rowCol[1];

    switch (character.split('-')[1]) {
      case 'P1':
      case 'P2':
      case 'P3':
        validMoves.addAll(generatePawnMoves(row, col));
        break;
      case 'H1':
        validMoves.addAll(generateHero1Moves(row, col));
        break;
      case 'H2':
        validMoves.addAll(generateHero2Moves(row, col));
        break;
    }

    return validMoves
        .where((move) =>
    !boardState.containsKey(move) || // Empty position
        boardState[move]!.startsWith(player == 'A' ? 'B' : 'A')) // Opponent's position
        .toList();
  }

  List<String> generatePawnMoves(int row, int col) {
    List<String> moves = [];
    if (row > 0) moves.add("row${row - 1}-col$col"); // Forward
    if (row < 4) moves.add("row${row + 1}-col$col"); // Backward
    if (col > 0) moves.add("row$row-col${col - 1}"); // Left
    if (col < 4) moves.add("row$row-col${col + 1}"); // Right
    return moves;
  }

  List<String> generateHero1Moves(int row, int col) {
    List<String> moves = [];
    if (row > 1) moves.add("row${row - 2}-col$col"); // Forward 2
    if (row < 3) moves.add("row${row + 2}-col$col"); // Backward 2
    if (col > 1) moves.add("row$row-col${col - 2}"); // Left 2
    if (col < 3) moves.add("row$row-col${col + 2}"); // Right 2
    return moves;
  }

  List<String> generateHero2Moves(int row, int col) {
    List<String> moves = [];
    if (row > 1 && col > 1) moves.add("row${row - 2}-col${col - 2}"); // FL Diagonal
    if (row > 1 && col < 3) moves.add("row${row - 2}-col${col + 2}"); // FR Diagonal
    if (row < 3 && col > 1) moves.add("row${row + 2}-col${col - 2}"); // BL Diagonal
    if (row < 3 && col < 3) moves.add("row${row + 2}-col${col + 2}"); // BR Diagonal
    return moves;
  }

  List<int> parsePosition(String position) {
    List<String> rowCol = position.split('-');
    return [
      int.parse(rowCol[0].replaceAll('row', '')),
      int.parse(rowCol[1].replaceAll('col', ''))
    ];
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }
}

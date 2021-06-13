import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgainstSystemX extends StatefulWidget {
  @override
  _AgainstSystemXState createState() => _AgainstSystemXState();
}

class _AgainstSystemXState extends State<AgainstSystemX> {
  bool ohTurn = true;
  List<String> displayEx0h = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
  ];
  int ohScore = 0;
  int exScore = 0;
  int filledBox = 0;

  static var myNewFont = GoogleFonts.pressStart2p(
      textStyle: TextStyle(color: Colors.black, letterSpacing: 3));
  static var myNewFontWhite = GoogleFonts.pressStart2p(
      textStyle: TextStyle(
    color: Colors.white,
    letterSpacing: 3,
    fontSize: 15.0,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(27.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Computer',
                            style: myNewFontWhite,
                          ),
                          Text(
                            ohScore.toString(),
                            style: myNewFontWhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(27.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'player x',
                            style: myNewFontWhite,
                          ),
                          Text(
                            exScore.toString(),
                            style: myNewFontWhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GridView.builder(
                itemCount: 9,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _tapped(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[700]),
                      ),
                      child: Center(
                        child: Text(
                          displayEx0h[index],
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          GestureDetector(
            onTap: resetGame,
            child: Padding(
              padding: EdgeInsets.only(left: 40, right: 40, bottom: 60),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(30),
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'RESET ',
                      style: myNewFont,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tapped(int index) {
    setState(() {
      if (ohTurn && displayEx0h[index] == '') {
        displayEx0h[index] = 'X';
        filledBox += 1;
      } else if (!ohTurn && displayEx0h[index] == '') {
        displayEx0h[index] = 'O';
        filledBox += 1;
      }
      ohTurn = !ohTurn;
      _chechWinner();
    });
  }

  void _chechWinner() {
    if (displayEx0h[0] == displayEx0h[1] &&
        displayEx0h[0] == displayEx0h[2] &&
        displayEx0h[0] != '') {
      _showWinDialog(displayEx0h[0]);
    }
    if (displayEx0h[3] == displayEx0h[4] &&
        displayEx0h[3] == displayEx0h[5] &&
        displayEx0h[3] != '') {
      _showWinDialog(displayEx0h[3]);
    }
    if (displayEx0h[6] == displayEx0h[7] &&
        displayEx0h[6] == displayEx0h[8] &&
        displayEx0h[6] != '') {
      _showWinDialog(displayEx0h[6]);
    }
    if (displayEx0h[0] == displayEx0h[3] &&
        displayEx0h[0] == displayEx0h[6] &&
        displayEx0h[0] != '') {
      _showWinDialog(displayEx0h[0]);
    }
    if (displayEx0h[1] == displayEx0h[4] &&
        displayEx0h[1] == displayEx0h[7] &&
        displayEx0h[1] != '') {
      _showWinDialog(displayEx0h[1]);
    }
    if (displayEx0h[2] == displayEx0h[5] &&
        displayEx0h[2] == displayEx0h[8] &&
        displayEx0h[2] != '') {
      _showWinDialog(displayEx0h[2]);
    }
    if (displayEx0h[0] == displayEx0h[4] &&
        displayEx0h[0] == displayEx0h[8] &&
        displayEx0h[0] != '') {
      _showWinDialog(displayEx0h[0]);
    }
    if (displayEx0h[2] == displayEx0h[4] &&
        displayEx0h[2] == displayEx0h[6] &&
        displayEx0h[2] != '') {
      _showWinDialog(displayEx0h[2]);
    } else if (filledBox == 9) {
      _showDrawDialog();
    }
  }

  void _showDrawDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Draw'),
            actions: [
              TextButton(
                onPressed: () {
                  _clearBoard();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Play Again!',
                ),
              )
            ],
          );
        });
  }

  void _showWinDialog(String winner) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Winner is: ' + winner),
            actions: [
              TextButton(
                onPressed: () {
                  _clearBoard();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Play Again!',
                ),
              )
            ],
          );
        });
    if (winner == 'X') {
      ohScore += 1;
    } else if (winner == 'O') {
      exScore += 1;
    }
  }

  void _clearBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayEx0h[i] = '';
      }
    });
    filledBox = 0;
  }

  void resetGame() {
    //if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() {
      _clearBoard();
    });
  }
}

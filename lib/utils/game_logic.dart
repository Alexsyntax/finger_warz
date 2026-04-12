enum Move { rock, paper, scissors }

class RoundResult {
  final String resultText;
  final int scoreAwarded;

  const RoundResult({required this.resultText, required this.scoreAwarded});
}

class GameLogic {
  static RoundResult decideRound(Move player, Move computer) {
    if (player == computer) {
      return const RoundResult(resultText: 'Draw', scoreAwarded: 5);
    }

    final playerWins =
        (player == Move.rock && computer == Move.scissors) ||
        (player == Move.paper && computer == Move.rock) ||
        (player == Move.scissors && computer == Move.paper);

    if (playerWins) {
      return const RoundResult(resultText: 'Win', scoreAwarded: 10);
    }

    return const RoundResult(resultText: 'Lose', scoreAwarded: 0);
  }

  static String moveLabel(Move move) {
    switch (move) {
      case Move.rock:
        return 'Rock';
      case Move.paper:
        return 'Paper';
      case Move.scissors:
        return 'Scissors';
    }
  }
}

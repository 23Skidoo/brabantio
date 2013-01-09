Alpha-beta pruning in Ocaml
===========================

A simple [Othello][1] (aka reversi) implementation that uses alpha-beta pruning
for searching the game tree. A functor (parametrised module) is used for
decoupling the alpha-beta algorithm from a particular game state representation
and choice of heuristic.

Building
--------

To build the program, run `ocamlbuild brabantio.native`. This will produce an
executable called `brabantio.native` in the current directory. There are no
dependencies besides the Ocaml standard library.

To build the documentation, run `ocamlbuild .docdir/index.html`.

Usage
-----

The program takes the following options:

* `-player1 PLAYER` - Set the type of the first (i.e., black) player. Possible
  values: `human`; `random` - picks a random valid move; `alphabeta` -
  alpha-beta pruning with a naive heuristic; `alphabeta-smart` - alpha-beta
  pruning with a smarter heuristic.

* `-player2 PLAYER` - Set the type of the second (white) player.

* ` -batch n` - Run `n` games non-interactively and print the result. Doesn't
  work when any of the players is human.

* ` -single-turn STATE` - Single turn mode. Given a game state and a player
  color, output the next move for this player or print "pass" if there is no
  possible move.

  The STATE argument is an ASCII string of length 65. The first character
  is W or B, and indicates which player is to move. The remaining characters
  should be E (for empty) O (for white markers), or X (for black markers). These
  64 characters describe the board, with the first character referring to the
  upper left hand corner, the second character referring to the second square
  from the left on the uppermost row, and so on.

* ` -time-limit n` - Time limit (in seconds) for the single-turn mode. The
  default is 30.

* `--help`, `-help` - Display a help message.

There are two main modes: batch and interactive. Interactive mode is used for
human vs. computer matches, while the batch mode is for testing how different
AIs fare against each other.

Rules of the game are described [elsewhere][1].

Name
----

[Brabantio][2] is Desdemona's father in Shakespeare's "Othello".

[1]: http://en.wikipedia.org/wiki/Reversi
[2]: http://en.wikipedia.org/wiki/Brabantio

Alpha-beta pruning in Ocaml
===========================

A simple [Othello][1] (aka reversi) implementation that uses alpha-beta pruning
for searching the game tree. A functor (parametrised module) is used for
decoupling the alpha-beta algorithm from the concrete game state implementation.

Building
--------

To build the main executable, run `ocamlbuild brabantio.native`. This will
produce an executable file `brabantio.native` in the current directory. There
are no dependencies besides the Ocaml standard library.

To build the documentation, run `ocamlbuild .docdir/index.html`.

Usage
-----

The program takes the following options:

* `-player1 PLAYER` - Set the type of the first (i.e. black) player. Possible
  values: `human`; `random` - picks a random valid move; `alphabeta` -
  alpha-beta pruning with a naive heuristic; `alphabeta-smart` - alpha-beta
  pruning with a smarter heuristic.

* `-player2 PLAYER` - Set the type of the second (white) player.

* ` -batch n` - Run `n` games non-interactively and print the result. Doesn't
  work when any of the players is human.

* `--help`, `-help` - Display a help message.

There are two main modes: batch and interactive. Interactive mode is used for
human vs. computer matches, while the batch mode is for testing how different
AIs fare against each other.

Rules of the game are described [elsewhere][1].

Name
----

Brabantio is Desdemona's father in Shakespeare's "Othello".

[1]: http://en.wikipedia.org/wiki/Reversi

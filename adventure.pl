:- dynamic at/2, location/2, has_key/0, gate_unlocked/0, last_location/1.

description(valley, 'You are in a pleasant valley, with a trail ahead.').
description(path, 'You are on a path, with ravines on both sides.').
description(cliff, 'You are teetering on the edge of a cliff.').
description(fork, 'You are at a fork in the path.').
description(maze(_), 'You are in a maze of twisty trails, all alike.').
description(mountaintop, 'You are on the mountaintop.').
description(gate, 'You are at a gate leading to the mountaintop, but it is locked.').

report :-
  at(you, Loc),
  description(Loc, Desc),
  write(Desc), nl,
  (location(key, Loc) -> write('There is a key here.'), nl; true),
  (at(ogre, Loc) -> write('There is an ogre here!'), nl; true).

connect(valley, forward, path).
connect(path, right, cliff).
connect(path, left, cliff).
connect(path, forward, fork).
connect(fork, left, maze(0)).
connect(fork, right, gate).
connect(maze(0), left, maze(1)).
connect(maze(0), right, maze(3)).
connect(maze(1), left, maze(0)).
connect(maze(1), right, maze(2)).
connect(maze(2), left, fork).
connect(maze(2), right, maze(0)).
connect(maze(3), left, maze(0)).
connect(maze(3), right, maze(3)).
connect(gate, forward, mountaintop) :- gate_unlocked.

location(key, maze(2)).

move(Dir) :-
  at(you, Loc),
  connect(Loc, Dir, Next),
  retract(at(you, Loc)),
  assert(at(you, Next)),
  (last_location(Last) -> retract(last_location(Last)); true),
  assert(last_location(Loc)),
  report,
  (Next == cliff -> cliff; true),
  (at(ogre, Next) -> ogre; true),
  !.

move(back) :-
  last_location(Last),
  at(you, Current),
  retract(at(you, Current)),
  assert(at(you, Last)),
  (last_location(Previous) -> retract(last_location(Previous)); true),
  assert(last_location(Current)),
  report,
  !.

move(_) :-
  write('That is not a legal move.\n'),
  report.

perform_move(forward) :- move(forward).
perform_move(left) :- move(left).
perform_move(right) :- move(right).
perform_move(back) :- move(back).

pickup :-
  location(key, Loc),
  at(you, Loc),
  retract(location(key, Loc)),
  assert(has_key),
  write('You picked up the key.'), nl.

unlock :-
  at(you, gate), has_key,
  write('You unlock the gate with the key.'), nl,
  assert(gate_unlocked).

drop :-
  has_key,
  at(you, Loc),
  retract(has_key),
  assert(location(key, Loc)),
  write('You dropped the key.'), nl.

ogre :-
  at(ogre, Loc),
  at(you, Loc),
  write('An ogre sucks your brain out through\n'),
  write('your eye sockets, and you die.\n'),
  retract(at(you, Loc)),
  assert(at(you, done)),
  !.

treasure :-
  at(treasure, Loc),
  at(you, Loc),
  write('There is a treasure here.\n'),
  write('Congratulations, you win!\n'),
  retract(at(you, Loc)),
  assert(at(you, done)),
  !.

cliff :-
  at(you, cliff),
  write('You fall off and die.\n'),
  retract(at(you, cliff)),
  assert(at(you, done)),
  !.

lightning_strike :-
  write('As you try to pass through the gate while holding the key, lightning strikes you!'), nl,
  retract(at(you, _)), 
  assert(at(you, done)),
  fail.

main :-
  at(you, done),
  write('Thanks for playing.\n'),
  !.

main :-
  at(you, gate), has_key, gate_unlocked,
  write('The gate is now unlocked. You can go through it.'), nl,
  !,
  read(Move),
  (
    Move == forward -> perform_move(forward), lightning_strike;
    Move == drop -> drop;
    true
  ),
  main.

main :-
  at(you, gate), has_key, gate_unlocked,
  write('The gate is now unlocked. You can go through it.'), nl,
  !,
  read(Move),
  (
    Move == forward -> perform_move(forward), lightning_strike;
    Move == drop -> drop, !;
    true
  ),
  main.

main :-
  at(you, mountaintop),
  treasure,
  !,
  main.

main :-
  write('\nNext move -- '),
  read(Move),
  (
    Move == forward -> perform_move(forward), !;
    Move == left -> perform_move(left), !;
    Move == right -> perform_move(right), !;
    Move == back -> perform_move(back), !;
    Move == pickup -> pickup, !;
    Move == unlock -> unlock, !;
    Move == drop -> drop, !;
    otherwise -> write('That is not a legal move.\n'), report, !, fail
  ),
  main.

go :-
  retractall(at(_,_)),
  retractall(location(_,_)),
  retractall(has_key),
  retractall(gate_unlocked),
  retractall(last_location(_)),
  assert(at(you, valley)),
  assert(at(ogre, maze(3))),
  assert(at(treasure, mountaintop)),
  assert(location(key, maze(2))),
  assert(at(treasure, mountaintop)),
  write('This is an adventure game. \n'),
  write('Legal moves are left, right, forward, back, pickup, unlock, and drop.\n'),
  write('End each move with a period.\n\n'),
  report,
  main.


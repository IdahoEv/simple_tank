SimpleTank
==========

This is the beginnings of a personal hobby project to re-create the classic 
1990's-era videogame "Bolo" by Stuart Cheshire.  It's written with a back-end-server in Elixir and
a front-end client in Javascript.  Both the back-end modeling and the client/serer communication
is completely asynchronous. All communication happens over websockets.

Usage
---------

Make sure you have elixir >= 1.0.0 installed.  Clone the repo, and change directory to it.  Run the following commands:

    mix deps.get
    mix deps.compile
    iex -S mix

Then open a browser to localhost:8080.

Running the Tests
-----------------

I don't have many tests yet, since I'm still learning to do TDD in Elixir.  But for those that are there, you can run them with:

    mix amrita



# Kano User Stories Frontend Challenge


## Summary

This project is built using [**Elm**](http://elm-lang.org) with [**bulma** sass](https://bulma.io).

This development should take much shorter time if I opted for other framework or simple JS + HTML.
However I do want to showcase the strongly typed functional frontend framework **Elm**,
as this is the inspiration behind **Redux** for **ReactJS**, and its strong claim that
it has never run into runtime error.


## Installation

After git clone this repository, simply run the following commands on project root:

`npm install -g elm`

`npm install`

After that, change directory to **src** and install *elm* packages:

`cd src`

`elm-package install --yes`


## Build and Run

To build the project, run `gulp build` under project root, the compiled files will be stored under **dist** directory.

Simply run a file server under **dist** directory, and navigate to the **index.html** file.

For example, if you have **python** installed, simply run `python -m SimpleHttpServer` under **dist** folder.

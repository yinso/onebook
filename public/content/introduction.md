# Introduction

`Onebook` is a simple book writing software that works with your desktop markup writing tool.

Specifically, `onebook` is a book viewer - you'll write in your favorite desktop markdown writing tool,
and you'll use `onebook` to view the writings.

`Onebook` is a [NodeJS](http://nodejs.org) web application.


## Dependency

`Onebook` depends on

* [NodeJS](http://nodejs.org) - this is required for `onebook` to run
* [Compass](http://compass-style.org) - this is **not** a hard dependency - you can write stylsheets manually.
* [Coffee-Bean](http://github.com/yinso/bean) - this is used to parse the bean file for tracking the book metadata.

## Installation

First, install `onebook`.

    npm install -g onebook

After you have installed `onebook`, you can create a default project in a given directory.

    cd <your_choice_of_directory>
    onebook init

The project created will have the following structures.

    /index.html - this is the basic html template for displaying the book
    /content - put your markdown content here.
    /js - holds the needed js for rendering the content
    /css - holds the stylesheets for formatting the content
    /sass - used for generating the css files (you do not need to use these).
    /config.rb - used by compass
    /project.bean - this holds the book metadata in coffee-script object format.



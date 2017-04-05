[![This project is considered experimental](https://img.shields.io/badge/Status-experimental-red.svg)](https://arp242.net/status/experimental)
# Highlight Marks
A vim plugin that highlights marks with different colors so you know where they are.

There are two global variables that you can specity to control the highlight coloring.
 - `g:highlightMarks_colors` controls what colors the gui displays and takes a list of colors (Names or RGB hex strings).
 - `g:highlightMarks_cterm_colors` controls what colors the terminal displays and takes a list of numbers.

There is also a command to get rid of the highlighting if starts annoying you: `:RemoveMarkHighlights`. With no arguments it will clear all mark highlighting. If you give a list of characters, it will clear the highlighting for the specified marks only.

# Word Ladder Solver

This is a program that solves word ladders using the A* path search algorithm.

## What is a word ladder?

A word ladder is a type of puzzle where two words (of the same length) are given such "pig" and "sty". The goal is to find a path between the two words. To move from word to word, a single letter is changed such that the new word is still a valid English word. For example, "pig" to "pug" to "pun" are all valid; however pig to "uig" to "zap" are not. Here is a valid solution for "pig" and "sty": pig -> big -> bag -> bay -> say -> sty.

## Usage 

Execute main.jl and wait. The program will prompt you to enter details of the word ladder to be solved. 

## Changing the dictionary of valid words

To use a different set of valid words, replace "words.txt" in the "EnglishWords" directory. Each word should be seperated by a new line.

## Acknowledgements

The file "words.txt" was pulled from this repository: [https://github.com/dwyl/english-words](https://github.com/dwyl/english-words)

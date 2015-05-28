sql.vim
=======
ViM script to execute database queries

History
-------
I didn't do anything crazy except make it work a little bit more nicely with my workflow. The real
credit goes to the programmers from which this originated:

1. Modified from [sybase.vim](https://github.com/vim-scripts/sybase.vim) by Scott James
2. Modified from [sqlplus.vim](http://vim.sourceforge.net/scripts/script.php?script_id=97) by Jamis Buck

Notes
-----
Default values are given and may be overridden. To quickly switch database
connection settings press <F8> in normal mode. By not entering a value in
one of the input dialogs it retains the previous value.

Dependencies
------------
The command line tool `sqsh`. This could probably be easily swapped out with
`isql` or something similar as well.

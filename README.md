# ccat
License: **GPL-3.0-or-later**  
Colorized Linux cat command.  
Uses nanorc files for coloring information.  
This is work in progress.  
Compiles with free pascal compiler.  
Works also with pascal.nanorc found here: [https://www.github.com/sith-ikjetil/pascal.nanorc]  

Usage:  
```
 cat test.pas | ccat --syntax=pascal
or
 ccat --syntax=pascal < test.pas
where
 # --syntax=pascal means it looks in ~/.nano/pascal.nanorc for nanorc syntax format
 # --syntax=perl means it looks in ~/.nano/perl.nanorc for nanorc syntax format
 # --syntax=c means it looks in ~/.nano/c.nanorc for nanorc syntax format 
 # etc..
 # if no nanorc file is found it renders input to output raw with no coloring or manipulation
```
The quality of the coloring of syntax varies depending on how good the quality of the nanorc.  
Not all nanorc syntax is supported. As of now only: 'color color-name "regular expression"' is supported.  

The ccat color rendering engine differs from nanos so output might be different on same nanorc.  


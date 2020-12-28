# ccat
License: **GPL-3.0-or-later**  
Color Linux cat type command.  
Uses rc/nanorc files for coloring information.  
Expects 1) rc files to be found under ~/.ccat
Expects - if not found under 1) - 2) nanorc files to be found under ~/.nano  
This is work in progress.  
Compiles with free pascal compiler.  
Works good with pascal.nanorc found here: [https://www.github.com/sith-ikjetil/pascal.nanorc]  

Usage:  
```
 cat test.pas
or
 ccat --syntax=pascal test.pas
or
 ccat --syntax=pascal < test.pas
or
 cat test.pas | ccat --syntax=pascal
where
 # --syntax=pascal means it looks in ~/.nano/pascal.nanorc for nanorc syntax format
 # --syntax=perl means it looks in ~/.nano/perl.nanorc for nanorc syntax format
 # --syntax=c means it looks in ~/.nano/c.nanorc for nanorc syntax format 
 # etc..
 # if no rc/nanorc file is found it renders input to output raw with no coloring or manipulation
```
The quality of the coloring of syntax varies depending on how good the quality of the rc/nanorc.  

Not all nanorc syntax is supported. As of now only: 'color fg-color-name "regular expression"' is supported.  

The ccat color rendering engine differs from nanos so output might be different on same nanorc.  


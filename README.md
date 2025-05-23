# ccat
License: **GPL-3.0-or-later**  

Color Linux cat type command.  

Uses ccrc/nanorc files for coloring information.  

Expects 1) ccrc files to be found under ~/.ccat/  

**Compiles with free pascal compiler.**  

Check out officially supported ccrc files under ccrc directory here: [https://github.com/sith-ikjetil/ccat/tree/main/ccrc]  

Usage:  
```bash
 ccat test.pas
or
 ccat --syntax=pascal < test.pas
or
 cat test.pas | ccat --syntax=pascal
where
 # --syntax=pascal means it looks in ~/.ccat/pascal.ccrc for syntax format
 # --syntax=perl means it looks in ~/.ccat/perl.ccrc for syntax format
 # --syntax=c means it looks in ~/.ccat/c.ccrc for syntax format 
 # etc..
 # if syntax is specified and no ccrc file is found it renders input to 
 #  output raw with no coloring or manipulation
 # if syntax is not specified and a file given is of unknown type then default it will 
 #  use the text syntax.
```
The quality of the coloring of syntax varies depending on how good the quality of the ccrc.  

As of now only the following syntax is supported in .ccrc files:
```
 color fg-color-name "<regular expression>"
```
It is also important to note that the order in which these color settings are set is important.

Also in .ccrc files the following multi line comments are supported from version 0.5.
```
 color fg-color-name start="<regular expression>" end="<regular expression>"
```
Please note that comments and multi line comments should be placed first in the .ccrc or .nanorc file.

In order to get coloring in nano when editing the ccrc files you need to copy  
the ccrc.nanorc file under nanorc to ~/.nano. Then run the following command:
```
 echo include \"~/.nano/ccrc.nanorc\" >> ~/.nanorc
```


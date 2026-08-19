% ccat(1) ccat 0.1
% Written by Kjetil Kristoffer Solberg
% December 2020

# NAME
ccat - coloring stdin or file to stdout using ccrc coloring

# SYNOPSIS
**ccat** [*OPTION*] [*FILE*]  
**ccat** [*OPTION*] < [*FILE*]  
**...** | **ccat** [*OPTION*]

# DESCRIPTION
Coloring stdin or [*FILE*] using a ccrc syntax file

# OPTIONS
**----help**  
: Shows the default help screen

**----syntax=***(syntax)*  
: Renders stdin or [*FILE*] to stdout and coloring using ccrc syntax files

# EXAMPLES
**ccat** f

**ccat ----syntax=pascal** f
: Coloring file f using pascal syntax.

**ccat ----syntax=pascal** < f
: Coloring file f using pascal syntax.

cat f | **ccat ----syntax=pascal**  
: Coloring file f using pascal syntax.

# KNOWN FILE TYPES
Assembly   **.asm**  
Arduino    **.ino**  
Awk        **.awk**  
C/C++      **.c|.cpp|.h**  
CSharp     **.cs**  
Fortran    **.f90|.f95|.f03**  
Haskell    **.hs**  
HTML       **.html**  
Javascript **.js**  
JSON       **.json**  
Pascal     **.pas**  
Perl       **.pl**  
Python     **.py**  
Shell      **.sh**  
SQL        **.sql**  
Swift      **.swift**  
Text **.txt**  
XML **.xml**  

# BUGS
All software have bugs :)

# COPYRIGHT
License GPL-3.0-or-later. This is free software: you are free to change and redistribute it. There is NO WARRENTY, to the extent permitted by law.

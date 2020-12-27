% ccat(1) ccat 0.1
% Written by Kjetil Kristoffer Solberg
% December 2020

# NAME
ccat - coloring stdin or file to stdout using nanorc coloring

# SYNOPSIS
**ccat** [*OPTION*] [*FILE*]  
**ccat** [*OPTION*] < [*FILE*]  
**...** | **ccat** [*OPTION*]

# DESCRIPTION
Coloring stdin or [*FILE*] using ~/.nano/(syntax).nanorc syntax file

# OPTIONS
**----help**  
: Shows the default help screen

**----syntax=***(syntax)*  
: Renders stdin or [*FILE*] to stdout coloring using ~/.nano/(syntax).nanorc file

# EXAMPLES
**ccat ----syntax=pascal** f  
: Coloring file f using pascal syntax (~/.nano/pascal.nanorc)

**ccat ----syntax=pascal** < f  
: Coloring file f using pascal syntax (~/.nano/pascal.nanorc)

cat f | **ccat ----syntax=pascal**  
: Coloring file f using pascal syntax (~/.nano/pascal.nanorc)

# BUGS
All software have bugs :)

# COPYRIGHT
License GPL-3.0-or-later. This is free software: you are free to change and redistribute it. There is NO WARRENTY, to the extent permitted by law.

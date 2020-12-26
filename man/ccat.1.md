% ccat(1) ccat 0.1
% Written by Kjetil Kristoffer Solberg
% December 2020

# NAME
ccat - coloring stdin to stdout using nanorc coloring

# SYNOPSIS
**ccat** [*OPTION*] < [*FILE*]  
**...** | **ccat** [*OPTION*]

# DESCRIPTION
Coloring stdin to stdout for content that has a .nanorc coloring syntax file.  
Files are expected to be under ~/.nano/(syntax).nanorc

# OPTIONS
**----help**  
: Shows the default help screen

**----syntax=***(syntax)*  
: Renders stdin to stdout coloring stdin to stdout using nanorc color scheme from ~/.nano/<syntax>.nanorc

# EXAMPLES
**ccat ----syntax=pascal** < f  
: Coloring file f to stdout using pascal syntax (~/.nano/pascal.nanorc)

**cat** **f** | **ccat** *----syntax=pascal*  
: Coloring file f to stdout using pascal syntax (~/.nano/pascal.nanorc)

# BUGS
All software have bugs :)

# COPYRIGHT
License GPL-3.0-or-later. This is free software: you are free to change and redistribute it. There is NO WARRENTY, to the extent permitted by law.

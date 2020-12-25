# ccat
License: **GPL-3.0-or-later**  
Colorized Linux cat command.  
This is work in progress.  
Compiles with free pascal compiler.  
Works with pascal.nanorc found here: [https://www.github.com/sith-ikjetil/pascal.nanorc]  

Usage:  
```
cat test.pas | ccat --syntax=pascal
or
ccat --syntax=pascal < test.pas
where
# --syntax=pascal means it looks in ~/.nano/pascal.nanorc for nanorc syntax format
```

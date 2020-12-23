program ccat;

uses
    SysUtils;

var
    //
    // Colors
    //
    g_clr_white: string = ''#00#27'[37m';
    g_clr_black: string = ''#00#27'[30m';
    g_clr_red: string = ''#00#27'[31m';
    g_clr_blue: string = ''#00#27'[34m';
    g_clr_green: string = ''#00#27'[32m';
    g_clr_yellow: string = ''#00#27'[33m';
    g_clr_magenta: string = ''#00#27'[35m';
    g_clr_cyan: string = ''#00#27'[36m';

    //
    // Colors Reset
    //
    g_clr_reset: string = ''#00#27'[0m';

    //
    // Bright Colors
    //
    g_clr_brightwhite: string = ''#00#27'[37;1m';
    g_clr_brightblack: string = ''#00#27'[30;1m';
    g_clr_brightred: string = ''#00#27'[31;1m';
    g_clr_brightblue: string = ''#00#27'[34;1m';
    g_clr_brightgreen: string = ''#00#27'[32;1m';
    g_clr_brightyellow: string = ''#00#27'[33;1m';
    g_clr_brightmagenta: string = ''#00#27'[35;1m';
    g_clr_brightcyan: string = ''#00#27'[36;1m';

    //
    // Misc
    //
    g_input: string;
    g_path_nanorc_dir: string = '~/.nano/';
    g_syntax: string = '';
    g_fnano: text;

//
// RenderHelp
//
// (i): Renders help screen
//
procedure RenderHelp();
begin
    writeln('Usage: ccat [option]');
    writeln();
    writeln('With no FILE, then read from standard input');
    writeln('<syntax> is a <syntax>.nanorc file from ~/.nano/<syntax>.nanorc');
    writeln();
    writeln('  --help               display this help screen and exit');
    writeln('  --syntax=<syntax>    render output using <syntax> syntax');
    writeln();
    writeln('Examples:');
    writeln('  ccat --syntax=pascal < f        Outputs stdin using pascal syntax');
    writeln('  cat f | ccat --syntax=pascal    Outputs stdin using pascal syntax');
    writeln();
    writeln();
end;

//
// RenderRaw
//
// (i): Renders input raw.
//
procedure RenderRaw();
begin
    readln(g_input);
    while not eof do 
    begin
	writeln(g_input);
	readln(g_input);
    end;
    writeln(g_input);
end;   

//
// RenderColored
//
// (i): Renders input with color output.
//
procedure RenderColored();
begin
    writeln('RenderColored...');
end;

//
// IsArgIn
//
// (i): Returnes if argument exists.
//
function IsArgIn(arg: string): boolean;
var
    i: integer = 1;
begin
    IsArgIn := false;

    for i := 1 to paramcount do
    begin
        if pos(arg,paramstr(i)) > 0 then
            IsArgIn := true;
            break;
    end;
end;

//
// GetArgIn
// 
// (i): Returnes that argument value.
//
function GetArgIn(arg: string): string;
var
    i: integer = 1;
begin
    GetArgIn := ' ';

    for i := 1 to paramcount do
    begin
        if pos(arg,paramstr(i)) > 0 then
            GetArgIn := rightstr(paramstr(i),Length(paramstr(i))-Length(arg)-1);
            break;
    end;    
end;

//
// AddItemToColorArray
//
// (i): Adds a colored reg expression to color array.
//
procedure AddItemToColorArray(line: string);
begin

end;


//
// LoadSyntaxNanoRc
//
// (i): Loads syntax information from ~/.nano/<syntax>.nanorc
//
function LoadSyntaxNanoRc() : boolean;
var
    fname: string;
    fnrc: textfile;
    line: string;
begin
    LoadSyntaxNanoRc := false;

    fname := getuserdir();
    fname += '.nano/';
    fname += g_syntax;
    fname += '.nanorc';
    
    if fileexists(fname) then
    begin
        Assign(fnrc, fname);
        reset(fnrc);
        
        while not eof(fnrc) do
        begin
            readln(fnrc, line);
            AddItemToColorArray(line);
        end;
        LoadSyntaxNanoRc := true;
    end
end;

//
// main function
//
begin
    if IsArgIn('--help') then                   // Check for help request
        RenderHelp()
    else
    begin
        if IsArgIn('--syntax') then             // Do we have syntax?
        begin
            g_syntax := GetArgIn('--syntax');   // Get syntax
            if LoadSyntaxNanoRc()               // Load <syntax>.nanorc and check if ok
            then RenderColored()                // Render colored all looks good
            else RenderRaw();                   // Render raw because load <syntax>.nanorc failed
        end
        else RenderRaw();                       // Render raw because we have no syntax
    end;
end.




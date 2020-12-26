//#: Title       : ccat.pas
//#: Date        : 2020-12-25
//#: Author      : Kjetil Kristoffer Solberg <post@ikjetil.no>
//#: Version     : 0.1
//#: Description : Source code to ccat.
program ccat;

{$MODE OBJFPC}
{$H+}

uses
    SysUtils, RegExpr;

type
    //
    // A reg expr. and its color.
    //
    TColorItem = record
        m_color: string;    // color
        m_re: string;       // regular expression
    end;

    //
    // A line item
    //
    TLineItem = record
        m_i: integer;
        m_len: integer;
        m_pre: string;
        m_post: string;
    end;
var
    //
    // Version string
    //
    g_version: string = '0.1';

    //
    // <syntax>.nanorc color records
    //
    g_colorItems: array [1..1000] of TColorItem;
    g_ciIndex: integer = 1;

    //
    // line items for each g_input (each line of input)
    //
    g_lineItems: array [1..1000] of TLineItem;
    g_liIndex: integer = 1;

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
    g_syntax: string;

//
// RenderHelp
//
// (i): Renders help screen
//
procedure RenderHelp();
begin
    writeln('Usage: ccat [option]');
    writeln('Version: ',g_version);
    writeln('Reads from standard input');
    writeln('<syntax> is a <syntax>.nanorc file from ~/.nano/<syntax>.nanorc');
    writeln();
    writeln('  --help               display this help screen and exit');
    writeln('  --syntax=<syntax>    render output using <syntax> syntax');
    writeln();
    writeln('Examples:');
    writeln('  ccat --syntax=pascal < f        Takes f as stdin and outputs using pascal syntax');
    writeln('  cat f | ccat --syntax=pascal    Takes f as stdin and outputs using pascal syntax');
    writeln();
    writeln('Created by Kjetil Kristoffer Solberg <post@ikjetil.no>');
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
// PreRenderInput
//
// (i): Sets up line items for rendering of input line
//
procedure PreRenderInput(input: string; ci: TColorItem);
var
    re: TRegExpr;
    i: integer;
    temp: string;
    right: string;
    temp_item: TLineItem;
begin
    temp := input;
    try
        try
            re := TRegExpr.Create(ci.m_re);
            if re.Exec(temp) then
            begin
                temp_item.m_i := pos(re.Match[0],temp);
                temp_item.m_len := length(re.Match[0]);
                temp_item.m_pre := ci.m_color;
                temp_item.m_post := g_clr_reset;

                g_lineItems[g_liIndex] := temp_item;
                g_liIndex += 1;        
        
                while re.ExecNext do
                begin
                    right := rightstr(temp,length(temp)-temp_item.m_i-length(re.Match[0])+1);
            
                    i := pos(re.Match[0], right);
                    temp_item.m_i := i + length(input) - length(right);
                    temp_item.m_len := length(re.Match[0]);
                    temp_item.m_pre := ci.m_color;
                    temp_item.m_post := g_clr_reset;

                    g_lineItems[g_liIndex] := temp_item;
                    g_liIndex += 1;        
                end;
            end;
        except
        end;
    finally
        re.Free();
    end;
end;

//
// IsOkToPostRender
//
// (i): Decline items to render in other items already rendered
//
function IsOkToPostRender(li: integer; i: integer; len: integer) : boolean;
var
    j: integer;
    max: integer;
begin
    IsOkToPostRender := true;
    max := g_liIndex - 1;
    for j := li to max do
    begin
        if (j <> li) then
        begin
            if (g_lineItems[j].m_i <= i) and ((g_lineItems[j].m_i + g_lineItems[j].m_len) > (i)) then
            begin
                IsOkToPostRender := false;
                break;
            end;
        end;
    end;
end;

//
// PostRenderInput
//
// (i): Post renders line input
//
function PostRenderInput(input: string) : string;
var
    i: integer = 1;
    j: integer;
    max: integer;
    temp: string;
    left: string;
    right: string;
    s: string;
begin
    PostRenderInput := input;
    max := g_liIndex - 1;

    temp := input;
    for i := 1 to max do
    begin
        if IsOkToPostRender(i,g_lineItems[i].m_i, g_lineItems[i].m_len) then
        begin
            left := leftstr(temp,g_lineItems[i].m_i-1);
            right := rightstr(temp,length(temp)-g_lineItems[i].m_i-g_lineItems[i].m_len+1);
            
            s := copy(temp, g_lineItems[i].m_i, g_lineItems[i].m_len);

            temp := left;
            temp += g_lineItems[i].m_pre;
            temp += s;
            temp += g_lineItems[i].m_post;
            temp += right;

            // Now update array for items further away
            for j := 1 to max do
            begin
                if (g_lineItems[j].m_i > g_lineItems[i].m_i) then
                begin
                    g_lineItems[j].m_i += length(g_lineItems[i].m_pre);
                    g_lineItems[j].m_i += length(g_lineItems[i].m_post);
                end;
            end;
        end;
    end;        

    PostRenderInput := temp;
    g_liIndex := 1;
end;

//
// RenderColored
//
// (i): Renders input with color output.
//
procedure RenderColored();
var
    i: integer = 1;
    max: integer;
    temp: string;
begin
    max := g_ciIndex - 1;

    readln(g_input);
    while not eof do 
    begin
        temp := g_input;
        for i := 1 to max do
        begin
            PreRenderInput(temp, g_colorItems[i]);
        end;
        temp := PostRenderInput(temp);
	    writeln(temp);
        readln(g_input);
    end;

    temp := g_input;
    for i := 1 to max do
    begin
        PreRenderInput(temp, g_colorItems[i]);
    end;
    temp := PostRenderInput(temp);
	writeln(temp);
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
    GetArgIn := '';

    for i := 1 to paramcount do
    begin
        if pos(arg,paramstr(i)) > 0 then
            GetArgIn := rightstr(paramstr(i),length(paramstr(i))-length(arg)-1);
            break;
    end;    
end;

//
// TranslateColorNameToColorValue
//
// (i): Translate color name to color value. Default white.
//
function TranslateColorNameToColorValue(name: string) : string;
begin
    TranslateColorNameToColorValue := g_clr_white;

    if comparetext(name,'white') = 0
    then TranslateColorNameToColorValue := g_clr_white;

    if comparetext(name,'black') = 0
    then TranslateColorNameToColorValue := g_clr_black;

    if comparetext(name,'red') = 0
    then TranslateColorNameToColorValue := g_clr_red;

    if comparetext(name,'blue') = 0
    then TranslateColorNameToColorValue := g_clr_blue;

    if comparetext(name,'green') = 0
    then TranslateColorNameToColorValue := g_clr_green;

    if comparetext(name,'yellow') = 0
    then TranslateColorNameToColorValue := g_clr_yellow;

    if comparetext(name,'magenta') = 0
    then TranslateColorNameToColorValue := g_clr_magenta;

    if comparetext(name,'cyan') = 0
    then TranslateColorNameToColorValue := g_clr_cyan;

    if comparetext(name,'brightwhite') = 0
    then TranslateColorNameToColorValue := g_clr_brightwhite;

    if comparetext(name,'brightblack') = 0
    then TranslateColorNameToColorValue := g_clr_brightblack;

    if comparetext(name,'brightred') = 0
    then TranslateColorNameToColorValue := g_clr_brightred;

    if comparetext(name,'brightblue') = 0
    then TranslateColorNameToColorValue := g_clr_brightblue;

    if comparetext(name,'brightgreen') = 0
    then TranslateColorNameToColorValue := g_clr_brightgreen;

    if comparetext(name,'brightyellow') = 0
    then TranslateColorNameToColorValue := g_clr_brightyellow;

    if comparetext(name,'brightmagenta') = 0
    then TranslateColorNameToColorValue := g_clr_brightmagenta;

    if comparetext(name,'brightcyan') = 0
    then TranslateColorNameToColorValue := g_clr_brightcyan;

end;

//
// NormalizeRegExPattern
//
// (i): Update pattern to work with this application.
//
function NormalizeRegExPattern(re: string) : string;
var
    left: string;
    right: string;
    temp: string;
    retval: string;
begin
    retval := re;
    NormalizeRegExPattern := retval;

    left := leftstr(re,2);
    right := rightstr(re,2);
    if (comparestr(left,'\<') = 0) and (comparestr(right,'\>') = 0) then
    begin
        temp := re;
        delete(temp,1,2);
        delete(temp,length(temp)-1,2);
        retval := temp;
    end;
    
    if length(retval) > 1 then
        if retval[1] = '(' then
            if retval[2] <> '\b' then 
                retval := concat('\b', retval, '\b');
   
    NormalizeRegExPattern := retval;
end;

//
// AddItemToColorArray
//
// (i): Adds a colored reg expression to color array.
//
procedure AddItemToColorArray(line: string);
var
    re: TRegExpr;
    temp_item: TColorItem;
begin
    if (length(line) > 1) and (line[1] <> '#') then
    begin
        if g_ciIndex < 1000 then
        begin
            temp_item.m_color := '';
            temp_item.m_re := '';
            try
                try
                    re := TRegExpr.Create('(color)\s(.*)\s"(.*)"');
                    if re.Exec(line) then
                    begin
                        temp_item.m_color := TranslateColorNameToColorValue(re.Match[2]);
                        temp_item.m_re := NormalizeRegExPattern(re.Match[3]);
                        if (length(temp_item.m_color) > 0) and (length(temp_item.m_re) > 0) then
                        begin
                            g_colorItems[g_ciIndex] := temp_item;
                            g_ciIndex += 1;
                        end;
                    end;
                except
                end;
            finally
                re.Free();
            end;
        end;
    end;
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
        assign(fnrc, fname);
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
// program block
//
begin
    if (paramcount = 0) or IsArgIn('--help') then                   // Check for help request
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

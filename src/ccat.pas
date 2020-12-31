//#: Title        : ccat.pas
//#: Date Created : 2020-12-25
//#: Author       : Kjetil Kristoffer Solberg <post@ikjetil.no>
//#: Version      : 0.2
//#: Description  : Source code to ccat.
program ccat;

{$MODE OBJFPC}
{$H+}

uses
    SysUtils, RegExpr;

type
    //
    // A syntax file's reg expr. and its color item
    //
    TColorItem = record
        m_color: string;    // color
        m_re: string;       // regular expression
    end;

    //
    // A input line item
    //
    TLineItem = record
        m_i: integer;   // index of item
        m_len: integer; // length of item
        m_pre: string;  // pre color string
        m_post: string; // post color string
    end;

const
    //
    // Version string
    //
    g_version = '0.2';

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

var
    //
    // <syntax>.rc/<syntax>.nanorc color records
    //
    g_colorItems: array [1..1000] of TColorItem;
    g_ciIndex: integer = 1;

    //
    // line items for each input (each line of input)
    //
    g_lineItems: array [1..1000] of TLineItem;
    g_liIndex: integer = 1;

    //
    // Misc
    //
    g_syntax: string;           // given or guessed syntax
    g_filename: string = '';    // filename if file argument
    
//
// RenderHelp
//
// (i): Renders help screen
//
procedure RenderHelp();
begin
    writeln('Usage: ccat [option]');
    writeln('Version: ', g_version);
    writeln('Reads from standard input');
    writeln('<syntax> is a <syntax>.ccrc/<syntax>.nanorc file from ~/.ccat or ~/.nano');
    writeln();
    writeln('  --help               display this help screen and exit');
    writeln('  --syntax=<syntax>    render output using <syntax> syntax');
    writeln();
    writeln('Examples:');
    writeln('  ccat f                          Takes f and guess what syntax should be');
    writeln('  ccat --syntax=pascal f          Takes f and outputs using pascal syntax');
    writeln('  ccat --syntax=pascal < f        Takes f and outputs using pascal syntax');
    writeln('  cat f | ccat --syntax=pascal    Takes f and outputs using pascal syntax');
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
var
    input: string;
    f: textfile;
begin
    if length(g_filename) > 0 then
    begin 
        assignfile(f, g_filename);
        reset(f);

        readln(f,input);
        while not eof(f) do 
        begin
    	    writeln(input);
            readln(f,input);
        end;

        close(f);

        writeln(input);
    end
    else
    begin
        readln(input);
        while not eof do 
        begin
    	    writeln(input);
            readln(input);
        end;
        writeln(input);
    end;
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
                    right := rightstr(temp,length(temp)-temp_item.m_i-temp_item.m_len+1);
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
begin
    IsOkToPostRender := true;
    
    for j := 1 to li do
    begin
        if (j <> li) then
        begin
            if ((i > (g_lineItems[j].m_i)) and (i < (g_lineItems[j].m_i+g_lineItems[j].m_len+length(g_lineItems[j].m_post))))
                or ((i < (g_lineItems[j].m_i)) and ((i+len) > (g_lineItems[j].m_i))) then
            begin
                IsOkToPostRender := false;
                exit;
            end
        end;
    end;
end;

//
// SortLineItemsByIndex
//
// (i): Sorts the g_lineItems array by m_i
//
procedure SortLineItemsByIndex(var items: array of TLineItem; size: integer);
var
    i: integer;
    j: integer;
    index: TLineItem;
begin
    for i := 1 to size-1 do
    begin
        index := items[i];
        j := i;
        while ((j > 0) and (items[j-1].m_i > index.m_i)) do
        begin
            items[j] := items[j-1];
            j := j - 1;
        end;
        items[j] := index;
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
                if (g_lineItems[j].m_i > g_lineItems[i].m_i) and ((g_lineItems[j].m_i + g_lineItems[j].m_len) <= (g_lineItems[i].m_i+g_lineItems[i].m_len)) then
                begin
                    g_lineItems[j].m_i += length(g_lineItems[i].m_pre);
                end
                else if ( g_lineItems[j].m_i > g_lineItems[i].m_i ) then
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
    input: string;
    i: integer = 1;
    max: integer;
    temp: string;
    f: text;
begin
    max := g_ciIndex - 1;

    if length(g_filename) > 0 then
    begin 
        assignfile(f, g_filename);
        reset(f);
    
        readln(f,input);
        
        while not eof(f) do 
        begin
            temp := input;
            for i := 1 to max do
            begin
                PreRenderInput(temp, g_colorItems[i]);
            end;
            SortLineItemsByIndex(g_lineItems,g_liIndex-1);
            temp := PostRenderInput(temp);    
            writeln(temp);
            readln(f,input);
        end;

        close(f);

        temp := input;
        for i := 1 to max do
        begin
            PreRenderInput(temp, g_colorItems[i]);
        end;
        SortLineItemsByIndex(g_lineItems,g_liIndex-1);
        temp := PostRenderInput(temp);
        writeln(temp);
    end
    else
    begin
        readln(input);
        while not eof do 
        begin
            temp := input;
            for i := 1 to max do
            begin
                PreRenderInput(temp, g_colorItems[i]);
            end;
            SortLineItemsByIndex(g_lineItems,g_liIndex-1);
            temp := PostRenderInput(temp);
            writeln(temp);
            readln(input);
        end;

        temp := input;
        for i := 1 to max do
        begin
            PreRenderInput(temp, g_colorItems[i]);
        end;
        SortLineItemsByIndex(g_lineItems,g_liIndex-1);
        temp := PostRenderInput(temp);
        writeln(temp);
    end;
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
        begin
            IsArgIn := true;
            break;
        end;
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
        begin
            GetArgIn := rightstr(paramstr(i),length(paramstr(i))-length(arg)-1);
            break;
        end;
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

    case name of
        'white': TranslateColorNameToColorValue := g_clr_white;
        'black': TranslateColorNameToColorValue := g_clr_black;
        'red': TranslateColorNameToColorValue := g_clr_red;
        'blue': TranslateColorNameToColorValue := g_clr_blue;
        'green': TranslateColorNameToColorValue := g_clr_green;
        'yellow': TranslateColorNameToColorValue := g_clr_yellow;
        'magenta': TranslateColorNameToColorValue := g_clr_magenta;
        'cyan': TranslateColorNameToColorValue := g_clr_cyan;
        'brightwhite': TranslateColorNameToColorValue := g_clr_brightwhite;
        'brightblack': TranslateColorNameToColorValue := g_clr_brightblack;
        'brightred': TranslateColorNameToColorValue := g_clr_brightred;
        'brightblue': TranslateColorNameToColorValue := g_clr_brightblue;
        'brightgreen': TranslateColorNameToColorValue := g_clr_brightgreen;
        'brightyellow': TranslateColorNameToColorValue := g_clr_brightyellow;
        'brightmagenta': TranslateColorNameToColorValue := g_clr_brightmagenta;
        'brightcyan': TranslateColorNameToColorValue := g_clr_brightcyan;
    end;
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
    temp: string;
begin
    if (length(line) > 1) and (line[1] <> '#') then
    begin
        if g_ciIndex < 1000 then
        begin
            temp_item.m_color := '';
            temp_item.m_re := '';
            try
                try
                    re := TRegExpr.Create('(icolor|color)[ ]+(.*)[ ]+"(.*)"');
                    if re.Exec(line) then
                    begin
                        temp := re.Match[2];
                        temp := trim(temp);

                        temp_item.m_color := TranslateColorNameToColorValue(temp);
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
// (i): Loads syntax information from 1) ~/.ccat/<syntax>.rc, then 
//      if not found 2) ~/.nano/<syntax>.nanorc
//
function LoadSyntaxNanoRc() : boolean;
var
    fname: string;
    fnrc: textfile;
    line: string;
begin
    LoadSyntaxNanoRc := false;

    // First check ~/.ccat/<g_syntax>.rc
    fname := getuserdir();
    fname += '.ccat/';
    fname += g_syntax;
    fname += '.ccrc';
    if fileexists(fname) then
    begin
        assign(fnrc, fname);
        reset(fnrc);

        while not eof(fnrc) do
        begin
            readln(fnrc, line);
            AddItemToColorArray(line);
        end;

        close(fnrc);

        LoadSyntaxNanoRc := true;
    end    
    else // else check ~/.nano/<g_syntax>.nanorc
    begin
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
       
            close(fnrc);
        
            LoadSyntaxNanoRc := true;
        end
    end;
end;

//
// GetArgFileName
//
// (i): First argument not known is estimated to be filename
//
function GetArgFileName() : string;
var
    i: integer;
begin
    GetArgFileName := '';

    for i := 1 to paramcount do
    begin
        if (pos('--syntax', paramstr(i)) = 0) and (pos('--help', paramstr(i)) = 0) then
        begin        
            if fileexists(paramstr(i)) then 
            begin
                GetArgFileName := paramstr(i);
                break;
            end;
        end;
    end;
end;

//
// GuessSyntax
//
// (i): Guess syntax from filename
//
function GuessSyntax(fname: string) : string;
var
    re: TRegExpr;
    ext: string;
begin
try
    try
        re := TRegExpr.Create('\.[A-Za-z_]+$');
        if re.Exec(fname) then
        begin
            ext := LowerCase(re.Match[0]);
            
            case ext of
                '.pas': GuessSyntax := 'pascal';
                '.ino': GuessSyntax := 'arduino';
                '.asm': GuessSyntax := 'asm';
                '.awk': GuessSyntax := 'awk';
                '.bat': GuessSyntax := 'batch';
                '.cmd': GuessSyntax := 'batch';
                '.c': GuessSyntax := 'c';
                '.cpp': GuessSyntax := 'c';
                '.h': GuessSyntax := 'c';
                '.hpp': GuessSyntax := 'c';
                '.cmake': GuessSyntax := 'cmake';
                '.coffee': GuessSyntax := 'coffescript';
                '.cs': GuessSyntax := 'csharp';
                '.css': GuessSyntax := 'css';
                '.csv': GuessSyntax := 'csv';
                '.f': GuessSyntax := 'fortran';
                '.f90': GuessSyntax := 'fortran';
                '.ff95': GuessSyntax := 'fortran';
                '.go': GuessSyntax := 'go';
                '.hs': GuessSyntax := 'haskell';
                '.java': GuessSyntax := 'java';
                '.js': GuessSyntax := 'js';
                '.json': GuessSyntax := 'json';
                '.kt': GuessSyntax := 'kotlin';
                '.kts': GuessSyntax := 'kotlin';
                '.el': GuessSyntax := 'lisp';
                '.lisp': GuessSyntax := 'lisp';
                '.scm': GuessSyntax := 'lisp';
                '.ss': GuessSyntax := 'lisp';
                '.pl': GuessSyntax := 'perl';
                '.pm': GuessSyntax := 'perl';
                '.py': GuessSyntax := 'python';
                '.rb': GuessSyntax := 'ruby';
                '.rs': GuessSyntax := 'rust';
                '.sql': GuessSyntax := 'sql';
                '.swift': GuessSyntax := 'swift';
                '.txt': GuessSyntax := 'text';
                '.text': GuessSyntax := 'text';
                '.xml': GuessSyntax := 'xml';
                '.repo': GuessSyntax := 'yum';
                '.yml': GuessSyntax := 'yaml';
                '.yaml': GuessSyntax := 'yaml';
            else
                GuessSyntax := 'text';
            end;
        end;
    except
    end;
    finally
        re.Free();
    end;
end;

//
// program block
//
begin
    if (paramcount = 0) then                   // No arguments show help screen
        RenderHelp()
    else if (paramcount = 1) and IsArgIn('--help') then         // One argument and is --help so show help screen
    begin
        RenderHelp();
    end
    else if (paramcount = 1) and IsArgIn('--syntax') then       // One argument is syntax and assume input from stdin
    begin
        g_syntax := GetArgIn('--syntax');       // Get syntax
        if LoadSyntaxNanoRc()                   // Load <syntax>.rc/<syntax>.nanorc and check if ok
        then RenderColored()                    // Render colored all looks good
        else RenderRaw();                       // Render raw
    end
    else if (paramcount = 1) and not IsArgIn('--syntax') then   // One argument no syntax so assume filename
    begin
        g_filename := GetArgFileName();         // Get FileName argument
        g_syntax := GuessSyntax(g_filename);    // Guess syntax
        if length(g_syntax) > 0 then 
        begin
            if LoadSyntaxNanoRc()               // Load <syntax>.rc/<syntax>.nanorc and check if ok
            then RenderColored()                // Render colored all looks good
            else RenderRaw();                   // Render raw
        end
        else RenderRaw();                       // Render raw
    end
    else if (paramcount = 2) and IsArgIn('--syntax') then       // Two arguments and assume filename and given syntax
    begin
        g_syntax := GetArgIn('--syntax');       // Get syntax
        g_filename := GetArgFileName();         // Get FileName argument
        if length(g_filename) = 0 
        then RenderRaw()                        // Render raw
        else
        begin
            if LoadSyntaxNanoRc()               // Load <syntax>.rc/<syntax>.nanorc and check if ok
            then RenderColored()                // Render colored all looks good
            else RenderRaw();                   // Render raw
        end
    end
end.

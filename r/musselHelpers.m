


urldecode(val)
	;
	; Decoded a URL Encoded string
	;
	new decoded,c,i

	set decoded=""
	for i=1:1:$zlength(val) do
	.	set c=$zextract(val,i,i)
	.	if c="+" set decoded=decoded_" "
	.	else  if c'="%" set decoded=decoded_c
	.	else  set decoded=decoded_$zchar($$FUNC^%HD($zextract(val,i+1,i+2))) set i=i+2
	quit decoded

urlencode(val)
	;
	; Encoded a string for URL usage
	;
	new encoded,c,i,safechar
	set encoded=""

	; Populate safe char only the first time
	if '$data(safechar) for i=45,46,95,126,48:1:57,65:1:90,97:1:122 set safechar($zchar(i))=""

	for i=1:1:$zlength(val) do
	.	set c=$zextract(val,i,i)
	.	if $data(safechar(c)) set encoded=encoded_c
	.	else  if c=" " set encoded=encoded_"+"
	.	else  set encoded=encoded_"%"_$$FUNC^%DH($zascii(c),2)

	quit encoded



escape(txt)
	;
	; Return an escaped JSON string
	;
	new escaped,i,a
	set escaped=""
	for i=1:1:$zlength(txt) do
	.	set a=$zascii(txt,i)
	.	if ((a>31)&(a'=34)&(a'=92)) set escaped=escaped_$zchar(a)
	.	else  set escaped=escaped_"\u00"_$$FUNC^%DH(a,2)

	quit escaped

jsonencode(arr)
    n quo s quo=""""
    q:$d(@arr)=0 "" ;If supplied array doesn't exist, return an empty string
    n json,test
    s test=$O(@arr@(""))

    i test="" d  q json  
    . ;Simple key/value pair
    . s json=json_"{"
    . s json=json_quo_sub_quo_":"
    . s json=json_quo_$$escape(@arr)_quo
    . s json=json_"}" 

    i test']]"a" d  q json  
    . ;List/array
    . s json=json_"["
    . n sub,comma
    . f  s sub=$O(@arr@(sub)) q:sub=""  d
    . . s:comma json=json_","  
    . . s json=json_$$jsonencode($na(@arr@(sub)))
    . . s comma=1
    . s json=json_"]" 

    e  d  q json
    . ;Object
    . s json=json_"{"
    . n sub,comma
    . f  s sub=$O(@arr@(sub)) q:sub=""  d
    . . s:comma json=json_","  
    . . s json=json_quo_sub_quo_":"
    . . i $d(@arr@(sub))'=10 s json=json_quo_$$escape(@arr@(sub))_quo
    . . e  s json=json_$$jsonencode($na(@arr@(sub)))
    . . s comma=1
    . s json=json_"}" 
    q json


jsondecode(json,ary,error)
    n at,c,ref
    d next(json,.at,.c)
    w !,$$value(json,.at,.c,.error,.ary,ref)
    w !,error
    q

next(json,at,c,mode)
    s at=at+1
    s c=$E(json,at)
    w !,at,$C(9),c
    i (mode'=1)&(c="") d next(json,.at,.c)
    q

value(json,at,c,error,ary,ref)
    if c="{" q $$object(json,.at,.c,.error,.ary,ref)
    if c="[" q $$array(json,.at,.c,.error,.ary,ref)
    if c="""" q $$string(json,.at,.c,.error)
    if c="t" q $$bool(json,.at,.c,.error)
    if c="f" q $$bool(json,.at,.c,.error)
    if c="n" q $$nully(json,.at,.c,.error)
    if (c="-")!(c?1N) q $$number(json,.at,.c,.error)
    s error="Couldn't determine value type at "_c
    q

nully(json,at,c,error)
    n val,i
    f i=1:1:4 d  
    . s val=val_c
    . d next(json,.at,.c)
    w !,val
    q:val="null" ""
    s error="Bad Null"_at_c
    q

bool(json,at,c,error)
    n val,i
    i c="t" d  
    . f i=1:1:4 d  
    . . s val=val_c
    . . d next(json,.at,.c)
    . w !,val
    i c="f" d  
    . f i=1:1:5 d
    . . s val=val_c
    . . d next(json,.at,.c)
    . w !,val
    q:val="true" 1
    q:val="false" 0 
    s error="Bad Bool"_at_c
    q

number(json,at,c,error)
    n val,i
    f  d  q:(c="")!(c'?.(1N,1"-",1"E",1"e",1"."))
    . s:c="e" c="E"
    . s val=val_c
    . d next(json,.at,.c)
    q +val

string(json,at,c,error)
    n val,i
    d next(json,.at,.c) ;Skip the opening quote
    f  d  q:(c="")!(c="""")
    . ;Need to handle escape chars
    . s val=val_c
    . d next(json,.at,.c,1)
    i c="" s error="String never closed"_at_c q
    d next(json,.at,.c)
    q val

array(json,at,c,error,ary,ref)
    n i
    s:ref="" ref=$na(ary)
    w !,ref
    i c'="[" s error="Array should start with bracket" q
    f i=0:1 d  q:(c'=",")
    . d next(json,.at,.c)
    . s @ref@(i)=$$value(json,.at,.c,.error,.ary,$na(@ref@(i)))
    i c="]" d next(json,.at,.c)
    q
object(json,at,c,error,ary,ref)
    n key,val
    s:ref="" ref=$na(ary)
    i c'="{" s error="Object should start with brace" q
    d next(json,.at,.c)
    i c="}" d next(json,.at,.c) q ""
    f  d  q:(c'=",")!(error'="")
    . ZSH "S"
    . s key=$$string(json,.at,.c,.error)
    . w !,key
    . i c'=":" s error="Need a colon in object defs: "_at q
    . d next(json,.at,.c)
    . s @ref@(key)=$$value(json,.at,.c,.error,.ary,$na(@ref@(key)))
    q
; var object = function() {
;   // ch is at opening curley brace, create & return the object
;   var object = {};
;   if(ch !== '{') error('object should start with {');
;   if(next() === '}') return object; // empty object

;   do {
;     var key = string(); // get key
;     if(ch !== ':') error('object property expecting ":"');
;     next();
;     object[key] = value(); // create property with whatever value is, perhaps another object/array
;     if(ch === '}') {  // object end reached
;       next();
;       return object;
;     }
;   } while(ch && ch === ',' && next()); // found ',' => more properties to go

;   error('bad object');
; };

test
    n json,at,c,error,ary,ref
    s json="{""hello"": {}, ""smart"":3}"
    s at=1,c=$E(json)
    d object^musselHelpers(json,.at,.c,.error,.ary,ref)
    w !
    zwrite ary
    k ^FET
    m ^FET=ary
    q

lexstring(string)
    n return,quo,c
    q:$E(string)'?1(1"""",1"'")
    s string=$E(string,2,$L(string))
    f c=0:1 d  q:$E(string,c)?1(1"""",1"'")
    s return=$E(string,1,c-1)
    s string=$E(string,c+1,$L(string))
    q return

lexnumber(string)
    n return,quo,c
    q:$E(string)'?1(1N)
    w !,"it's a number"
    f c=1:1 d  q:$E(string,c)'?1N
    s return=$E(string,1,c-1)
    s string=$E(string,c+1,$L(string))
    q return

; def lex_number(string):
;     json_number = ''

;     number_characters = [str(d) for d in range(0, 10)] + ['-', 'e', '.']

;     for c in string:
;         if c in number_characters:
;             json_number += c
;         else:
;             break

;     rest = string[len(json_number):]

;     if not len(json_number):
;         return None, string

;     if '.' in json_number:
;         return float(json_number), rest

;     return int(json_number), rest


; def lex_bool(string):
;     string_len = len(string)

;     if string_len >= TRUE_LEN and \
;          string[:TRUE_LEN] == 'true':
;         return True, string[TRUE_LEN:]
;     elif string_len >= FALSE_LEN and \
;          string[:FALSE_LEN] == 'false':
;         return False, string[FALSE_LEN:]

;     return None, string


; def lex_null(string):
;     string_len = len(string)

;     if string_len >= NULL_LEN and \
;          string[:NULL_LEN] == 'null':
;         return True, string[NULL_LEN]

;     return None, string


; def lex(string):
;     tokens = []

;     while len(string):
;         json_string, string = lex_string(string)
;         if json_string is not None:
;             tokens.append(json_string)
;             continue

;         json_number, string = lex_number(string)
;         if json_number is not None:
;             tokens.append(json_number)
;             continue

;         json_bool, string = lex_bool(string)
;         if json_bool is not None:
;             tokens.append(json_bool)
;             continue

;         json_null, string = lex_null(string)
;         if json_null is not None:
;             tokens.append(None)
;             continue

;         c = string[0]

;         if c in JSON_WHITESPACE:
;             # Ignore whitespace
;             string = string[1:]
;         elif c in JSON_SYNTAX:
;             tokens.append(c)
;             string = string[1:]
;         else:
;             raise Exception('Unexpected character: {}'.format(c))

;     return tokens





; matchFirstLast(string,first,last)
;     q ($E(string)=first)&($E(string,$L(string))=last)

; isArray(string,first,last)
;     q $$matchFirstLast(string,"[","]")
; isObject(string,first,last)
;     q $$matchFirstLast(string,"{","}")
; hasDoubleQuotes(string,first,last)
;     q $$matchFirstLast(string,"""","""")
; hasSingleQuotes(string,first,last)
;     q $$matchFirstLast(string,"'","'")

; jsondecode(json,arr,start)
;     ; Modes:
;     ; 0     default ; trying to find a new object or a new array
;     ; 1     keysearch
;     ; 11    keyread
;     ; 2     valuesearch
;     ; 22    value 
;     n quo s quo=""""
;     s:start="" start=1
;     w !,"newobject"
;     n idx,cur,mode,key,val,depth,aref,done
;     s mode=0,depth=0,aref=$NA(arr)
;     f idx=1:1:$L(json) q:done  d  
;     . q:$A(json,idx)<32
;     . s cur=$E(json,idx)
;     . i cur="{"

;     q




    ; . w !,idx,?5,mode,?10,depth,?15,cur,?20,aref
    ; . q:cur=quo
    ; . i (mode=0)&(cur="{") s mode=1 q   ;Start looking for a key
    ; . i (mode=1)&($A(cur)>32) s mode=11 k key   ; We found a keystart
    ; . i (mode=11)&(cur=":") s mode=2 q   ; End keyread, start searching for value
    ; . i (mode=2)&(cur="{") s depth=depth+1,mode=1,aref=aref_"/"_key q  
    ; . i (mode=2)&($A(cur)>32) s mode=22 k val   ; We found a valuestart
    ; . i (mode=22)&(cur=",") s arr(depth,key)=val,mode=1 q  ; End keyread, start searching for value
    ; . i (mode=22)&(cur="{") s depth=depth+1,mode=1 q  ;recurse
    ; . i (mode=22)&(cur="}") s arr(depth,key)=val,depth=depth-1,mode=1 q  ;recurse
    ; . ;
    ; . ;i cur="}" s arr(depth,key)=val,mode=0 q  ;Back to basics
    ; . i mode=11 s key=key_cur w ?40,key
    ; . i mode=22 s val=val_cur w ?40,key,?60,val

    ; q

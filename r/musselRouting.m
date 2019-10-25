;Comment
;findRoutes
; ASSUMES: TCPIO, the current connected socket
findRoutes(routes)
    d SILENT^%RSEL("*","SRC") ; A way of getting a list of routine names
    n i,x,curro
    s curro=""
    for  s curro=$O(%ZR(curro)) q:curro=""  d  
    . for i=1:1 X "set x=$text(+i^"_curro_")" quit:x=""  d
    . . d:$E(x,1,2)=";@"
    . . . n path,tagln,offs
    . . . s path=$E(x,4,$L(x));;$P(x,"/",2,$L(x))
    . . . s offs=i+1
    . . . X "s tagln=$text(+offs^"_curro_")"
    . . . s routes(path)=$P(tagln,"(",1)_"^"_curro
    u 0 u TCPIO ; Assumes TCPIO from the calling context. For some reason ^%RSEL will use 0 otherwise.
    q
;Here we have the path, that's the actual URL, and the route, that's the current potential thing evaluating 
matchRoute(request,response,routes) ; u 0
    n path,routine,route,args,done,method
    s path=request("path")
    F  S route=$O(routes(route)) q:route=""  d  q:done  
    . n matchPath,cnt,fail,args
    . S matchPath=$P(route," ",2)
    . ;w !,!,route,$L(matchPath,"/")'=$L(path,"/")
    . q:$L(matchPath,"/")'=$L(path,"/") ; must have same number segments
    . ; If the potential match does have the same number of segments, evaluate each segment
    . for cnt=1:1:$L(path,"/") D  Q:fail
    . . n pathSeg,matchPathSeg,pattern,matchPathVar  
    . . S pathSeg=$P(path,"/",cnt) ;$$URLDEC^VPRJRUT($P(path,"/",I),1)
    . . S matchPathSeg=$P(matchPath,"/",cnt) ;$$URLDEC^VPRJRUT($P(pattern,"/",I),1)
    . . ;w !,pathSeg,"=",matchPathSeg
    . . I $E(matchPathSeg)'="{" S fail=($$FUNC^%LCASE(pathSeg)'=$$FUNC^%LCASE(matchPathSeg)) Q ; Literal path; doesn't contain curlies
    . . I $E(matchPathSeg)="{" S matchPathSeg=$E(matchPathSeg,2,$L(matchPathSeg)-1) ; get rid of curly braces
    . . ;w !,matchPathVar
    . . S matchPathVar=$P(matchPathSeg,"?"),pattern=$P(matchPathSeg,"?",2) ; Get just the variable part, before the pattern
    . . I $L(pattern) S fail=(pathSeg'?@pattern) Q:fail ; If there's a pattern, try to match it. If no match then fail
    . . s args(matchPathVar)=pathSeg
    . q:fail
    . ;If we haven't quit yet then this is the routine
    . S routine=routes(route),method=$P(route," ")
    . ;Last check: the method has to match
    . q:method'=request("method")
    . s done=1
    . M request("args")=args
    ;u 0 w !,"routine: ",routine,!,"route ",route u TCPIO
    i routine'="",method'=request("method") s response="HTTP/1.1 405 Method Not Allowed",response("body")="405 Method Not Allowed" quit; must be the same method
    i routine="" s response="HTTP/1.1 404 Not Found",response("body")="404 Page Not Found" quit
    X "d "_routine_"(.request,.response)"
    QUIT
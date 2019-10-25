; musselResponse
; response object:
;    response="HTTP/1.1 200 OK"
;    response("body")="{""key"":""value""}"
;    response("headers","Content-Length")=15
;    response("headers","Date")="SAT, 01 DEC 2018 20:57:02 GMT"
;    response("headers","Server")="Mussel/0.1GT.M V6.3-005 Linux x86_64"

response(request,routes)
    n del,response,header;,path
    s del=$C(13,10) ; The bang operator doesn't work in here because the socket is in nodelim mode. Force CRLF as a delimiter
    s response="HTTP/1.1 200 OK"
	s response("headers","Date")=$zdate($$localToGMT(),"DAY, DD MON YEAR 24:60:SS ")_"GMT"
    s response("headers","Server")="Mussel/0.1 "_$ZV
    s response("headers","Cache-Control")="no-cache"
    
    ; Find the appropriate route for the request
    d matchRoute^musselRouting(.request,.response,.routes)
    
    s response("headers","Content-Length")=$L(response("body"))
    ;Write the response out to the socket
    ;U 0 w ! zwr request w ! zwr response u TCPIO
    ; Write response line, like "HTTP/1.1 200 OK" 
    w response
    w del
    ; Write all the headers
    f  s header=$O(response("headers",header)) q:header=""  d  
    . w header_": "_response("headers",header)_del
    w del
    ; Write the body
    w response("body")
    q

localToGMT()
    n dt,tm,off,diff
    set dt=$piece($zh,",",1)     ; Date
    set tm=$piece($zh,",",2)     ; Second in local
    set off=$piece($zh,",",4)    ; Offset
    set diff=tm+off
    if diff>86400 set dt=dt+1,tm=diff-86400     ; 86400 seconds in a day
    else  if diff<1 set dt=dt-1,tm=tm+86400
    else  set tm=diff
    q (dt_","_tm)

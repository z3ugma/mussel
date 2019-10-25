;FTWEB

main(port)
    U 0
    w $C(27)_"[0m"
    VIEW "NOUNDEF"
    S $ET="goto errorTrap^FTWEB"
    ;s $ET="BREAK"
    
    n stop,key,timeout,quit,tries,requestsocket,sockdev,con,contentlength,body,ip,request,routes
    s quit=0
    s timeout=45
    w !,"Process ID: ",$J
    S port=$G(port,9080)
    ;
    ; Device ID
    S TCPIO="SCK$"_port
    ;
    ; Open Code
    C TCPIO ; Close if the socket was still open from the last run
    
    O TCPIO:(LISTEN=port_":TCP":delim=$C(13,10):attach="listener"):15:"socket"
    E  U 0 W !,"Error: cannot open port "_port,", is another process using it?",! Q
    U TCPIO
    W /LISTEN(50)
    U 0 W !,"Listening on port "_port U TCPIO
loop ; wait for a connection, switch to the connection socket, process the connection, go back to listening
    f  d  
    . k body,requestsocket,ip,request,routes
    . U TCPIO:(socket="listener")
    . s requestsocket=$$awaitConnection(TCPIO,.ip) i requestsocket="" C TCPIO Q
    . ;Switch from the listen socket to the connected socket
    . U TCPIO:(socket=requestsocket:delim=$C(13,10))
    . U 0 d findRoutes^musselRouting(.routes) U TCPIO
    . d parseRequestLine(TCPIO,ip,.request)
    . d getHeaders(.request)
    . U TCPIO:(nodelim) ; Switch to no delim mode to read the body 
    . d getBody(.request)
    . ;u 0 w ! zwr request u TCPIO
    . d response^musselResponse(.request,.routes)
    . C TCPIO:(socket=requestsocket)
    C TCPIO 
    q

awaitConnection(io,ip)
    use io
    new key,con,done,requestsocket
    for  do  quit:done
    . if 0
	. write /wait(timeout)
    . set con=$TEST
    . if con  do  
    . . set key=$key
    . . set requestsocket=$P(key,"|",2)
    . . set done=1 quit
    s ip=$$writeIP(key)
    quit requestsocket

parseRequestLine(io,ip,request)
    n line,uri,params,pmcnt,end,parstr,cnt,key
    u io
    ;Read first line of header
    r line:timeout i '$T C TCPIO Q
    ;Switch to terminal and write it
    u 0 w !,ip,?15,$zdate($H,"YYYY-MM-DD 24:60:SS"),?35,$P(line," ",1,1),?41,$P(line," ",2,2) U io
    s request("method")=$P(line," ")
    s uri=$$urldecode^musselHelpers($P(line," ",2,2))
    s request("path")=$P(uri,"?",1)
    s params=$P(uri,"?",2)
    s pmcnt=$L(params,"&")
    f i=1:1:pmcnt d
    . s end=$F(params,"&")
    . s:end=0 end=$L(params)+2
    . s parstr=$E(params,1,end-2)
    . s key=$P(parstr,"=",1)
    . s cnt=$D(request("queryparams",key,0))
    . s cnt=cnt+1
    . s:parstr request("queryparams",key,cnt)=$P(parstr,"=",2)
    . s:parstr request("queryparams",key,0)=cnt
    . s params=$E(params,end,$L(params)) 
    q

getHeaders(request)
    ;Read rest of header
    n done,contentlength
    for  quit:done  do ; Read until we hit a blank line
    . k line
    . R line:timeout i '$T C TCPIO Q
    . i $L(line)=0 s done=1 q
    . s request("headers",$$FUNC^%LCASE($P(line,":")))=$P(line," ",2,9999)
    q

getBody(request)
    ;Read Body
    n line,contentlength
    s contentlength=request("headers","content-length")
    i contentlength>0 R line#contentlength:timeout i '$T C TCPIO Q
    s request("body")=line
    q 

writeIP(key)
    n ip
    s ip=$P(key,"|",3)
    s:$P(ip,":",3)="ffff" ip=$P(ip,":",4)
    q ip

errorTrap
    U TCPIO
    W "HTTP/1.1 500 Internal Server Error",$C(13,10),$C(13,10),"Internal Server Error",!
    C TCPIO
    U 0
    w $C(27)_"[31:0m" ; Make screen red
    w !,!,!,$ZSTATUS
    N %LVL,%TOP,%N
    S %TOP=$STACK(-1),%N=0
    F %LVL=0:1:%TOP S %N=%N+1 w !,$STACK(%LVL,"PLACE")_":"_$STACK(%LVL,"MCODE")
    w $C(27)_"[0:0m" ; Reset screen
    w !,!
    HALT
    Q


;i cnt=1 u 0 w !,$$writeIP(key),?15,$$FUNC^%D," ",$$time($H),?35,$P(line," ",1,1),?41,$P(line," ",2,2)
;i cnt=1 u 0 w $C(27)_"[1;31m",!,$$writeIP(key),?15,$$FUNC^%D," ",$$time($H),?35,$P(line," ",1,1),?41,$P(line," ",2,2),$C(27)_"[0m"
;u 0 w !,$$writeIP(key),?15,$zdate($horolog,"YYYY-MM-DD 24:60:SS"),?40,line;$P(line," ",1,2)
;w $C(27)_"[38:5:22m" ; Make screen red


;@ GET /echo
echo(request,response)
    n ln
    s ln="request"
    f  s ln=$Q(@ln) q:ln=""  d  
    . s response("body")=response("body")_ln_": "_$G(@ln,0)_$C(13,10)
    q

;@ GET /random
random(request,response)
    s response("body")=$R(1000)
    q

;@ GET /g/{global}
global(request,response)
    s response("headers","Content-Type")="text/plain"
    n ln,glo
    s glo=request("args","global")
    s ln="^"_glo
    f  s ln=$Q(@ln) q:ln=""  d  
    . s response("body")=response("body")_ln_": "_$G(@ln,0)_$C(13,10)
    q

;@ GET /allroutes
allroutes(request,response)
    n routes,ro,ln,method,path,sorted,p,m
    d findRoutes^musselRouting(.routes)
    f  s ro=$O(routes(ro)) q:ro=""  d  
    . s method=$P(ro," ")
    . s path=$P(ro," ",2)
    . s sorted(path,method)=routes(ro)
    f  s p=$O(sorted(p)) q:p=""  d  
    . f  s m=$O(sorted(p,m)) q:m=""  d  
    . . s response("body")=response("body")_p_" "_m_": "_sorted(p,m)_$C(13,10)
    q

;@ GET /req/{par1}/{par2?.N}
req(request,response)
    n ln
    s ln="request"
    f  s ln=$Q(@ln) q:ln=""  d  
    . s response("body")=response("body")_ln_": "_$G(@ln,0)_$C(13,10)
    q

;@ POST /update
update(request,response)
    n glo,val
    s glo=$P(request("body"),"^",1,2)
    s val=$P(request("body"),"^",3)
    s @glo=val
    s response("body")=glo_$C(13,10)_val
    q

;@ DELETE /update
delete(request,response)
    s response("body")="Deleted"
    q

;@ GET /static/{asset}
static(request,response)
    ;s response("headers","Content-Type")="image/png"
    s sd=request("args","asset")
    open sd:(fixed:wrap:readonly:chset="M")
    for  use sd read line:timeout quit:$zeof  d  
    . s response("body")=line
    close sd
    U TCPIO
    q

;@ GET /
index(request,response)
    s request("args","asset")="index.html"
    d static(.request,.response)
    q

;@ GET /json/{glo}
json(request,response)
    n glo
    s response("headers","Content-Type")="application/json"
    s glo="^"_$$urldecode^musselHelpers(request("args","glo"))
    s response("body")=$$jsonencode^musselHelpers(glo)
    q

;@ POST /json
jdc(request,response)
    s response("body")=""
    n ary,error
    u 0
    d jsondecode^musselHelpers(request("body"),.ary,.error)
    s response("body")=error_$C(13,10)_$C(13,10)

    u 0 
    s ln=$na(ary)
    f  s ln=$Q(@ln) q:ln=""  d  
    . s response("body")=response("body")_ln_": "_$G(@ln,0)_$C(13,10)
    w !,response("body") u TCPIO
    u TCPIO
    q
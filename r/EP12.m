EP12    
    WRITE !,"THIS IS ",$TEXT(+0)
    USE $P:(EXCEPTION="D BYE":CTRAP=$C(3))
    WRITE !,"TYPE <CTRL-C> TO STOP"
LOOP
    FOR  DO  
    . READ !,"TYPE A NUMBER: ",X
    . WRITE ?20,"NUM",X
BYE     
    WRITE !,"YOU TYPED <CTRL-C> YOU MUST BE DONE!"
    USE $P:(EXCEPTION="":CTRAP="")
    WRITE !,"$ZSTATUS=",$ZSTATUS
    ZGOTO 1
return function(J,Rules,Config)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 check(type(J.selection)=="function","Throw selection must be validated on the server")
 check(J.selection(150,50)==50 and J.selection(150,151)==nil,"Earlier biome allowed, over-power refused")
 for _,bad in {0/0,math.huge,-1,0,"100"}do check(J.selection(150,bad)==nil,"Invalid selection refused")end
 check(J.selection(.5,.5)==.5 and J.selection(0,0)==0,"Low legacy power remains valid")
 check(math.abs(J.distance(150,50,.1)-55)<1e-8 and J.distance(150,50,-.05)==47.5,"Bonus applies to chosen strength")
 check(math.abs(J.distance(150,50,999)-55)<1e-8 and J.distance(150,50,-999)==47.5,"Bonus cannot escape config cap")
 check(J.perfect(.1)and not J.perfect(0),"Perfect uses top of meter only")
 local reward=Rules.reward(1,3,1,"paper");check(J.odds(reward,"paper")==43,"Epic specific car odds include car selection")
 check(J.odds(reward,"pink")<43,"Ticket luck improves displayed odds consistently")
 return n.." juice assertions passed"
end

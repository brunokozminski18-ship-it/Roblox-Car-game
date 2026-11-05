return function(Index,Codec)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 local writes,reads=0,0;local listBudget,writeBudget=5,10;local fail=false;local db={}
 local store={SetAsync=function(_,key,value)if fail then error("throttle")end;writes+=1;db[key]=value end,
 GetSortedAsync=function(_,ascending,count)
  check(ascending==false and count==10,"Top10 descending only");reads+=1;if fail then error("throttle")end
  local rows={};for k,v in db do table.insert(rows,{key=k,value=v})end;table.sort(rows,function(a,b)return a.value>b.value end)
  return {GetCurrentPage=function()return rows end}
 end}
 local api=Index.new({TopMoney=store},function(kind)return if kind=="list"then listBudget else writeBudget end,1)
 api.queue(1,{TopMoney=100});api.queue(2,{TopMoney=300});api.queue(3,{TopMoney=200})
 check(api.write(0)and not api.write(.5)and writes==1,"Writes staggered")
 api.write(1);api.write(2);check(writes==3,"Three QA profiles mirrored")
 local rows,ok=api.read("TopMoney",10);check(ok and #rows==3 and rows[1].UserId==2 and rows[3].UserId==1,"Sorted QA profiles")
 api.queue(1,{TopMoney=100});check(not api.write(3)and writes==3,"Unchanged score skipped")
 api.queue(1,{TopMoney=0});writeBudget=0;check(not api.write(4)and writes==3,"No write when budget exhausted")
 writeBudget=10;check(api.write(5)and db.u_1==0,"Zero score corrects sold/spent state")
 listBudget=0;local cached,success=api.read("TopMoney",10);check(not success and cached==rows and reads==1,"No read at zero budget, cache kept")
 listBudget=5;fail=true;cached,success=api.read("TopMoney",10);check(not success and cached==rows,"Throttled read keeps cache")
 api.queue(2,{TopMoney=99});check(not api.write(6)and next(api.pending)~=nil,"Failed write remains queued")
 fail=false;check(not api.write(7)and api.write(16)and db.u_2==99,"Failed writes back off and retry")
 api.queue(2,{TopMoney=50});api.queue(2,{TopMoney=99});check(next(api.pending)==nil,"Returning to last written value cancels a stale pending write")
 local callback
 local racingStore={SetAsync=function(_,key,value)if callback then local fn=callback;callback=nil;fn()end;db[key]=value end}
 local race=Index.new({TopMoney=racingStore},function()return 10 end,1)
 race.queue(4,{TopMoney=100});race.write(0);race.queue(4,{TopMoney=200})
 callback=function()race.queue(4,{TopMoney=100})end
 race.write(1);check(next(race.pending)~=nil,"Latest correction survives in-flight write")
 race.write(2);check(db.u_4==100,"In-flight write cannot erase latest profile value")
 local updates=0
 local monotonic={UpdateAsync=function(_,key,transform)updates+=1;db[key]=transform(db[key])end}
 db.u_5=40000
 local best=Index.new({LuckiestCatch=monotonic},function()return 10 end,1,{LuckiestCatch=true})
 best.queue(5,{LuckiestCatch=5});check(best.write(0)and db.u_5==40000 and updates==1,"Old server cannot lower historical luck")
 race.cache.TopMoney={{UserId=4,Value=200}}
 race.reconcile(4,{TopMoney=100},10);check(next(race.pending)~=nil,"Read detects stale external overwrite despite unchanged profile")
 race.write(3);check(db.u_4==100,"Current profile repairs stale visible index")
 race.cache.TopMoney={{UserId=1,Value=1}}
 race.reconcile(4,{TopMoney=100},10);check(next(race.pending)~=nil,"Missing eligible top10 player is reindexed")
 local ordered={UpdateAsync=function(_,key,transform)if callback then local fn=callback;callback=nil;fn()end;local value=transform(db[key]);if value~=nil then db[key]=value end end}
 local versioned=Index.new({TopMoney=ordered,MostCars=ordered},function()return 10 end,1,nil,{TopMoney=true,MostCars=true})
 versioned.queue(8,{TopMoney=500},2);versioned.write(0);local newest=db.u_8
 versioned.queue(8,{TopMoney=10},1);versioned.write(1)
 check(db.u_8==newest,"Late old server cannot lower offline player's money")
 versioned.queue(8,{TopMoney=900},1);versioned.write(2)
 check(db.u_8==newest,"Late old server cannot inflate offline player's money")
 versioned.queue(8,{TopMoney=20},3);versioned.write(3)
 check(db.u_8<newest,"New session can legitimately spend money")
 versioned.queue(8,{TopMoney=20},4);check(next(versioned.pending)~=nil,"Same score on rejoin still publishes new generation")
 versioned.write(4);check(db.u_8%Codec.Base==4,"Same score stores latest generation")
 versioned.queue(8,{TopMoney=20},5);callback=function()versioned.queue(8,{TopMoney=20},6)end
 versioned.write(5);check(next(versioned.pending)~=nil,"In-flight same score cannot erase newer generation")
 versioned.write(6);check(db.u_8%Codec.Base==6,"Newest pending generation survives and commits")
 for _,amount in {0,1,999999,1000000,1000001,123456789,1e12,1e15}do
  local packed=Codec.pack("TopMoney",amount,99999997)
  local decoded,generation=Codec.unpack("TopMoney",packed)
  check(packed<9007199254740991 and generation==99999997,"Packed score and session fit exact integer range")
  check(math.abs(decoded-amount)<=math.max(1,amount*.000003),"Money encoding within three parts per million")
 end
 local fresh=Index.new({TopMoney=store},function()return 0 end,1);check(fresh.read("TopMoney",10)==nil,"No cache returns nil for local fallback")
 return n.." leaderboard assertions passed"
end

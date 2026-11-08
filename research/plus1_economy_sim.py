"""Offline +1 model. Reads numeric GameConfig fields; no network or Roblox runtime.
Run: python research/plus1_economy_sim.py
16 studs/s, 0.25s server ticks, travel, 3s wall cooldown, integer Currency.Earn.
Policy: buy next gear; fill three pet slots per world; strongest three equipped.
Rebirth only if time saved to the next boss exceeds rebuilding lost Power.
Optional rewards (Daily/Tasks/codes) excluded. Not a prediction of player behaviour.
"""
from pathlib import Path
import csv
import math
import random
import re
from functools import cache
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'games/_TEMPLATE/reports/codex_night3'
SOURCE = (ROOT / 'template/src/shared/GameConfig.luau').read_text(encoding='utf-8')

@cache
def number(key, source=SOURCE):
    return float(re.search(r'\b' + key + r'\s*=\s*([\d.]+)', source)[1])

CORE = SOURCE.split('Config.PlusOne = {')[1].split('Config.Analytics')[0]
FORMS = [(float(at), name) for at, name in re.findall(r'at = ([\d.]+), name = "([^"]+)"', CORE)]
GEAR = [(name, float(price), float(mult)) for name, price, mult in re.findall(r'name = "([^"]+)", price = ([\d.]+), mult = ([\d.]+)', CORE)]
WALLS = [(float(hp), float(reward)) for hp, reward in re.findall(r'\{ hp = ([\d.]+), reward = ([\d.]+) \}', CORE)]
WORLDS = [(name, float(scale), float(hp), float(reward)) for name, scale, hp, reward in re.findall(r'name = "([^"]+)", floor = .*?scale = ([\d.]+), boss = \{ name = "[^"]+", hp = ([\d.]+), reward = ([\d.]+)', CORE)]
EGG_PRICES = [float(x) for x in re.search(r'amount = \(\{ ([\d, ]+) \}\)\[world\]', SOURCE)[1].split(',')]
WEIGHTS = [float(x) for x in re.search(r'for j, weight in \{ ([\d, ]+) \}', SOURCE)[1].split(',')]
PET_J, PET_WORLD = map(float, re.search(r'items\[id\].power = 1 \+ j \* ([\d.]+) \+ \(world - 1\) \* ([\d.]+)', SOURCE).groups())
PET_CAP = number('maxMultiplier', SOURCE.split('Config.Pets =')[1])
SLOTS = int(number('maxEquipped'))
REBIRTH = SOURCE.split('Config.Rebirth = {')[1].split('Config.Quests')[0]
DT = .25

def form_for(power):
    return max(i for i, (at, _) in enumerate(FORMS) if power >= at)

def wall_stats(world, index):
    if index == len(WALLS): return (*WORLDS[world][2:], True)
    hp, reward = WALLS[index]
    return hp * WORLDS[world][1], reward * WORLDS[world][1], False

def pet_multiplier(powers):
    return min(PET_CAP, 1 + sum(p - 1 for p in powers if math.isfinite(p) and p >= 1))

def pick_with(probabilities, r):
    acc = 0
    for i, p in enumerate(probabilities):
        if p > 0:
            acc += p
            if r < acc: return i
    return max(i for i, p in enumerate(probabilities) if p > 0)

def simulate(seed=42, pets=True, daily=False):
    rng = random.Random(seed)
    time = power = cash = 0
    gear = world = rebirths = 0
    owned = []
    hatches = [0]*len(WORLDS)
    cooldown = {}
    seen = set()
    events = []
    samples = []
    spacing = number('spacing', CORE)
    pos = -6.0  # distance along the track, start spawn
    target = spacing
    returning = False
    finished = False
    def log(kind, label):
        if (kind, label) not in seen:
            seen.add((kind, label)); events.append((round(time,2),kind,label,round(power),round(cash)))
    log('world', WORLDS[0][0])
    if daily: cash += number("amount", SOURCE.split("Config.Daily =")[1])
    while time < 6*3600 and not finished:
        mult = min(number('maxMultiplier'), (GEAR[gear-1][2] if gear else 1) * pet_multiplier(sorted(owned,reverse=True)[:SLOTS]) * (1+rebirths*number('bonusPerRebirth',REBIRTH)))
        rate = 16/number('stepStuds',CORE)*number('perStep',CORE)*mult
        cost = math.ceil(number('baseCost',REBIRTH)*number('growth',REBIRTH)**rebirths)
        boss = WORLDS[world][2]
        future_rate = min(number('maxMultiplier'), mult*(1+(rebirths+1)*number('bonusPerRebirth',REBIRTH))/(1+rebirths*number('bonusPerRebirth',REBIRTH))) * 16/number('stepStuds',CORE)*number('perStep',CORE)
        if power >= cost and boss/future_rate < max(0,boss-power)/rate:
            power=0;rebirths+=1;log('rebirth',str(rebirths))
        wants_gear = gear < len(GEAR) and cash >= GEAR[gear][1]
        wants_egg = pets and hatches[world] < SLOTS and cash >= EGG_PRICES[world]
        if (wants_gear or wants_egg) and not returning:
            returning=True;target=-6
        distance = min(16*DT, abs(target-pos))
        old = pos
        pos += math.copysign(distance, target-pos) if distance else 0
        # Currency.Earn batches two steps per tick while walking at 16 studs/s.
        power += math.floor(distance/number('stepStuds',CORE)*number('perStep',CORE)*mult)
        time += DT
        for at,name in FORMS:
            if power >= at:
                log('form',name)
                if rebirths: log('reform',f'{rebirths}:{name}')
        if returning and pos == -6:
            if gear < len(GEAR) and cash >= GEAR[gear][1]:
                cash -= GEAR[gear][1];log('gear',GEAR[gear][0]);gear+=1
            elif wants_egg:
                cash -= EGG_PRICES[world]
                j=pick_with([w/sum(WEIGHTS) for w in WEIGHTS],rng.random())+1
                owned.append(1+j*PET_J+world*PET_WORLD);hatches[world]+=1
                log('egg',f'{world+1}.{hatches[world]}')
            returning=False
        previous_world=world
        for index in range(len(WALLS)+1):
            hp,reward,boss_wall=wall_stats(world,index)
            key=(world,index)
            if abs(pos-(index+1)*spacing)<=6.5 and power>=hp and time>=cooldown.get(key,0):
                cooldown[key]=time+3;cash+=reward
                log('boss' if boss_wall else 'wall',f'{world+1}.{index+1}')
                if boss_wall and world<len(WORLDS):
                    world+=1;pos=-6;returning=False
                    if world==len(WORLDS):finished=True
                    else:log('world',WORLDS[world][0])
                    break
        if finished:continue
        if not returning:
            accessible=[i for i in range(len(WALLS)+1) if wall_stats(world,i)[0] <= power]
            # Target is the furthest reachable wall; bounce within its reach while farming.
            if accessible:
                center=(max(accessible)+1)*spacing
                target=center+4 if pos <= center else center-4
            else:
                target=spacing if pos < spacing-5 else spacing-12
        if int(time*4)%240==0:samples.append((time,power))
    return events,samples

def tests():
    assert len(WORLDS)==len(EGG_PRICES)==3 and len(WALLS)==5
    for i,(at,_) in enumerate(FORMS):
        assert form_for(at)==i
        if i: assert form_for(at-1)==i-1
    assert wall_stats(0,0)==(25,5,False)
    for w in range(3):
        assert wall_stats(w,5)==(*WORLDS[w][2:],True)
        assert wall_stats(w,4)[0] < wall_stats(w,5)[0]
    assert pet_multiplier([])==1
    assert abs(pet_multiplier([1.2]*3)-1.6)<1e-9
    assert pet_multiplier([100])==PET_CAP
    assert pet_multiplier([float('nan'),float('inf'),0])==1
    probs=[w/sum(WEIGHTS) for w in WEIGHTS]
    assert abs(sum(probs)-1)<1e-12
    assert pick_with([1,0],.999999)==0
    acc=0
    for i,p in enumerate(probs):
        assert pick_with(probs,acc+1e-8)==i
        acc+=p
    rng=random.Random(1234);counts=[0]*4
    for _ in range(100000):counts[pick_with(probs,rng.random())]+=1
    assert sum((n-100000*p)**2/(100000*p) for n,p in zip(counts,probs))<20
    # Guard source contracts against accidental drift in the Python replicas.
    service=(ROOT/'template/src/server/Services/Eggs.luau').read_text()
    odds=(ROOT/'template/src/shared/LihFolk/Odds.luau').read_text()
    assert 'bonus += power - 1' in service and 'if r < acc then' in odds
    print('PASS: Python replicas: form boundaries, wall stats, additive cap, roll boundaries + 100k chi-square')

def main():
    tests();OUT.mkdir(parents=True,exist_ok=True)
    events,samples=simulate()
    with (OUT/'economy.csv').open('w',newline='',encoding='utf-8') as f:
        writer=csv.writer(f);writer.writerow(['seconds','kind','milestone','power','cash']);writer.writerows(events)
    for t,k,n,p,c in events:print(f'{t/60:7.2f} min | {k:8} | {n:20} | Power {p} | Cash {c}')
    print('Sensitivity: seed / eggs / first boss minutes / finish minutes')
    for pets in (True,False):
        for seed in (1,42,99):
            ev,_=simulate(seed,pets);boss=next(t for t,k,n,*_ in ev if k=='boss' and n=='1.6')
            print(seed,pets,round(boss/60,2),round(ev[-1][0]/60,2))
            assert 20*60 <= boss <= 40*60, (seed,pets,boss)
            assert any(k=='boss' and n=='3.6' for t,k,n,*_ in ev)
            assert len([1 for t,k,n,*_ in ev if k=='wall']) == len(WALLS)*len(WORLDS)
            if pets:
                assert next(t for t,k,n,*_ in ev if k=='egg')<300
            assert next(t for t,k,n,*_ in ev if k=='wall')<60
            assert next(t for t,k,n,*_ in ev if k=='gear')<120
            meaningful=sorted({t for t,k,n,*_ in ev})
            gap=max(b-a for a,b in zip(meaningful,meaningful[1:]))
            print('  largest milestone gap:',round(gap/60,2),'min')
            assert gap <= 300, (seed,pets,gap)
    ev,_=simulate(42,True,True)
    print('Daily sensitivity first boss:',round(next(t for t,k,n,*_ in ev if k=='boss')/60,2),'min')
    image=Image.new('RGB',(1200,650),'#f4f5f8');d=ImageDraw.Draw(image)
    d.text((35,20),'PLUS ONE | Offline simulation, seed 42 | NOT FINAL',fill='#162238')
    if samples:
        max_t=max(t for t,p in samples);max_p=max(p for t,p in samples)
        points=[(70+t/max_t*1050,570-p/max_p*500) for t,p in samples]
        d.line(points,fill='#237dc0',width=3)
        for t,k,n,*_ in events:
            if k in ('boss','rebirth'):
                x=70+t/max_t*1050;d.line((x,60,x,570),fill='#cf617c');d.text((x+2,80 if k=='boss' else 110),f'{k} {n}',fill='#752939')
        for i in range(7):
            x=70+i*175;d.text((x,590),f'{max_t*i/6/60:.0f} min',fill='#162238')
        for i in range(6):d.text((10,570-i*100),f'{max_p*i/5:.0f}',fill='#162238')
    image.save(OUT/'economy.png')

if __name__=='__main__':main()

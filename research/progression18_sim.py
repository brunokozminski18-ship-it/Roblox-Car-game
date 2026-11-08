"""Design check for 18 biomes x 8 cars (THROW TICKETS AT CARS!). Pure maths, no game code.
Run: python research/progression18_sim.py   -> prints tables used in research/Progression18.md

Model (matches the game's current rules, see games/ThrowTicketsAtCars/GAME_DESIGN.md):
- Power comes only from training: power/s = Work(best exercise) / WorkPerPower(biome).
- Each biome unlocks one exercise (Work doubles) and one ticket; price = Minutes x reference income/min.
- While saving for the new exercise the player trains with the previous one (half speed).
- Car odds: rarity weights 70/22/7/1, ticket luck multiplies non-Common weights by (1+luck), split evenly
  inside the rarity; variants Gold 5% / Diamond 1% / Neon 0.25%, luck applies to variants too.
Targets are anchored first (LihFolk "Progression and Pacing Design": anchor and solve, sawtooth),
then WorkPerPower is solved from them.
"""
import math

# ---------------------------------------------------------------- targets
BIOMES = ["Junkyard", "Suburbs", "Downtown", "Farm Roads", "Desert Highway", "Snowy Pass", "Sports Track",
          "Millionaire Hills", "Hypercar Island", "Future City",                       # launch (1-10)
          "Moon Base", "Candy Land", "Volcano Road", "Toy Town", "Haunted Highway",       # updates
          "Dino Valley", "Ocean Floor", "Cosmic Highway"]
RELEASE = ["Launch"] * 10 + ["U1"] * 2 + ["U2"] * 2 + ["U3"] * 2 + ["U4"] * 2
# Power needed to land in the biome. 1-10 = current Config (do not change), 11-18 grow x1.30.
POWER = [0, 50, 150, 300, 550, 900, 1400, 2200, 3400, 5000,
         7000, 9500, 12500, 16500, 21500, 28000, 36000, 46000]
POWER_END = 60000
# Active-play minutes spent INSIDE each biome (sawtooth: short early, growing ~1.2-1.3x late).
T_MIN = [3, 5, 10, 17, 25, 35, 45, 55, 65, 75,
         95, 115, 140, 165, 195, 225, 260, 300]
# Biome base income ($/s for a Common, Paper ticket). 1-10 = current Config.
BASE = [1, 5, 22, 90, 360, 1400, 5500, 21000, 80000, 300000]
for _ in range(8): BASE.append(round(BASE[-1] * 2.4))   # late growth compressed: keeps prices under MaxCash
# Ticket income multiplier and luck. 1-11 = current Config; 12-18 grow x1.15 income, +0.07 luck, cap 1.0.
TICKET_MULT = [1, 1.5, 2.2, 3.2, 4.6, 12, 18, 27, 40, 60, 90]
TICKET_LUCK = [0, .05, .10, .15, .20, .25, .30, .35, .40, .45, .50]
while len(TICKET_MULT) < 18:
    TICKET_MULT.append(round(TICKET_MULT[-1] * 1.15, 1)); TICKET_LUCK.append(min(1.0, round(TICKET_LUCK[-1] + .07, 2)))
# Price in minutes of reference income at the unlock biome.
EX_MIN = [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 20, 22, 25, 28]   # exercise unlocked in biome i
TI_MIN = [0, 1.5, 3, 4, 5, 6, 8, 10, 12, 15, 20, 22, 25, 28, 31, 34, 38, 42]
WORK = [1, 2] + [2 ** i for i in range(2, 18)]       # exercise Work, doubles per biome (index = biome-1, two in biome 1)
TRAIN_SHARE = 0.7          # share of active time on the training pad (rest = throwing / parking)
CATCH_LOOP_S = 14          # one throw -> reveal -> tow (Config.Simulation.CatchLoopSeconds)
RARITY = [("Common", 70, 1, 3), ("Rare", 22, 2, 2), ("Epic", 7, 3, 2), ("Legendary", 1, 5, 1)]   # name, weight, income x, cars per biome
VARIANTS = [("Normal", .9375, 1), ("Gold", .05, 2), ("Diamond", .01, 4), ("Neon", .0025, 8)]
PITY_LEGENDARY = 120       # proposed hard pity (catches without a Legendary, any biome)

def ref_income_per_min(b):
    """Reference income at biome b (0-based): parked 6 cars ~ avg rarity 3x + sales, like Config."""
    rt = sum(w * m for _, w, m, _ in RARITY) / sum(w for _, w, _, _ in RARITY)
    eq = 3 if b == 0 else 6 * 3 + (180 / 45) * rt
    return BASE[b] * TICKET_MULT[b] * eq * 60

def solve_training():
    rows, t_total = [], 0.0
    for b in range(18):
        d_power = (POWER[b + 1] if b + 1 < 18 else POWER_END) - POWER[b]
        work = 2 ** (b + 1)          # biome 1: Focused (2); biome b: Work 2^b (Weighted 4 ... )
        m = EX_MIN[b]
        # T = m/2 + d/(60 R share)  ->  R = d / (60 share (T - m/2))
        R = d_power / (60 * TRAIN_SHARE * max(0.5, T_MIN[b] - m / 2))
        wpp = work / R
        t_total += T_MIN[b]
        rows.append((b, d_power, work, R, wpp, t_total))
    return rows

def odds(luck):
    w = [r[1] * (1 if i == 0 else 1 + luck) for i, r in enumerate(RARITY)]
    tot = sum(w)
    per_car = [w[i] / tot / RARITY[i][3] for i in range(4)]
    vw = [v[1] * (1 if i == 0 else 1 + luck) for i, v in enumerate(VARIANTS)]
    vt = sum(vw)
    return [w[i] / tot for i in range(4)], per_car, [x / vt for x in vw]

def coupon_catches(luck):
    """Expected catches to own all 8 normal cars of one biome (unequal probabilities, inclusion-exclusion approx by simulation)."""
    import random
    _, per_car, _ = odds(luck)
    probs = []
    for i, r in enumerate(RARITY): probs += [per_car[i]] * r[3]
    rng = random.Random(7); tot = 0; N = 4000
    for _ in range(N):
        seen = set(); n = 0
        while len(seen) < 8:
            x = rng.random(); acc = 0; n += 1
            for k, p in enumerate(probs):
                acc += p
                if x < acc: seen.add(k); break
        tot += n
    return tot / N

def fmt(x):
    for s, v in (("Qd", 1e15), ("T", 1e12), ("B", 1e9), ("M", 1e6), ("K", 1e3)):
        if abs(x) >= v: return f"{x / v:.1f}{s}"
    return f"{x:.0f}"

if __name__ == "__main__":
    rows = solve_training()
    print("| # | Biom | Wydanie | Power od | Czas w biomie | Łącznie (aktywnie) | Power/s | WorkPerPower | Dochód bazowy/s | Mandat x / luck | Ref. dochód/min | Ćwiczenie | Mandat |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for b, d, work, R, wpp, tt in rows:
        ri = ref_income_per_min(b)
        print(f"| {b+1} | {BIOMES[b]} | {RELEASE[b]} | {POWER[b]:,} | {T_MIN[b]} min | {tt/60:.1f} h | {R*TRAIN_SHARE:.2f} | {wpp:,.0f} | {fmt(BASE[b])} | x{TICKET_MULT[b]} / {TICKET_LUCK[b]:.2f} | {fmt(ri)} | {fmt(EX_MIN[b]*ri)} ({EX_MIN[b]} min) | {fmt(TI_MIN[b]*ri)} ({TI_MIN[b]} min) |")
    peak = max(max(EX_MIN[b], TI_MIN[b]) * ref_income_per_min(b) for b in range(18))
    print(f"\nNajwyższa cena: {fmt(peak)}  (MaxCash dziś 1e15; 2^53 = {fmt(2**53)})")
    print("\n| Luck | Common | Rare | Epic | Legendary | 1 konkretne Legendary | Legendary Neon | Legendary: mediana / p90 / p99 złapań | Komplet 8 aut biomu (śr. złapań) |")
    print("|---|---|---|---|---|---|---|---|---|")
    for luck in (0, .25, .5, 1.0):
        tier, per_car, var = odds(luck)
        pL = tier[3]
        med, p90, p99 = math.log(2) / pL, 2.303 / pL, 4.605 / pL
        print(f"| {luck:.2f} | {tier[0]*100:.1f}% | {tier[1]*100:.1f}% | {tier[2]*100:.1f}% | {pL*100:.2f}% | 1 in {1/per_car[3]:,.0f} | 1 in {1/(per_car[3]*var[3]):,.0f} | {med:.0f} / {p90:.0f} / {p99:.0f} (pity {PITY_LEGENDARY}) | {coupon_catches(luck):.0f} |")
    catch_per_min = (1 - TRAIN_SHARE) * 60 / CATCH_LOOP_S
    print(f"\nZłapań na minutę aktywnej gry: {catch_per_min:.2f}; Legendary mediana przy luck 0: {math.log(2)/0.01/catch_per_min:.0f} min, p90: {2.303/0.01/catch_per_min:.0f} min")

md ← 0‿31‿28‿31‿30‿31‿30‿31‿31‿30‿31‿30‿31
ry ← 1970
rn ← 4 # Thursday
Leap ← {((0=4|𝕩) ∧ 0≠100|𝕩) ∨ 0=400|𝕩}
Leaps ← {+´Leap ry+↕1+𝕩-ry}
days ← "Monday"‿"Tuesday"‿"Wednesday"‿"Thursday"‿"Friday"‿"Saturday"‿"Sunday"
Day ⇐ {y‿m‿d←𝕩 ⋄ n←(d-1)+(+´m↑md)+(365×y-ry)+(Leaps y)+¯1×(Leap y)∧m∊1‿2 ⋄ (7|rn-˜7+n)⊏days}

m: 0 31 28 31 30 31 30 31 31 30 31 30 31
ry: 1970
rn: 4 / Thursday
leap: {((0=4!x) & (~0=100!x)) | (0=400!x)}
leaps: {+/leap (ry+!(1+x-ry))}
days: `Monday `Tuesday `Wednesday `Thursday `Friday `Saturday `Sunday
day: {Y:*x; M:x@1; D:-1#x; N:(D-1)+(+/M#m)+(365*Y-ry)+(leaps Y)+(-1*(|/M=1 2)&leap Y); `0:$days@7!(7+N)-rn}

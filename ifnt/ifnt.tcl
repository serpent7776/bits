# E.g.:
# % ifn't false {puts 12}
# 12
# % ifn't true {puts 12}
#

proc ifn't {cond cmds} {if {!$cond} $cmds}

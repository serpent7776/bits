#!/usr/bin/env bash
,() { echo -n '['; }; .() { ,; ,(){ echo -n ☀️,\ ; }; if [ $# -eq 1 ]; then echo ☀️\ ]; else shift; $1 $*; fi; }; . . . . . . . . .

# perf-stats-to-sc

Export `perf stat` output to sc/sc-im spreadsheet.

- sc: https://en.wikipedia.org/wiki/Sc_(spreadsheet_calculator)
- sc-im: https://github.com/andmarti1424/sc-im

Intended use is to gather stats for several executables in single file and convert that to sc spreadsheet, e.g.:

```sh
: > stats.txt
for exe in ...; do
    perf stat -o stats.txt --append "$exe"
done

perf-stat-to-sc.pl < stats.txt > stats.sc
```

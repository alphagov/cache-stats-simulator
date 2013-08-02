Cache time simulator
====================

The cache time simulator will help you to choose appropriate cache time
settings for your app based on real data.

It will simulate the effect of changing the cache time for different urls.
It takes as input akamai log files in the 'esw3c_waf_S' format.

These should be placed in the data/ subdirectory.

Usage
=====

Place the akamai log files in the data directory:

```
~/alphagov/cache-time-simulator$ ls data/*.gz
data/gdslog_184926.esw3c_waf_S.201307300000-0400-0.gz
```

Then generate sorted, stripped down versions (only /government urls are selected)

```
$ ./bin/sort_all.sh

~/alphagov/cache-time-simulator$ ./bin/sort_all.sh
Sorting data/gdslog_184926.esw3c_waf_S.201307300000-0400-0.gz...
Done.
```

Then calculate stats (takes about 1.5 mins to process 2 days worth of logs):

```
$ ./bin/stats.sh
~/alphagov/cache-time-simulator$ ./bin/stats.sh
Cache stats
Cache time(mins)	Hits	Misses
2	2262517	990597
5	2405725	847389
10	2537116	715998
15	2600295	652819
20	2645882	607232
30	2707261	545853

```

The stats script merges all the sorted log files and invokes run_stats.awk.

You can adjust the stats output by modifying the cache_times_mins variable.

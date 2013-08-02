# run_stats.awk
#
# Assumes STDIN is SORTED tab separated file with two columns, {URL, DATESTAMP}

BEGIN {
  FS="\t";
  OFS="\t";

  #         1    2    3     4         5      6         7        8          9          10            11        12
  # fields: date time cs-ip cs-method cs-uri sc-status sc-bytes time-taken cs-Referer cs-User-Agent cs-Cookie x-wafinfo
  URL = 1;
  DATETIME =2;

  prev_url=""
  prev_datetime=0

  # Configuration of cache time buckets. Change this to change the stats breakdown.
  split("2,5,10,15,20,30", cache_times_mins, ",")
  for (i in cache_times_mins) {
    cache_times_seconds[i] = cache_times_mins[i] * 60
  }
}

function record_cache_time(url, time_since_last_request)
{
  for (i in cache_times_seconds) {
    if (time_since_last_request < cache_times_seconds[i]) {
      cache_hits[i]++
    } else {
      cache_misses[i]++
    }
  }
}

{
  gsub(/[-:]/, " ", $DATETIME)
  cur_datetime = mktime($DATETIME)
  if (prev_url != $URL) {
    prev_datetime=0
  }
  record_cache_time($URL, cur_datetime-prev_datetime)
  prev_url = $URL
  prev_datetime = cur_datetime
}

END {
  print "Cache stats"
  print "Cache time(mins)", "Hits", "Misses"
  for (i in cache_hits) {
    print cache_times_mins[i], cache_hits[i], cache_misses[i]
  }
}
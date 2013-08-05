# run_stats.awk
#
# Assumes STDIN is SORTED tab separated file with two columns, {URL, DATESTAMP}

BEGIN {
  FS="\t";
  OFS="\t";

  # fields
  URL = 1;
  DATETIME =2;
  STATUS = 3;
  BYTES = 4;

  prev_url=""
  prev_datetime=0

  page_types["edition:show"] = "^/www-origin.production.alphagov.co.uk/government/(news|policies|speeches|fatalities|publications|case-studies|world-location-news|statistical-data-sets|consultations)/[^/]+(/[^/]+)*$"
  page_types["worldwide_edition:show"] = "^/www-origin.production.alphagov.co.uk/government/(priority|world)/[^/]+(/[^/]+)*$"
  page_types["other:show"] = "^/www-origin.production.alphagov.co.uk/government/(series|ministers|people|policy-teams|policy-advisory-groups|fields-of-operation)/[^/]+(/[^/]+)*$"
  page_types["all orgs index"] = "^/www-origin.production.alphagov.co.uk/government/organisations$"
  page_types["organisation:homepage"] = "^/www-origin.production.alphagov.co.uk/government/organisations/[^/]+$"
  page_types["organisation:sub_page"] = "^/www-origin.production.alphagov.co.uk/government/organisations/[^/]+(/[^/]+)*$"
  page_types["edition:index:locale"] = "^/www-origin.production.alphagov.co.uk/government/(policies|publications|announcements)\\.[a-z0-9]{2}(-[a-z0-9]*)(\\?.*)?$"
  page_types["edition:index"] = "^/www-origin.production.alphagov.co.uk/government/(policies|publications|announcements)(\\.json)?(\\?.*)?$"
  page_types["attachments"] = "^/www-origin.production.alphagov.co.uk/government/uploads"
  page_types["atom"] = "^/www-origin.production.alphagov.co.uk/government/(feed|.*\\.atom)"
  page_types["placeholder"] = "^/www-origin.production.alphagov.co.uk/government/placeholder"
  page_types["atom:govdelivery"] = "^/www-origin.production.alphagov.co.uk/government/.*\\.atom.*\\?govdelivery_version=yes"
  page_types["topics:index"] = "^/www-origin.production.alphagov.co.uk/government/topics$"
  page_types["topics:topic-name:index"] = "^/www-origin.production.alphagov.co.uk/government/topics/[a-z-]*$"
  page_types["topics:other"] = "^/www-origin.production.alphagov.co.uk/government/topics/[^/]+/[^/]+(/[^/]+)*$"
  page_types["topical-events"] = "^/www-origin.production.alphagov.co.uk/government/topical-events/[^/]+(/[^/]+)*$"
  page_types["other:index"] = "^/www-origin.production.alphagov.co.uk/government/(case-studies|policy-advisory-groups|fields-of-operation|series|ministers|people|policy-teams|policy-advisory-groups|fields-of-operation|world/organisations|world)$"

  # Configuration of cache time buckets. Change this to change the stats breakdown.
  split("0,0.5,1,2,5,10,15,20,30", cache_times_mins, ",")
  for (i in cache_times_mins) {
    cache_times_seconds[i] = cache_times_mins[i] * 60
  }

  ok_status_codes = "200,206,304"
}

function find_page_type(url, status_code)
{
  for (page_type in page_types) {
    if (url ~ page_types[page_type]) {
      return page_type
    }
  }
  return "unknown"
}

function record_cache_time(url, page_type, time_since_last_request, status, bytes)
{
  if (index(ok_status_codes, status)) {
    actual_page_type = page_type
  } else {
    actual_page_type = status
  }
  for (i in cache_times_seconds) {
    if (time_since_last_request < cache_times_seconds[i]) {
      cache_hits[actual_page_type, i]++
    } else {
      cache_misses[actual_page_type, i]++
    }
  }
}

{
  gsub(/[-:]/, " ", $DATETIME)
  cur_datetime = mktime($DATETIME)
  if (prev_url != $URL) {
    prev_datetime = 0
    page_type = find_page_type($URL, $STATUS)
  }
  record_cache_time($URL, page_type, cur_datetime-prev_datetime, $STATUS, $BYTES)
  prev_url = $URL
  prev_datetime = cur_datetime
}

END {
  print "Cache stats"
  print "Cache time(mins)", "Page type", "Hits", "Misses"
  for (combined in cache_misses) {
    split(combined, parts, SUBSEP)
    page_type = parts[1]
    i = parts[2]
    print cache_times_mins[i], page_type, cache_hits[page_type, i], cache_misses[page_type, i]
  }
}
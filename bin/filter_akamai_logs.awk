BEGIN {
  FS="\t";
  OFS="\t";

  #         1    2    3     4         5      6         7        8          9          10            11        12
  # fields: date time cs-ip cs-method cs-uri sc-status sc-bytes time-taken cs-Referer cs-User-Agent cs-Cookie x-wafinfo
  DATE = 1;
  TIME = 2;
  URL = 5;
  STATUS = 6;
  BYTES = 7;
  TIME_TAKEN = 8;
}

# Skip commented lines
/^#/ { next }

# Success lines
$URL ~ /^\/www-origin.production.alphagov.co.uk\// {
  print $URL, $DATE " " $TIME, $STATUS, $BYTES
}

BEGIN {
  FS=" ";
  OFS="\t";

  # 1        2   3   4    5  6   7    8        9   10  11        12
  # 1.2.3.4  "-" "-" Mon, 10 Nov 2014 06:04:59 GMT GET /some/url 200
  DAY = 4;
  DATE = 5;
  MONTH = 6;
  YEAR = 7;
  TIME = 8;
  TIMEZONE = 9;
  URL = 11;
  STATUS = 12;

  split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", month_names, " ")
}

function month_number(month)
{
  for (i in month_names) {
    if (month_names[i] == month) {
      return i;
    }
  }
  return 0;
}

# Skip commented lines
/^#/ { next }

# Success lines
{
  time_with_spaces = gsub(/[-:]/, " ", $TIME)
  print $URL, $YEAR " " month_number($MONTH) " " $DATE " " $TIME " 0", $STATUS, ""
}

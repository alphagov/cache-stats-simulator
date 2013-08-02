#!/bin/sh

for FILE in data/*.gz; do
  SORTED="${FILE}.sorted"
  if [ -e "${SORTED}" ]; then
    echo "${FILE} already sorted"
  else
    echo "Sorting ${FILE}"
    gzip -dc "$FILE" | gawk -f bin/akamai_to_sql_import.awk | sort -t$'\t' -S3G -o "${SORTED}"
  fi
done

echo "Done."

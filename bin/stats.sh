#!/bin/sh

LC_ALL=C sort -m data/*sorted | gawk -f bin/run_stats.awk

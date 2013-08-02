#!/bin/sh

sort -m data/*sorted | gawk -f bin/run_stats.awk
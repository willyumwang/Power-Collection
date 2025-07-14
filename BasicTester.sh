#!/bin/bash

# Check for interval argument
if [ -z "$1" ]; then
  echo "Usage: $0 <interval_in_seconds>"
  exit 1
fi

interval=$1
output_dir="power_tests"
today=$(date '+%Y-%m-%d')

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Find the next available file number for today
counter=1
while [ -f "$output_dir/powertest_output_${today}_$counter.csv" ]; do
  ((counter++))
done

output_file="$output_dir/powertest_output_${today}_$counter.csv"

# Add header to the new file
echo "Timestamp,Sys Pwr Line" > "$output_file"

# Loop to collect data
while true; do
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  line=$(powertest -r | grep "Sys Pwr")
  if [ ! -z "$line" ]; then
    output_line="$timestamp,$line"
    echo "$output_line" >> "$output_file"
    echo "$output_line"  # Print to console
  fi
  sleep "$interval"
done

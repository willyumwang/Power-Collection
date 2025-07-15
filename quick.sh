if [ -z "$1" ]; then
 echo "Usage: $0 <interval_in_seconds>"
 exit 1
fi
interval="$1"
output_dir="power_tests"
mkdir -p "$output_dir"
timestamp=$(date +"%Y-%m-%d")
counter=1
# Ensure unique filename
while [ -e "$output_dir"/powertest_raw_"$timestamp"_"$counter".csv ]; do
 counter=$((counter + 1))
done
output_file="$output_dir"/powertest_raw_"$timestamp"_"$counter".csv
echo "Timestamp,Power (W),Current (A)" > "$output_file"
while true; do
 raw=$(powertest -r | grep "Sys Pwr")
 # Extract values with awk — based on fixed structure
 power=$(echo "$raw" | awk -F'[:,]' '{gsub(/[^0-9.]/,"",$2); print $2}')
 current=$(echo "$raw" | awk -F',' '{gsub(/[^0-9.]/,"",$2); print $2}')
 now=$(date +"%Y-%m-%d %H:%M:%S.%6N")
 echo "$now,$power,$current" >> "$output_file"
 sleep "$interval"
done

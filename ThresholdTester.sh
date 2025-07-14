# Check for interval argument
if [ -z "$1" ]; then
   echo "Usage: $0 <interval_in_seconds>"
   exit 1
fi
interval="$1"
output_dir="power_tests"
today=$(date '+%Y-%m-%d')
# Create output directory if needed
mkdir -p "$output_dir"
# Create unique CSV file
counter=1
while [ -f "$output_dir/powertest_output_${today}_$counter.csv" ]; do
   counter=$((counter + 1))
done
output_file="$output_dir/powertest_output_${today}_$counter.csv"
echo "Timestamp,Sys Pwr Line" > "$output_file"
# ANSI color codes
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
WHITE="\033[1;37m"
RESET="\033[0m"
# Loop for data collection
while true; do
   timestamp=$(date '+%Y-%m-%d %H:%M:%S')
   line=$(powertest -r | grep "Sys Pwr")
   if [ ! -z "$line" ]; then
       clean_line=$(echo "$line" | sed 's/  */ /g' | sed 's/^ //')
       output_line="$timestamp,$clean_line"
       echo "$output_line" >> "$output_file"
       # Extract the FIRST number before "watts" (not sled 0W)
       raw_power=$(echo "$clean_line" | sed -n 's/[^0-9]*\([0-9][0-9]*\) watts.*/\1/p')
       power=$(echo "$raw_power" | tr -cd '0-9')
       # Apply color logic
       if [ -n "$power" ] && echo "$power" | grep -qE '^[0-9]+$'; then
           if [ "$power" -gt 1000 ]; then
               color="$RED"
           elif [ "$power" -ge 350 ]; then
               color="$GREEN"
           else
               color="$YELLOW"
           fi
       else
           color="$WHITE"
           output_line="$timestamp,Sys Pwr Missing or Invalid"
       fi
       # Print to terminal with color
       printf "${color}%s${RESET}\n" "$output_line"
   fi
   sleep "$interval"
done

#!/bin/bash

# Output file for timing results
OUTPUT_FILE="execution_times.txt"

# Database connection parameters
MASTER_PORT="9700"
DB_NAME="Citus_M"

# SQL file paths
SQL_FILES=(
    "/Users/nishantsushmakar/Documents/projects_ulb/tpcds-official-kit-citus/tpcdskit-official-mac/tools/tpcds.sql"
    "/Users/nishantsushmakar/Documents/projects_ulb/tpcds-official-kit-citus/tpcdskit-official-mac/tools/tpcds_ri.sql"
    "/Users/nishantsushmakar/Documents/projects_ulb/tpcds-official-kit-citus/tpcdskit-official-mac/Queries/dist_ref_tables.sql"
)

# Data directory
DATA_DIR="/Users/nishantsushmakar/Documents/projects_ulb/tpcds-official-kit-citus/data-1-gb"

# Tables array
tables=( "date_dim" "customer_address" "customer_demographics" "income_band" "household_demographics" 
    "customer" "item" "reason" "ship_mode" "time_dim" "warehouse" 
    "promotion" "web_site" "call_center" "catalog_page" "catalog_returns" "catalog_sales" 
    "inventory" "store" "store_returns" "store_sales" "web_page" "web_returns" "web_sales" 
    "dbgen_version")

# Clear or create the output file
> "$OUTPUT_FILE"

get_timestamp_micro() {
    perl -MTime::HiRes=time -e 'printf "%d%06d\n", time, (time - int(time))*1000000'
}

# Function to format timestamp for display (macOS compatible)
format_timestamp() {
    local epoch_micro=$1
    perl -e 'use POSIX qw(strftime); printf("%s.%06d\n", strftime("%Y-%m-%d %H:%M:%S", localtime($ARGV[0]/1000000)), $ARGV[0]%1000000)' "$epoch_micro"
}


# Execute SQL files and measure time
echo "SQL File Execution Times:" >> "$OUTPUT_FILE"
echo "------------------------" >> "$OUTPUT_FILE"

for sql_file in "${SQL_FILES[@]}"; do
    file_name=$(basename "$sql_file")
    echo "Executing $file_name..."
    
    # Get start time
    first_micro=$(get_timestamp_micro)
    first_timestamp=$(format_timestamp $first_micro)
    
    # Execute SQL file
    psql -p $MASTER_PORT -d $DB_NAME -f "$sql_file"
    
    # Get end time
    last_micro=$(get_timestamp_micro)
    last_timestamp=$(format_timestamp $last_micro)
    
    # Calculate execution time in microseconds
    execution_time=$((last_micro - first_micro))
    
    # Write results to file
    echo "$file_name:" >> "$OUTPUT_FILE"
    echo "  Start Time: $first_timestamp" >> "$OUTPUT_FILE"
    echo "  End Time: $last_timestamp" >> "$OUTPUT_FILE"
    echo "  Duration: $execution_time microseconds" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
done

echo -e "\nTable Loading Times:" >> "$OUTPUT_FILE"
echo "-------------------" >> "$OUTPUT_FILE"

# Execute load_data.sh and measure time for each table
for table in "${tables[@]}"; do
    file="$DATA_DIR/$table.dat"
    echo "Loading $table..."
    
    # Get start time
    first_micro=$(get_timestamp_micro)
    first_timestamp=$(format_timestamp $first_micro)
    
    # Execute COPY command
    psql -p $MASTER_PORT $DB_NAME -c "SET client_encoding = 'WIN1252';COPY $table FROM '$file' WITH (FORMAT csv, DELIMITER '|');"
    
    # Get end time
    last_micro=$(get_timestamp_micro)
    last_timestamp=$(format_timestamp $last_micro)
    
    # Calculate execution time in microseconds
    execution_time=$((last_micro - first_micro))
    
    # Write results to file
    echo "$table:" >> "$OUTPUT_FILE"
    echo "  Start Time: $first_timestamp" >> "$OUTPUT_FILE"
    echo "  End Time: $last_timestamp" >> "$OUTPUT_FILE"
    echo "  Duration: $execution_time microseconds" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
done

echo "Execution completed. Results saved in $OUTPUT_FILE"
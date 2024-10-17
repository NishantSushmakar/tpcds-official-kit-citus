#!/bin/bash

# Database connection parameters
DB_HOST="localhost"
DB_PORT="9700"
DB_NAME="Citus_M"
DB_USER="nishantsushmakar"
DB_PASSWORD=""


# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <sql_file>"
    exit 1
fi

input_file="$1"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found!"
    exit 1
fi

# Create output directory if it doesn't exist
output_dir="query_analysis"
mkdir -p "$output_dir"

# Create CSV file with headers
csv_file="${output_dir}/query_analysis.csv"
echo "query_number,query,first_timestamp,last_timestamp,execution_time_microseconds,explain_output,error_message,status" > "$csv_file"

# Function to get timestamp in microseconds (macOS compatible)
get_timestamp_micro() {
    perl -MTime::HiRes=time -e 'printf "%d%06d\n", time, (time - int(time))*1000000'
}

# Function to format timestamp for display (macOS compatible)
format_timestamp() {
    local epoch_micro=$1
    perl -e 'use POSIX qw(strftime); printf("%s.%06d\n", strftime("%Y-%m-%d %H:%M:%S", localtime($ARGV[0]/1000000)), $ARGV[0]%1000000)' "$epoch_micro"
}

# Function to execute query and get execution time
execute_query() {
    local query="$1"
    local query_num="$2"
    local explain_output
    local error_message=""
    local status="SUCCESS"

    # Add EXPLAIN to the query
    local explain_query="$query"

    # Get first timestamp
    local first_micro=$(get_timestamp_micro)
    local first_timestamp=$(format_timestamp $first_micro)

    # Execute query with EXPLAIN
    explain_output=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "$explain_query" 2>&1)
    query_exit_code=$?
    
    # Get last timestamp
    local last_micro=$(get_timestamp_micro)
    local last_timestamp=$(format_timestamp $last_micro)
    
    # Calculate execution time in microseconds
    local execution_time=$((last_micro - first_micro))

    # Check if query failed
    if [ $query_exit_code -ne 0 ]; then
        status="ERROR"
        error_message="Query Error: $explain_output"
        explain_output="FAILED"
    fi

    # Escape special characters for CSV
    query=$(echo "$query" | sed 's/"/""/g')
    explain_output=$(echo "" | tr '\n' ' ' | sed 's/"/""/g')
    error_message=$(echo "$error_message" | sed 's/"/""/g')

    # Write to CSV file
    echo "\"$query_num\",\"$query\",\"$first_timestamp\",\"$last_timestamp\",\"$execution_time\",\"$explain_output\",\"$error_message\",\"$status\"" >> "$csv_file"

    # Print status to console
    echo "Status: $status"
    if [ ! -z "$error_message" ]; then
        echo "Error: $error_message"
    fi

    return $query_exit_code
}

# Initialize variables
current_query=""
in_query=false
query_count=0
success_count=0
error_count=0
current_query_num=""

# Process the file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Check if line contains start of query
    if [[ $line =~ ^[[:space:]]*--[[:space:]]*start[[:space:]]*query[[:space:]]*([0-9]+) ]]; then
        # Extract query number
        current_query_num="${BASH_REMATCH[1]}"
        in_query=true
        current_query=""
        continue
    fi
    
    # Check if line contains end of query
    if [[ $line =~ ^[[:space:]]*--[[:space:]]*end[[:space:]]*query ]]; then
        if [ "$in_query" = true ] && [ ! -z "$current_query" ]; then
            query_count=$((query_count + 1))
            echo "Executing query $current_query_num..."
            execute_query "$current_query" "$current_query_num"
            if [ $? -eq 0 ]; then
                success_count=$((success_count + 1))
            else
                error_count=$((error_count + 1))
            fi
            echo "Query $current_query_num completed."
            echo "----------------------------------------"
        fi
        in_query=false
        continue
    fi
    
    # If we're between start and end comments, append to current query
    if [ "$in_query" = true ]; then
        # Append non-empty lines to current query
        if [[ $line =~ [^[:space:]] ]]; then
            if [ -z "$current_query" ]; then
                current_query="$line"
            else
                current_query="${current_query}"$'\n'"$line"
            fi
        fi
    fi
done < "$input_file"

echo "Processing complete. Summary:"
echo "Total queries executed: $query_count"
echo "Successful queries: $success_count"
echo "Failed queries: $error_count"
echo "Results have been saved to: $csv_file"

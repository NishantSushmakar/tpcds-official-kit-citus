DATA_DIR=$(realpath "../Data/3GB")
MASTER_PORT="9700"
DB_NAME="Citus"

tables=( "date_dim" "customer_address" "customer_demographics" "income_band" "household_demographics" 
    "customer" "item" "reason" "ship_mode" "time_dim" "warehouse" 
    "promotion" "web_site" "call_center" "catalog_page" "catalog_returns" "catalog_sales" 
    "inventory" "store" "store_returns" "store_sales" "web_page" "web_returns" "web_sales" 
    "dbgen_version")


# Loop through each .dat file in the directory

for table in "${tables[@]}"; do

    file=$DATA_DIR/$table.dat

    echo "Populating table $table_name from $file..."

    # Run the COPY command to populate the table
    psql -p $MASTER_PORT $DB_NAME -c "SET client_encoding = 'WIN1252';COPY $table FROM '$file' WITH (FORMAT csv, DELIMITER '|');"
    
    if [ $? -eq 0 ]; then
        echo "Table $table_name populated successfully."
    else
        echo "Failed to populate table $table_name."
    fi
done

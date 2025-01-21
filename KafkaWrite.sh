#!/bin/bash

# Variables
KAFKA_BINARY_PATH="/path/to/kafka-consumer-groups" # Path to your Kafka binary or executable
BOOTSTRAP_SERVER="localhost:9092"                # Kafka broker
GROUP="my-first-application"                     # Consumer group name
BQ_DATASET="your_dataset_id"                     # BigQuery dataset
BQ_TABLE="your_table_id"                         # BigQuery table
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")       # Current UTC timestamp

# Run Kafka Consumer Group Describe Command
OUTPUT=$($KAFKA_BINARY_PATH --bootstrap-server $BOOTSTRAP_SERVER --group $GROUP --describe)

# Check if the command succeeded
if [ $? -ne 0 ]; then
  echo "Error describing the consumer group."
  exit 1
fi

# Parse the output and format it as JSON
JSON_DATA=$(echo "$OUTPUT" | awk -v timestamp="$TIMESTAMP" '
  BEGIN {
    print "["
  }
  NR > 1 && NF > 0 {
    printf "%s{\"GROUP\":\"%s\", \"TOPIC\":\"%s\", \"PARTITION\":%d, \"CURRENT_OFFSET\":%d, \"LOG_END_OFFSET\":%d, \"LAG\":%d, \"CONSUMER_ID\":\"%s\", \"HOST\":\"%s\", \"CLIENT_ID\":\"%s\", \"TIMESTAMP\":\"%s\"}",
      separator, $1, $2, $3, $4, $5, $6, $7, $8, $9, timestamp
    separator = ","
  }
  END {
    print "]"
  }
')

# Check if JSON data was created successfully
if [ -z "$JSON_DATA" ]; then
  echo "Error parsing Kafka output."
  exit 1
fi

# Write the data to BigQuery
echo "$JSON_DATA" | bq insert --source_format=NEWLINE_DELIMITED_JSON $BQ_DATASET.$BQ_TABLE -

# Check if the insertion succeeded
if [ $? -eq 0 ]; then
  echo "Data successfully inserted into BigQuery."
else
  echo "Error inserting data into BigQuery."
  exit 1
fi

#!/bin/bash

# Set the current date
NOW=$(date +"%m-%d-%Y")

# Set the required time of 11pm
TIME=23:00:00

# Check if the current time matches the required time
if [ "$(date +%H:%M:%S)" = "$TIME" ]; then

    # INIT GCP
    PROJECT_ID="PUT PROJECT ID HERE"
    LOCATION="asia-southeast1"
    GCP_CREDS="/home/certs/credentials.json"
    gcloud auth activate-service-account --key-file="$GCP_CREDS"
    gcloud config set project "$PROJECT_ID"
    gcloud config set compute/region "$LOCATION"

    # Execute the script
    /home/mblife-mysql/cron.sh
fi

# Wait 1 minute before looping again
sleep 60

# Loop the script
while true
do
    bash /home/mblife-mysql/main.sh
done

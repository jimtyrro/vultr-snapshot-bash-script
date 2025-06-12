#!/bin/sh
# Adjust the path below per your system.
PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:/opt/homebrew/sbin"

# Getting the current date.
CURRENT_DATE=$(gdate +"%Y-%m-%dT%H:%M:%S.%3N")

# Configure the variables below
VULTR_API_KEY="Your API Key"
INSTANCE_ID="Your Instance ID"
SNAPSHOT_LIMIT=4

# Get snapshots info
SNAPSHOTS_RESPONSE=$(
  curl "https://api.vultr.com/v2/snapshots" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}"
  )

SNAPSHOT_COUNT=$(echo "$SNAPSHOTS_RESPONSE" | jq '.snapshots | length')
LAST_SNAPSHOT_ID=$(echo "$SNAPSHOTS_RESPONSE" | jq -r '.snapshots | sort_by(.date_created) | .[0].id')

# Get instance details
INSTANCE_RESPONSE=$(
  curl "https://api.vultr.com/v2/instances/${INSTANCE_ID}" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}"
  )

INSTANCE_PLAN=$(echo "$INSTANCE_RESPONSE" | jq -r '.instance.plan')
INSTANCE_REGION=$(echo "$INSTANCE_RESPONSE" | jq -r '.instance.region')
# Replace "your-tag-here" with your specific tag name
INSTANCE_TAG=$(echo "$INSTANCE_RESPONSE" | jq -r '.instance.tags[] | select(. == "your-tag-here")')

# Combine all the instance details to create the snapshot description
SNAPSHOT_DESCRIPTION="${INSTANCE_TAG}-${INSTANCE_PLAN}-${INSTANCE_REGION}_${CURRENT_DATE}"

# If the number of snapshots is greater than the limit, delete the oldest one
if [ "$SNAPSHOT_COUNT" -ge "$SNAPSHOT_LIMIT" ]; then
  curl "https://api.vultr.com/v2/snapshots/${LAST_SNAPSHOT_ID}" \
    -X DELETE \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    || exit 1;
fi

# Create a new snapshot
curl "https://api.vultr.com/v2/snapshots" \
  -X POST \
  -H "Authorization: Bearer ${VULTR_API_KEY}" \
  -H "Content-Type: application/json" \
  --data '{
    "instance_id" : "'"$INSTANCE_ID"'",
    "description" : "'"$SNAPSHOT_DESCRIPTION"'"
  }';

# Optional: print the snapshot description if needed
# echo "Created snapshot with description: ${SNAPSHOT_DESCRIPTION}"
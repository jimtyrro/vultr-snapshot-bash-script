#!/bin/sh
# Adjust the path below per your system.
PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:/opt/homebrew/sbin"

# Getting the current date.
CURRENT_DATE=$(gdate +"%Y-%m-%dT%H:%M:%S.%3N")

# Configure the variables below
VULTR_API_KEY="Your API Key"
INSTANCE_ID="Your Instance ID"
SNAPSHOT_LIMIT=4

# Get the number of snapshots
SNAPSHOT_COUNT=$(
  curl "https://api.vultr.com/v2/snapshots" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -o '"id"' | wc -l
  )

# Get the ID of the oldest snapshot
LAST_SNAPSHOT_ID=$(
  curl "https://api.vultr.com/v2/snapshots" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -o '"id":"[^"]*"' | head -1 | cut -d '"' -f 4
  )

# Get the plan name of the Vultr instance
INSTANCE_PLAN=$(
  curl "https://api.vultr.com/v2/instances/${INSTANCE_ID}" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -o '"plan":"[^"]*"' | cut -d '"' -f 4
  )

# Get the region name of the Vultr instance
INSTANCE_REGION=$(
  curl "https://api.vultr.com/v2/instances/${INSTANCE_ID}" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -o '"region":"[^"]*"' | cut -d '"' -f 4
  )

# Get the tag of the Vultr instance
INSTANCE_TAG=$(
  curl "https://api.vultr.com/v2/instances/${INSTANCE_ID}" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -o '"your-tag-here"' | sed 's/"//g' | head -1
  )

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
#!/bin/sh
# Adjust the path below per your system.
PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:/opt/homebrew/sbin"

# Getting the current date. (I use `gdate` to get millisecons (.%3N) in my timestamp for the date variable, but you can use just `date` if you don't need to have miliseconds in your snapshot timestamp, e.g. $(date +"%Y-%m-%dT%H:%M:%S")).
CURRENT_DATE=$(gdate +"%Y-%m-%dT%H:%M:%S.%3N")

# Configure the variables below
# Add your Vultr API Key
VULTR_API_KEY="Your API Key"
# Get it by running `vultr-cli instance list` command if you have the vultr-cli installed.
INSTANCE_ID="Your Instance ID"
# Add the number of snapshots you want to keep.
SNAPSHOT_LIMIT=4

# Get the number of snapshots
SNAPSHOT_COUNT=$(
  curl "https://api.vultr.com/v2/snapshots" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -o '"id"' | wc -l
  )
# Get the ID of the last snapshot
LAST_SNAPSHOT_ID=$(
  curl "https://api.vultr.com/v2/snapshots" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep '"' \
    | cut -d '"' -f 6
  )
# Get the plan name of the Vultr instance to use it in the snapshot description
INSTANCE_PLAN=$(
  curl "https://api.vultr.com/v2/instances/${INSTANCE_ID}" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -w "plan" \
    | cut -d ':' -f 10 \
    | cut -d '"' -f 2
  )
# Get the region name of the Vultr instance to use it in the snapshot description
INSTANCE_REGION=$(
  curl "https://api.vultr.com/v2/instances/${INSTANCE_ID}" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -w "region" \
    | cut -d ':' -f 9 \
    | cut -d '"' -f 2
  )
# Get the tag of the Vultr instance to use it in the snapshot description. (It will grab the first tag from the instance so I recomned to use a meaningful first tag for your instance when you create it).
INSTANCE_TAG=$(
  curl "https://api.vultr.com/v2/instances/${INSTANCE_ID}" \
    -X GET \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | grep -w "tag" \
    | cut -d ':' -f 29 \
    | cut -d '"' -f 2
  )
# Now we simply combine all the instance details collected above to create the snapshot description. Feel free to chaNge the  order to your liking. The description variable below will output as an example the following descriotion: "companyname-voc-c-4c-8gb-75s-amd-chi_2024-07-2024-07-17T05:59:06.895"
SNAPSHOT_DESCRIPTION="${INSTANCE_TAG}-${INSTANCE_PLAN}-${INSTANCE_REGION}_${CURRENT_DATE}"

# If the number of snapshots is greater than the limit, delete the oldest one
if [ "$SNAPSHOT_COUNT" -ge "$SNAPSHOT_LIMIT" ]; then
  curl "https://api.vultr.com/v2/snapshots/${LAST_SNAPSHOT_ID}" \
    -X DELETE \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    || exit 1;
fi
# If the number of snapshots is less than the limit, create a new snapshot
curl "https://api.vultr.com/v2/snapshots" \
  -X POST \
  -H "Authorization: Bearer ${VULTR_API_KEY}" \
  -H "Content-Type: application/json" \
  --data '{
    "instance_id" : "'"$INSTANCE_ID"'",
    "description" : "'"$SNAPSHOT_DESCRIPTION"'"
  }';

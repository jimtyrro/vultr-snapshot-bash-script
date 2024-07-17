## Overview
This very rought and rudmentary bash script was created in attempt to provide a simple and free solution for anyone wanted to create free snapshots on Vultr cloud.
It assumes you will create separate scripts for each Vult instance you want to snapshot. Therefore you will need to add the instance ID of the server you want ot creata snapshot for. 

It can be run from any computer or laptop, just download the script, make it exacutable (chmod +x scriptname) and add it to your cronjob, e.g. on my Mac laptop I do this:

Exacute this command:

`crontab -e`

Then add the following line to your cronjob file (replace **** with your username). This will run daily at 1am:

`0 1 * * * /Users/******/Cronjobs/vultr-snapshot-script.sh > /dev/null 2>&1`

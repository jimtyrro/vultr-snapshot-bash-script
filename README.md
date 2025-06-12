## Overview

This very rough and rudimentary bash script was created in attempt to provide a simple and free solution for anyone wanted to create free snapshots on Vultr cloud using their latest API v2.

It intended to be run on your personal computer/laptop, not on a server due to lack of security features, such as ptotecting Vultr API, etc.

```
So please DO NOT USE it on your server!!
```
It assumes you will create separate scripts for each Vultr instance you want to snapshot. Therefore you will need to add the instance ID of the server you want ot create snapshot for.

It can be run from any computer or laptop, just download the script, make it executable (chmod +x scriptname) and add it to your cronjob, e.g. on my Mac laptop I do this:

Execute this command:

```shell
crontab -e
```

Then add the following line to your cronjob file (replace \*\*\*\* with your username). This will run daily at 1am:

```shell
0 1 * * * /Users/******/Cronjobs/vultr-snapshot-script.sh > /dev/null 2>&1
```

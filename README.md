After login run
    source /usr/lib/fis-gtm/V6.3-005_x86_64/gtmprofile

It's like a virtualenv - allows you to run gtm at the prompt to get an M interpreter

Stuff in vagrant's .profile:
```
source /usr/lib/fis-gtm/V6.3-005_x86_64/gtmprofile
source /fetdb/env.vista
cd /fetdb
```
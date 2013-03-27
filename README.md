PennMUSH Backup Script
=====================

Introduction
------------
This is a very simple PennMUSH backup script I wrote some time ago. I'm just throwing it up here in case anyone finds it useful in the future (though I'm sure there are a million better ways to do this)

Operation
---------
All this script does is grap a copy of the required MUSH database files, optionally does SQL dumps, tars and bzips it all together and rsyncs to a location. It then deletes all backup files older than 30 days

Instructions
------------
Download, fill in the defines at the top of the file and away you go. I would suggest running it once a day via cron. Feel free to adapt to your needs however you see fit.

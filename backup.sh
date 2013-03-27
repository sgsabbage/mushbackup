#!/bin/bash

# MUSH backup script.
# This script takes a mush database along with sql dumps
# and pushes them into a datestamped directory structure
# before tar-ing and bzip-ing it. When finished it deletes
# the directory and sends a copy of the compressed dir using
# mutt.
# Will delete all backups older than a specified time.
# Intended to be used once a day.

# 2009-07-09 SGS - 0.1 File created
# 2009-07-10 SGS - 0.2 Emails
# 2010-02-24 SGS - 0.3 No more emails. Uses rsync instead.

# Copyright (c) 2013 Sean Sabbage
#	
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

echo "Backup script starting."

# Important defines!

backupPath='/path/to/backup/directory'		# The path to save the backups to - Explicit to be sure.
dataPath='/path/to/mush/game/data/'		# The location of the game databases - As above
gameDbs='chatdb.gz outdb.gz maildb.gz'		# The game databases

sqlHost=''				# The SQL server address. If not set it will not attempt to dump SQL databases
sqlUser=''					# SQL server user
sqlPass=''					# SQL password - If not set it will ignore.
sqlDbs=''					# Databases to save

backupTime=`date +%Y%m%d`			# Backup stamp

rsyncLocation=''  				# Location to rsync to

cd $backupPath	# Important to be in the right directory.
echo "Creating backup directory $backupTime."
mkdir $backupTime	# Make the directory to save to.
cd $backupTime	# Make sure you're in the right dir.
mkdir 'data'	# Directory for game data.

# Copies each of the databases to the data directory.
for db in $gameDbs
do
	echo "Backing up "$db"."
	cp ${dataPath}${db} 'data/'${db}
done

echo "DB backup complete."

# If sqlHost is not set it won't try to dump the dbs.
if [ "$sqlHost" != "" ]
then

	echo "Backing up SQL."

	# If sql password isn't set, don't add a -p option.
	if [ "$sqlPass" != "" ]
	then
		dumpPass="-p ${sqlPass}"
	fi

	mkdir 'sql'	# Makes the SQL directory

	# Dumps each DB in turn.
	for db in $sqlDbs
	do
		echo "Dumping $db."
		mysqldump -h $sqlHost -u $sqlUser $dumpPass $db > sql/${db}.sql
	done

	echo "SQL backup complete."
else
	echo "Skipping SQL backup."
fi

cd .. # Moves back down to the backup dir.

echo "Compressing directory."
tar --bzip2 -cf ${backupTime}.tar.bz2 $backupTime	# --bzip2 option used to be compatible with older versions of tar.

echo "Deleting directory."
rm -r $backupTime	# Deletes the directory. We have a compressed version after all.

echo "rsyncing "
rsync --delete -qarz . ${rsyncLocation}

echo "Deleting old backups."
find . -iname "20*.tar.bz2" -ctime +30 -delete 		# Deletes all backups older than 30 days. Will not work past 2099. Could use *.tar.bz2 instead

echo "Backup script complete."

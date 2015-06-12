#!/bin/sh

# based off the following script
# https://github.com/cowgill/spamhaus

# path to pfctl
PFCTL="/sbin/pfctl";

# tablename
TABLENAME="spamhaus";

# list of known spammers
URL1="http://www.spamhaus.org/drop/drop.lasso";
URL2="http://www.spamhaus.org/drop/edrop.lasso";

# save local copy here
FILE1="/tmp/drop.lasso";
FILE2="/tmp/edrop.lasso";
COMBINED="/tmp/drop-edrop.combined"

# unban old entries
if [ -f $COMBINED ]; then
    for IP in $( cat $COMBINED ); do
        $PFCTL -t $TABLENAME -T delete $IP
    done
fi

# get a copy of the spam lists
fetch -q $URL1 -o $FILE1
if [ $? -ne 0 ]; then
    exit 1
fi
fetch -q $URL2 -o $FILE2
if [ $? -ne 0 ]; then
    exit 1
fi

# combine files and filter
cat $FILE1 $FILE2 | egrep -v '^;' | awk '{ print $1}' > $COMBINED

# remove the spam lists
unlink $FILE1
unlink $FILE2

# ban new entries
for IP in $( cat $COMBINED ); do
    $PFCTL -t $TABLENAME -T add $IP
done

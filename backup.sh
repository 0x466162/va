#!/bin/ksh
BSTORE=/mnt/backup
RET=7
UMOUNT=0

[[ -z $1 ]] && \
{
        echo "please give FS to dump"
        exit 1
}
FS2DUMP="$*"

mount | grep "on $BSTORE "
rt=$?

if [[ $rt -ne 0 ]];
then
        mount /mnt/backup 2>&1 >/dev/null || \
          { echo "can't mount $BSTORE" ; exit 2 ;}
        UMOUNT=1
fi 

for src in $FS2DUMP;
do
        fsname=$src
        fsname=$(echo ${fsname#/*} | tr '/' '_')
        [[ $src == '/' ]] && fsname=rootfs
        dump -h0 -0uaf /mnt/backup/$(date +%Y-%m-%d-full_$fsname.dmp) $src
done

echo "cleaning up..."
find ${BSTORE} -mtime +${RET} -print -exec rm -- {} \;

[[ $UMOUNT -eq 1 ]] && umount $BSTORE

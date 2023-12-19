#!/bin/bash

WORKDIR="/Users/alessandro/Documents/CMS/Phase2/PQC/DBcode/"
DONEDIR="/Users/alessandro/Documents/CMS/Phase2/PQC/DBcode/Loaded/"
NEWDIR="/Users/alessandro/Documents/CMS/Phase2/PQC/DBcode/New/"
ISSUEDIR="/Users/alessandro/Documents/CMS/Phase2/PQC/DBcode/Issue/"
LOGDIR="/Users/alessandro/Documents/CMS/Phase2/PQC/DBcode/Logs/"

#cd $WORKDIR
files=`ls ${NEWDIR}*.zip`
echo "Following files will be processed:"
echo $files
for filename in $files;do
    echo $filename
    batch=`basename ${filename} | sed 's/.zip//g'`
    echo $batch
    echo "unzip $NEWDIR/${batch}.zip -d $NEWDIR"
    unzip -q "${NEWDIR}/${batch}.zip" -d $NEWDIR
    python3 Conversion_txt_to_XML/Convert_txt_to_xml_v2.py $NEWDIR/$batch > "${LOGDIR}${batch}_conversion.log"
    echo "Conversion Done"
    echo "Loading on DB..."
    upload=`python3 ${WORKDIR}cmsdbldr/src/main/python/cmsdbldr_client.py --login --url=https://cmsdca.cern.ch/trk_loader/trker/cmsr "${NEWDIR}/$batch/FinalFiles.zip"`
    `echo $upload > "${LOGDIR}${batch}_dbLoad.log"`
    dbC=`echo $upload | grep "200"`
    if [ "$dbC" = "" ]; then
	echo "Loading Failed"
	mv "${NEWDIR}/${batch}" $ISSUEDIR	    
	mv "${NEWDIR}/${batch}.zip" $ISSUEDIR
    else
	echo "Loading Completed successfully"
	echo "Cleaning files..."
	mv "${NEWDIR}/${batch}.zip" "$DONEDIR/${batch}.zip"
	rm -rf "${NEWDIR}/${batch}"
    fi
done
		

#!/bin/bash

#example of if you had many subjects, can also edit to simply read the folder name if you want too
#for s in $(seq 000 067); do

#change these numbers to the subject folder names for each subject
#for s in 001 002 003; do

#set up a submission to a node, specifing the amount of RAM, max time allowed for processes, where to put text outputs of the process and error files (you could for example change this path to the subject dir so all log files are saved in each subject dir, name of job and the script to run.
#qsub -q compute -l mem=16gb -l walltime=120:00:00 -o ~/Desktop/ -e ~/Desktop/ -N "${s}" -v ids=${s} preproce_cluster.sh  

# Define 
output_path="/imaging/henson/users/rt01/MSc_Project/ADNI"

rm file_list.txt
find ../ADNIdata -type f -name "*Scaled_Br_*" > file_list.txt

# Submit to cluster 
#for id in {0001..0005}; do # for id in {0001..0324}; do 

#echo FileId, participant_id, group, sex, age > ADNIparticipant.csv

header=`head -n 1 ADNI.csv`
echo $header,\"SubId\" >  ADNIparticipant.csv

id=1000
while read line; do
	((id++))

	echo LINE: $line
	fileid=`echo $line | awk -F\/ '{print $6}'`
	echo ID: $fileid

	idn="Sub$id"
	echo $idn
	
	index=0
	while read csv_line; do
		((index++))
		#echo $index
		#grp=`echo $csv_line | awk -F\" '{print $6}'`
		#sex=`echo $csv_line | awk -F\" '{print $8}'`
		#age=`echo $csv_line | awk -F\" '{print $10}'`
		#echo $csv_line | awk -v inx=$index -v fileid=$fileid -v grp=$grp -v sex=$sex -v age=$age -F\" '{ if ($2 == fileid) { print $fileid","idn","grp","sex","age }}' >> ADNIparticipant.csv
		echo $csv_line | awk -v idn=$idn -v fileid=$fileid -v line=$line -F\" '{ if ($2 == fileid) { print $line","idn }}' >> ADNIparticipant.csv
	done < ADNI.csv

	#echo $idn
	sbatch --job-name="Sub${id}_preproc" --mem-per-cpu=32GB --output="/imaging/henson/users/rt01/MSc_Project/ADNI/Sub${id}.log" FS_preproc.sh "$idn" "$line"
done < file_list.txt


#done



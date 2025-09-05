#! /bin/bash

# command line parameters
# $1: Reference genome location
# $2: Path to the flowcell directory
# $3: Sample 1, Read 1
# $4: Sample 1, Read 2
# $5, $6: Sample 2, Read 1 and 2
# $7, $8: Sample 3, Read 1 and 2
# $9, $10: Sample 4, Read 1 and 2
# $11, $12: Sample 5, Read 1 and 2
# $13, $14: Sample 6, Read 1 and 2


perform_alignment ()
{

bowtie2 -p 32 --end-to-end --very-sensitive -3 131 -I 0 -X 200 \
-x $1 \
-1 $2/$3 \
-2 $2/$4 \
-S $5.sam  

samtools view -bS $5.sam > $5.bam 

samtools sort -@ 32 -m 2G $5.bam -o $5.sorted.bam 

samtools index $5.sorted.bam 

samtools bamshuf $5.sorted.bam $5.shuffle 

samtools view $5.shuffle.bam | perl /data/reddylab/software/count_fragments_and_diversity_PE.pm \
             >   $5.fragments \
           2>  $5.complexity 

#bamCoverage --normalizeUsingRPKM -b  $5.sorted.bam -o $5.bigwig

samtools idxstats $5.sorted.bam | awk '{print $1"\t"$3}' | grep -v "^\*" > $5.counts

mv $5.complexity ../analysis
#mv $5.bigwig ../analysis
mv $5.counts ../analysis

}

perform_alignment $1 $2 $3 $4 $5

#perform_alignment $1 $2 $5 $6 pool2
#perform_alignment $1 $2 $7 $8 pool3
#perform_alignment $1 $2 $9 ${10} pool4
#perform_alignment $1 $2 ${11} ${12} pool5
#perform_alignment $1 $2 ${13} ${14} pool6

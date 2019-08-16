
#WD = directory for outfiles to be written to
#REF_GENOME = genome to blast baits to. Checks for non-specific binding of baits.
#ALN_DIR = directory with exon alignments to design baits for in fasta format.
#BaitFisher_Path = path to folder containing  BaitFisher and BaitFilter
#BaitFisherHelper_Path = Path to folder containing BaitFisherHelper files


export WD=/Users/josec/Desktop/exoncap/corals/BaitsV3/BaitFisher_all1
export REF_GENOME=/Users/josec/Desktop/exoncap/corals/RefSeq/GCF_000222465.1_Adig_1.1_genomic.fna
export ALN_DIR=$WD/exonaln_all1
export BaitFisher_Path=/Users/josec/Desktop/Gitclones/BaitFisher-package
export BaitFisherHelper_Path=/Users/josec/Desktop/git_repos/BaitFisherHelper



export A_ALN_DIR=${ALN_DIR}_annotated
cd $WD/
mkdir BF_files
mkdir $A_ALN_DIR


#Prepare Exon alignments by renaming as >GeneID|Taxa using this python script
python3 $BaitFisherHelper_Path/Prepare4baitfisher.py -in $ALN_DIR -out  $A_ALN_DIR
# Set up parameter file for BaitFisher from template
cp $BaitFisherHelper_Path/parameter_template.txt BFparameters.txt
sed -i -e "s|ALN_DIR|$A_ALN_DIR|g" -e "s|WD|$WD|g" BFparameters.txt
#####
#Edit BFparameter file to change baitfisher settings from defaults.
#####
cd $WD/BF_files/
$BaitFisher_Path/BaitFisher-v1.2.8 ../BFparameters.txt
mv ../loci_baits.txt .
$BaitFisher_Path/BaitFilter-v1.0.6 -i loci_baits.txt -m thin-b --thinning-step-width 60 -o prefil_baits.txt 
#Remove baits that blast to multiple locaitons in the reference genome.
$BaitFisher_Path/BaitFilter-v1.0.6 -i prefil_baits.txt --blast-first-hit-evalue 1e-20 --blast-second-hit-evalue 1e-10 --ref-blast-db $REF_GENOME  -o baits_filtered_by_blast-l -m blast-l --blast-extra-commandline "-num_threads 7" 1> o_filter_blast.log 2> e_filter_blast.log
$BaitFisher_Path/BaitFilter-v1.0.6 -i baits_filtered_by_blast-l -c four-column-upload -o prefasta.txt 1> finalstats.txt
#Reformat bait seqs as Fasta
python3 $BaitFisherHelper_Path/BaitFisherCleaner.py -in prefasta.txt -out raw_baits.fasta
#Run dustmasker to identify low complexity regions
dustmasker -in raw_baits.fasta -out dusted_baits.fasta -outfmt 'fasta'

#Remove baits with low complexity regions with:
python3 $BaitFisherHelper_Path/RemovelowercaseSeqs.py -in dusted_baits.fasta -out baits.fasta

# print number of baits
echo 'Number of Baits before dustmask:'
grep ">" raw_baits.fasta | wc -l
echo 'Number of Baits after dustmask:'
grep ">" baits.fasta |wc -l

#delete very large file that can be reproduced in seconds
rm loci_baits.txt
#mv baits file to maid directory
mv baits.fasta $WD

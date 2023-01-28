#!/bin/bash
#SBATCH -p v6_384
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o ./logs/snap_round1.out
#SBATCH -e ./logs/snap_round1.log 

source activate maker

if [ ! -d "./snap/round1" ]; then
	mkdir -p ./snap/round1
fi

cd ./snap/round1

echo 'Started model extraction.'

gff3_merge -d ../../Themeda_rnd1.maker.output/Themeda_rnd1_master_datastore_index.log
# Export 'confident' gene models from MAKER
# Use models with AED>0.25 and Aa_count>=50, helps get rid of junky models.
maker2zff -x 0.25 -l 50 Themeda_rnd1.all.gff
#rename 's/genome/Microstegium_rnd1.zff.length50_aed0.25/g' *
echo 'Completed exporting gene models.'

# Stat gathering and validation
fathom genome.ann genome.dna -gene-stats > gene-stats.log 2>&1
fathom genome.ann genome.dna -validate > validate.log 2>&1

# Collect training sequences and annotations, plus 1000 surrounding bp for training
fathom genome.ann genome.dna -categorize 1000 > categorize.log 2>&1
fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1

# Create training params
mkdir params
cd params
forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..
echo 'Completed creating training params.'

# HMM assembly
hmm-assembler.pl Themeda_rnd1.zff.length50_aed0.25 ./params > Themeda_rnd1.zff.length50_aed0.25.hmm
echo 'Completed assembling hidden markov model.'
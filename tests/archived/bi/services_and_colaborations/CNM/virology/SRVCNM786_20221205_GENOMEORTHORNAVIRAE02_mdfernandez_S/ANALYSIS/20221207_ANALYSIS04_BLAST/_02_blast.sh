srun --chdir /scratch/bi/SRVCNM786_20221205_GENOMEORTHORNAVIRAE02_mdfernandez_S/ANALYSIS/20221207_ANALYSIS04_BLAST --partition middle_idx --mem 376530M --time 48:00:00 --cpus-per-task 10 --output logs/blastn_PTA201_%j.log --job-name blastn_PTA201 blastn -num_threads 10 -db /data/bi/references/virus/BLAST/all_virus.fasta -query ./PTA201.scaffolds.fa -out PTA201.blast.txt -outfmt '6 stitle std slen qlen qcovs' &
srun --chdir /scratch/bi/SRVCNM786_20221205_GENOMEORTHORNAVIRAE02_mdfernandez_S/ANALYSIS/20221207_ANALYSIS04_BLAST --partition middle_idx --mem 376530M --time 48:00:00 --cpus-per-task 10 --output logs/blastn_PTA203_%j.log --job-name blastn_PTA203 blastn -num_threads 10 -db /data/bi/references/virus/BLAST/all_virus.fasta -query ./PTA203.scaffolds.fa -out PTA203.blast.txt -outfmt '6 stitle std slen qlen qcovs' &
srun --chdir /scratch/bi/SRVCNM786_20221205_GENOMEORTHORNAVIRAE02_mdfernandez_S/ANALYSIS/20221207_ANALYSIS04_BLAST --partition middle_idx --mem 376530M --time 48:00:00 --cpus-per-task 10 --output logs/blastn_PTA205_%j.log --job-name blastn_PTA205 blastn -num_threads 10 -db /data/bi/references/virus/BLAST/all_virus.fasta -query ./PTA205.scaffolds.fa -out PTA205.blast.txt -outfmt '6 stitle std slen qlen qcovs' &
srun --chdir /scratch/bi/SRVCNM786_20221205_GENOMEORTHORNAVIRAE02_mdfernandez_S/ANALYSIS/20221207_ANALYSIS04_BLAST --partition middle_idx --mem 376530M --time 48:00:00 --cpus-per-task 10 --output logs/blastn_PTA200_%j.log --job-name blastn_PTA200 blastn -num_threads 10 -db /data/bi/references/virus/BLAST/all_virus.fasta -query ./PTA200.scaffolds.fa -out PTA200.blast.txt -outfmt '6 stitle std slen qlen qcovs' &
srun --chdir /scratch/bi/SRVCNM786_20221205_GENOMEORTHORNAVIRAE02_mdfernandez_S/ANALYSIS/20221207_ANALYSIS04_BLAST --partition middle_idx --mem 376530M --time 48:00:00 --cpus-per-task 10 --output logs/blastn_PTA202_%j.log --job-name blastn_PTA202 blastn -num_threads 10 -db /data/bi/references/virus/BLAST/all_virus.fasta -query ./PTA202.scaffolds.fa -out PTA202.blast.txt -outfmt '6 stitle std slen qlen qcovs' &
srun --chdir /scratch/bi/SRVCNM786_20221205_GENOMEORTHORNAVIRAE02_mdfernandez_S/ANALYSIS/20221207_ANALYSIS04_BLAST --partition middle_idx --mem 376530M --time 48:00:00 --cpus-per-task 10 --output logs/blastn_PTA204_%j.log --job-name blastn_PTA204 blastn -num_threads 10 -db /data/bi/references/virus/BLAST/all_virus.fasta -query ./PTA204.scaffolds.fa -out PTA204.blast.txt -outfmt '6 stitle std slen qlen qcovs' &
srun --chdir /scratch/bi/SRVCNM786_20221205_GENOMEORTHORNAVIRAE02_mdfernandez_S/ANALYSIS/20221207_ANALYSIS04_BLAST --partition middle_idx --mem 376530M --time 48:00:00 --cpus-per-task 10 --output logs/blastn_PTA206_%j.log --job-name blastn_PTA206 blastn -num_threads 10 -db /data/bi/references/virus/BLAST/all_virus.fasta -query ./PTA206.scaffolds.fa -out PTA206.blast.txt -outfmt '6 stitle std slen qlen qcovs' &

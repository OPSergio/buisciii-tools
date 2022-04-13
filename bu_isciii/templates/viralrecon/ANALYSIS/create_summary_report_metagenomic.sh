echo -e "run\tuser\thost\tVirussequence\tsample\ttotalreads\treadshostR1\treadshost\t%readshost\treadsvirus\t%readsvirus\tunmappedreads\t%unmapedreads\tmedianDPcoveragevirus\tCoverage>10x(%)\tVariantsinconsensusx10\tMissenseVariants\t%Ns10x" > mapping_illumina.tab
RUN=$(ls -l ../../RAW/ | cut -d'/' -f4 | sort -u | grep -v 'total' | head -n1)
USER=$(pwd | cut -d '/' -f6 | cut -d '_' -f4)
HOST=$(pwd | cut -d '/' -f8 | cut -d '_' -f4 | tr '[:upper:]' '[:lower:]' | sed 's/.*/\u&/')

cat samples_id.txt | while read in
do
	echo -e "${RUN}\t${USER}\t${HOST}\tNC_045512.2\t${in}\t$(grep 'total_reads' */fastp/${in}.fastp.json | head -n2 | tail -n1 | cut -d ':' -f2 | sed 's/,//g')\t$(cat */kraken2/${in}.kraken2.report.txt | grep -P '\tS' | sort -n -r -k3 | head -n1 | cut -f3)\t$(cat */kraken2/${in}.kraken2.report.txt | grep -P '\tS' | sort -n -r -k3 | head -n1 | cut -f3 | awk '{print ($1*2)}')\t$(cat */kraken2/${in}.kraken2.report.txt | grep -P '\tS' | sort -n -r -k3 | head -n1 | cut -f1 | sed 's/ //g' | tr '.' ',')\t$(cat */variants/bowtie2/samtools_stats/${in}.sorted.bam.flagstat | grep '+ 0 mapped' | cut -d ' ' -f1)\t$(cat */multiqc/summary_variants_metrics_mqc.csv | grep ^${in}, | cut -d ',' -f5 | tr '.' ',')\t$(echo "$(echo -e "$(grep 'total_reads' */fastp/${in}.fastp.json | head -n2 | tail -n1 | cut -d ':' -f2 | sed 's/,//g')\t$(cat */kraken2/${in}.kraken2.report.txt | grep -P '\tS' | sort -n -r -k3 | head -n1 | cut -f3 | awk '{print $1*2}')\t$(cat */variants/bowtie2/samtools_stats/${in}.sorted.bam.flagstat | grep '+ 0 mapped' | cut -d ' ' -f1)" | awk '{print $1-($2+$3)}')")\t$(echo "$(echo -e "$(grep 'total_reads' */fastp/${in}.fastp.json | head -n2 | tail -n1 | cut -d ':' -f2 | sed 's/,//g')\t$(cat */kraken2/${in}.kraken2.report.txt | grep -P '\tS' | sort -n -r -k3 | head -n1 | cut -f3 | awk '{print $1*2}')\t$(cat */variants/bowtie2/samtools_stats/${in}.sorted.bam.flagstat | grep '+ 0 mapped' | cut -d ' ' -f1)" | awk '{print (($1-($2+$3))/$1)*100}')" | tr '.' ',')\t$(cat */multiqc/summary_variants_metrics_mqc.csv | grep ^${in}, | cut -d ',' -f8 | tr '.' ',')\t$(cat */multiqc/summary_variants_metrics_mqc.csv | grep ^${in}, | cut -d ',' -f10 | tr '.' ',')\t$(zcat */variants/ivar/consensus/bcftools/${in}.filtered.vcf.gz | grep -v '^#' | wc -l)\t$(LC_ALL=C awk -F, '{if($10 >= 0.75)print $0}' */variants/ivar/variants_long_table.csv | grep ^${in}, | grep 'missense' | wc -l)\t$(cat %Ns.tab | grep -w ${in} | cut -f2 | tr '.' ',')"  >> mapping_illumina.tab
done

#!/usr/bin/python

# USAGE:
# python3 step7-extract-genic-gff-convert.py themeda_seq_translation_brief.tab themeda_aed0.5_noseq_final.gff themeda_aed0.5_genic_final.gff
import sys

seq_tr_dict = {}  # Seq_1 (Nomenclature IDs) -> NC000000.1 (Meaningful sequence names)

with open(sys.argv[1], mode='r') as in_seqtr_tab_fh:
	for entry in in_seqtr_tab_fh:
		if len(list(entry.split("\t")) == 2):
			seq_tr_dict[str(entry.split("\t")[0])] = str(entry.split("\t")[1])


with open(sys.argv[2], mode='r') as in_gff_fh:
	with open(sys.argv[3], mode='w') as out_gff_fh:

		for entry in in_gff_fh:
			if not entry.startswith("#"):
				entry_split_list = entry.split("\t")
				
				if str(entry_split_list[2]) in ["contig", "gene", "mRNA", "exon", "CDS", "five_prime_UTR", "three_prime_UTR"]:
					if seq_tr_dict[str(entry_split_list[0])]:
						entry_split_list[0] = seq_tr_dict[str(entry_split_list[0])]
					else:
						print("Warning: no sequence match in translation tab:\n%s" % entry)

					out_gff_fh.write("\t".join(entry_split_list))
			else:
				out_gff_fh.write(entry)
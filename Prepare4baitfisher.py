#!/usr/bin/python
import os
import sys
from pathlib import Path
from Bio import SeqIO

"""
Copies each fasta in -in to -out dir renaming the name of each sequence. 
Sequences are named ">infilename|infastaname"

***example*** 

infile named indir/Gene22.fasta:
>taxa1
AGATCG
>taxa2
GCTAGC

outfile named outdir/Gene22.fasta:
>Gene22|taxa1
AGATCG
>Gene22|taxa2
GCTAGC
"""

def pipe(indir, outdir):
    p_in = Path(indir)
    p_out = Path(outdir)
    files = list(p_in.glob('*.fas*'))
    for file in files:
        filename = file.name
        genename = file.stem
        record2write = []
        for record in SeqIO.parse(str(file),'fasta'):
            recordnamestring = f"{genename}|{record.name}"
            record.id = recordnamestring
            record.description = ''
            # record.name = recordnamestring
            record2write.append(record)
        SeqIO.write(record2write, str(p_out.joinpath(filename)) ,'fasta')
    return


def main():
    args = sys.argv[1:]
    usage='usage: python3 Prepare4baitfisher.py -in Dir/with/exonaln -out Dir/with/renamed_exonaln'
    if not args:
        print(usage)
        sys.exit(1)

    if args[0] == '-in':
        indir = args[1]
        del args[0:2]
    if args[0] == '-out':
        outdir = args[1]
        del args[0:2]
    else:
        print(usage)

    pipe(indir=indir, outdir=outdir)
    return

if __name__ == '__main__':
    main()


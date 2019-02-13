#!/usr/bin/python3
import os
import sys
from pathlib import Path
from Bio import SeqIO

"""
Reads the -in fasta file and copies it to the -out fasta file. Only sequences with ALL UPPERCASE bp are copied.
If bp of a sequence has lowercase letters it is not copied to the outfile.
"""


def copy_upper_only(infile,outfile):
    outrecords = []
    for record in SeqIO.parse(str(Path(infile)), "fasta"):
        if any(c.islower() for c in record.seq):
            pass
        else:
            outrecords.append(record)
    SeqIO.write(outrecords, str(Path(outfile)), "fasta")

    return

def main():
    args = sys.argv[1:]
    usage='usage: python3 RemovelowercaseSeqs.py -in dustmasked_seqs.fasta -out OnlyUPPERseqs.fasta'
    if not args:
        print(usage)
        sys.exit(1)

    if args[0] == '-in':
        infile = args[1]
        del args[0:2]
    if args[0] == '-out':
        outfile = args[1]
        del args[0:2]
    else:
        print(usage)
    copy_upper_only(infile=infile,outfile=outfile)

            
if __name__ == '__main__':
    main()

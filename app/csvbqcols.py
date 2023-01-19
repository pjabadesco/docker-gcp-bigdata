#!/usr/bin/env python
import argparse
import csv

def get_args():
    """Get CLI arguments and options"""
    parser = argparse.ArgumentParser(
        prog='csvbqcols',
        description='small utility to convert columns files for bigquery'
    )
    parser.add_argument('input')
    parser.add_argument('output', nargs='?', default=None)
    parser.add_argument('-c', '--cols',
                        default=',',
                        help='schema cols')
    return parser.parse_args()


def convert(bcpdata, lineterminator='*@@*', delimiter='@**@', quote='"', newdelimiter=',', escapechar='\\', newline='\n'):
    bcpdata = bcpdata.replace(newline, ' ')
    bcpdata = bcpdata.replace('\r', ' ')
    bcpdata = bcpdata.replace(escapechar, escapechar + escapechar)
    bcpdata = bcpdata.replace(quote, quote + quote)
    bcpdata = bcpdata.replace(delimiter, quote + newdelimiter + quote)
    bcpdata = bcpdata.replace(lineterminator, quote + newline + quote)
    # bcpdata = quote + bcpdata + quote
    return bcpdata

def main():
    args = get_args()
    with open(args.input, 'r') as fi, open(args.output, 'a') as fo:
        fo.write('"')
        for line in fi:            
            fo.write(convert(line))        
        fo.write('"')

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass

#!/usr/bin/env python
import argparse
import json
import time
from subprocess import check_output

def get_args():
    """Get CLI arguments and options"""
    parser = argparse.ArgumentParser(
        prog='bq2bq',
        description='small utility to copy bigquery datasets cross-project'
    )
    parser.add_argument('FROM_PROJECT')
    parser.add_argument('TO_PROJECT')
    parser.add_argument('DATASET')
    return parser.parse_args()

args = get_args()
tables = json.loads(check_output("bq ls --max_results=300 --format=json "+ args.DATASET, shell=True).decode())

try:
    check_output('bq ls -d --project_id=' + args.TO_PROJECT + ' | grep -w ' + args.DATASET, shell=True)
except Exception as e:
    check_output('bq mk --location=asia-southeast1 --project_id=' + args.TO_PROJECT + ' ' + args.DATASET, shell=True)

for table_item in tables:
    table = table_item['tableReference']['tableId']
    print("Table = " + args.DATASET + "." + table)
    
    command = 'bq cp -f ' + args.FROM_PROJECT + ':' + args.DATASET + '.' + table + ' ' + args.TO_PROJECT + ':' + args.DATASET + '.' + table
    print(command)

    try:
        result = check_output(command, shell=True)

    except Exception as e:
        continue

    print(result)
    time.sleep(5)
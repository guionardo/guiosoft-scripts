import datetime
import os
from sys import argv

from fetchers import FETCHERS
from markdown_parser import replace_content
from models import Versions


def main():
    if len(argv) < 2:
        print('Expected README.md path')
        exit(1)
    readme = argv[1]
    if not os.path.exists(readme):
        print(readme, 'not found')
        exit(1)
    versions = Versions()
    for fetcher in FETCHERS:
        if info := fetcher().fetch():
            versions[info.name] = info

    versions_json = os.path.join(os.path.dirname(
        os.path.abspath(readme)), 'versions.json')
    with open(versions_json, 'w') as j:
        j.write(versions.to_json())
    print('Created ', versions_json)

    md_table = list(versions.to_md_table())

    md_table.extend(
        ['', f'[versions.json updated @ {datetime.datetime.now()}](versions.json)', ''])
    new_md = replace_content(readme, 'Software Versions', md_table)
    with open(readme) as file:
        old_content = file.read()
        if old_content == new_md:
            print('No changes')
            exit(1)

    with open(readme, 'w') as file:
        file.write(new_md)
    print('Updated versions')


if __name__ == '__main__':
    main()

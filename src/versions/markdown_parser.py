from typing import List


def replace_content(filename: str, header_name: str, new_content: List[str], header_level: int = 2) -> str:
    with open(filename) as file:
        rows = file.readlines()
    header = '#'*header_level
    found = False
    new_body = []
    row = ''
    not_found = True
    not_updated = True
    for row in rows:
        row = row.rstrip()
        if not found:
            if row.startswith(f'{header} {header_name}'):
                found = True
                not_found = False
            new_body.append(row)
            continue

        if row.startswith('#'):
            if found:
                # End of header1
                new_body.extend(['', *new_content, '', row])
                found = False
                not_updated = False
            else:
                new_body.append(row)

    if not_found:
        new_body.extend(['', f'{header} {header_name}', '', *new_content])
    elif not_updated:
        new_body.extend(['', *new_content])
    if not row:
        new_body.append('')

    return '\n'.join(new_body)

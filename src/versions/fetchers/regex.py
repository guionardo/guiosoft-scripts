import re
from typing import Optional


def get_first_match(regex: str, text: str | bytes) -> Optional[str]:
    if isinstance(text, bytes):
        text = text.decode('utf-8')
    matches = re.finditer(regex, text, re.MULTILINE)
    for _, match in enumerate(matches, start=1):
        for group in match.groups():
            return group

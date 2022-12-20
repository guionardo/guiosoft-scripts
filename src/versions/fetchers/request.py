import shutil
from io import BytesIO
from typing import Tuple

import requests
from tqdm.auto import tqdm


def get(url: str, raise_for_status: bool = False) -> Tuple[bytes, int]:
    """Do a HTTP GET request and returns body and status code"""
    print('GET ', url)
    with requests.get(url, stream=True) as resp:
        # if resp.
        # if raise_for_status:
        #     resp.raise_for_status()
        total_size = int(resp.headers.get('Content-Length', '0'))
        if total_size == 0 or resp.content:
            return resp.content, resp.status_code
        with tqdm.wrapattr(resp.raw, "read", total=total_size, desc='') as raw:
            body = BytesIO()
            shutil.copyfileobj(raw, body)

        body.seek(0, 0)
        return body.read(), resp.status_code

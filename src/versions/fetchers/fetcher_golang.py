import datetime
import logging
from typing import Optional

from packaging.version import Version

from .fetcher import Fetcher, SoftwareInfo
from .regex import get_first_match


class FetcherGolang(Fetcher):

    def do_fetch(self) -> Optional[SoftwareInfo]:
        body, status = self.get('https://golang.org/dl/')
        if not (200 <= status < 300):
            return
        latest_url = get_first_match(
            r'<a class=\"download downloadBox\" href=\"(\/dl\/go.*.linux-amd64.tar.gz)">', body)
        if not latest_url or not (version := get_first_match(r'([0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2})', latest_url)):
            return
        today = datetime.datetime.now()
        today = datetime.datetime(today.year, today.month, today.day)
        return SoftwareInfo('golang', Version(version), version, 'https://golang.org'+latest_url, today)

    def get_logger(self) -> logging.Logger:
        return logging.getLogger(self.__class__.__name__)

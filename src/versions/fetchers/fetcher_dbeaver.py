import logging
from typing import Optional, Tuple

from .fetcher import Fetcher, SoftwareInfo


class FetcherDBeaver(Fetcher):

    def do_fetch(self) -> Optional[SoftwareInfo]:

        version, name, release_date = self.get_github_release()
        return SoftwareInfo('dbeaver', version, name, 'https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb', release_date)

    def get_github_data(self) -> Tuple[str, str]:
        return 'dbeaver', 'dbeaver'

    def get_logger(self) -> logging.Logger:
        return logging.getLogger(self.__class__.__name__)

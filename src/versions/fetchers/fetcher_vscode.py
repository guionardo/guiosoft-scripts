import logging
from typing import Optional

from .fetcher import Fetcher, SoftwareInfo


class FetcherVsCode(Fetcher):

    def do_fetch(self) -> Optional[SoftwareInfo]:
        version, name, release_date = self.get_github_release()

        return SoftwareInfo("vscode", version, name, 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64', release_date)

    def get_github_data(self):
        return 'microsoft', 'vscode'

    def get_logger(self) -> logging.Logger:
        return logging.getLogger(self.__class__.__name__)

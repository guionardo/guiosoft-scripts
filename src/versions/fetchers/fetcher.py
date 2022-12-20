import json
import logging
from typing import Optional, Protocol, Tuple

from dateutil import parser
from models import SoftwareInfo
from packaging.version import Version

from .request import get


class Fetcher(Protocol):

    def fetch(self) -> Optional[SoftwareInfo]:
        """Fetch software info"""
        try:
            return self.do_fetch()
        except Exception as exc:
            self.get_logger().error('Error on fetching - %s', exc)

    def get_github_data(self) -> Tuple[str, str]:
        """Get owner and repository names"""

    def get_github_release(self):
        owner, repository = self.get_github_data()
        body, _ = get(
            f'https://api.github.com/repos/{owner}/{repository}/releases/latest')
        release = json.loads(body)

        return Version(release['tag_name']), release['name'], parser.parse(release['published_at'])

    def get(self, url: str, raise_for_status: bool = False) -> Tuple[bytes, int]:
        return get(url, raise_for_status)

    def get_logger(self) -> logging.Logger:
        """Current logger"""

    def do_fetch(self) -> Optional[SoftwareInfo]:
        """Implements fetch"""

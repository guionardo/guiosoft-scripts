import json
from dataclasses import dataclass
from datetime import datetime
from typing import Optional

from packaging.version import Version


@dataclass
class SoftwareInfo:
    name: str
    version: Optional[Version]
    release_name: Optional[str]
    artifact_url: str
    release_date: Optional[datetime]

    def to_dict(self) -> dict:
        return dict(name=self.name,
                    version=str(self.version),
                    release_name=self.release_name,
                    artifact_url=self.artifact_url,
                    release_date=self.release_date)


class Versions(dict):

    def set(self, si: SoftwareInfo):
        self[si.name] = si

    def to_md_table(self):
        yield '| Name | Version | Date | Release |'
        yield '|------|---------|------|---------|'
        for name, info in self.items():
            yield f'| {name} | {info.version} | {info.release_date.strftime("%Y-%m-%d")} | [{info.release_name}]({info.artifact_url}) |'

    def to_json(self):
        json_dict = {
            k: v.to_dict() for k, v in self.items()
        }
        return json.dumps(json_dict, indent=2, default=str)

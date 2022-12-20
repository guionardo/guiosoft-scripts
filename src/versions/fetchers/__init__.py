from .fetcher_dbeaver import FetcherDBeaver
from .fetcher_golang import FetcherGolang
from .fetcher_vscode import FetcherVsCode

FETCHERS = [FetcherVsCode, FetcherDBeaver, FetcherGolang]

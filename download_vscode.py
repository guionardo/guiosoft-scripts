import json
import os
import urllib.request
from hashlib import sha256


def get_metadata():
    try:
        print("Setup VSCODE")
        print("* Obtendo metadata para download")
        contents = urllib.request.urlopen(
            "https://code.visualstudio.com/sha?build=stable").read()
        jc: dict = json.loads(contents)
        assert (isinstance(jc, dict) and isinstance(
            jc.get('products'), list)), "Conteúdo inválido"
        product = [p for p in jc.get('products') if p.get(
            'platform', {}).get('os', '_') == 'linux-deb-x64']
        if product:
            return product[0]
        raise Exception("Não foi possível identificar versão linux-dev-x64")
    except Exception as exc:
        print(exc)
    return None


def download_vscode(metadata):
    assert metadata, "Metadata não encontrado"
    url = metadata.get('url')
    assert url, "URL não encontrada"
    sha256hash = metadata.get('sha256hash')
    assert sha256hash, "Hash não encontrado"

    descricao = '{0} v{1}'.format(
        metadata['platform']['prettyname'], metadata['productVersion'])
    assert '_' not in descricao, "Erro na identificação da versão"
    print(f'* vscode {descricao}')
    # [{'url': 'https://az764295.vo.msecnd.net/stable/3866c3553be8b268c8a7f8c0482c0c0177aa8bfa/code_1.59.1-1629375198_amd64.deb', 'name': '1.59.1', 'version': '3866c3553be8b268c8a7f8c0482c0c0177aa8bfa', 'productVersion': '1.59.1',
    #     'hash': 'f0211b887b784c9a1e93b1c08c13845b24503313', 'timestamp': 1629373952829, 'sha256hash': '417fdb32aa3c1116439de3f88a7c173c256efbdbe277a08940431670cacb7392', 'build': 'stable', 'platform': {'os': 'linux-deb-x64', 'prettyname': 'Linux .deb (64 bit)'}}]
    try:
        print("* Efetuando download do vscode: ", url)
        content = urllib.request.urlopen(url).read()

        hash = sha256(content)
        assert hash.hexdigest(
        ) == sha256hash, f"Hash esperado: {sha256hash} -> recebido: {hash.hexdigest()}"
        file_name = os.path.basename(url)

        with open(file_name, 'wb') as f:
            f.write(content)
        return file_name
    except Exception as exc:
        print(exc)


if __name__ == '__main__':
    metadata = get_metadata()
    # print(metadata)
    filename = download_vscode(metadata)
    # print(filename)

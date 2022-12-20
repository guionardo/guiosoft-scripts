import unittest
import tempfile


from versions.markdown_parser import replace_content


class TestMarkdownParser(unittest.TestCase):

    original_content = """
# Test 1

Test name

## Some header

Some data

## Target header

Old data

## Some another header

BLABLABLA

"""
    expected_content = """
# Test 1

Test name

## Some header

Some data

## Target header

New data
Second new line

## Some another header

BLABLABLA

"""

    def test_0(self):
        with tempfile.NamedTemporaryFile('w', delete=True) as tmp:
            tmp.write(self.original_content)
            tmp.flush()

            new_content = replace_content(tmp.name, 'Target header', [
                                          'New data', 'Second new line'])
        expected = self.expected_content.splitlines(keepends=False)
        new = new_content.splitlines(keepends=False)
        print(expected)
        print(new)
        self.assertListEqual(expected, new)

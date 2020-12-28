# Font Ligaturizer

Adding programming ligatures from [FiraCode](https://github.com/tonsky/FiraCode) to any font

## Usage

Simply execute `ligaturize.py` with a font file. This script is currently hardcoded to use `./ligature-source/firacode` as the source for ligatures.

```bash
python3 ligaturize.py ./sample/DejaVuSansMono.ttf
```

The resulting font will add 'Liga` as a suffix eg: ./sample/DejaVuSansMonoLiga.ttf

Optionally, you can provide an output file name as a second parameter if you wish however, this will not change the name of the resulting font:

```bash
python3 ligaturize.py ./sample/DejaVuSansMono.ttf ./sample/ModifiedDejaVuSansMono.ttf
```

### Requirements

This script requires FontForge python bindings. For Debian/Ubuntu they are available in `python-fontforge` package.

#### Python

- python3-fontforge | python-fontforge

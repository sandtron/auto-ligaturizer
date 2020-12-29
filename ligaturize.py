import os
import sys
import fontforge
import json


def _decode_list(data):
    rv = []
    for item in data:
        if isinstance(item, unicode):
            item = item.encode('utf-8')
        elif isinstance(item, list):
            item = _decode_list(item)
        elif isinstance(item, dict):
            item = _decode_dict(item)
        rv.append(item)
    return rv


def _decode_dict(data):
    rv = {}
    for key, value in data.iteritems():
        if isinstance(key, unicode):
            key = key.encode('utf-8')
        if isinstance(value, unicode):
            value = value.encode('utf-8')
        elif isinstance(value, list):
            value = _decode_list(value)
        elif isinstance(value, dict):
            value = _decode_dict(value)
        rv[key] = value
    return rv


ligature_source_dir = os.path.join(sys.path[0], "ligature-sources/firacode")

in_file = sys.argv[1]

try:
    out_file = sys.argv[2]
except IndexError:
    in_file_name, in_file_ext = os.path.splitext(in_file)
    out_file = in_file_name+"Liga"+in_file_ext

config = {
    'source_ttf': in_file,
    'output': {
        'filename': out_file,
        'copyright_add': "\nProgramming ligatures added by Ilya Skriblovsky from FiraCode\nFiraCode Copyright (c) 2015 by Nikita Prokopov"
    }}

with open(os.path.join(ligature_source_dir, 'mapping.json'), 'r') as cfg:
    jsonCfg = json.load(cfg, object_hook=_decode_dict)
    config["add_ligatures"] = jsonCfg["add_ligatures"]
    config["ligature_source_ttf"] = os.path.join(
        ligature_source_dir, jsonCfg["source_ligature_filename"])


class LigatureCreator(object):

    def __init__(self, font, ligature_source_font):
        self.font = font
        self.ligature_source_font = ligature_source_font

        self._lig_counter = 0

    def add_ligature(self, input_chars, source_ligature_name):
        self._lig_counter += 1

        ligature_name = 'lig.{}'.format(self._lig_counter)

        self.font.createChar(-1, ligature_name)
        ligature_source_font.selection.none()
        ligature_source_font.selection.select(source_ligature_name)
        ligature_source_font.copy()
        self.font.selection.none()
        self.font.selection.select(ligature_name)
        self.font.paste()

        self.font.selection.none()
        self.font.selection.select('space')
        self.font.copy()

        def lookup_name(i): return 'lookup.{}.{}'.format(self._lig_counter, i)
        def lookup_sub_name(i): return 'lookup.sub.{}.{}'.format(
            self._lig_counter, i)

        def cr_name(i): return 'CR.{}.{}'.format(self._lig_counter, i)

        for i, char in enumerate(input_chars):
            self.font.addLookup(lookup_name(i), 'gsub_single', (), ())
            self.font.addLookupSubtable(lookup_name(i), lookup_sub_name(i))

            if i < len(input_chars) - 1:
                self.font.createChar(-1, cr_name(i))
                self.font.selection.none()
                self.font.selection.select(cr_name(i))
                self.font.paste()

                self.font[char].addPosSub(lookup_sub_name(i), cr_name(i))
            else:
                self.font[char].addPosSub(lookup_sub_name(i), ligature_name)

        calt_lookup_name = 'calt.{}'.format(self._lig_counter)
        self.font.addLookup(calt_lookup_name, 'gsub_contextchain', (), (('calt', (('DFLT', ('dflt',)), ('arab', ('dflt',)), ('armn', ('dflt',)), ('cyrl', ('SRB ', 'dflt')), ('geor', ('dflt',)), (
            'grek', ('dflt',)), ('lao ', ('dflt',)), ('latn', ('CAT ', 'ESP ', 'GAL ', 'ISM ', 'KSM ', 'LSM ', 'MOL ', 'NSM ', 'ROM ', 'SKS ', 'SSM ', 'dflt')), ('math', ('dflt',)), ('thai', ('dflt',)))),))
        for i, char in enumerate(input_chars):
            ctx_subtable_name = 'calt.{}.{}'.format(self._lig_counter, i)
            ctx_spec = '{prev} | {cur} @<{lookup}> | {next}'.format(
                prev=' '.join(cr_name(j) for j in range(i)),
                cur=char,
                lookup=lookup_name(i),
                next=' '.join(input_chars[i+1:]),
            )
            self.font.addContextualSubtable(
                calt_lookup_name, ctx_subtable_name, 'glyph', ctx_spec)


def change_font_names(font,  copyright_add):
    font.fontname += " Liga"
    font.fullname += "Liga"
    font.familyname += " Liga"
    font.copyright += copyright_add
    font.sfnt_names = tuple(
        (row[0], 'UniqueID', 'Liga') if row[1] == 'UniqueID' else row
        for row in font.sfnt_names
    )


font = fontforge.open(config['source_ttf'])
ligature_source_font = fontforge.open(config['ligature_source_ttf'])
ligature_source_font.em = font.em

creator = LigatureCreator(font, ligature_source_font)
def ligature_length(lig): return len(lig['chars'])


for lig_spec in sorted(config['add_ligatures'], key=ligature_length):
    try:
        creator.add_ligature(
            lig_spec['chars'], lig_spec['source_ligature_name'])
    except Exception as e:
        print('Exception while adding ligature: {}'.format(lig_spec))
        raise

change_font_names(font, config['output']['copyright_add'])

font.generate(config['output']['filename'])

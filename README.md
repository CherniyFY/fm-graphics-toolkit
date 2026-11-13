# fm-graphics-toolkit

Two small tools for managing the graphics folder of a Football Manager install:
extract a graphics pack into place, then check that every image it declares
actually resolves.

Ships no game files, no graphics packs, nothing downloaded. Nothing here
fetches from the network.

Unofficial. Not affiliated with Sports Interactive or Sega.

## The graphics folder

Football Manager reads loose images from a `graphics` folder inside the user
data directory:

| platform | path |
| --- | --- |
| Windows | `Documents\Sports Interactive\Football Manager <ver>\graphics` |
| Linux / Proton | `<prefix>/drive_c/users/<user>/Documents/Sports Interactive/Football Manager <ver>/graphics` |

Inside it, packs sit in their own subfolders, conventionally grouped by type:

```
graphics/
  logos/<pack name>/
  kits/<pack name>/
  faces/<pack name>/
  config.xml            <- optional, pack-level
```

Each `<pack name>` folder carries a `config.xml` that maps a source image to a
game entity:

```xml
<record>
  <boolean id="preload" value="true"/>
  <boolean id="amap" value="true"/>
  <list id="maps">
    <record from="arsenal" to="graphics/pictures/club/602/logo"/>
  </list>
</record>
```

`from` is a filename relative to the `config.xml` (backslashes or forward
slashes, extension usually omitted). If the file is absent, the entry is dead:
no error, no visible fallback, just a missing badge in game. That silent
failure is what `check_graphics.py` exists for.

The game caches these images. After installing a pack, clear the cache
(Preferences -> Interface -> Clear cache) or nothing changes on screen.

## Install a pack

```
./install_pack.sh <archive> <graphics-root>/logos
```

- `unrar` for `.rar`, `7z` for everything else.
- Extracts to a temp dir, counts files, then copies the tree into the target.
- Refuses `*.part` (incomplete download).
- Refuses archives with no `config.xml`, since such a pack maps nothing.
- Existing files in the target are overwritten; the archive wins.

Nothing is deleted. Point the target at a fresh subfolder when a pack is meant
to replace an older one, then remove the old folder by hand.

## Validate the folder

```
./check_graphics.py <graphics-root>
```

Prints one summary line:

```
configs=412 mappings=98311 xml_errors=0 missing=37
```

- `configs` — `config.xml` files found under the root.
- `mappings` — `<record from=...>` entries across all of them.
- `xml_errors` — configs that failed to parse.
- `missing` — mappings whose image is absent (tried `from`, `from.png`,
  `from` + `.png` literally).

Then up to 20 `MISSING <config> <from>` lines and 10 `XMLERR <config> <error>`
lines. Exit status is always 0 — read the summary line, do not branch on exit
code.

Typical readings on a healthy, fully populated folder: `xml_errors=0` and
`missing=0`. A nonzero `missing` that stays constant across a reinstall means
the pack itself is incomplete, not the copy.

## Requirements

- `python3` (stdlib only) for `check_graphics.py`
- `bash`, `find`, `mapfile` (bash 4+), `7z`, `unrar` as needed for `install_pack.sh`

## Validation

Validated with synthetic fixtures for resolved and missing image mappings,
malformed XML, successful ZIP installation, rejection of archives without a
`config.xml`, incomplete downloads, and command usage errors.

## License

MIT

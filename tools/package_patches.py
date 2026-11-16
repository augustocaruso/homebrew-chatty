"""Package the reviewed patch files with deterministic, non-personal metadata."""

import argparse
import gzip
import hashlib
import tarfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path, help="New .tar.gz release asset")
    arguments = parser.parse_args()
    root = Path(__file__).resolve().parents[1] / "patches"
    with (
        arguments.destination.open("xb") as raw,
        gzip.GzipFile(fileobj=raw, filename="", mode="wb", mtime=0) as compressed,
        tarfile.open(
            fileobj=compressed, mode="w", format=tarfile.USTAR_FORMAT
        ) as archive,
    ):
        for path in sorted(root.rglob("*.patch")):
            info = tarfile.TarInfo(path.relative_to(root).as_posix())
            info.size = path.stat().st_size
            info.mode = 0o644
            info.mtime = 0
            with path.open("rb") as source:
                archive.addfile(info, source)
    with arguments.destination.open("rb") as source:
        print(hashlib.file_digest(source, "sha256").hexdigest())


if __name__ == "__main__":
    main()

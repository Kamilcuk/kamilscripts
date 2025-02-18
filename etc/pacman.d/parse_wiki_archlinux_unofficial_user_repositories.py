#!/usr/bin/env python
import logging
import os
import argparse
import subprocess
import re
import sys
from dataclasses import dataclass
from html.parser import HTMLParser
from pathlib import Path
from typing import Callable, Dict, List, Optional, Tuple

import requests


@dataclass
class Section:
    signed: bool
    name: str
    comment: str = ""
    config: str = ""

    def str(self):
        ret = "\n".join(
            [
                f"# {self.name}",
                *(
                    f"# {line.strip()}"
                    for line in self.comment.splitlines()
                    if line.strip()
                ),
                *(line for line in self.config.splitlines() if line),
                "",
            ]
        )
        assert ret, f"{self}"
        return ret

    def is_signed_by_tu(self):
        return any(
            re.match("Key-ID:.*TU[.]?", line) or re.match("Key-ID:.*Not needed.*", line)
            for line in self.comment.splitlines()
        )

    def is_valid(self):
        assert "\n" not in self.name
        ret = self.name and self.comment and self.config
        if ret:
            assert self.config.count("\n") > 2
        return ret


class MyHTMLParser(HTMLParser):
    tag: str = ""
    """Last tag"""
    attrs: Dict[str, Optional[str]] = {}
    """Last tag attributes"""
    lastid: Optional[str] = None

    issigned: Optional[bool] = None
    """Signed or not signed"""

    cursection: Optional[Section] = None
    sections: List[Section] = []

    def handle_starttag(self, tag, attrs):
        self.tag = tag
        self.attrs = {a[0]: a[1] for a in attrs}
        if (
            self.tag == "span"
            and self.attrs.get("class") == "mw-headline"
            and self.attrs.get("id")
        ):
            self.lastid = self.attrs["id"]
            if self.lastid == "Signed":
                self.issigned = True
                self.cursection = None
            elif self.lastid == "Unsigned":
                self.issigned = False
                self.cursection = None
            if self.issigned is not None:
                # print(self.cursection)
                assert self.lastid
                self.cursection = Section(self.issigned, self.lastid)
                self.sections.append(self.cursection)
        # logging.debug(f"Encountered a start tag: {tag} {attrs}")
        pass

    def handle_endtag(self, tag):
        pass

    def handle_data(self, data):
        # logging.debug(f"Encountered some data: {data}")
        if self.issigned is not None:
            issignedstr = f"{'' if self.issigned else 'un'}signed"
            if self.lastid == "ada":
                print(f"{issignedstr} {self.lastid} {self.tag} {self.attrs} {data}")
            if self.cursection:
                if self.tag == "b" and self.attrs == {} and data.strip():
                    if data.endswith(":") and not self.cursection.comment.endswith(
                        "\n"
                    ):
                        self.cursection.comment += "\n"
                    self.cursection.comment += f"{data} "
                elif data and self.tag == "a" and "href" in self.attrs:
                    if "html" in str(self.attrs["href"]):
                        self.cursection.comment += f"[{self.attrs['href']}]({data})"
                    else:
                        self.cursection.comment += f"{data}"
                elif self.tag == "pre" and self.attrs == {}:
                    self.cursection.config += data
        pass


def output(filename: str, sections: List[Section]):
    assert sections, f"No sections to write to {filename}"
    print(f"---- {filename} Writing {len(sections)} sections ----")
    if len(sections) == 1:
        for s in sections:
            print(s.str().strip())
    with open(filename, "w") as f:
        print("# DO NOT EDIT MANUALLY", file=f)
        print(f"# {filename} generated by {Path(sys.argv[0]).name} script", file=f)
        print(file=f)
        print(file=f)
        for s in sections:
            print(s.str(), file=f)
    print(f"---- {filename} Done writing ----")


def partition(
    sections: List[Section], condition: Callable[[Section], bool]
) -> Tuple[List[Section], List[Section]]:
    """Partition a list of section depending on condition. Return list if true condition first."""
    return (
        [s for s in sections if condition(s)],
        [s for s in sections if not condition(s)],
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("download", "parse"))
    args = parser.parse_args()
    if args.mode == "download":
        subprocess.check_call(
            "curl -sS https://wiki.archlinux.org/title/Unofficial_user_repositories >./_unofficial_user_repositories.html",
            shell=True,
        )
        exit()
    logging.basicConfig(level=logging.DEBUG)
    os.chdir(Path(__file__).parent)
    pagef = Path("_unofficial_user_repositories.html")
    if not pagef.exists():
        r = requests.get(
            "https://wiki.archlinux.org/title/unofficial_user_repositories"
        )
        with open(pagef, "wb") as f:
            f.write(r.content)

    with open(pagef, "r") as f:
        parser = MyHTMLParser()
        parser.feed(f.read())

    sections = parser.sections
    sections = [x for x in sections if x.is_valid()]
    # Ignore alph, because it's managed by AUR
    alhp, sections = partition(sections, lambda s: s.name.upper() == "ALHP")
    archzfs, sections = partition(sections, lambda s: s.name == "archzfs")
    signed, unsigned = partition(sections, lambda s: s.signed)
    signed_TU, signed_notTU = partition(signed, lambda s: s.is_signed_by_tu())
    best_names = ["ownstuff", "chaotic-aur", "archlinuxcn"]
    best_repos = [s for s in sections if s.name in best_names]
    assert len(best_repos) == len(best_names), f"{best_names}\n{best_repos}"
    output("unofficial_best_repositories.conf", best_repos)
    output("archzfs.conf", archzfs)
    output("alhp.conf", alhp)
    output("unofficial_signed_TU_repositories.conf", signed_TU)
    output("unofficial_signed_notTU_repositories.conf", signed_notTU)
    output("unofficial_unsigned_repositories.conf", unsigned)


if __name__ == "__main__":
    main()

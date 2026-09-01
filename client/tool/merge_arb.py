#!/usr/bin/env python3
"""Fold the per-feature string fragments into the two ARB files.

The extraction was split across several workers, each writing its own keys to
`lib/l10n/_pending_<area>_{en,zh}.json`, so that they could not clobber one
another in a shared file. This merges them and refuses to do so quietly when
something is wrong:

  - a key defined twice with different English is a collision, not a merge
  - a key present in one language and not the other would ship a blank to
    somebody, which is worse than shipping English
  - a placeholder that appears in one language and not the other will throw at
    runtime rather than at build time, so it is caught here
"""
import json
import pathlib
import re
import sys

L10N = pathlib.Path(__file__).resolve().parent.parent / "lib" / "l10n"
PLACEHOLDER = re.compile(r"\{(\w+)\}")


def load(path):
    return json.loads(path.read_text()) if path.exists() else {}


def main() -> int:
    en, zh = load(L10N / "app_en.arb"), load(L10N / "app_zh.arb")
    problems = []

    for frag in sorted(L10N.glob("_pending_*_en.json")):
        area = frag.name[len("_pending_"):-len("_en.json")]
        zh_frag = L10N / f"_pending_{area}_zh.json"
        if not zh_frag.exists():
            problems.append(f"{area}: no Chinese fragment")
            continue

        add_en, add_zh = load(frag), load(zh_frag)

        only_en = set(add_en) - set(add_zh) - {k for k in add_en if k.startswith("@")}
        only_zh = set(add_zh) - set(add_en)
        for k in sorted(only_en):
            problems.append(f"{area}: '{k}' has no Chinese")
        for k in sorted(only_zh):
            problems.append(f"{area}: '{k}' has no English")

        for key, value in add_en.items():
            if key.startswith("@@"):
                continue
            if key in en and en[key] != value and not key.startswith("@"):
                problems.append(
                    f"{area}: '{key}' already means '{en[key]}', not '{value}'"
                )
                continue
            en[key] = value

        for key, value in add_zh.items():
            if key.startswith("@@"):
                continue
            zh[key] = value

    # Placeholders have to match, or the generated code and the translation
    # disagree and it fails at runtime in the language nobody tested.
    for key, value in en.items():
        if key.startswith("@") or key not in zh:
            continue
        a, b = set(PLACEHOLDER.findall(str(value))), set(PLACEHOLDER.findall(str(zh[key])))
        if a != b:
            problems.append(f"'{key}': placeholders {sorted(a)} vs {sorted(b)}")

    if problems:
        print("merge refused:\n  " + "\n  ".join(problems))
        return 1

    (L10N / "app_en.arb").write_text(
        json.dumps(en, indent=2, ensure_ascii=False) + "\n"
    )
    (L10N / "app_zh.arb").write_text(
        json.dumps(zh, indent=2, ensure_ascii=False) + "\n"
    )
    keys = len([k for k in en if not k.startswith("@")])
    print(f"merged: {keys} keys in both languages")
    return 0


if __name__ == "__main__":
    sys.exit(main())

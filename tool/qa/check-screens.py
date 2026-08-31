#!/usr/bin/env python3
"""Enforce the design-system rules that are cheap to break and slow to notice.

Run from the repository root:

    python3 tool/qa/check-screens.py

Every rule here exists because it was broken during a real build, or because
the frozen specs state it and nothing else enforces it.
"""
import glob
import json
import os
import re
import sys

CLIENT = "client/lib"
FAILURES = []
CHECKED = 0


def fail(rule, where, detail):
    FAILURES.append(f"{rule}\n    {where}\n    {detail}")


def screens():
    """Every Dart file under features/ — the screen layer."""
    for root, _, files in os.walk(f"{CLIENT}/features"):
        for f in files:
            if f.endswith(".dart"):
                yield os.path.join(root, f)


def check_no_raw_values():
    """Colour and geometry must resolve through tokens.

    B2-FREEZE §6: "Never copy raw Hex values into screens."
    """
    global CHECKED
    hex_colour = re.compile(r"Color\(0x[0-9A-Fa-f]{6,8}\)")
    material = re.compile(r"\bColors\.[a-z]")
    for path in screens():
        CHECKED += 1
        src = open(path).read()
        for m in hex_colour.finditer(src):
            line = src[: m.start()].count("\n") + 1
            fail("raw colour in a screen", f"{path}:{line}", m.group(0))
        for m in material.finditer(src):
            line = src[: m.start()].count("\n") + 1
            fail("Material colour in a screen", f"{path}:{line}", m.group(0))


def check_no_inline_svg():
    """SVG-FREEZE §1: screens reference Asset IDs, never path data."""
    for path in screens():
        src = open(path).read()
        if "SvgPicture.asset" in src:
            fail(
                "SvgPicture used directly",
                path,
                "use DsSvg so the tone licence is enforced",
            )
        if re.search(r'["\']M\s*-?\d+[\d\s,.\-]{20,}', src):
            fail("inline SVG path data", path, "reference a registered master")


def check_no_queue_vocabulary():
    """A person's day is not a work queue.

    Copy rule from the product contract; a widget test also covers Today.
    """
    banned = ["overdue", "backlog", "to-do list"]
    for path in screens():
        src = strip_comments(open(path).read())
        for word in banned:
            for m in re.finditer(rf"['\"][^'\"]*\b{word}\b", src, re.I):
                line = src[: m.start()].count("\n") + 1
                fail("queue vocabulary in copy", f"{path}:{line}", word)


def strip_comments(src):
    """Source with `//` comments removed, line numbering preserved.

    Every copy rule below looks for a forbidden word in a string literal. A
    comment explaining *why* the word is forbidden contains it too, so without
    this the checks fire on the very notes that document them — which teaches
    people to stop writing the notes.

    Line-based and deliberately simple. It leaves `/* */` alone (this codebase
    does not use them) and does not try to tell a `//` inside a string from a
    real comment; a URL in a literal loses its tail, which no rule reads.
    """
    out = []
    for line in src.split("\n"):
        stripped = line.lstrip()
        if stripped.startswith("//"):
            out.append("")
        else:
            out.append(line)
    return "\n".join(out)


def check_no_backend_states_in_copy():
    """Backend state names never reach a person."""
    states = [
        "WAITING_ACK",
        "NEEDS_REVIEW",
        "NEED_TO_DISCUSS",
        "RESCHEDULE_REQUESTED",
        "EXCUSE_REQUESTED",
    ]
    for path in screens():
        src = strip_comments(open(path).read())
        for state in states:
            # A state name inside a string literal is copy. Comparing against
            # one is fine, so only flag literals that are not on the right of
            # an equality or a switch case.
            for m in re.finditer(rf"['\"]([^'\"]*\b{state}\b[^'\"]*)['\"]", src):
                before = src[max(0, m.start() - 30):m.start()]
                after = src[m.end():m.end() + 6]
                # Comparing against a state is fine. So is a switch arm that
                # maps it to human copy — that is the rule being satisfied,
                # not broken.
                if re.search(r"(==|case|state\s*[:=])\s*$", before):
                    continue
                if re.match(r"\s*(=>|:)", after):
                    continue
                line = src[: m.start()].count("\n") + 1
                fail("backend state rendered as copy", f"{path}:{line}", state)


def check_gates_respected():
    """Only a ready_for_build screen may have an implementation.

    What counts as an implementation is a *widget*. A command layer under
    `application/` talks to the server and draws nothing, so it may exist —
    and must, since a screen built on an unbuilt command layer would arrive
    all at once with nothing verified underneath it.

    The rule used to match any `SCR-nn` anywhere in `features/`, which meant a
    comment naming the screen a file will one day serve tripped it. Rules that
    fire on prose get worked around rather than obeyed.
    """
    index = json.load(open("manifests/screen-index.json"))
    open_gates = {
        s["screen_id"]
        for s in index["screens"]
        if s["build_gate"] == "ready_for_build"
    }
    for path in screens():
        # Only the presentation layer draws.
        if f"{os.sep}presentation{os.sep}" not in path:
            continue
        src = open(path).read()
        if not re.search(r"extends\s+(Stateless|Stateful|Consumer\w*)Widget", src):
            continue
        declared = re.search(r"(SCR-\d{2})", src)
        if declared and declared.group(1) not in open_gates:
            fail(
                "screen implemented while its gate is closed",
                path,
                f"{declared.group(1)} is not ready_for_build",
            )


def check_assets_resolve():
    """Every registered master exists, and DsAssets matches the freeze."""
    registry = json.load(open("manifests/assets.json"))
    for asset in registry["assets"]:
        if asset["status"] != "approved":
            continue
        if not os.path.exists(asset["source_path"]):
            fail("registered master missing", asset["id"], asset["source_path"])

    generated = open("app/lib/src/design_system/ds_assets.dart").read()
    for asset in registry["assets"]:
        if asset["status"] == "approved" and f"'{asset['id']}'" not in generated:
            fail("approved asset absent from DsAssets", asset["id"], "regenerate")


def check_preview_fits_viewport():
    """Every candidate preview renders at the reference viewport and fits it.

    Two things at once, because they fail together. A `preview.webp` is what a
    reviewer compares screens by, so it has to be at one scale — and once it
    is, the same file can be probed for content running off the bottom, which
    is the defect that survived three rounds of review on SCR-01.

    Twelve candidates predate this and sit at source resolution (853 × 1844).
    They are scaled before probing rather than rewritten: they are approved
    artifacts, and re-encoding them to satisfy a checker would change files
    nobody asked to change. New candidates are held to 390 × 844.
    """
    global CHECKED
    try:
        from PIL import Image
    except ImportError:
        return  # Pillow is not a hard dependency of the repository.

    grandfathered = 853, 1844
    for path in sorted(glob.glob("design/screens/*/candidates/**/preview.webp",
                                 recursive=True)):
        CHECKED += 1
        image = Image.open(path)
        if image.size not in ((390, 844), grandfathered):
            fail(
                "candidate preview is not the reference viewport",
                path,
                f"{image.size[0]}x{image.size[1]}, expected 390x844",
            )
            continue

        grey = image.convert("L")
        if grey.size != (390, 844):
            grey = grey.resize((390, 844))
        pixels = grey.load()
        last = 0
        for y in range(844):
            if max(pixels[x, y] for x in range(0, 390, 2)) > 120:
                last = y
        # 838 rather than 844: a glyph's last antialiased row is not content
        # running off the screen.
        if last > 838:
            fail(
                "candidate content runs past the bottom of the viewport",
                path,
                f"last content at {last}dp of 844",
            )


def check_package_qualified():
    """Assets and fonts must resolve from the package, not the host.

    Every one of these was a real defect: bare paths 404'd all 33 SVGs, and
    bare font families silently fell back to a system face.
    """
    assets = open("app/lib/src/design_system/ds_assets.dart").read()
    for m in re.finditer(r"'(assets/(?:svg|textures)/[^']+)'", assets):
        fail("unqualified asset path", "ds_assets.dart", m.group(1))

    typography = open("app/lib/src/design_system/ds_typography.dart").read()
    roles = typography.count("TextStyle(")
    qualified = typography.count("package: _package")
    if roles != qualified:
        fail(
            "type role without a package qualifier",
            "ds_typography.dart",
            f"{roles} roles, {qualified} qualified — the rest fall back silently",
        )


def check_text_in_row_is_bounded():
    """A `Text` directly inside a `Row` must be `Expanded` or `Flexible`.

    This exact overflow was found by hand on five screens — the entrance,
    SCR-09, SCR-10, SCR-12 and SCR-33 — always the same shape: an icon, a gap,
    and a sentence that fits until a longer name or a translation arrives.
    Runtime catches it only if a test happens to render that state at 390dp.

    Deliberately shallow: it looks one line ahead for the `Text(` that follows
    a `Row(`'s opening, which is where the pattern actually appears. A real
    parser would catch more and be wrong more often.
    """
    for path in sorted(glob.glob("client/lib/features/**/*.dart", recursive=True)):
        lines = open(path).read().split("\n")
        for i, line in enumerate(lines):
            if not re.search(r"\bRow\($", line.strip()):
                continue
            # Walk this Row's immediate children, stopping at its close.
            depth = 0
            for j in range(i + 1, min(i + 60, len(lines))):
                body = lines[j]
                stripped = body.strip()
                depth += body.count("(") - body.count(")")
                if depth < 0:
                    break
                # An unwrapped Text at the Row's own child indentation, and
                # only when something precedes it. A leading Text takes the
                # space it needs and pushes later children along; one that
                # follows an icon or a gap is the shape that overflows, and it
                # is the shape all five real cases had.
                if re.match(r"^Text\($", stripped) and depth <= 2:
                    before = "\n".join(lines[i + 1:j])
                    follows_sibling = re.search(
                        r"(SizedBox|DsSvg|Icon|Container|Spacer)\(", before
                    )
                    prev = lines[j - 1].strip()
                    if follows_sibling and not re.search(
                        r"(Expanded|Flexible)\(", prev
                    ):
                        fail(
                            "unbounded Text in a Row",
                            f"{path}:{j + 1}",
                            "wrap it in Expanded or Flexible — this overflows "
                            "on a longer name or a translation",
                        )


def main():
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
    for check in (
        check_no_raw_values,
        check_no_inline_svg,
        check_no_queue_vocabulary,
        check_no_backend_states_in_copy,
        check_gates_respected,
        check_assets_resolve,
        check_preview_fits_viewport,
        check_package_qualified,
        check_text_in_row_is_bounded,
    ):
        check()

    if FAILURES:
        print(f"{len(FAILURES)} problem(s):\n")
        for f in FAILURES:
            print(f"  {f}\n")
        return 1
    print(f"design-system checks passed ({CHECKED} screen files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

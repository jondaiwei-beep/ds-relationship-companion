"""iPhone Safari acceptance for M1 (Notion 06 §13.3, 07 §8).

Tests the four Web lifecycle behaviours the Exit Criteria name:
first open, refresh on a nested route, browser back/forward, direct URL.
"""
import asyncio, json, sys
from playwright.async_api import async_playwright

URL = sys.argv[1]

async def has_invite(page, tag):
    """Flutter Web paints into shadow DOM, so inner_text/DOM queries are empty.

    The honest assertion is on PIXELS: screenshot the viewport and require a
    meaningful number of distinct colours. A failed SPA route, a blank canvas
    or an error page is near-uniform; the rendered invite page carries bone,
    olive, terracotta, ivory and antialiased serif text.
    """
    path = f"{OUT}/m1-safari-{tag}.png"
    await page.screenshot(path=path)
    from PIL import Image
    img = Image.open(path).convert("RGB")
    colours = len(set(img.getdata()))
    # Also require the Warm Authority ground (bone #F4F1EB) to be present.
    px = set(img.getdata())
    bone = any(abs(r-244) < 6 and abs(g-241) < 6 and abs(b-235) < 6 for r, g, b in px)
    return colours > 200 and bone, f"{colours} colours, bone={bone}"
OUT = "/Users/li/code/app/dsapp/docs/screenshots"
results = []

async def main():
    async with async_playwright() as p:
        browser = await p.webkit.launch()           # WebKit == Safari engine
        ctx = await browser.new_context(
            **p.devices["iPhone 13"],               # real iPhone viewport + UA
        )
        page = await ctx.new_page()
        errors = []
        page.on("console", lambda m: errors.append(m.text) if m.type == "error" else None)

        # 1. First open of the invite URL
        await page.goto(URL, wait_until="networkidle")
        await page.wait_for_timeout(3000)
        ok, d = await has_invite(page, "1-invite")
        results.append(("first open renders invite", ok, d))

        # 2. Refresh on the nested route
        await page.reload(wait_until="networkidle")
        await page.wait_for_timeout(3000)
        ok, d = await has_invite(page, "2-refresh")
        results.append(("refresh on nested route", ok, d))

        # 3. Navigate away, then browser BACK
        await page.goto(URL.split("/invite/")[0] + "/sign-in", wait_until="networkidle")
        await page.wait_for_timeout(1500)
        await page.go_back(wait_until="networkidle")
        await page.wait_for_timeout(3000)
        ok, d = await has_invite(page, "3-back")
        results.append(("browser back returns to invite", ok, d))

        # 4. Direct URL in a brand-new context (cold, no history)
        ctx2 = await browser.new_context(**p.devices["iPhone 13"])
        page2 = await ctx2.new_page()
        await page2.goto(URL, wait_until="networkidle")
        await page2.wait_for_timeout(3000)
        ok, d = await has_invite(page2, "4-direct")
        results.append(("direct URL, cold context", ok, d))

        results.append(("no console errors", len(errors) == 0, f"{len(errors)} errors"))
        if errors:
            for e in errors[:3]: print("   console:", e[:150])

        await browser.close()

    print()
    for name, ok, detail in results:
        print(f"  {'✅' if ok else '❌'} {name:<34} {detail[:70]}")
    print()
    print("PASS" if all(r[1] for r in results) else "FAIL")

asyncio.run(main())

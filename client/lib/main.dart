// The product entry point is intentionally absent while every screen gate is
// blocked. Screens are rebuilt one at a time against the approved design
// system as their Screen Package reaches `ready_for_build`; the route contract
// they must restore is recorded in docs/rebuild/route-contract.md.
//
// This file exists so the package compiles and its data-layer tests run. It is
// not a placeholder screen to iterate on — the first real UI here will be a
// rebuilt SCR-01 Today.
void main() {
  throw UnsupportedError(
    'No screen is built yet. See docs/rebuild/route-contract.md.',
  );
}

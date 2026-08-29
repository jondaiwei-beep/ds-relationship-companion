# Component contracts

Foundation geometry is frozen in `design/tokens/B2-FREEZE.md`: primary/secondary/destructive buttons, text fields, selection/list rows, bottom navigation, modal sheets and dialogs must consume those semantic dimensions, radii, borders and colors.

Component behavior is still a separate gate. Each component contract must specify typography, platform behavior and default/pressed/disabled/loading/error/success states before a dependent screen becomes `ready_for_build`. Partner presence, ritual emblem, timeline and response marks must use the registered SVG masters rather than component-local paths.

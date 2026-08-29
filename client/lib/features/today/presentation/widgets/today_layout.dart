import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// Horizontal inset for this surface. `spacing.md` fixes the mobile default at
/// 20dp; it belongs in one place so a row cannot drift from the rest.
const todayInset = EdgeInsets.symmetric(horizontal: DsSpacing.space5);

/// Supporting copy: item metadata and the quiet adjustment actions.
///
/// The frozen 14px secondary role reads too heavy against the 28px headline.
/// Proposed as `body.support` in `design/tokens/PROPOSED-B3.md`; inline until
/// that freeze lands.
const todaySupportSize = 12.0;
const todaySupportHeight = 17 / 12;

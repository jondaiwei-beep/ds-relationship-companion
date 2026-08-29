package com.dsapp.backend.activation.domain

/** What the couple said they wanted more of (Notion 02 §A1). */
enum class DesiredOutcome { CLOSER, STRUCTURE, SERVICE, ACCOUNTABILITY, EXPLORE }

/**
 * Seed content for the Starter Rhythm — Notion 05 §4/§5.
 *
 * Every candidate must be **low–moderate intensity, low privacy sensitivity,
 * and completable in a few minutes**. Nothing here may hint at punishment,
 * proof, or points: the first day must not teach the couple that this app is
 * about scoring each other.
 *
 * Notion 05 §5 asks for 8–12 Expectation candidates, 4–6 Rituals and 3
 * Check-in framings — not a 50-item library. Content depth waits until real
 * couples show us what they actually use.
 */
object StarterContent {

    data class Candidate(val title: String, val purpose: String)

    /** 1 steady Ritual per outcome, plus shared fallbacks. */
    private val rituals: Map<DesiredOutcome, List<Candidate>> = mapOf(
        DesiredOutcome.CLOSER to listOf(
            Candidate("Evening check-in", "A pause for presence before the day closes."),
            Candidate("Morning intention", "One line about how you want today to feel."),
        ),
        DesiredOutcome.STRUCTURE to listOf(
            Candidate("Evening check-in", "A steady point in the day you can both rely on."),
            Candidate("Close the day", "Mark the end of the day together, however briefly."),
        ),
        DesiredOutcome.SERVICE to listOf(
            Candidate("Prepare the evening space", "A small act of care before you reconnect."),
            Candidate("Evening check-in", "A moment to notice what the other needs."),
        ),
        DesiredOutcome.ACCOUNTABILITY to listOf(
            Candidate("Evening check-in", "A regular place to say how the day actually went."),
            Candidate("Morning intention", "Name one thing you are giving attention to today."),
        ),
        DesiredOutcome.EXPLORE to listOf(
            Candidate("Evening check-in", "A calm place to say what you are curious about."),
            Candidate("Morning intention", "One thing you would like to notice today."),
        ),
    )

    /** 1 meaningful Expectation per outcome. */
    private val expectations: Map<DesiredOutcome, List<Candidate>> = mapOf(
        DesiredOutcome.CLOSER to listOf(
            Candidate("Send one message that isn't logistics",
                "Something that is only about the two of you."),
            Candidate("Say one thing you noticed about them today",
                "Being seen is the point."),
        ),
        DesiredOutcome.STRUCTURE to listOf(
            Candidate("Tidy one shared space", "Small, visible, and finished in minutes."),
            Candidate("Set out what tomorrow needs", "Make the morning easier for both of you."),
        ),
        DesiredOutcome.SERVICE to listOf(
            Candidate("Prepare the evening space", "A small act of care before you reconnect."),
            Candidate("Make them a drink the way they like it",
                "Attention to a detail you already know."),
        ),
        DesiredOutcome.ACCOUNTABILITY to listOf(
            Candidate("Name one thing you are avoiding", "Naming it is the whole task."),
            Candidate("Do the small thing you keep postponing",
                "Five minutes, not a project."),
        ),
        DesiredOutcome.EXPLORE to listOf(
            Candidate("Share one thing you're curious about",
                "No commitment attached to saying it."),
            Candidate("Ask them one question you haven't asked",
                "Curiosity, not an interview."),
        ),
    )

    /** 3 check-in framings (Notion 05 §5). */
    val checkInFramings = listOf(
        "How is your energy today?",
        "What would help right now?",
        "What kind of day has this been?",
    )

    fun ritualFor(outcome: DesiredOutcome): Candidate = rituals.getValue(outcome).first()

    fun expectationFor(outcome: DesiredOutcome): Candidate = expectations.getValue(outcome).first()

    /**
     * The optional second Expectation — a SUGGESTION, never part of the default.
     *
     * Notion 05 §4: the first day must not arrive already full.
     */
    fun optionalSecondExpectation(outcome: DesiredOutcome): Candidate =
        expectations.getValue(outcome)[1]

    /** Everything on offer, for a "replace anything that doesn't fit" picker. */
    fun allRituals(outcome: DesiredOutcome): List<Candidate> = rituals.getValue(outcome)
    fun allExpectations(outcome: DesiredOutcome): List<Candidate> = expectations.getValue(outcome)
}

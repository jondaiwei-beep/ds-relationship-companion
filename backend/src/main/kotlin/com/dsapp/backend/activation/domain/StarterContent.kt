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
 *
 * The outcomes a couple can pick are D/s outcomes, and the seeds must answer
 * the question that was actually asked. SERVICE previously offered "tidy one
 * shared space" and "make them a drink the way they like it" — a chore list,
 * which is what service looks like to someone who does not know what the word
 * means here. What makes an act service is that it was asked for and is owed
 * to someone by agreement, so the seeds carry that instead. Same for
 * STRUCTURE, which is protocol rather than tidiness, and ACCOUNTABILITY,
 * where reporting back to the person who asked is the substance of it.
 */
object StarterContent {

    data class Candidate(val title: String, val purpose: String)

    /** 1 steady Ritual per outcome, plus shared fallbacks. */
    private val rituals: Map<DesiredOutcome, List<Candidate>> = mapOf(
        DesiredOutcome.CLOSER to listOf(
            Candidate("Evening check-in", "A pause for presence before the day closes."),
            Candidate("A greeting that is only yours", "One agreed word that says you are both here on purpose."),
        ),
        DesiredOutcome.STRUCTURE to listOf(
            Candidate("A greeting that is only yours", "A small agreed form to step back into the dynamic."),
            Candidate("Close the day", "Mark the end of the day together, however briefly."),
        ),
        DesiredOutcome.SERVICE to listOf(
            Candidate("One standing act of service", "Ordinary on its own; service because it was asked for."),
            Candidate("Evening check-in", "A moment to notice what the other needs."),
        ),
        DesiredOutcome.ACCOUNTABILITY to listOf(
            Candidate("Report back when it is done", "A short line to the person who asked, not a log."),
            Candidate("Evening check-in", "A regular place to say how the day actually went."),
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
                "Being seen is what it is for."),
        ),
        DesiredOutcome.STRUCTURE to listOf(
            Candidate("Ask before, for one specific thing",
                "One ordinary thing that gets asked about first."),
            Candidate("Set out what tomorrow needs",
                "Make the morning easier for both of you."),
        ),
        DesiredOutcome.SERVICE to listOf(
            Candidate("Prepare something before they arrive",
                "Agree once what 'ready' means, then keep it."),
            Candidate("Do it their way, not the efficient way",
                "Following the instruction is what is asked for, not the result."),
        ),
        DesiredOutcome.ACCOUNTABILITY to listOf(
            Candidate("Name one thing you are avoiding", "Naming it is the whole task."),
            Candidate("Do the small thing you keep postponing",
                "Five minutes, not a project."),
        ),
        DesiredOutcome.EXPLORE to listOf(
            Candidate("Name one limit out loud",
                "One thing off the table, and one you are unsure about."),
            Candidate("Ask them one question you haven't asked",
                "Curiosity, not an interview."),
        ),
    )

    /** 3 check-in framings (Notion 05 §5). */
    val checkInFramings = listOf(
        "How is your energy today?",
        "What would help right now?",
        "What do you need afterwards?",
    )

    /**
     * What an apart couple gets instead, whatever they chose as an outcome.
     *
     * Distance changes the first day more than the outcome does. "Prepare the
     * evening space" and "one standing act of service" assume a shared room;
     * offered to a couple in different timezones they read as written for
     * somebody else, which is exactly the impression this product cannot
     * afford on day one. LDR is the design pressure case in 00-overview and
     * the wizard has always asked the question — it just never sent the
     * answer.
     *
     * Deliberately outcome-independent. A second full matrix of five outcomes
     * would double the content for a distinction most couples would not
     * notice on their first day; the thing they will notice is whether the
     * app knows they are apart.
     */
    private val distanceRitual = Candidate(
        "One hour you both keep",
        "A shared hour beats a shared minute you both keep missing.",
    )

    private val distanceExpectation = Candidate(
        "Say goodnight to the timezone you are not in",
        "Whoever sleeps first should not be the one who feels forgotten.",
    )

    private val distanceSecond = Candidate(
        "Ask for something that lands while you are asleep",
        "Direction does not need both of you awake at once.",
    )

    fun ritualFor(outcome: DesiredOutcome, longDistance: Boolean = false): Candidate =
        if (longDistance) distanceRitual else rituals.getValue(outcome).first()

    fun expectationFor(outcome: DesiredOutcome, longDistance: Boolean = false): Candidate =
        if (longDistance) distanceExpectation else expectations.getValue(outcome).first()

    /**
     * The optional second Expectation — a SUGGESTION, never part of the default.
     *
     * Notion 05 §4: the first day must not arrive already full.
     */
    fun optionalSecondExpectation(
        outcome: DesiredOutcome,
        longDistance: Boolean = false,
    ): Candidate =
        if (longDistance) distanceSecond else expectations.getValue(outcome)[1]

    /** Everything on offer, for a "replace anything that doesn't fit" picker. */
    fun allRituals(outcome: DesiredOutcome): List<Candidate> = rituals.getValue(outcome)
    fun allExpectations(outcome: DesiredOutcome): List<Candidate> = expectations.getValue(outcome)
}

package com.dsapp.backend.activation.domain

/** What the couple said they wanted more of (Notion 02 §A1). */
enum class DesiredOutcome { CLOSER, STRUCTURE, SERVICE, ACCOUNTABILITY, EXPLORE }

/**
 * Seed content for the first day — Notion 05 §4/§5.
 *
 * Rewritten 2026-09-02 with the owner's decision to remove every content
 * restriction. The old rule was "low intensity, low privacy sensitivity,
 * nothing that hints at punishment": the first day read as a couples app and
 * a person who came here for a D/s dynamic could not tell we knew what that
 * was. The first day now names the thing — honorifics, kneeling, permission,
 * a nightly report to the Dominant — at starter size: one rule, one ritual,
 * both completable in minutes.
 *
 * Still small by design. Notion 05 §4: the first day must not arrive already
 * full. One ritual and one expectation, with an optional second.
 */
object StarterContent {

    data class Candidate(val title: String, val purpose: String)

    /** 1 steady Ritual per outcome, plus shared fallbacks. */
    private val rituals: Map<DesiredOutcome, List<Candidate>> = mapOf(
        DesiredOutcome.CLOSER to listOf(
            Candidate("The nightly report", "What was asked, what was done, in your Dominant's hearing."),
            Candidate("An honorific at agreed moments", "Sir, Ma'am, Master — one word that says who you are to each other."),
        ),
        DesiredOutcome.STRUCTURE to listOf(
            Candidate("An honorific at agreed moments", "A title used at set times is the smallest piece of protocol that holds."),
            Candidate("Kneel when they come home", "Thirty seconds. The body remembers the dynamic faster than talk does."),
        ),
        DesiredOutcome.SERVICE to listOf(
            Candidate("One standing act of service", "Their coffee, their clothes laid out — owed by agreement, and inspected."),
            Candidate("Inspection", "The Dominant looks, and says what they see."),
        ),
        DesiredOutcome.ACCOUNTABILITY to listOf(
            Candidate("The nightly report", "Account for the day. The Dominant acknowledges or corrects."),
            Candidate("Report when it is done", "'Done, Sir.' is a complete report."),
        ),
        DesiredOutcome.EXPLORE to listOf(
            Candidate("Green, yellow, red", "Agree the safeword and what happens in the ten seconds after it."),
            Candidate("The nightly report", "A calm place to say what you are curious about."),
        ),
    )

    /** 1 meaningful Expectation per outcome. */
    private val expectations: Map<DesiredOutcome, List<Candidate>> = mapOf(
        DesiredOutcome.CLOSER to listOf(
            Candidate("Praise the actual thing",
                "'You asked first, and I saw it.' Once today, name what they did."),
            Candidate("Send one message that is an order, not logistics",
                "One instruction, clear enough to obey."),
        ),
        DesiredOutcome.STRUCTURE to listOf(
            Candidate("Ask permission for one specific thing",
                "Eating, bed, leaving the house — pick one and ask first, today."),
            Candidate("Three standing rules, written down",
                "Required, forbidden, needs permission. Three, not thirty."),
        ),
        DesiredOutcome.SERVICE to listOf(
            Candidate("Have it ready before they arrive",
                "Agree once what 'ready' means, then keep it."),
            Candidate("Do it their way, not the efficient way",
                "Obedience to the detail is the service."),
        ),
        DesiredOutcome.ACCOUNTABILITY to listOf(
            Candidate("Agree the consequences before they are needed",
                "For each rule, what follows when it is broken. Agreed by both, in calm."),
            Candidate("Name one thing you are avoiding", "Naming it to your Dominant is the whole task."),
        ),
        DesiredOutcome.EXPLORE to listOf(
            Candidate("Hard limits and soft limits, out loud",
                "Each of you names both. The Dominant's limits count too."),
            Candidate("Ask them one question you have not dared to",
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
        "The earlier evening sends the report; the later one answers when they wake.",
    )

    private val distanceSecond = Candidate(
        "Give an order that lands while you sleep",
        "Waking up to an instruction is waking up owned.",
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

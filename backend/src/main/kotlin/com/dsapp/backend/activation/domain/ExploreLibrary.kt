package com.dsapp.backend.activation.domain

/**
 * The small, reviewed library a person can browse before anyone else is
 * involved — Notion 02 §1 permits a light Explore in Core Beta.
 *
 * This exists because the product previously showed a new person five empty
 * surfaces and then asked them to send a private link about an intimate
 * subject to someone they know. It had no way to demonstrate its own taste
 * or judgement first. Distribution depends on someone deciding this is good
 * enough to share, and nothing was there to be convinced by.
 *
 * ## Why this file was rewritten
 *
 * The first version demonstrated taste, but not *this product's* taste. Its
 * sixteen entries — send a message that isn't logistics, twenty minutes with
 * the phone away, make one thing easier for them tomorrow — were true things
 * about couples, and a reader could not tell from any of them that this app
 * is for D/s. A person arriving with a dynamic they are trying to maintain
 * read them and correctly concluded the product did not know what they were
 * doing here.
 *
 * The product definition is not vague about this: "a private companion that
 * helps consensual adult D/s couples keep their dynamic present". The generic
 * register was an execution drift, not the spec.
 *
 * So every entry now assumes the thing the product assumes — that these two
 * people have agreed one of them gives direction and the other receives it —
 * and is written to be useless to a couple who have not. That is the point.
 * An idea that works equally well for anyone is an idea this library should
 * not carry.
 *
 * ## What has NOT changed
 *
 * The safety rules are the same and are load-bearing, not decoration:
 * low-to-moderate intensity, low privacy sensitivity, completable in minutes.
 * Nothing hints at punishment, proof, or points (00-overview Non-goals bars
 * automatic punishment and compliance scoring outright). Nothing is explicit
 * and nothing describes a scene. Protocol here is the ordinary,
 * daily-maintenance kind — how you speak, what you ask before, what you say
 * after — which is where a dynamic is actually kept alive, and which no
 * generic couples tool has any language for.
 *
 * Two of these collections carry the load a D/s tool cannot skip: negotiation
 * before, and aftercare after. A library that taught the ritual without them
 * would be teaching the dangerous half.
 *
 * Deliberately small. A large library would be a content product; this is
 * enough to prove the product has judgement, and no more until real couples
 * show what they actually use.
 */
object ExploreLibrary {

    enum class Kind { RITUAL, EXPECTATION, CHECK_IN }

    data class Idea(
        val id: String,
        val kind: Kind,
        val title: String,
        /** Why it matters — the line that makes it a request, not a chore. */
        val purpose: String,
        /** What it actually looks like in practice. */
        val detail: String,
        val collectionId: String,
    )

    data class Collection(
        val id: String,
        val title: String,
        /** One sentence a person can judge the whole set by. */
        val blurb: String,
    )

    val collections = listOf(
        Collection(
            "protocol",
            "Everyday protocol",
            "Small agreed forms that keep the dynamic present on an ordinary Tuesday.",
        ),
        Collection(
            "service",
            "Service that is felt",
            "Acts done as service, where being told is part of what makes it one.",
        ),
        Collection(
            "authority",
            "Holding authority well",
            "The work on the giving side, which is mostly attention.",
        ),
        Collection(
            "distance",
            "When you are apart",
            "Keeping a dynamic real across timezones and empty evenings.",
        ),
        Collection(
            "negotiation",
            "Before, and how you'd stop",
            "Agreeing the shape of things while everyone is calm.",
        ),
        Collection(
            "aftercare",
            "Afterwards",
            "The part that gets skipped, and the part people leave over.",
        ),
        Collection(
            "beginning",
            "Just starting out",
            "Where to begin if the two of you are new to this.",
        ),
    )

    val ideas = listOf(
        // — Everyday protocol ————————————————————————————
        Idea(
            "greeting-form", Kind.RITUAL,
            "A greeting that is only yours",
            "A form of address is the cheapest way to step back into the dynamic.",
            "Agree one word or gesture used at a set moment — arriving home, "
                + "the first message of the day. It costs nothing and it marks "
                + "that you are both here on purpose.",
            "protocol",
        ),
        Idea(
            "ask-before", Kind.EXPECTATION,
            "Ask before, for one specific thing",
            "Asking permission for something small keeps the agreement in daily use.",
            "Pick one ordinary thing and agree it is asked about first. One is "
                + "enough. A rule you actually keep beats five you quietly drop.",
            "protocol",
        ),
        Idea(
            "position-or-posture", Kind.RITUAL,
            "One posture, held briefly",
            "The body remembers the dynamic faster than conversation does.",
            "A way of sitting or waiting, agreed in advance, held for a minute "
                + "or two at a set time. Nothing strenuous, and nothing that "
                + "needs more privacy than you have.",
            "protocol",
        ),
        Idea(
            "report-back", Kind.EXPECTATION,
            "Report back when it is done",
            "The reporting is the service, as much as the act is.",
            "Not a receipt and not a log — a short line to the person who asked, "
                + "saying it is finished. What makes it land is that it goes to "
                + "them rather than into an app.",
            "protocol",
        ),

        // — Service that is felt ————————————————————————
        Idea(
            "standing-service", Kind.RITUAL,
            "One standing act of service",
            "A task becomes service when it is owed to someone by agreement.",
            "Choose something ordinary and make it theirs. The difference from "
                + "a chore is entirely that it was asked for and is done for "
                + "them.",
            "service",
        ),
        Idea(
            "their-way-not-yours", Kind.EXPECTATION,
            "Do it their way, not the efficient way",
            "Following the instruction is what is being asked for, not the result.",
            "Something with a specified manner — how it is folded, when it is "
                + "done, which words are used. Doing it 'better' is not doing it.",
            "service",
        ),
        Idea(
            "prepare-for-them", Kind.EXPECTATION,
            "Prepare something before they arrive",
            "Anticipation is a skill, and being anticipated is what it gives back.",
            "Agree what 'ready' means once, then keep it. Small enough to "
                + "repeat on a bad week.",
            "service",
        ),

        // — Holding authority well ——————————————————————
        Idea(
            "one-clear-instruction", Kind.EXPECTATION,
            "Give one instruction that is actually clear",
            "Most expectations that go nowhere were unclear, not refused.",
            "Say what, and say when. Vagueness reads as a test, and being "
                + "tested is corrosive. If they had to guess, that is yours to fix.",
            "authority",
        ),
        Idea(
            "notice-the-effort", Kind.RITUAL,
            "Name what they did, specifically",
            "Unnoticed service stops being offered.",
            "Once a day, name the actual thing — 'you asked first, and I saw "
                + "that' — not general praise. Specific is what proves you were "
                + "paying attention.",
            "authority",
        ),
        Idea(
            "hold-or-release", Kind.CHECK_IN,
            "Decide what to lift this week",
            "Authority includes deciding when less is right.",
            "Look at what is standing and take something off deliberately, "
                + "before it lapses on its own. Lifting a rule is a decision, "
                + "not a concession.",
            "authority",
        ),

        // — When you are apart ——————————————————————————
        //
        // LDR is the design pressure case in 00-overview — Android giving
        // member, iPhone receiving member, different timezones — and until
        // now the library had nothing for it. Distance does not weaken a
        // dynamic by removing contact; it weakens it by removing the small
        // unplanned moments that carry it, which is why every idea here is
        // something that survives being scheduled.
        Idea(
            "same-hour", Kind.RITUAL,
            "One hour you both keep",
            "A shared hour beats a shared minute you both keep missing.",
            "Work out one window that is reasonable in both timezones and "
                + "keep it. It matters more that it is the same hour than "
                + "that it is a convenient one.",
            "distance",
        ),
        Idea(
            "before-you-sleep", Kind.EXPECTATION,
            "Say goodnight to the timezone you are not in",
            "Whoever sleeps first should not be the one who feels forgotten.",
            "The earlier evening sends first, and the later one answers when "
                + "they get there. Neither of you waits up.",
            "distance",
        ),
        Idea(
            "asked-for-in-advance", Kind.EXPECTATION,
            "Ask for something that lands while you are asleep",
            "Direction does not need both of you awake at once.",
            "Set it before you go to bed so it is waiting when their day "
                + "starts. Being thought of ahead of time is what it gives.",
            "distance",
        ),
        Idea(
            "one-thing-you-cannot-see", Kind.EXPECTATION,
            "Something you will never witness",
            "Distance makes trust the substance rather than the setting.",
            "Ask for something you have no way of checking, and say plainly "
                + "that you are not going to check. That is the whole of it.",
            "distance",
        ),
        Idea(
            "the-empty-evening", Kind.CHECK_IN,
            "Name the evening that was hard",
            "The distance is worst at a predictable hour, and it is rarely said.",
            "Most people apart have one time of day that is heaviest. Say "
                + "which one yours was this week.",
            "distance",
        ),
        Idea(
            "something-with-your-hands", Kind.RITUAL,
            "An object that stays with them",
            "A dynamic that lives only in text has nothing to hold.",
            "Something small, chosen by one and kept by the other. Worn, "
                + "carried, or left where it is seen daily.",
            "distance",
        ),
        Idea(
            "next-time-we-are-together", Kind.CHECK_IN,
            "One thing for when you are next in the same room",
            "Anticipation is the version of presence distance allows.",
            "Add to it whenever you think of something. It is not a plan and "
                + "nothing has to happen on the day.",
            "distance",
        ),

        // — Before, and how you'd stop ——————————————————
        Idea(
            "name-a-limit", Kind.CHECK_IN,
            "Name one limit out loud",
            "A limit said in advance is worth more than one discovered mid-way.",
            "One thing that is off the table, and one you are unsure about. "
                + "The unsure one is the useful half — it is where the "
                + "conversation actually is.",
            "negotiation",
        ),
        Idea(
            "how-youd-stop", Kind.CHECK_IN,
            "Agree how either of you stops things",
            "The word only works if it was agreed while calm.",
            "Decide what is said, and what happens immediately after it is "
                + "said. Both of you get one. Agreeing it is not pessimism, it "
                + "is what makes the rest possible.",
            "negotiation",
        ),
        Idea(
            "whats-changed", Kind.CHECK_IN,
            "What has changed since we agreed this",
            "Consent is not a signature, it is a subscription.",
            "Revisit one standing agreement and say plainly whether it still "
                + "fits. Changing it is ordinary. Say so out loud so it stays "
                + "ordinary.",
            "negotiation",
        ),

        // — Afterwards ——————————————————————————————————
        Idea(
            "aftercare-ask", Kind.CHECK_IN,
            "Ask what they need afterwards",
            "Aftercare is not a mood, it is a question with an answer.",
            "Ask directly — quiet, contact, food, being left alone for ten "
                + "minutes. Guessing wrong is common and asking costs nothing.",
            "aftercare",
        ),
        Idea(
            "aftercare-for-the-other-one", Kind.CHECK_IN,
            "The one who gave direction needs it too",
            "Drop happens on both sides, and only one side gets asked about.",
            "Say how you are, honestly, to the person you were directing. "
                + "Holding authority is work, and pretending otherwise is how "
                + "people quietly stop wanting to do it.",
            "aftercare",
        ),
        Idea(
            "next-day", Kind.CHECK_IN,
            "Check in the next day, not just after",
            "The dip often lands a day late.",
            "One line the following day. It is the cheapest thing in this "
                + "library and the most often skipped.",
            "aftercare",
        ),

        // — Just starting out ———————————————————————————
        Idea(
            "one-rule-one-week", Kind.RITUAL,
            "One agreement, for one week",
            "Start smaller than feels worthwhile.",
            "Pick the least ambitious thing here and keep it for seven days. "
                + "Most people begin with a whole protocol and abandon it by "
                + "Thursday.",
            "beginning",
        ),
        Idea(
            "say-no-once", Kind.EXPECTATION,
            "Practise saying no to something small",
            "A yes only means something if no is available.",
            "Agree in advance that this is expected. It makes the real no, "
                + "when it comes, ordinary rather than a crisis.",
            "beginning",
        ),
        Idea(
            "how-is-this-going", Kind.CHECK_IN,
            "How is this going?",
            "Ask early, before it becomes a bigger conversation.",
            "After a few days, say plainly what is working and what is not. "
                + "Changing it is part of it.",
            "beginning",
        ),
    )

    fun byCollection(collectionId: String) =
        ideas.filter { it.collectionId == collectionId }

    fun find(id: String) = ideas.firstOrNull { it.id == id }
}

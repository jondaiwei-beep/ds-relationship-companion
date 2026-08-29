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
 * Every entry is written to the same rules as the Starter Rhythm content:
 * low to moderate intensity, low privacy sensitivity, completable in
 * minutes, and never hinting at punishment, proof, or points. Nothing here
 * is explicit, and nothing describes a scene — these are ways two people pay
 * attention to each other.
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
            "presence",
            "Being present",
            "Small ways to be reachable to each other in an ordinary week.",
        ),
        Collection(
            "care",
            "Care, given and noticed",
            "Acts that are small enough to keep doing and specific enough to feel.",
        ),
        Collection(
            "rhythm",
            "A rhythm you can keep",
            "Anchors in the day that hold without becoming a schedule.",
        ),
        Collection(
            "honesty",
            "Saying the true thing",
            "Prompts for what is easier to leave unsaid.",
        ),
        Collection(
            "beginning",
            "Just starting out",
            "Where to begin if you have never done anything like this.",
        ),
    )

    val ideas = listOf(
        // — Being present ————————————————————————————————
        Idea(
            "one-message", Kind.EXPECTATION,
            "Send one message that isn't logistics",
            "Something that is only about the two of you.",
            "No plans, no groceries, no scheduling. One line that would only "
                + "make sense between you.",
            "presence",
        ),
        Idea(
            "first-thought", Kind.EXPECTATION,
            "Tell them the first thing you thought of them today",
            "Being thought of is different from being managed.",
            "Whenever it happened — waking up, on the train, mid-meeting. "
                + "Say what it actually was.",
            "presence",
        ),
        Idea(
            "evening-checkin", Kind.CHECK_IN,
            "Evening check-in",
            "A pause for presence before the day closes.",
            "How the day actually went, in as few words as you like. It is "
                + "not a report and it can be one word.",
            "presence",
        ),
        Idea(
            "phone-down", Kind.EXPECTATION,
            "Twenty minutes with the phone in another room",
            "Attention is the thing being asked for, not the time.",
            "Agree when. What matters is that it is deliberate, and that "
                + "they know you chose it.",
            "presence",
        ),

        // — Care ————————————————————————————————————————
        Idea(
            "evening-space", Kind.EXPECTATION,
            "Prepare the evening space",
            "A small act of care before you reconnect.",
            "Whatever 'ready' means in your home — lights, a tidy surface, "
                + "something warm. Small enough to repeat.",
            "care",
        ),
        Idea(
            "one-thing-easier", Kind.EXPECTATION,
            "Make one thing easier for them tomorrow",
            "Care that lands before it is asked for.",
            "Something they would otherwise have to do. Do not announce it "
                + "in advance.",
            "care",
        ),
        Idea(
            "notice-out-loud", Kind.RITUAL,
            "Notice one thing out loud",
            "What goes unsaid stops being felt.",
            "Once a day, name one specific thing they did. Specific, not "
                + "general — 'you handled that call well', not 'you're great'.",
            "care",
        ),

        // — Rhythm ——————————————————————————————————————
        Idea(
            "morning-intention", Kind.RITUAL,
            "Morning intention",
            "One line about how you want today to feel.",
            "Sent whenever you wake. It sets a tone rather than a task.",
            "rhythm",
        ),
        Idea(
            "close-the-day", Kind.RITUAL,
            "Close the day",
            "Mark the end of the day together, however briefly.",
            "A short, repeatable signal that the day is done. It matters "
                + "more that it is reliable than that it is long.",
            "rhythm",
        ),
        Idea(
            "one-standing-ask", Kind.EXPECTATION,
            "One standing ask, no deadline",
            "Not everything needs a time attached.",
            "Something you would like whenever it happens. It stays open "
                + "until they do it, and nothing goes wrong if today is not "
                + "the day.",
            "rhythm",
        ),

        // — Honesty —————————————————————————————————————
        Idea(
            "harder-to-say", Kind.CHECK_IN,
            "The thing that was harder to say",
            "The unsaid thing is usually the one that matters.",
            "Say one thing you nearly did not. It can be small. It can be "
                + "kept private if you are not ready to share it.",
            "honesty",
        ),
        Idea(
            "what-i-needed", Kind.CHECK_IN,
            "What I needed today",
            "Naming a need is not a complaint.",
            "What would have helped, whether or not you got it. Useful even "
                + "when the day went well.",
            "honesty",
        ),
        Idea(
            "ask-for-something", Kind.EXPECTATION,
            "Ask for something you usually wouldn't",
            "Asking is a skill, and it gets easier with practice.",
            "Small on purpose. The asking is the thing, not what you ask for.",
            "honesty",
        ),

        // — Beginning ———————————————————————————————————
        Idea(
            "one-week-one-thing", Kind.RITUAL,
            "One thing, once a day, for a week",
            "Start smaller than feels worthwhile.",
            "Pick the least ambitious thing on this list and keep it for "
                + "seven days. Most people start too big and stop.",
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
        Idea(
            "say-no-once", Kind.EXPECTATION,
            "Practise saying no to something small",
            "A yes only means something if no is available.",
            "Agree in advance that this is expected. It makes the real no, "
                + "when it comes, ordinary rather than a crisis.",
            "beginning",
        ),
    )

    fun byCollection(collectionId: String) =
        ideas.filter { it.collectionId == collectionId }

    fun find(id: String) = ideas.firstOrNull { it.id == id }
}

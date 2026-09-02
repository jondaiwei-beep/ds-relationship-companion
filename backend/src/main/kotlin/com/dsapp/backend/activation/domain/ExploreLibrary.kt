package com.dsapp.backend.activation.domain

/**
 * The reviewed library a person can browse before anyone else is involved.
 *
 * ## Who this is written for
 *
 * People in, or starting, a D/s dynamic — one of them holds authority, the
 * other has given it. That is the whole audience. Owner's decision,
 * 2026-09-02: "解除所有限制。我们就是为这些用户提供服务。"
 *
 * ## Why this file was rewritten a second time
 *
 * The previous version already assumed a dynamic, but it said everything in
 * euphemism. "One posture, held briefly" meant kneeling. "An object that
 * stays with them" meant a collar. "A form of address" meant Sir, Ma'am,
 * Master, Mistress. A test enforced this: kneel, collar, cuff, spank, master,
 * slave, worship, obey, discipline and punish were banned substrings, on the
 * theory that a person might be reading on a train.
 *
 * The effect was that a D/s product could not say the words D/s people use,
 * and readers correctly concluded it was a couples app wearing a costume. The
 * competitor this category is measured against is *named* Kneel. The train
 * problem is solved by the private entrance (REQ-TRUST-001), not by
 * sanitising the content behind it.
 *
 * So this library now says what it means. Kneeling is kneeling. A collar is a
 * collar. Rules have consequences and the library says so. Play is named —
 * impact, bondage, orgasm control, chastity — where the idea is about how to
 * negotiate or care around it.
 *
 * ## What still holds
 *
 * Two things, and both are about trust rather than taste:
 *
 * - **The system never speaks in the partner's voice.** Every idea here is
 *   something one of the two people does or says. None of it is the app
 *   praising, correcting, or addressing anyone.
 * - **Nothing here is a scene script.** Ideas about play are about the
 *   negotiation before and the care after — the half people skip and the half
 *   that goes wrong. The scene itself belongs to the two of them.
 *
 * Still deliberately bounded. Enough to prove the product knows what it is
 * for, and no more until real couples show what they use.
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
            "Protocol",
            "Honorifics, positions, permissions — the forms that make a Tuesday part of the dynamic.",
        ),
        Collection(
            "service",
            "Service",
            "Acts owed to someone by agreement, done their way, reported back.",
        ),
        Collection(
            "authority",
            "Holding authority",
            "The Dominant's work: clear direction, real attention, and knowing when to lift a rule.",
        ),
        Collection(
            "rules",
            "Rules and consequences",
            "Standing rules, what happens when one is broken, and how mercy stays a choice.",
        ),
        Collection(
            "play",
            "Around a scene",
            "Not the scene — what is agreed before it and what is owed after it.",
        ),
        Collection(
            "distance",
            "Apart",
            "Keeping a dynamic real across timezones and empty evenings.",
        ),
        Collection(
            "negotiation",
            "Limits and stopping",
            "Hard limits, soft limits, safewords — agreed while everyone is calm.",
        ),
        Collection(
            "aftercare",
            "Aftercare",
            "For both of you. The part that gets skipped and the part people leave over.",
        ),
        Collection(
            "beginning",
            "Starting out",
            "If the two of you are new to D/s, begin here.",
        ),
    )

    val ideas = listOf(
        // ── Protocol ──────────────────────────────────────────────────────
        Idea(
            "honorific", Kind.RITUAL,
            "An honorific, used at agreed moments",
            "Sir, Ma'am, Master, Mistress, Daddy — a title is the cheapest way to step back into the dynamic.",
            "Agree the word and when it is used: on arriving home, when asking permission, "
                + "in messages after a set hour. Using it everywhere wears it out; using it at "
                + "agreed moments makes the moment.",
            "protocol",
        ),
        Idea(
            "kneel-greeting", Kind.RITUAL,
            "Kneel when they come home",
            "The body remembers the dynamic faster than conversation does.",
            "Waiting kneeling at the door, or kneeling once they have sat down — thirty "
                + "seconds, eyes where they were told to be. It ends when the Dominant says "
                + "it does. Agree the position once so nobody is guessing.",
            "protocol",
        ),
        Idea(
            "ask-permission", Kind.EXPECTATION,
            "Ask permission for one specific thing",
            "Permission asked daily keeps the authority in daily use.",
            "Pick one ordinary thing — eating, leaving the house, going to bed, spending "
                + "over an amount, an orgasm — and agree it is asked for first. One is "
                + "enough to start; a list of ten is a cage nobody keeps.",
            "protocol",
        ),
        Idea(
            "positions", Kind.RITUAL,
            "Three positions, named",
            "A named position is an instruction that needs no sentence.",
            "Kneeling, standing for inspection, present — whatever the two of you choose. "
                + "Name them, practise them once while calm, and then a single word is "
                + "enough. High protocol is built from small named things.",
            "protocol",
        ),
        Idea(
            "report-back", Kind.EXPECTATION,
            "Report when it is done",
            "The reporting is the service, as much as the act is.",
            "Not a log — a short line to the person who gave the instruction, in the form "
                + "they asked for. 'Done, Sir.' is a complete report. Being told, and "
                + "being the one who is told, is the point.",
            "protocol",
        ),
        Idea(
            "nightly-report", Kind.RITUAL,
            "The nightly report",
            "A submissive who accounts for the day is held; a Dominant who hears it is present.",
            "Before sleep: what was asked, what was done, what was not and why. The "
                + "Dominant answers — a word of acknowledgement or a correction. Two "
                + "minutes, every night, is more dynamic than one grand weekend.",
            "protocol",
        ),

        // ── Service ───────────────────────────────────────────────────────
        Idea(
            "standing-service", Kind.RITUAL,
            "One standing act of service",
            "A chore becomes service the moment it is owed to someone.",
            "Their coffee made the way they take it, their clothes laid out, their bath run. "
                + "The difference from a chore is that it was claimed by one and owed by the "
                + "other, and that it is noticed.",
            "service",
        ),
        Idea(
            "their-way", Kind.EXPECTATION,
            "Do it their way, not the efficient way",
            "Following the instruction is what is being asked for, not the result.",
            "Something with a specified manner — how it is folded, in what order, what "
                + "is worn while doing it. The submissive's better idea is not asked for. "
                + "Obedience to the detail is the service.",
            "service",
        ),
        Idea(
            "prepare-for-them", Kind.EXPECTATION,
            "Have it ready before they arrive",
            "Anticipation is a skill, and being anticipated is what it gives back.",
            "Agree once what 'ready' means — the room, the drink, yourself — then keep it "
                + "without being reminded. Small enough to do every time; specific enough "
                + "to be inspected.",
            "service",
        ),
        Idea(
            "inspection", Kind.RITUAL,
            "Inspection",
            "Service that is never inspected quietly stops mattering.",
            "The Dominant looks — at the task, the room, the submissive — and says what "
                + "they see. Approval and correction both count. What is checked is what "
                + "is kept.",
            "service",
        ),

        // ── Authority ─────────────────────────────────────────────────────
        Idea(
            "clear-instruction", Kind.EXPECTATION,
            "Give one instruction that is actually clear",
            "Most orders that go nowhere were unclear, not disobeyed.",
            "Say what, say when, say how you will know. Vagueness reads as a test, and "
                + "being tested is not what a submissive agreed to. Clarity is a form of "
                + "care from the top.",
            "authority",
        ),
        Idea(
            "praise-specifically", Kind.RITUAL,
            "Praise the actual thing",
            "Unnoticed obedience stops being offered.",
            "Once a day, name it: 'You asked first, and I saw it.' 'You knelt without "
                + "being told.' Good girl / good boy lands harder when it is attached to "
                + "something real.",
            "authority",
        ),
        Idea(
            "lift-a-rule", Kind.CHECK_IN,
            "Decide what to lift this week",
            "Authority includes deciding when less is right.",
            "Look at what is standing and take something off deliberately, out loud. A "
                + "rule lifted by the Dominant is still the Dominant's rule. A rule that "
                + "quietly lapses is nobody's.",
            "authority",
        ),
        Idea(
            "dominants-own-check", Kind.CHECK_IN,
            "The Dominant's own check",
            "Topping is work, and drop is not only for submissives.",
            "Once a week, honestly: am I giving direction or just approving? Am I "
                + "enjoying this or performing it? Say the answer to your submissive. "
                + "Authority that can admit tiredness lasts.",
            "authority",
        ),

        // ── Rules and consequences ────────────────────────────────────────
        Idea(
            "three-rules", Kind.EXPECTATION,
            "Three standing rules, written down",
            "A rule that is not written is an argument waiting to happen.",
            "Not thirty — three. What is required, what is forbidden, what needs "
                + "permission. Written where both can read them. Everything else is a "
                + "request until it earns a place on the list.",
            "rules",
        ),
        Idea(
            "agree-consequences", Kind.CHECK_IN,
            "Agree the consequences before they are needed",
            "A punishment invented in anger is revenge. One agreed in calm is discipline.",
            "For each rule, what follows when it is broken: writing lines, a corner, "
                + "loss of a privilege, a spanking, an early bedtime. Agreed by both. "
                + "Then the moment it is needed is not a negotiation.",
            "rules",
        ),
        Idea(
            "punishment-then-done", Kind.RITUAL,
            "Punishment, then it is over",
            "The point of a consequence is that afterwards the slate is clean.",
            "Name the rule broken, carry out what was agreed, then say it is finished — "
                + "and mean it. No bringing it up later. A punishment that lingers is "
                + "resentment with a schedule.",
            "rules",
        ),
        Idea(
            "let-it-go", Kind.CHECK_IN,
            "Letting it go is also an order",
            "Mercy chosen by the Dominant is authority, not weakness.",
            "Sometimes the rule was broken and the right call is to waive it — a hard "
                + "week, a real reason. Say it plainly: 'I am letting this one go.' The "
                + "submissive should know it was decided, not forgotten.",
            "rules",
        ),
        Idea(
            "funishment", Kind.CHECK_IN,
            "Know which of you wants the punishment",
            "If a consequence is something they want, it is not a consequence.",
            "Say it out loud: which agreed punishments are actually play, and which "
                + "actually correct. Both are fine. Confusing them is how a brat learns "
                + "that breaking rules is rewarded.",
            "rules",
        ),

        // ── Around a scene ────────────────────────────────────────────────
        Idea(
            "scene-negotiation", Kind.CHECK_IN,
            "Negotiate the scene while dressed",
            "Everything agreed beforehand is a thing that cannot go wrong during.",
            "What is on the table tonight — impact, bondage, orgasm control, whatever it "
                + "is — and what is not. Marks or no marks. How long. The safeword. Ten "
                + "minutes of this buys an hour of not having to think.",
            "play",
        ),
        Idea(
            "traffic-lights", Kind.RITUAL,
            "Green, yellow, red",
            "A safeword only works if it has been said out loud in a calm room.",
            "Green is more, yellow is hold here, red is everything stops now. Agree "
                + "what happens in the ten seconds after red — restraints off, lights up, "
                + "a blanket. Practise saying it once so it is not the first time.",
            "play",
        ),
        Idea(
            "check-in-during", Kind.EXPECTATION,
            "Check in without breaking the scene",
            "A Dominant who checks in is not less dominant.",
            "Agree the form in advance — 'colour?', a squeeze of the hand answered by a "
                + "squeeze — so the check is part of the scene rather than an exit from "
                + "it. Silence is not consent; a squeeze is.",
            "play",
        ),
        Idea(
            "chastity-terms", Kind.CHECK_IN,
            "If you use chastity or orgasm control, write the terms",
            "Denial is a rule like any other, and rules need edges.",
            "How long. Who decides release. What counts as breaking it. What is said "
                + "when permission is asked and given. Written down, because 'until I "
                + "say' is only fair if both of you knew that going in.",
            "play",
        ),

        // ── Apart ─────────────────────────────────────────────────────────
        Idea(
            "same-hour", Kind.RITUAL,
            "One hour you both keep",
            "A shared hour beats a shared minute you both keep missing.",
            "Work out one window that is reasonable in both timezones and protect it. "
                + "Protocol applies inside it — the honorific, the report, the kneeling on "
                + "camera if that is yours.",
            "distance",
        ),
        Idea(
            "goodnight-across", Kind.EXPECTATION,
            "Say goodnight to the timezone you are not in",
            "Whoever sleeps first should not be the one who feels forgotten.",
            "The earlier evening sends first — the report, a photo of the position, the "
                + "words agreed — and the later one answers when they wake. Permission to "
                + "sleep is a real thing to give.",
            "distance",
        ),
        Idea(
            "order-while-asleep", Kind.EXPECTATION,
            "Give an order that lands while you sleep",
            "Direction does not need both of you awake at once.",
            "Set it before bed so it is waiting when their day starts: what to wear, "
                + "what to do first, what to send by noon. Waking up to an instruction is "
                + "waking up owned.",
            "distance",
        ),
        Idea(
            "unwitnessed", Kind.EXPECTATION,
            "Something you will never be able to check",
            "Distance makes trust the substance rather than the setting.",
            "Order something you have no way of verifying, and say plainly that you are "
                + "trusting their word. An honest 'I did not' is worth more here than a "
                + "photo.",
            "distance",
        ),
        Idea(
            "collar-apart", Kind.RITUAL,
            "A collar, or something that stands for one",
            "A dynamic that lives only in text has nothing to hold.",
            "A day collar, a bracelet, a lock — chosen by the Dominant, worn by the "
                + "submissive. Put on and taken off at agreed times, or never. Something "
                + "on the body says what the phone cannot.",
            "distance",
        ),
        Idea(
            "the-hard-hour", Kind.CHECK_IN,
            "Name the hour that is hardest",
            "The distance is worst at a predictable time, and it is rarely said.",
            "Most people apart have one heavy hour. Say which. The other can aim "
                + "something at it — an order, a message, a call — instead of guessing.",
            "distance",
        ),

        // ── Limits and stopping ───────────────────────────────────────────
        Idea(
            "hard-and-soft", Kind.CHECK_IN,
            "Hard limits and soft limits, out loud",
            "A limit said in advance is worth more than one discovered mid-way.",
            "Hard: never, not up for discussion. Soft: not now, maybe, only in some "
                + "conditions. Each of you names both. The Dominant's limits count as "
                + "much as the submissive's.",
            "negotiation",
        ),
        Idea(
            "stopping", Kind.CHECK_IN,
            "Agree how either of you stops things",
            "The word only works if it was agreed while calm.",
            "The safeword, the gesture when a mouth is not free, and what happens in "
                + "the minute after it. Either of you can use it. Using it is never "
                + "punished — that rule is above every other rule.",
            "negotiation",
        ),
        Idea(
            "renegotiate", Kind.CHECK_IN,
            "What has changed since we agreed this",
            "Consent is not a signature, it is a subscription.",
            "Revisit one standing agreement — a rule, a limit, the terms of the collar — "
                + "and say plainly whether it still holds. Changing it is not failing "
                + "it.",
            "negotiation",
        ),

        // ── Aftercare ─────────────────────────────────────────────────────
        Idea(
            "aftercare-ask", Kind.CHECK_IN,
            "Ask what they need afterwards, before",
            "Aftercare is not a mood, it is a question with an answer.",
            "Ask directly — quiet, being held, water, sugar, being left alone for ten "
                + "minutes, hearing 'you did well'. The answer changes with the scene. "
                + "Ask each time.",
            "aftercare",
        ),
        Idea(
            "top-drop", Kind.CHECK_IN,
            "Aftercare for the Dominant",
            "Drop is not only for submissives, and it arrives a day late.",
            "The next morning, or the one after: how does the person who held the "
                + "power feel about what they did? Guilt and doubt are common and they "
                + "pass faster when said. The submissive can give this.",
            "aftercare",
        ),
        Idea(
            "day-after", Kind.EXPECTATION,
            "The day-after message",
            "Sub drop arrives after the scene, not during it.",
            "Twelve to thirty-six hours later, a message from the Dominant: one thing "
                + "about last night, one question about now. Not logistics. This is the "
                + "part people leave over.",
            "aftercare",
        ),

        // ── Starting out ──────────────────────────────────────────────────
        Idea(
            "one-thing-first", Kind.EXPECTATION,
            "One rule, for one week",
            "A dynamic is built by keeping one small thing, not by declaring a lifestyle.",
            "Pick one — an honorific, a bedtime, asking permission for one thing. Keep "
                + "it for a week before adding anything. What survives the week is "
                + "real.",
            "beginning",
        ),
        Idea(
            "talk-after-days", Kind.CHECK_IN,
            "Say what is working after a few days",
            "Ask early, before it becomes a bigger conversation.",
            "After a few days, plainly: what felt right, what felt like acting, what "
                + "you want more of. Both of you. Changing it is part of it.",
            "beginning",
        ),
    )

    fun byCollection(collectionId: String) =
        ideas.filter { it.collectionId == collectionId }

    fun find(id: String) = ideas.firstOrNull { it.id == id }
}

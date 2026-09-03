package com.dsapp.backend.today.application

/** The occurrence is in a state where this write makes no sense (409). */
class OccurrenceNotActionable(val code: String) : RuntimeException(code)

/** The task cannot take this change from this actor in its current status (409). */
class TaskNotActionable(val code: String) : RuntimeException(code)

/** No such task/occurrence/note in a dynamic the actor can see (404). */
class NoSuchItem : RuntimeException("no such item")

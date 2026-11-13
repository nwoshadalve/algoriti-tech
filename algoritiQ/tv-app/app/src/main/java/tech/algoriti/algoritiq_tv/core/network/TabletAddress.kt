/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.network

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

/** The tablet's address typed in by hand, for a network where its `algoritiq.local` name is not heard. */
object TabletAddress {
    /**
     * A plain IPv4 address from what was typed, or null when it is not one. Spaces are ignored and
     * Bengali digits are read as the same digits, so the remote can type either.
     */
    fun parse(text: String): String? {
        val typed = text.filterNot { it.isWhitespace() }.map { if (it in '০'..'৯') '0' + (it - '০') else it }.joinToString("")
        val parts = typed.split('.')
        if (parts.size != 4) return null
        val numbers =
            parts.map { part ->
                if (part.isEmpty() || part.length > 3 || !part.all { it in '0'..'9' }) return null
                part.toInt().takeIf { it in 0..255 } ?: return null
            }
        if (numbers.all { it == 0 }) return null
        return numbers.joinToString(".")
    }
}

/** Keeps that address on this TV so it survives a restart. Read from network threads, so it is synchronous. */
@Singleton
class TabletAddressStore
    @Inject
    constructor(
        @ApplicationContext context: Context,
    ) {
        private val prefs = context.getSharedPreferences(FILE, Context.MODE_PRIVATE)

        fun saved(): String? = prefs.getString(KEY, null)?.let(TabletAddress::parse)

        fun save(address: String) {
            prefs.edit().putString(KEY, address).apply()
        }

        private companion object {
            const val FILE = "algoritiq_tv_tablet"
            const val KEY = "address"
        }
    }

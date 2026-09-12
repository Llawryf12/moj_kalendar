package com.example.moj_kalendar

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.style.ForegroundColorSpan
import android.text.style.StyleSpan
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar

class CalendarWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val rawEvents = prefs.getString("events", "") ?: ""

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(
                context.packageName,
                R.layout.calendar_widget
            )

            val calendar = Calendar.getInstance()
            
            val todayYear = calendar.get(Calendar.YEAR)
            val todayMonth = calendar.get(Calendar.MONTH)
            val todayDay = calendar.get(Calendar.DAY_OF_MONTH)

            val year = calendar.get(Calendar.YEAR)
            val month = calendar.get(Calendar.MONTH)

            val monthNames = arrayOf(
                "Siječanj", "Veljača", "Ožujak", "Travanj", "Svibanj", "Lipanj",
                "Srpanj", "Kolovoz", "Rujan", "Listopad", "Studeni", "Prosinac"
            )

            views.setTextViewText(R.id.monthTitle, "${monthNames[month]} $year")

            calendar.set(Calendar.DAY_OF_MONTH, 1)

            val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)
            val firstDay = calendar.get(Calendar.DAY_OF_WEEK)

            val offset = when (firstDay) {
                Calendar.SUNDAY -> 6
                else -> firstDay - Calendar.MONDAY
            }

            val calendarText = SpannableStringBuilder()

            // Zaglavlje (2 razmaka + slovo = 3 znaka po stupcu)
            calendarText.append("  P  U  S  Č  P  S  N\n")

            // Prazna mjesta prije prvog dana (3 razmaka)
            repeat(offset) {
                calendarText.append("   ")
            }

            val isCurrentMonth = (year == todayYear && month == todayMonth)

            // Dani (formatirani na točno 3 mjesta: %3d)
            for (day in 1..daysInMonth) {
                val start = calendarText.length
                calendarText.append(String.format("%3d", day))
                val end = calendarText.length

                if (isCurrentMonth && day == todayDay) {
                    calendarText.setSpan(
                        StyleSpan(Typeface.BOLD),
                        start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                    calendarText.setSpan(
                        ForegroundColorSpan(Color.parseColor("#E53935")),
                        start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                }

                if ((offset + day) % 7 == 0) {
                    calendarText.append("\n")
                }
            }

            // 🛠️ DOPUNA: Dodajemo razmake za preostale dane u zadnjem redu 
            // kako bi zadnji redak imao jednaku širinu kao i ostali
            val remainingInLastWeek = (offset + daysInMonth) % 7
            if (remainingInLastWeek != 0) {
                repeat(7 - remainingInLastWeek) {
                    calendarText.append("   ")
                }
            }

            views.setTextViewText(R.id.calendarGrid, calendarText)

            // -----------------------------
            // DOGAĐAJI
            // -----------------------------
            val agenda = StringBuilder()

            if (rawEvents.isNotEmpty()) {
                val events = rawEvents.split(";;")
                for (event in events.take(4)) {
                    val parts = event.split("|")
                    if (parts.size >= 3) {
                        val date = parts[0]
                        val time = parts[1]
                        val title = parts[2]
                        val dateParts = date.split(",")

                        if (dateParts.size == 3) {
                            val eventYear = dateParts[0].toIntOrNull()
                            val eventMonth = dateParts[1].toIntOrNull()
                            val eventDay = dateParts[2].toIntOrNull()

                            if (eventYear == year && eventMonth == month + 1) {
                                agenda.append("• $eventDay. $time  $title\n")
                            }
                        }
                    }
                }
            }

            if (agenda.isEmpty()) {
                agenda.append("Nema događaja ovaj mjesec")
            }

            views.setTextViewText(R.id.agenda, agenda.toString())
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
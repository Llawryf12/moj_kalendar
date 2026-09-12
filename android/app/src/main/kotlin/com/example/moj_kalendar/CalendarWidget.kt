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
            
            // Spremamo današnji datum za usporedbu
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

            // Prvi dan mjeseca
            calendar.set(Calendar.DAY_OF_MONTH, 1)

            val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)
            val firstDay = calendar.get(Calendar.DAY_OF_WEEK)

            // Ponedjeljak = prvi dan tjedna
            val offset = when (firstDay) {
                Calendar.SUNDAY -> 6
                else -> firstDay - Calendar.MONDAY
            }

            // Koristimo SpannableStringBuilder za stiliziranje teksta
            val calendarText = SpannableStringBuilder()

            // Zaglavlje
            calendarText.append("   P   U   S   Č   P   S   N\n")

            // Prazna mjesta prije prvog dana
            repeat(offset) {
                calendarText.append("    ")
            }

            // Je li mjesec koji prikazujemo trenutni mjesec?
            val isCurrentMonth = (year == todayYear && month == todayMonth)

            // Dani
            for (day in 1..daysInMonth) {
                val start = calendarText.length
                calendarText.append(String.format("%4d", day))
                val end = calendarText.length

                // Ako je to današnji dan, bojamo ga u crveno i stavljamo bold
                if (isCurrentMonth && day == todayDay) {
                    calendarText.setSpan(
                        StyleSpan(Typeface.BOLD),
                        start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                    calendarText.setSpan(
                        ForegroundColorSpan(Color.parseColor("#E53935")), // Crvena boja
                        start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                }

                if ((offset + day) % 7 == 0) {
                    calendarText.append("\n")
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
package com.example.moj_kalendar

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.GridLayout
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.*

class CalendarWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {

    val prefs = HomeWidgetPlugin.getData(context)

    val raw = prefs.getString("events", "") ?: ""
    val monthData = prefs.getString("month", "") ?: ""

    val views = RemoteViews(context.packageName, R.layout.calendar_widget)

    val monthText = if (monthData.isNotEmpty()) {
        val parts = monthData.split(",")
        "${getMonthName(parts[1].toInt())} ${parts[0]}"
    } else "Calendar"

    views.setTextViewText(R.id.monthTitle, monthText)

    val events = if (raw.isNotEmpty()) raw.split(";;") else emptyList()

    val agenda = StringBuilder()

    for (e in events.take(5)) {
        val p = e.split("|")
        if (p.size == 4) {
            agenda.append("• ${p[1]} ${p[2]}\n")
        }
    }

    val days = generateMonthDays()

    var dayText = ""
    for (d in days) {
        val hasEvent = events.any { it.contains(",${d},") }
        dayText += if (hasEvent) "● $d  " else "$d  "
    }

    views.setTextViewText(R.id.calendarGrid, dayText)
    views.setTextViewText(R.id.agenda, agenda.toString())

    for (id in appWidgetIds) {
        appWidgetManager.updateAppWidget(id, views)
    }
}

    private fun getMonthName(month: Int): String {
        val months = arrayOf(
            "Jan","Feb","Mar","Apr","May","Jun",
            "Jul","Aug","Sep","Oct","Nov","Dec"
        )
        return months[month - 1]
    }

    private fun generateMonthDays(): List<Int> {
        val cal = Calendar.getInstance()
        val max = cal.getActualMaximum(Calendar.DAY_OF_MONTH)
        return (1..max).toList()
    }
}
package com.example.moj_kalendar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class MyWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        data: android.content.SharedPreferences
    ) {

        val eventsString = data.getString("events", "")
        val events = if (!eventsString.isNullOrEmpty())
            eventsString.split("|")
        else
            listOf("Nema događaja")

        for (widgetId in appWidgetIds) {

            // ✅ OVDJE DEFINIRAŠ views
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            val displayText = events.take(5).joinToString("\n\n")

           views.removeAllViews(R.id.widget_list)

for (event in events.take(5)) {
    val item = RemoteViews(context.packageName, R.layout.widget_item)

    item.setTextViewText(R.id.item_text, event)

    views.addView(R.id.widget_list, item)
}

            // klik otvara app
            val intent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)

            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.widget_list, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
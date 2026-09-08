.class public final Lkh/chhankitek/calendar/ReminderAlarms;
.super Ljava/lang/Object;
.source "ReminderAlarms.java"


# static fields
.field static final ACTION:Ljava/lang/String; = "kh.chhankitek.calendar.REMIND"

.field static final BG:Ljava/lang/String; = "background"

.field static final CHANNEL:Ljava/lang/String; = "khmer_reminders"

.field static final FIRED:Ljava/lang/String; = "fired"

.field static final KEY:Ljava/lang/String; = "reminders"

.field static final PREFS:Ljava/lang/String; = "khmer_cal"


# direct methods
.method private constructor <init>()V
    .locals 0

    .line 31
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static alarmPi(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/app/PendingIntent;
    .locals 3

    .line 183
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lkh/chhankitek/calendar/ReminderReceiver;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 184
    const-string v1, "kh.chhankitek.calendar.REMIND"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 185
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "khmer://reminder/"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {p1}, Landroid/net/Uri;->encode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 186
    const-string v1, "id"

    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 187
    const-string v1, ""

    if-nez p2, :cond_0

    move-object p2, v1

    :cond_0
    const-string v2, "title"

    invoke-virtual {v0, v2, p2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 188
    if-nez p3, :cond_1

    move-object p3, v1

    :cond_1
    const-string p2, "body"

    invoke-virtual {v0, p2, p3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 189
    invoke-static {p1}, Lkh/chhankitek/calendar/ReminderAlarms;->requestCode(Ljava/lang/String;)I

    move-result p1

    invoke-static {}, Lkh/chhankitek/calendar/ReminderAlarms;->piFlags()I

    move-result p2

    invoke-static {p0, p1, v0, p2}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object p0

    return-object p0
.end method

.method private static alreadyFired(Landroid/content/Context;Ljava/lang/String;)Z
    .locals 3

    .line 236
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object p0

    const-string v0, "fired"

    const-string v1, "[]"

    invoke-interface {p0, v0, v1}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->parse(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p0

    .line 237
    const/4 v0, 0x0

    move v1, v0

    :goto_0
    invoke-virtual {p0}, Lorg/json/JSONArray;->length()I

    move-result v2

    if-ge v1, v2, :cond_1

    .line 238
    invoke-virtual {p0, v1}, Lorg/json/JSONArray;->optString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    const/4 p0, 0x1

    return p0

    .line 237
    :cond_0
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 240
    :cond_1
    return v0
.end method

.method private static cancelAll(Landroid/content/Context;Ljava/lang/String;)V
    .locals 6

    .line 169
    invoke-static {p1}, Lkh/chhankitek/calendar/ReminderAlarms;->parse(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p1

    .line 170
    const-string v0, "alarm"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/AlarmManager;

    .line 171
    if-nez v0, :cond_0

    return-void

    .line 172
    :cond_0
    const/4 v1, 0x0

    :goto_0
    invoke-virtual {p1}, Lorg/json/JSONArray;->length()I

    move-result v2

    if-ge v1, v2, :cond_2

    .line 173
    invoke-virtual {p1, v1}, Lorg/json/JSONArray;->optJSONObject(I)Lorg/json/JSONObject;

    move-result-object v2

    .line 174
    if-nez v2, :cond_1

    goto :goto_1

    .line 176
    :cond_1
    :try_start_0
    const-string v3, "id"

    invoke-virtual {v2, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    const-string v4, "title"

    invoke-virtual {v2, v4}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    const-string v5, "body"

    invoke-virtual {v2, v5}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {p0, v3, v4, v2}, Lkh/chhankitek/calendar/ReminderAlarms;->alarmPi(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/app/PendingIntent;

    move-result-object v2

    invoke-virtual {v0, v2}, Landroid/app/AlarmManager;->cancel(Landroid/app/PendingIntent;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 178
    goto :goto_1

    .line 177
    :catchall_0
    move-exception v2

    .line 172
    :goto_1
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 180
    :cond_2
    return-void
.end method

.method static createChannel(Landroid/content/Context;)V
    .locals 4

    .line 116
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1a

    if-ge v0, v1, :cond_0

    return-void

    .line 117
    :cond_0
    new-instance v0, Landroid/app/NotificationChannel;

    const-string v1, "\u1794\u17d2\u179a\u178f\u17b7\u1791\u17b7\u1793\u1781\u17d2\u1798\u17c2\u179a"

    const/4 v2, 0x4

    const-string v3, "khmer_reminders"

    invoke-direct {v0, v3, v1, v2}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V

    .line 119
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/app/NotificationChannel;->enableVibration(Z)V

    .line 120
    invoke-virtual {v0, v1}, Landroid/app/NotificationChannel;->enableLights(Z)V

    .line 121
    const-string v2, "Calendar reminders"

    invoke-virtual {v0, v2}, Landroid/app/NotificationChannel;->setDescription(Ljava/lang/String;)V

    .line 122
    invoke-virtual {v0, v1}, Landroid/app/NotificationChannel;->setLockscreenVisibility(I)V

    .line 123
    const-string v1, "notification"

    invoke-virtual {p0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/app/NotificationManager;

    .line 124
    if-eqz p0, :cond_1

    invoke-virtual {p0, v0}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V

    .line 125
    :cond_1
    return-void
.end method

.method public static deliver(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    .line 62
    if-eqz p1, :cond_0

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    if-lez v0, :cond_0

    invoke-static {p0, p1}, Lkh/chhankitek/calendar/ReminderAlarms;->markFired(Landroid/content/Context;Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    return-void

    .line 63
    :cond_0
    if-eqz p2, :cond_1

    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v0

    if-nez v0, :cond_2

    :cond_1
    if-eqz p1, :cond_2

    .line 64
    invoke-static {p0, p1}, Lkh/chhankitek/calendar/ReminderAlarms;->find(Landroid/content/Context;Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p1

    .line 65
    if-eqz p1, :cond_2

    .line 66
    const-string p2, "title"

    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p2

    .line 67
    const-string p3, "body"

    invoke-virtual {p1, p3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p3

    .line 70
    :cond_2
    invoke-static {p0, p2, p3}, Lkh/chhankitek/calendar/ReminderAlarms;->show(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V

    .line 71
    return-void
.end method

.method private static enableReceivers(Landroid/content/Context;)V
    .locals 4

    .line 199
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    .line 200
    nop

    .line 202
    const/4 v1, 0x1

    :try_start_0
    new-instance v2, Landroid/content/ComponentName;

    const-class v3, Lkh/chhankitek/calendar/ReminderReceiver;

    invoke-direct {v2, p0, v3}, Landroid/content/ComponentName;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    invoke-virtual {v0, v2, v1, v1}, Landroid/content/pm/PackageManager;->setComponentEnabledSetting(Landroid/content/ComponentName;II)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 204
    goto :goto_0

    .line 203
    :catchall_0
    move-exception v2

    .line 206
    :goto_0
    :try_start_1
    new-instance v2, Landroid/content/ComponentName;

    const-class v3, Lkh/chhankitek/calendar/BootReceiver;

    invoke-direct {v2, p0, v3}, Landroid/content/ComponentName;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    invoke-virtual {v0, v2, v1, v1}, Landroid/content/pm/PackageManager;->setComponentEnabledSetting(Landroid/content/ComponentName;II)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 208
    goto :goto_1

    .line 207
    :catchall_1
    move-exception p0

    .line 209
    :goto_1
    return-void
.end method

.method public static engineStatus(Landroid/content/Context;)Ljava/lang/String;
    .locals 4

    .line 58
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->nextAt(Landroid/content/Context;)J

    move-result-wide v0

    const-wide/16 v2, 0x0

    cmp-long p0, v0, v2

    if-lez p0, :cond_0

    const-string p0, "scheduled"

    goto :goto_0

    :cond_0
    const-string p0, "stopped"

    :goto_0
    return-object p0
.end method

.method private static find(Landroid/content/Context;Ljava/lang/String;)Lorg/json/JSONObject;
    .locals 3

    .line 227
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object p0

    const-string v0, "reminders"

    const-string v1, "[]"

    invoke-interface {p0, v0, v1}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->parse(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p0

    .line 228
    const/4 v0, 0x0

    :goto_0
    invoke-virtual {p0}, Lorg/json/JSONArray;->length()I

    move-result v1

    if-ge v0, v1, :cond_1

    .line 229
    invoke-virtual {p0, v0}, Lorg/json/JSONArray;->optJSONObject(I)Lorg/json/JSONObject;

    move-result-object v1

    .line 230
    if-eqz v1, :cond_0

    const-string v2, "id"

    invoke-virtual {v1, v2}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    return-object v1

    .line 228
    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 232
    :cond_1
    const/4 p0, 0x0

    return-object p0
.end method

.method static icon(Landroid/content/Context;)I
    .locals 0

    .line 280
    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object p0

    iget p0, p0, Landroid/content/pm/ApplicationInfo;->icon:I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 281
    if-eqz p0, :cond_0

    return p0

    .line 283
    :cond_0
    goto :goto_0

    .line 282
    :catchall_0
    move-exception p0

    .line 284
    :goto_0
    const p0, 0x108009b

    return p0
.end method

.method private static markFired(Landroid/content/Context;Ljava/lang/String;)Z
    .locals 5

    .line 244
    const/4 v0, 0x1

    if-eqz p1, :cond_3

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v1

    if-nez v1, :cond_0

    goto :goto_1

    .line 245
    :cond_0
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object v1

    .line 246
    const-string v2, "[]"

    const-string v3, "fired"

    invoke-interface {v1, v3, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lkh/chhankitek/calendar/ReminderAlarms;->parse(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v2

    .line 247
    invoke-static {p0, p1}, Lkh/chhankitek/calendar/ReminderAlarms;->alreadyFired(Landroid/content/Context;Ljava/lang/String;)Z

    move-result p0

    const/4 v4, 0x0

    if-eqz p0, :cond_1

    return v4

    .line 248
    :cond_1
    invoke-virtual {v2, p1}, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 249
    new-instance p0, Lorg/json/JSONArray;

    invoke-direct {p0}, Lorg/json/JSONArray;-><init>()V

    .line 250
    invoke-virtual {v2}, Lorg/json/JSONArray;->length()I

    move-result p1

    add-int/lit16 p1, p1, -0xf0

    invoke-static {v4, p1}, Ljava/lang/Math;->max(II)I

    move-result p1

    .line 251
    nop

    :goto_0
    invoke-virtual {v2}, Lorg/json/JSONArray;->length()I

    move-result v4

    if-ge p1, v4, :cond_2

    invoke-virtual {v2, p1}, Lorg/json/JSONArray;->optString(I)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {p0, v4}, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 252
    :cond_2
    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object p1

    invoke-virtual {p0}, Lorg/json/JSONArray;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-interface {p1, v3, p0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    invoke-interface {p0}, Landroid/content/SharedPreferences$Editor;->commit()Z

    .line 253
    return v0

    .line 244
    :cond_3
    :goto_1
    return v0
.end method

.method private static nextAt(Landroid/content/Context;)J
    .locals 12

    .line 212
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object v0

    const-string v1, "reminders"

    const-string v2, "[]"

    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lkh/chhankitek/calendar/ReminderAlarms;->parse(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v0

    .line 213
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v1

    .line 214
    nop

    .line 215
    const-wide/16 v3, 0x0

    const/4 v5, 0x0

    move-wide v6, v3

    :goto_0
    invoke-virtual {v0}, Lorg/json/JSONArray;->length()I

    move-result v8

    if-ge v5, v8, :cond_4

    .line 216
    invoke-virtual {v0, v5}, Lorg/json/JSONArray;->optJSONObject(I)Lorg/json/JSONObject;

    move-result-object v8

    .line 217
    if-nez v8, :cond_0

    goto :goto_1

    .line 218
    :cond_0
    const-string v9, "id"

    const-string v10, ""

    invoke-virtual {v8, v9, v10}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    .line 219
    const-string v10, "at"

    invoke-virtual {v8, v10, v3, v4}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;J)J

    move-result-wide v10

    .line 220
    invoke-virtual {v9}, Ljava/lang/String;->length()I

    move-result v8

    if-eqz v8, :cond_3

    cmp-long v8, v10, v1

    if-lez v8, :cond_3

    invoke-static {p0, v9}, Lkh/chhankitek/calendar/ReminderAlarms;->alreadyFired(Landroid/content/Context;Ljava/lang/String;)Z

    move-result v8

    if-eqz v8, :cond_1

    goto :goto_1

    .line 221
    :cond_1
    cmp-long v8, v6, v3

    if-eqz v8, :cond_2

    cmp-long v8, v10, v6

    if-gez v8, :cond_3

    :cond_2
    move-wide v6, v10

    .line 215
    :cond_3
    :goto_1
    add-int/lit8 v5, v5, 0x1

    goto :goto_0

    .line 223
    :cond_4
    return-wide v6
.end method

.method private static parse(Ljava/lang/String;)Lorg/json/JSONArray;
    .locals 1

    .line 262
    :try_start_0
    new-instance v0, Lorg/json/JSONArray;

    if-nez p0, :cond_0

    const-string p0, "[]"

    :cond_0
    invoke-direct {v0, p0}, Lorg/json/JSONArray;-><init>(Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object v0

    .line 263
    :catchall_0
    move-exception p0

    .line 264
    new-instance p0, Lorg/json/JSONArray;

    invoke-direct {p0}, Lorg/json/JSONArray;-><init>()V

    return-object p0
.end method

.method private static piFlags()I
    .locals 1

    .line 269
    nop

    .line 270
    nop

    .line 271
    const/high16 v0, 0xc000000

    return v0
.end method

.method private static prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;
    .locals 2

    .line 257
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    const-string v0, "khmer_cal"

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object p0

    return-object p0
.end method

.method private static requestCode(Ljava/lang/String;)I
    .locals 1

    .line 275
    if-nez p0, :cond_0

    const/4 p0, 0x1

    goto :goto_0

    :cond_0
    invoke-virtual {p0}, Ljava/lang/String;->hashCode()I

    move-result p0

    const v0, 0x7fffffff

    and-int/2addr p0, v0

    :goto_0
    return p0
.end method

.method public static restore(Landroid/content/Context;)V
    .locals 3

    .line 44
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    .line 45
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->enableReceivers(Landroid/content/Context;)V

    .line 46
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object v0

    const-string v1, "reminders"

    const-string v2, "[]"

    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Lkh/chhankitek/calendar/ReminderAlarms;->scheduleAll(Landroid/content/Context;Ljava/lang/String;)V

    .line 47
    return-void
.end method

.method public static saveAndSchedule(Landroid/content/Context;Ljava/lang/String;)V
    .locals 4

    .line 34
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    .line 35
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object v0

    .line 36
    const-string v1, "reminders"

    const-string v2, "[]"

    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-static {p0, v3}, Lkh/chhankitek/calendar/ReminderAlarms;->cancelAll(Landroid/content/Context;Ljava/lang/String;)V

    .line 37
    if-eqz p1, :cond_0

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v3

    if-nez v3, :cond_1

    :cond_0
    move-object p1, v2

    .line 38
    :cond_1
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0, v1, p1}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->commit()Z

    .line 39
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->enableReceivers(Landroid/content/Context;)V

    .line 40
    invoke-static {p0, p1}, Lkh/chhankitek/calendar/ReminderAlarms;->scheduleAll(Landroid/content/Context;Ljava/lang/String;)V

    .line 41
    return-void
.end method

.method private static scheduleAll(Landroid/content/Context;Ljava/lang/String;)V
    .locals 12

    .line 128
    invoke-static {p1}, Lkh/chhankitek/calendar/ReminderAlarms;->parse(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p1

    .line 129
    const-string v0, "alarm"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/AlarmManager;

    .line 130
    if-nez v0, :cond_0

    return-void

    .line 131
    :cond_0
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v1

    .line 132
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->showPi(Landroid/content/Context;)Landroid/app/PendingIntent;

    move-result-object v3

    .line 133
    const/4 v4, 0x0

    :goto_0
    invoke-virtual {p1}, Lorg/json/JSONArray;->length()I

    move-result v5

    if-ge v4, v5, :cond_5

    .line 134
    invoke-virtual {p1, v4}, Lorg/json/JSONArray;->optJSONObject(I)Lorg/json/JSONObject;

    move-result-object v5

    .line 135
    if-nez v5, :cond_1

    goto :goto_1

    .line 136
    :cond_1
    const-string v6, "id"

    const-string v7, ""

    invoke-virtual {v5, v6, v7}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 137
    const-string v7, "at"

    const-wide/16 v8, 0x0

    invoke-virtual {v5, v7, v8, v9}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;J)J

    move-result-wide v10

    .line 138
    cmp-long v8, v10, v8

    if-nez v8, :cond_2

    const-wide/16 v8, 0x0

    invoke-virtual {v5, v7, v8, v9}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v7

    double-to-long v10, v7

    .line 139
    :cond_2
    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v7

    if-eqz v7, :cond_4

    cmp-long v7, v10, v1

    if-lez v7, :cond_4

    invoke-static {p0, v6}, Lkh/chhankitek/calendar/ReminderAlarms;->alreadyFired(Landroid/content/Context;Ljava/lang/String;)Z

    move-result v7

    if-eqz v7, :cond_3

    goto :goto_1

    .line 140
    :cond_3
    const-string v7, "title"

    invoke-virtual {v5, v7}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    const-string v8, "body"

    invoke-virtual {v5, v8}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    invoke-static {p0, v6, v7, v5}, Lkh/chhankitek/calendar/ReminderAlarms;->alarmPi(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/app/PendingIntent;

    move-result-object v5

    .line 141
    invoke-static {v0, v10, v11, v3, v5}, Lkh/chhankitek/calendar/ReminderAlarms;->setAlarmClock(Landroid/app/AlarmManager;JLandroid/app/PendingIntent;Landroid/app/PendingIntent;)Z

    move-result v6

    if-nez v6, :cond_4

    .line 142
    invoke-static {v0, v10, v11, v5}, Lkh/chhankitek/calendar/ReminderAlarms;->setExact(Landroid/app/AlarmManager;JLandroid/app/PendingIntent;)V

    .line 133
    :cond_4
    :goto_1
    add-int/lit8 v4, v4, 0x1

    goto :goto_0

    .line 145
    :cond_5
    return-void
.end method

.method private static setAlarmClock(Landroid/app/AlarmManager;JLandroid/app/PendingIntent;Landroid/app/PendingIntent;)Z
    .locals 1

    .line 149
    :try_start_0
    new-instance v0, Landroid/app/AlarmManager$AlarmClockInfo;

    invoke-direct {v0, p1, p2, p3}, Landroid/app/AlarmManager$AlarmClockInfo;-><init>(JLandroid/app/PendingIntent;)V

    invoke-virtual {p0, v0, p4}, Landroid/app/AlarmManager;->setAlarmClock(Landroid/app/AlarmManager$AlarmClockInfo;Landroid/app/PendingIntent;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 150
    const/4 p0, 0x1

    return p0

    .line 151
    :catchall_0
    move-exception p0

    .line 152
    const/4 p0, 0x0

    return p0
.end method

.method private static setExact(Landroid/app/AlarmManager;JLandroid/app/PendingIntent;)V
    .locals 2

    .line 158
    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1f

    if-lt v0, v1, :cond_0

    invoke-virtual {p0}, Landroid/app/AlarmManager;->canScheduleExactAlarms()Z

    move-result v0

    if-nez v0, :cond_0

    return-void

    .line 159
    :cond_0
    nop

    .line 160
    const/4 v0, 0x0

    invoke-virtual {p0, v0, p1, p2, p3}, Landroid/app/AlarmManager;->setExactAndAllowWhileIdle(IJLandroid/app/PendingIntent;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 161
    return-void

    .line 164
    :catchall_0
    move-exception p0

    .line 166
    return-void
.end method

.method public static setWantsBackground(Landroid/content/Context;Z)V
    .locals 1

    .line 50
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object p0

    invoke-interface {p0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    const-string v0, "background"

    invoke-interface {p0, v0, p1}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    invoke-interface {p0}, Landroid/content/SharedPreferences$Editor;->commit()Z

    .line 51
    return-void
.end method

.method public static show(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V
    .locals 5

    .line 74
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    .line 75
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->createChannel(Landroid/content/Context;)V

    .line 76
    const-string v0, "notification"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/NotificationManager;

    .line 77
    if-nez v0, :cond_0

    return-void

    .line 79
    :cond_0
    :try_start_0
    invoke-virtual {v0}, Landroid/app/NotificationManager;->areNotificationsEnabled()Z

    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-nez v1, :cond_1

    return-void

    .line 81
    :cond_1
    goto :goto_0

    .line 80
    :catchall_0
    move-exception v1

    .line 82
    :goto_0
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x21

    if-lt v1, v2, :cond_2

    .line 83
    const-string v1, "android.permission.POST_NOTIFICATIONS"

    invoke-virtual {p0, v1}, Landroid/content/Context;->checkSelfPermission(Ljava/lang/String;)I

    move-result v1

    if-eqz v1, :cond_2

    .line 85
    return-void

    .line 87
    :cond_2
    if-eqz p1, :cond_3

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v1

    if-nez v1, :cond_4

    :cond_3
    const-string p1, "\u1794\u17d2\u179a\u178f\u17b7\u1791\u17b7\u1793\u1781\u17d2\u1798\u17c2\u179a"

    .line 88
    :cond_4
    if-nez p2, :cond_5

    const-string p2, ""

    .line 90
    :cond_5
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1a

    if-lt v1, v2, :cond_6

    .line 91
    new-instance v1, Landroid/app/Notification$Builder;

    const-string v2, "khmer_reminders"

    invoke-direct {v1, p0, v2}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    goto :goto_1

    .line 92
    :cond_6
    new-instance v1, Landroid/app/Notification$Builder;

    invoke-direct {v1, p0}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;)V

    .line 93
    :goto_1
    nop

    .line 94
    invoke-virtual {v1, p1}, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;

    move-result-object v2

    .line 95
    invoke-virtual {v2, p2}, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;

    move-result-object p2

    .line 96
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->icon(Landroid/content/Context;)I

    move-result v2

    invoke-virtual {p2, v2}, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;

    move-result-object p2

    .line 97
    const/4 v2, 0x1

    invoke-virtual {p2, v2}, Landroid/app/Notification$Builder;->setAutoCancel(Z)Landroid/app/Notification$Builder;

    move-result-object p2

    .line 98
    const/4 v3, -0x1

    invoke-virtual {p2, v3}, Landroid/app/Notification$Builder;->setDefaults(I)Landroid/app/Notification$Builder;

    .line 99
    nop

    .line 100
    const/4 p2, 0x2

    invoke-virtual {v1, p2}, Landroid/app/Notification$Builder;->setPriority(I)Landroid/app/Notification$Builder;

    .line 102
    :try_start_1
    const-string p2, "reminder"

    invoke-virtual {v1, p2}, Landroid/app/Notification$Builder;->setCategory(Ljava/lang/String;)Landroid/app/Notification$Builder;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 104
    goto :goto_2

    .line 103
    :catchall_1
    move-exception p2

    .line 106
    :goto_2
    invoke-virtual {v1, v2}, Landroid/app/Notification$Builder;->setVisibility(I)Landroid/app/Notification$Builder;

    .line 108
    :try_start_2
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->showPi(Landroid/content/Context;)Landroid/app/PendingIntent;

    move-result-object p0

    invoke-virtual {v1, p0}, Landroid/app/Notification$Builder;->setContentIntent(Landroid/app/PendingIntent;)Landroid/app/Notification$Builder;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    .line 110
    goto :goto_3

    .line 109
    :catchall_2
    move-exception p0

    .line 111
    :goto_3
    invoke-virtual {p1}, Ljava/lang/String;->hashCode()I

    move-result p0

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide p1

    const-wide/32 v3, 0xffff

    and-long/2addr p1, v3

    long-to-int p1, p1

    xor-int/2addr p0, p1

    .line 112
    if-nez p0, :cond_7

    goto :goto_4

    :cond_7
    move v2, p0

    :goto_4
    invoke-virtual {v1}, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;

    move-result-object p0

    invoke-virtual {v0, v2, p0}, Landroid/app/NotificationManager;->notify(ILandroid/app/Notification;)V

    .line 113
    return-void
.end method

.method private static showPi(Landroid/content/Context;)Landroid/app/PendingIntent;
    .locals 3

    .line 193
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lkh/chhankitek/calendar/MainActivity;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 194
    const/high16 v1, 0x34000000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 195
    const/4 v1, 0x0

    invoke-static {}, Lkh/chhankitek/calendar/ReminderAlarms;->piFlags()I

    move-result v2

    invoke-static {p0, v1, v0, v2}, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object p0

    return-object p0
.end method

.method public static wantsBackground(Landroid/content/Context;)Z
    .locals 2

    .line 54
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->prefs(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object p0

    const-string v0, "background"

    const/4 v1, 0x0

    invoke-interface {p0, v0, v1}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z

    move-result p0

    return p0
.end method

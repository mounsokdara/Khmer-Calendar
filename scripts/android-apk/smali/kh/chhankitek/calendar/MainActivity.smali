.class public Lkh/chhankitek/calendar/MainActivity;
.super Landroid/app/Activity;
.source "MainActivity.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lkh/chhankitek/calendar/MainActivity$Bridge;,
        Lkh/chhankitek/calendar/MainActivity$Chrome;,
        Lkh/chhankitek/calendar/MainActivity$Client;
    }
.end annotation


# static fields
.field private static final CHANNEL:Ljava/lang/String; = "khmer_reminders"

.field private static final ORIGIN:Ljava/lang/String; = "https://app.khmer.calendar"


# instance fields
.field private backgroundAskedAt:J

.field private backgroundStep:I

.field private pendingGeo:Landroid/webkit/GeolocationPermissions$Callback;

.field private pendingGeoOrigin:Ljava/lang/String;

.field private web:Landroid/webkit/WebView;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 38
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method

.method static synthetic access$000(Lkh/chhankitek/calendar/MainActivity;)Landroid/webkit/WebView;
    .locals 0

    .line 38
    iget-object p0, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    return-object p0
.end method

.method static synthetic access$100(Lkh/chhankitek/calendar/MainActivity;)Z
    .locals 0

    .line 38
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->isNight()Z

    move-result p0

    return p0
.end method

.method static synthetic access$1000(Lkh/chhankitek/calendar/MainActivity;Z)V
    .locals 0

    .line 38
    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity;->setWantsBackground(Z)V

    return-void
.end method

.method static synthetic access$1100(Lkh/chhankitek/calendar/MainActivity;)Ljava/lang/String;
    .locals 0

    .line 38
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->backgroundState()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static synthetic access$1202(Lkh/chhankitek/calendar/MainActivity;I)I
    .locals 0

    .line 38
    iput p1, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    return p1
.end method

.method static synthetic access$1300(Lkh/chhankitek/calendar/MainActivity;)V
    .locals 0

    .line 38
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->continueBackground()V

    return-void
.end method

.method static synthetic access$1402(Lkh/chhankitek/calendar/MainActivity;Landroid/webkit/GeolocationPermissions$Callback;)Landroid/webkit/GeolocationPermissions$Callback;
    .locals 0

    .line 38
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->pendingGeo:Landroid/webkit/GeolocationPermissions$Callback;

    return-object p1
.end method

.method static synthetic access$1502(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;)Ljava/lang/String;
    .locals 0

    .line 38
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->pendingGeoOrigin:Ljava/lang/String;

    return-object p1
.end method

.method static synthetic access$200(Lkh/chhankitek/calendar/MainActivity;)Ljava/lang/String;
    .locals 0

    .line 38
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->notifyState()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static synthetic access$300(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;)Z
    .locals 0

    .line 38
    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity;->hasPerm(Ljava/lang/String;)Z

    move-result p0

    return p0
.end method

.method static synthetic access$400(Lkh/chhankitek/calendar/MainActivity;)Z
    .locals 0

    .line 38
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->notificationsAllowed()Z

    move-result p0

    return p0
.end method

.method static synthetic access$500(Lkh/chhankitek/calendar/MainActivity;)V
    .locals 0

    .line 38
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->openNotificationSettings()V

    return-void
.end method

.method static synthetic access$600(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    .line 38
    invoke-direct {p0, p1, p2}, Lkh/chhankitek/calendar/MainActivity;->emitPerm(Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method static synthetic access$700(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/Runnable;)V
    .locals 0

    .line 38
    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity;->runOnWeb(Ljava/lang/Runnable;)V

    return-void
.end method

.method static synthetic access$800(Lkh/chhankitek/calendar/MainActivity;)Ljava/lang/String;
    .locals 0

    .line 38
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->locationState()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static synthetic access$900(Lkh/chhankitek/calendar/MainActivity;)V
    .locals 0

    .line 38
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->allowGeolocation()V

    return-void
.end method

.method private allowGeolocation()V
    .locals 2

    .line 209
    :try_start_0
    invoke-static {}, Landroid/webkit/GeolocationPermissions;->getInstance()Landroid/webkit/GeolocationPermissions;

    move-result-object v0

    const-string v1, "https://app.khmer.calendar"

    invoke-virtual {v0, v1}, Landroid/webkit/GeolocationPermissions;->allow(Ljava/lang/String;)V

    .line 210
    invoke-static {}, Landroid/webkit/GeolocationPermissions;->getInstance()Landroid/webkit/GeolocationPermissions;

    move-result-object v0

    const-string v1, "https://app.khmer.calendar/"

    invoke-virtual {v0, v1}, Landroid/webkit/GeolocationPermissions;->allow(Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 212
    goto :goto_0

    .line 211
    :catchall_0
    move-exception v0

    .line 213
    :goto_0
    return-void
.end method

.method private applySystemBars()V
    .locals 4

    .line 128
    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    .line 129
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->isNight()Z

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "#1C1110"

    goto :goto_0

    :cond_0
    const-string v1, "#9A3B38"

    :goto_0
    invoke-static {v1}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I

    move-result v1

    .line 130
    invoke-virtual {v0, v1}, Landroid/view/Window;->setStatusBarColor(I)V

    .line 131
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1a

    if-lt v2, v3, :cond_1

    .line 132
    invoke-virtual {v0, v1}, Landroid/view/Window;->setNavigationBarColor(I)V

    .line 134
    :cond_1
    return-void
.end method

.method private applyWebDarkMode(Landroid/webkit/WebSettings;)V
    .locals 4

    .line 94
    if-nez p1, :cond_0

    return-void

    .line 95
    :cond_0
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->isNight()Z

    move-result v0

    .line 97
    const/4 v1, 0x0

    :try_start_0
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1d

    if-lt v2, v3, :cond_2

    .line 98
    if-eqz v0, :cond_1

    const/4 v0, 0x2

    goto :goto_0

    :cond_1
    move v0, v1

    :goto_0
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setForceDark(I)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 101
    :cond_2
    goto :goto_1

    .line 100
    :catchall_0
    move-exception v0

    .line 103
    :goto_1
    :try_start_1
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x21

    if-lt v0, v2, :cond_3

    .line 104
    invoke-virtual {p1, v1}, Landroid/webkit/WebSettings;->setAlgorithmicDarkeningAllowed(Z)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 107
    :cond_3
    goto :goto_2

    .line 106
    :catchall_1
    move-exception p1

    .line 108
    :goto_2
    return-void
.end method

.method private backgroundAllowed()Z
    .locals 1

    .line 313
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->exactAlarmsAllowed()Z

    move-result v0

    return v0
.end method

.method private backgroundState()Ljava/lang/String;
    .locals 1

    .line 317
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->backgroundAllowed()Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "granted"

    goto :goto_0

    :cond_0
    const-string v0, "default"

    :goto_0
    return-object v0
.end method

.method private batteryIgnored()Z
    .locals 3

    .line 305
    const/4 v0, 0x1

    :try_start_0
    const-string v1, "power"

    invoke-virtual {p0, v1}, Lkh/chhankitek/calendar/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/os/PowerManager;

    .line 306
    if-eqz v1, :cond_1

    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/os/PowerManager;->isIgnoringBatteryOptimizations(Ljava/lang/String;)Z

    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :cond_1
    :goto_0
    return v0

    .line 307
    :catchall_0
    move-exception v1

    .line 308
    return v0
.end method

.method private continueBackground()V
    .locals 5

    .line 348
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->exactAlarmsAllowed()Z

    move-result v0

    const-string v1, "package:"

    const/4 v2, 0x2

    const/4 v3, 0x1

    if-nez v0, :cond_0

    .line 349
    iget v0, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    if-gt v0, v3, :cond_0

    .line 350
    iput v2, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    .line 351
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v2

    iput-wide v2, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundAskedAt:J

    .line 353
    :try_start_0
    new-instance v0, Landroid/content/Intent;

    const-string v2, "android.settings.REQUEST_SCHEDULE_EXACT_ALARM"

    invoke-direct {v0, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 354
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 355
    invoke-virtual {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 357
    goto :goto_0

    .line 356
    :catchall_0
    move-exception v0

    .line 358
    :goto_0
    return-void

    .line 361
    :cond_0
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->batteryIgnored()Z

    move-result v0

    const/4 v4, 0x3

    if-nez v0, :cond_1

    .line 362
    iget v0, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    if-gt v0, v2, :cond_1

    .line 363
    iput v4, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    .line 364
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v2

    iput-wide v2, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundAskedAt:J

    .line 366
    :try_start_1
    new-instance v0, Landroid/content/Intent;

    const-string v2, "android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"

    invoke-direct {v0, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 367
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 368
    invoke-virtual {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 370
    goto :goto_1

    .line 369
    :catchall_1
    move-exception v0

    .line 371
    :goto_1
    return-void

    .line 374
    :cond_1
    iget v0, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    if-gt v0, v4, :cond_2

    .line 375
    const/4 v0, 0x4

    iput v0, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    .line 376
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    iput-wide v0, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundAskedAt:J

    .line 377
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->openAutostartSettings()Z

    move-result v0

    if-eqz v0, :cond_2

    return-void

    .line 379
    :cond_2
    const/4 v0, 0x0

    iput v0, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    .line 380
    invoke-direct {p0, v3}, Lkh/chhankitek/calendar/MainActivity;->setWantsBackground(Z)V

    .line 381
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->restore(Landroid/content/Context;)V

    .line 382
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->backgroundAllowed()Z

    move-result v0

    if-eqz v0, :cond_3

    const-string v0, "granted"

    goto :goto_2

    :cond_3
    const-string v0, "denied"

    :goto_2
    const-string v1, "background"

    invoke-direct {p0, v1, v0}, Lkh/chhankitek/calendar/MainActivity;->emitPerm(Ljava/lang/String;Ljava/lang/String;)V

    .line 383
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->emitStatus()V

    .line 384
    return-void
.end method

.method private createChannel()V
    .locals 4

    .line 137
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1a

    if-ge v0, v1, :cond_0

    return-void

    .line 138
    :cond_0
    new-instance v0, Landroid/app/NotificationChannel;

    const-string v1, "\u1794\u17d2\u179a\u178f\u17b7\u1791\u17b7\u1793\u1781\u17d2\u1798\u17c2\u179a"

    const/4 v2, 0x4

    const-string v3, "khmer_reminders"

    invoke-direct {v0, v3, v1, v2}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V

    .line 140
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/app/NotificationChannel;->enableVibration(Z)V

    .line 141
    invoke-virtual {v0, v1}, Landroid/app/NotificationChannel;->enableLights(Z)V

    .line 142
    const-string v2, "Reminders"

    invoke-virtual {v0, v2}, Landroid/app/NotificationChannel;->setDescription(Ljava/lang/String;)V

    .line 143
    invoke-virtual {v0, v1}, Landroid/app/NotificationChannel;->setLockscreenVisibility(I)V

    .line 144
    const-string v1, "notification"

    invoke-virtual {p0, v1}, Lkh/chhankitek/calendar/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/app/NotificationManager;

    .line 145
    if-eqz v1, :cond_1

    invoke-virtual {v1, v0}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V

    .line 146
    :cond_1
    return-void
.end method

.method private emitPerm(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    .line 216
    new-instance v0, Lkh/chhankitek/calendar/MainActivity$1;

    invoke-direct {v0, p0, p1, p2}, Lkh/chhankitek/calendar/MainActivity$1;-><init>(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;Ljava/lang/String;)V

    invoke-direct {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->runOnWeb(Ljava/lang/Runnable;)V

    .line 229
    return-void
.end method

.method private emitStatus()V
    .locals 7

    .line 232
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->isNight()Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "1"

    goto :goto_0

    :cond_0
    const-string v0, "0"

    :goto_0
    move-object v3, v0

    .line 233
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->notifyState()Ljava/lang/String;

    move-result-object v4

    .line 234
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->locationState()Ljava/lang/String;

    move-result-object v5

    .line 235
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->backgroundState()Ljava/lang/String;

    move-result-object v6

    .line 236
    new-instance v0, Lkh/chhankitek/calendar/MainActivity$2;

    move-object v1, v0

    move-object v2, p0

    invoke-direct/range {v1 .. v6}, Lkh/chhankitek/calendar/MainActivity$2;-><init>(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    invoke-direct {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->runOnWeb(Ljava/lang/Runnable;)V

    .line 253
    return-void
.end method

.method private exactAlarmsAllowed()Z
    .locals 3

    .line 294
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1f

    const/4 v2, 0x1

    if-ge v0, v1, :cond_0

    return v2

    .line 296
    :cond_0
    :try_start_0
    const-string v0, "alarm"

    invoke-virtual {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/AlarmManager;

    .line 297
    if-eqz v0, :cond_2

    invoke-virtual {v0}, Landroid/app/AlarmManager;->canScheduleExactAlarms()Z

    move-result v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_1

    goto :goto_0

    :cond_1
    const/4 v2, 0x0

    :cond_2
    :goto_0
    return v2

    .line 298
    :catchall_0
    move-exception v0

    .line 299
    return v2
.end method

.method private hasPerm(Ljava/lang/String;)Z
    .locals 0

    .line 261
    nop

    .line 262
    invoke-virtual {p0, p1}, Lkh/chhankitek/calendar/MainActivity;->checkSelfPermission(Ljava/lang/String;)I

    move-result p1

    if-nez p1, :cond_0

    const/4 p1, 0x1

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    :goto_0
    return p1
.end method

.method private isNight()Z
    .locals 5

    .line 112
    const/4 v0, 0x0

    const/16 v1, 0x20

    const/4 v2, 0x1

    :try_start_0
    invoke-static {}, Landroid/content/res/Resources;->getSystem()Landroid/content/res/Resources;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v3

    .line 113
    iget v3, v3, Landroid/content/res/Configuration;->uiMode:I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    and-int/lit8 v3, v3, 0x30

    .line 114
    if-ne v3, v1, :cond_0

    return v2

    .line 115
    :cond_0
    const/16 v4, 0x10

    if-ne v3, v4, :cond_1

    return v0

    .line 117
    :cond_1
    goto :goto_0

    .line 116
    :catchall_0
    move-exception v3

    .line 119
    :goto_0
    :try_start_1
    const-string v3, "uimode"

    invoke-virtual {p0, v3}, Lkh/chhankitek/calendar/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Landroid/app/UiModeManager;

    .line 120
    if-eqz v3, :cond_2

    invoke-virtual {v3}, Landroid/app/UiModeManager;->getNightMode()I

    move-result v3
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    const/4 v4, 0x2

    if-ne v3, v4, :cond_2

    return v2

    .line 122
    :cond_2
    goto :goto_1

    .line 121
    :catchall_1
    move-exception v3

    .line 123
    :goto_1
    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v3

    iget v3, v3, Landroid/content/res/Configuration;->uiMode:I

    and-int/lit8 v3, v3, 0x30

    .line 124
    if-ne v3, v1, :cond_3

    move v0, v2

    :cond_3
    return v0
.end method

.method private locationState()Ljava/lang/String;
    .locals 1

    .line 421
    const-string v0, "android.permission.ACCESS_FINE_LOCATION"

    invoke-direct {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->hasPerm(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_1

    .line 422
    const-string v0, "android.permission.ACCESS_COARSE_LOCATION"

    invoke-direct {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->hasPerm(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_0

    .line 425
    :cond_0
    const-string v0, "default"

    return-object v0

    .line 423
    :cond_1
    :goto_0
    const-string v0, "granted"

    return-object v0
.end method

.method private named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    .locals 2

    .line 415
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 416
    new-instance v1, Landroid/content/ComponentName;

    invoke-direct {v1, p1, p2}, Landroid/content/ComponentName;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setComponent(Landroid/content/ComponentName;)Landroid/content/Intent;

    .line 417
    return-object v0
.end method

.method private notificationIcon()I
    .locals 1

    .line 430
    :try_start_0
    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v0

    iget v0, v0, Landroid/content/pm/ApplicationInfo;->icon:I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 431
    if-eqz v0, :cond_0

    return v0

    .line 433
    :cond_0
    goto :goto_0

    .line 432
    :catchall_0
    move-exception v0

    .line 434
    :goto_0
    const v0, 0x108009b

    return v0
.end method

.method private notificationsAllowed()Z
    .locals 4

    .line 266
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    const/4 v2, 0x0

    if-lt v0, v1, :cond_0

    const-string v0, "android.permission.POST_NOTIFICATIONS"

    invoke-direct {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->hasPerm(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 267
    return v2

    .line 270
    :cond_0
    :try_start_0
    const-string v0, "notification"

    invoke-virtual {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/NotificationManager;

    .line 271
    if-nez v0, :cond_1

    return v2

    .line 272
    :cond_1
    invoke-virtual {v0}, Landroid/app/NotificationManager;->areNotificationsEnabled()Z

    move-result v1

    if-nez v1, :cond_2

    return v2

    .line 273
    :cond_2
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1a

    if-lt v1, v3, :cond_3

    .line 274
    const-string v1, "khmer_reminders"

    invoke-virtual {v0, v1}, Landroid/app/NotificationManager;->getNotificationChannel(Ljava/lang/String;)Landroid/app/NotificationChannel;

    move-result-object v0

    .line 275
    if-eqz v0, :cond_3

    invoke-virtual {v0}, Landroid/app/NotificationChannel;->getImportance()I

    move-result v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-nez v0, :cond_3

    .line 276
    return v2

    .line 281
    :cond_3
    nop

    .line 282
    const/4 v0, 0x1

    return v0

    .line 279
    :catchall_0
    move-exception v0

    .line 280
    return v2
.end method

.method private notifyState()Ljava/lang/String;
    .locals 2

    .line 286
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->notificationsAllowed()Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "granted"

    return-object v0

    .line 287
    :cond_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    if-lt v0, v1, :cond_1

    const-string v0, "android.permission.POST_NOTIFICATIONS"

    invoke-direct {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->hasPerm(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_1

    .line 288
    const-string v0, "default"

    return-object v0

    .line 290
    :cond_1
    const-string v0, "denied"

    return-object v0
.end method

.method private openAutostartSettings()Z
    .locals 11

    .line 387
    new-instance v0, Landroid/content/Intent;

    const-string v1, "miui.intent.action.OP_AUTO_START"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 389
    const-string v1, "android.intent.category.DEFAULT"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v2

    .line 390
    const-string v0, "com.miui.securitycenter"

    const-string v1, "com.miui.permcenter.autostart.AutoStartManagementActivity"

    invoke-direct {p0, v0, v1}, Lkh/chhankitek/calendar/MainActivity;->named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v3

    .line 391
    const-string v0, "com.huawei.systemmanager"

    const-string v1, "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"

    invoke-direct {p0, v0, v1}, Lkh/chhankitek/calendar/MainActivity;->named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v4

    .line 392
    const-string v1, "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity"

    invoke-direct {p0, v0, v1}, Lkh/chhankitek/calendar/MainActivity;->named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v5

    .line 393
    const-string v0, "com.coloros.safecenter"

    const-string v1, "com.coloros.safecenter.startupapp.StartupAppListActivity"

    invoke-direct {p0, v0, v1}, Lkh/chhankitek/calendar/MainActivity;->named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v6

    .line 394
    const-string v0, "com.oppo.safe"

    const-string v1, "com.oppo.safe.permission.startup.StartupAppListActivity"

    invoke-direct {p0, v0, v1}, Lkh/chhankitek/calendar/MainActivity;->named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v7

    .line 395
    const-string v0, "com.vivo.permissionmanager"

    const-string v1, "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"

    invoke-direct {p0, v0, v1}, Lkh/chhankitek/calendar/MainActivity;->named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v8

    .line 396
    const-string v0, "com.samsung.android.lool"

    const-string v1, "com.samsung.android.sm.ui.battery.BatteryActivity"

    invoke-direct {p0, v0, v1}, Lkh/chhankitek/calendar/MainActivity;->named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v9

    .line 397
    const-string v0, "com.samsung.android.sm"

    invoke-direct {p0, v0, v1}, Lkh/chhankitek/calendar/MainActivity;->named(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v10

    filled-new-array/range {v2 .. v10}, [Landroid/content/Intent;

    move-result-object v0

    .line 399
    const/4 v1, 0x0

    move v2, v1

    :goto_0
    const/16 v3, 0x9

    if-ge v2, v3, :cond_2

    .line 400
    aget-object v3, v0, v2

    .line 401
    if-nez v3, :cond_0

    goto :goto_1

    .line 403
    :cond_0
    const/high16 v4, 0x10000000

    :try_start_0
    invoke-virtual {v3, v4}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 404
    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v4

    invoke-virtual {v4, v3, v1}, Landroid/content/pm/PackageManager;->resolveActivity(Landroid/content/Intent;I)Landroid/content/pm/ResolveInfo;

    move-result-object v4

    if-eqz v4, :cond_1

    .line 405
    invoke-virtual {p0, v3}, Lkh/chhankitek/calendar/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 406
    const/4 v0, 0x1

    return v0

    .line 409
    :cond_1
    goto :goto_1

    .line 408
    :catchall_0
    move-exception v3

    .line 399
    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 411
    :cond_2
    return v1
.end method

.method private openNotificationSettings()V
    .locals 3

    .line 330
    const-string v0, "android.provider.extra.APP_PACKAGE"

    :try_start_0
    new-instance v1, Landroid/content/Intent;

    const-string v2, "android.settings.APP_NOTIFICATION_SETTINGS"

    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 331
    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v0, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 332
    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v0, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 333
    const-string v0, "app_package"

    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v0, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 334
    const-string v0, "app_uid"

    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v2

    iget v2, v2, Landroid/content/pm/ApplicationInfo;->uid:I

    invoke-virtual {v1, v0, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 335
    invoke-virtual {p0, v1}, Lkh/chhankitek/calendar/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 336
    return-void

    .line 337
    :catchall_0
    move-exception v0

    .line 340
    :try_start_1
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.settings.APPLICATION_DETAILS_SETTINGS"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 341
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "package:"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 342
    invoke-virtual {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 344
    goto :goto_0

    .line 343
    :catchall_1
    move-exception v0

    .line 345
    :goto_0
    return-void
.end method

.method private runOnWeb(Ljava/lang/Runnable;)V
    .locals 1

    .line 256
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    if-eqz v0, :cond_0

    invoke-virtual {v0, p1}, Landroid/webkit/WebView;->post(Ljava/lang/Runnable;)Z

    goto :goto_0

    .line 257
    :cond_0
    invoke-virtual {p0, p1}, Lkh/chhankitek/calendar/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V

    .line 258
    :goto_0
    return-void
.end method

.method private setWantsBackground(Z)V
    .locals 0

    .line 325
    invoke-static {p0, p1}, Lkh/chhankitek/calendar/ReminderAlarms;->setWantsBackground(Landroid/content/Context;Z)V

    .line 326
    return-void
.end method

.method private wantsBackground()Z
    .locals 1

    .line 321
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->wantsBackground(Landroid/content/Context;)Z

    move-result v0

    return v0
.end method


# virtual methods
.method public onBackPressed()V
    .locals 1

    .line 174
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoBack()Z

    move-result v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->goBack()V

    goto :goto_0

    .line 175
    :cond_0
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V

    .line 176
    :goto_0
    return-void
.end method

.method public onConfigurationChanged(Landroid/content/res/Configuration;)V
    .locals 1

    .line 164
    invoke-super {p0, p1}, Landroid/app/Activity;->onConfigurationChanged(Landroid/content/res/Configuration;)V

    .line 165
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->applySystemBars()V

    .line 166
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    if-nez p1, :cond_0

    return-void

    .line 167
    :cond_0
    invoke-virtual {p1}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object p1

    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity;->applyWebDarkMode(Landroid/webkit/WebSettings;)V

    .line 168
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->isNight()Z

    move-result v0

    if-eqz v0, :cond_1

    const v0, -0xe3eef0

    goto :goto_0

    :cond_1
    const/16 v0, -0x401

    :goto_0
    invoke-virtual {p1, v0}, Landroid/webkit/WebView;->setBackgroundColor(I)V

    .line 169
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->emitStatus()V

    .line 170
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 3

    .line 50
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1d

    if-lt v0, v1, :cond_0

    .line 51
    const v0, 0x10302e3

    invoke-virtual {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->setTheme(I)V

    .line 53
    :cond_0
    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->requestWindowFeature(I)Z

    .line 54
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 55
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->applySystemBars()V

    .line 56
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->createChannel(Landroid/content/Context;)V

    .line 57
    invoke-static {p0}, Lkh/chhankitek/calendar/ReminderAlarms;->restore(Landroid/content/Context;)V

    .line 59
    new-instance p1, Landroid/webkit/WebView;

    invoke-direct {p1, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V

    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    .line 60
    const/4 v1, 0x2

    invoke-virtual {p1, v1}, Landroid/webkit/WebView;->setOverScrollMode(I)V

    .line 61
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->isNight()Z

    move-result v2

    if-eqz v2, :cond_1

    const v2, -0xe3eef0

    goto :goto_0

    :cond_1
    const/16 v2, -0x401

    :goto_0
    invoke-virtual {p1, v2}, Landroid/webkit/WebView;->setBackgroundColor(I)V

    .line 63
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    invoke-virtual {p1}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object p1

    .line 64
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V

    .line 65
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V

    .line 66
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setDatabaseEnabled(Z)V

    .line 67
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setAllowFileAccess(Z)V

    .line 68
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setAllowContentAccess(Z)V

    .line 69
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setAllowFileAccessFromFileURLs(Z)V

    .line 70
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setAllowUniversalAccessFromFileURLs(Z)V

    .line 71
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setLoadWithOverviewMode(Z)V

    .line 72
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setUseWideViewPort(Z)V

    .line 73
    const/4 v2, 0x0

    invoke-virtual {p1, v2}, Landroid/webkit/WebSettings;->setSupportZoom(Z)V

    .line 74
    invoke-virtual {p1, v2}, Landroid/webkit/WebSettings;->setBuiltInZoomControls(Z)V

    .line 75
    invoke-virtual {p1, v2}, Landroid/webkit/WebSettings;->setDisplayZoomControls(Z)V

    .line 76
    invoke-virtual {p1, v2}, Landroid/webkit/WebSettings;->setMediaPlaybackRequiresUserGesture(Z)V

    .line 77
    const/4 v2, -0x1

    invoke-virtual {p1, v2}, Landroid/webkit/WebSettings;->setCacheMode(I)V

    .line 78
    invoke-virtual {p1, v1}, Landroid/webkit/WebSettings;->setMixedContentMode(I)V

    .line 80
    :try_start_0
    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setGeolocationEnabled(Z)V

    .line 81
    invoke-virtual {p0}, Lkh/chhankitek/calendar/MainActivity;->getFilesDir()Ljava/io/File;

    move-result-object v0

    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/webkit/WebSettings;->setGeolocationDatabasePath(Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 83
    goto :goto_1

    .line 82
    :catchall_0
    move-exception v0

    .line 84
    :goto_1
    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity;->applyWebDarkMode(Landroid/webkit/WebSettings;)V

    .line 86
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    new-instance v0, Lkh/chhankitek/calendar/MainActivity$Bridge;

    invoke-direct {v0, p0}, Lkh/chhankitek/calendar/MainActivity$Bridge;-><init>(Lkh/chhankitek/calendar/MainActivity;)V

    const-string v1, "KhmerNative"

    invoke-virtual {p1, v0, v1}, Landroid/webkit/WebView;->addJavascriptInterface(Ljava/lang/Object;Ljava/lang/String;)V

    .line 87
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    new-instance v0, Lkh/chhankitek/calendar/MainActivity$Chrome;

    invoke-direct {v0, p0}, Lkh/chhankitek/calendar/MainActivity$Chrome;-><init>(Lkh/chhankitek/calendar/MainActivity;)V

    invoke-virtual {p1, v0}, Landroid/webkit/WebView;->setWebChromeClient(Landroid/webkit/WebChromeClient;)V

    .line 88
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    new-instance v0, Lkh/chhankitek/calendar/MainActivity$Client;

    invoke-direct {v0, p0}, Lkh/chhankitek/calendar/MainActivity$Client;-><init>(Lkh/chhankitek/calendar/MainActivity;)V

    invoke-virtual {p1, v0}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    .line 89
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    invoke-virtual {p0, p1}, Lkh/chhankitek/calendar/MainActivity;->setContentView(Landroid/view/View;)V

    .line 90
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    const-string v0, "https://app.khmer.calendar/index.html"

    invoke-virtual {p1, v0}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    .line 91
    return-void
.end method

.method public onRequestPermissionsResult(I[Ljava/lang/String;[I)V
    .locals 3

    .line 180
    invoke-super {p0, p1, p2, p3}, Landroid/app/Activity;->onRequestPermissionsResult(I[Ljava/lang/String;[I)V

    .line 181
    nop

    .line 182
    const/4 p2, 0x0

    if-eqz p3, :cond_1

    .line 183
    array-length v0, p3

    move v1, p2

    :goto_0
    if-ge v1, v0, :cond_1

    aget v2, p3, v1

    .line 184
    if-nez v2, :cond_0

    .line 185
    nop

    .line 186
    const/4 p3, 0x1

    goto :goto_1

    .line 183
    :cond_0
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 190
    :cond_1
    move p3, p2

    :goto_1
    const/16 v0, 0x3ea

    if-ne p1, v0, :cond_3

    .line 191
    if-eqz p3, :cond_2

    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->allowGeolocation()V

    .line 192
    :cond_2
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity;->pendingGeo:Landroid/webkit/GeolocationPermissions$Callback;

    if-eqz v0, :cond_3

    .line 193
    iget-object v1, p0, Lkh/chhankitek/calendar/MainActivity;->pendingGeoOrigin:Ljava/lang/String;

    invoke-interface {v0, v1, p3, p2}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V

    .line 194
    const/4 p2, 0x0

    iput-object p2, p0, Lkh/chhankitek/calendar/MainActivity;->pendingGeo:Landroid/webkit/GeolocationPermissions$Callback;

    .line 195
    iput-object p2, p0, Lkh/chhankitek/calendar/MainActivity;->pendingGeoOrigin:Ljava/lang/String;

    .line 198
    :cond_3
    const/16 p2, 0x3e9

    const-string v0, "granted"

    const-string v1, "denied"

    if-ne p1, p2, :cond_6

    .line 199
    if-eqz p3, :cond_4

    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->notificationsAllowed()Z

    move-result p1

    if-nez p1, :cond_4

    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->openNotificationSettings()V

    .line 200
    :cond_4
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->notificationsAllowed()Z

    move-result p1

    if-eqz p1, :cond_5

    goto :goto_2

    :cond_5
    move-object v0, v1

    :goto_2
    const-string p1, "notify"

    invoke-direct {p0, p1, v0}, Lkh/chhankitek/calendar/MainActivity;->emitPerm(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_4

    .line 202
    :cond_6
    if-eqz p3, :cond_7

    goto :goto_3

    :cond_7
    move-object v0, v1

    :goto_3
    const-string p1, "location"

    invoke-direct {p0, p1, v0}, Lkh/chhankitek/calendar/MainActivity;->emitPerm(Ljava/lang/String;Ljava/lang/String;)V

    .line 204
    :goto_4
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->emitStatus()V

    .line 205
    return-void
.end method

.method protected onResume()V
    .locals 4

    .line 150
    invoke-super {p0}, Landroid/app/Activity;->onResume()V

    .line 151
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->applySystemBars()V

    .line 152
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    if-eqz v0, :cond_1

    .line 153
    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object v0

    invoke-direct {p0, v0}, Lkh/chhankitek/calendar/MainActivity;->applyWebDarkMode(Landroid/webkit/WebSettings;)V

    .line 154
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity;->web:Landroid/webkit/WebView;

    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->isNight()Z

    move-result v1

    if-eqz v1, :cond_0

    const v1, -0xe3eef0

    goto :goto_0

    :cond_0
    const/16 v1, -0x401

    :goto_0
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setBackgroundColor(I)V

    .line 155
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->emitStatus()V

    .line 157
    :cond_1
    iget v0, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundStep:I

    if-lez v0, :cond_2

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    iget-wide v2, p0, Lkh/chhankitek/calendar/MainActivity;->backgroundAskedAt:J

    sub-long/2addr v0, v2

    const-wide/16 v2, 0x320

    cmp-long v0, v0, v2

    if-lez v0, :cond_2

    .line 158
    invoke-direct {p0}, Lkh/chhankitek/calendar/MainActivity;->continueBackground()V

    .line 160
    :cond_2
    return-void
.end method

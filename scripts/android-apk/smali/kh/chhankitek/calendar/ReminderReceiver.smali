.class public Lkh/chhankitek/calendar/ReminderReceiver;
.super Landroid/content/BroadcastReceiver;
.source "ReminderReceiver.java"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 9
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 5

    .line 12
    if-nez p1, :cond_0

    return-void

    .line 13
    :cond_0
    invoke-virtual {p0}, Lkh/chhankitek/calendar/ReminderReceiver;->goAsync()Landroid/content/BroadcastReceiver$PendingResult;

    move-result-object v0

    .line 14
    nop

    .line 16
    const/4 v1, 0x0

    :try_start_0
    const-string v2, "power"

    invoke-virtual {p1, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/os/PowerManager;

    .line 17
    if-eqz v2, :cond_1

    .line 18
    const-string v3, "khmer:alarm"

    const/4 v4, 0x1

    invoke-virtual {v2, v4, v3}, Landroid/os/PowerManager;->newWakeLock(ILjava/lang/String;)Landroid/os/PowerManager$WakeLock;

    move-result-object v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 19
    const-wide/16 v3, 0x3a98

    :try_start_1
    invoke-virtual {v2, v3, v4}, Landroid/os/PowerManager$WakeLock;->acquire(J)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_0

    .line 21
    :catchall_0
    move-exception v3

    goto :goto_1

    .line 17
    :cond_1
    move-object v2, v1

    .line 22
    :goto_0
    goto :goto_1

    .line 21
    :catchall_1
    move-exception v2

    move-object v2, v1

    .line 24
    :goto_1
    if-eqz p2, :cond_2

    :try_start_2
    const-string v3, "id"

    invoke-virtual {p2, v3}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    goto :goto_2

    .line 30
    :catchall_2
    move-exception p1

    goto :goto_6

    .line 24
    :cond_2
    move-object v3, v1

    .line 25
    :goto_2
    if-eqz p2, :cond_3

    const-string v4, "title"

    invoke-virtual {p2, v4}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    goto :goto_3

    :cond_3
    move-object v4, v1

    .line 26
    :goto_3
    if-eqz p2, :cond_4

    const-string v1, "body"

    invoke-virtual {p2, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 27
    :cond_4
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p2

    invoke-static {p2, v3, v4, v1}, Lkh/chhankitek/calendar/ReminderAlarms;->deliver(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 28
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    invoke-static {p1}, Lkh/chhankitek/calendar/ReminderAlarms;->restore(Landroid/content/Context;)V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    .line 30
    if-eqz v2, :cond_6

    .line 32
    :try_start_3
    invoke-virtual {v2}, Landroid/os/PowerManager$WakeLock;->isHeld()Z

    move-result p1

    if-eqz p1, :cond_5

    invoke-virtual {v2}, Landroid/os/PowerManager$WakeLock;->release()V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_3

    .line 34
    :cond_5
    goto :goto_4

    .line 33
    :catchall_3
    move-exception p1

    .line 37
    :cond_6
    :goto_4
    :try_start_4
    invoke-virtual {v0}, Landroid/content/BroadcastReceiver$PendingResult;->finish()V
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_4

    .line 39
    goto :goto_5

    .line 38
    :catchall_4
    move-exception p1

    .line 40
    nop

    .line 41
    :goto_5
    return-void

    .line 30
    :goto_6
    if-eqz v2, :cond_8

    .line 32
    :try_start_5
    invoke-virtual {v2}, Landroid/os/PowerManager$WakeLock;->isHeld()Z

    move-result p2

    if-eqz p2, :cond_7

    invoke-virtual {v2}, Landroid/os/PowerManager$WakeLock;->release()V
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_5

    .line 34
    :cond_7
    goto :goto_7

    .line 33
    :catchall_5
    move-exception p2

    .line 37
    :cond_8
    :goto_7
    :try_start_6
    invoke-virtual {v0}, Landroid/content/BroadcastReceiver$PendingResult;->finish()V
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_6

    .line 39
    goto :goto_8

    .line 38
    :catchall_6
    move-exception p2

    .line 40
    :goto_8
    throw p1
.end method

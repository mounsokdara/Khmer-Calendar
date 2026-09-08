.class final Lkh/chhankitek/calendar/MainActivity$Bridge;
.super Ljava/lang/Object;
.source "MainActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lkh/chhankitek/calendar/MainActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x10
    name = "Bridge"
.end annotation


# instance fields
.field final synthetic this$0:Lkh/chhankitek/calendar/MainActivity;


# direct methods
.method constructor <init>(Lkh/chhankitek/calendar/MainActivity;)V
    .locals 0

    .line 437
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public backgroundPermission()Ljava/lang/String;
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 506
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$1100(Lkh/chhankitek/calendar/MainActivity;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public engineStatus()Ljava/lang/String;
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 511
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-virtual {v0}, Lkh/chhankitek/calendar/MainActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lkh/chhankitek/calendar/ReminderAlarms;->engineStatus(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public isNightMode()Ljava/lang/String;
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 440
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$100(Lkh/chhankitek/calendar/MainActivity;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "1"

    goto :goto_0

    :cond_0
    const-string v0, "0"

    :goto_0
    return-object v0
.end method

.method public locationPermission()Ljava/lang/String;
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 473
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$800(Lkh/chhankitek/calendar/MainActivity;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public notificationPermission()Ljava/lang/String;
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 445
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$200(Lkh/chhankitek/calendar/MainActivity;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public requestBackground()V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 522
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    new-instance v1, Lkh/chhankitek/calendar/MainActivity$Bridge$3;

    invoke-direct {v1, p0}, Lkh/chhankitek/calendar/MainActivity$Bridge$3;-><init>(Lkh/chhankitek/calendar/MainActivity$Bridge;)V

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$700(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/Runnable;)V

    .line 529
    return-void
.end method

.method public requestLocation()V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 478
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    new-instance v1, Lkh/chhankitek/calendar/MainActivity$Bridge$2;

    invoke-direct {v1, p0}, Lkh/chhankitek/calendar/MainActivity$Bridge$2;-><init>(Lkh/chhankitek/calendar/MainActivity$Bridge;)V

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$700(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/Runnable;)V

    .line 495
    return-void
.end method

.method public requestNotifications()V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 450
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    new-instance v1, Lkh/chhankitek/calendar/MainActivity$Bridge$1;

    invoke-direct {v1, p0}, Lkh/chhankitek/calendar/MainActivity$Bridge$1;-><init>(Lkh/chhankitek/calendar/MainActivity$Bridge;)V

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$700(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/Runnable;)V

    .line 464
    return-void
.end method

.method public showNotification(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 468
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-virtual {v0}, Lkh/chhankitek/calendar/MainActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0, p1, p2}, Lkh/chhankitek/calendar/ReminderAlarms;->show(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V

    .line 469
    return-void
.end method

.method public startBackground()V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 516
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$1000(Lkh/chhankitek/calendar/MainActivity;Z)V

    .line 517
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-virtual {v0}, Lkh/chhankitek/calendar/MainActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lkh/chhankitek/calendar/ReminderAlarms;->restore(Landroid/content/Context;)V

    .line 518
    return-void
.end method

.method public stopBackground()V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 533
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    new-instance v1, Lkh/chhankitek/calendar/MainActivity$Bridge$4;

    invoke-direct {v1, p0}, Lkh/chhankitek/calendar/MainActivity$Bridge$4;-><init>(Lkh/chhankitek/calendar/MainActivity$Bridge;)V

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$700(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/Runnable;)V

    .line 541
    return-void
.end method

.method public syncReminders(Ljava/lang/String;)V
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 499
    if-nez p1, :cond_0

    const-string p1, "[]"

    .line 500
    :cond_0
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-virtual {v0}, Lkh/chhankitek/calendar/MainActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0, p1}, Lkh/chhankitek/calendar/ReminderAlarms;->saveAndSchedule(Landroid/content/Context;Ljava/lang/String;)V

    .line 501
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    const/4 v0, 0x1

    invoke-static {p1, v0}, Lkh/chhankitek/calendar/MainActivity;->access$1000(Lkh/chhankitek/calendar/MainActivity;Z)V

    .line 502
    return-void
.end method

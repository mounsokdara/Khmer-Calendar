.class Lkh/chhankitek/calendar/MainActivity$Bridge$1;
.super Ljava/lang/Object;
.source "MainActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lkh/chhankitek/calendar/MainActivity$Bridge;->requestNotifications()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;


# direct methods
.method constructor <init>(Lkh/chhankitek/calendar/MainActivity$Bridge;)V
    .locals 0

    .line 451
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$1;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .line 453
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    if-lt v0, v1, :cond_0

    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$1;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    const-string v1, "android.permission.POST_NOTIFICATIONS"

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$300(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 454
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$1;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    filled-new-array {v1}, [Ljava/lang/String;

    move-result-object v1

    const/16 v2, 0x3e9

    invoke-virtual {v0, v1, v2}, Lkh/chhankitek/calendar/MainActivity;->requestPermissions([Ljava/lang/String;I)V

    .line 455
    return-void

    .line 457
    :cond_0
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$1;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$400(Lkh/chhankitek/calendar/MainActivity;)Z

    move-result v0

    if-nez v0, :cond_1

    .line 458
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$1;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$500(Lkh/chhankitek/calendar/MainActivity;)V

    .line 459
    return-void

    .line 461
    :cond_1
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$1;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    const-string v1, "notify"

    const-string v2, "granted"

    invoke-static {v0, v1, v2}, Lkh/chhankitek/calendar/MainActivity;->access$600(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;Ljava/lang/String;)V

    .line 462
    return-void
.end method

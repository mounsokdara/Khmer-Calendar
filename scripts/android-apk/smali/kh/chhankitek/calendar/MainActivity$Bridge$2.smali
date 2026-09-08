.class Lkh/chhankitek/calendar/MainActivity$Bridge$2;
.super Ljava/lang/Object;
.source "MainActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lkh/chhankitek/calendar/MainActivity$Bridge;->requestLocation()V
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

    .line 479
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$2;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .line 481
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$2;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    const-string v1, "android.permission.ACCESS_FINE_LOCATION"

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$300(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$2;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    .line 482
    const-string v2, "android.permission.ACCESS_COARSE_LOCATION"

    invoke-static {v0, v2}, Lkh/chhankitek/calendar/MainActivity;->access$300(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 483
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$2;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    filled-new-array {v1, v2}, [Ljava/lang/String;

    move-result-object v1

    const/16 v2, 0x3ea

    invoke-virtual {v0, v1, v2}, Lkh/chhankitek/calendar/MainActivity;->requestPermissions([Ljava/lang/String;I)V

    goto :goto_0

    .line 490
    :cond_0
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$2;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$900(Lkh/chhankitek/calendar/MainActivity;)V

    .line 491
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$2;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    const-string v1, "location"

    const-string v2, "granted"

    invoke-static {v0, v1, v2}, Lkh/chhankitek/calendar/MainActivity;->access$600(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;Ljava/lang/String;)V

    .line 493
    :goto_0
    return-void
.end method

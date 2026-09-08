.class Lkh/chhankitek/calendar/MainActivity$Bridge$4;
.super Ljava/lang/Object;
.source "MainActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lkh/chhankitek/calendar/MainActivity$Bridge;->stopBackground()V
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

    .line 534
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$4;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .line 536
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$4;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$1202(Lkh/chhankitek/calendar/MainActivity;I)I

    .line 537
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$4;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$1000(Lkh/chhankitek/calendar/MainActivity;Z)V

    .line 538
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$4;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    iget-object v1, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$4;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v1, v1, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v1}, Lkh/chhankitek/calendar/MainActivity;->access$1100(Lkh/chhankitek/calendar/MainActivity;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "background"

    invoke-static {v0, v2, v1}, Lkh/chhankitek/calendar/MainActivity;->access$600(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;Ljava/lang/String;)V

    .line 539
    return-void
.end method

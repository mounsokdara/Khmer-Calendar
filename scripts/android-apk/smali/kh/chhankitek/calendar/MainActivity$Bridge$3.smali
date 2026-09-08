.class Lkh/chhankitek/calendar/MainActivity$Bridge$3;
.super Ljava/lang/Object;
.source "MainActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lkh/chhankitek/calendar/MainActivity$Bridge;->requestBackground()V
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

    .line 523
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$3;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .line 525
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$3;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$1202(Lkh/chhankitek/calendar/MainActivity;I)I

    .line 526
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Bridge$3;->this$1:Lkh/chhankitek/calendar/MainActivity$Bridge;

    iget-object v0, v0, Lkh/chhankitek/calendar/MainActivity$Bridge;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$1300(Lkh/chhankitek/calendar/MainActivity;)V

    .line 527
    return-void
.end method

.class final Lkh/chhankitek/calendar/MainActivity$Chrome;
.super Landroid/webkit/WebChromeClient;
.source "MainActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lkh/chhankitek/calendar/MainActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x10
    name = "Chrome"
.end annotation


# instance fields
.field final synthetic this$0:Lkh/chhankitek/calendar/MainActivity;


# direct methods
.method constructor <init>(Lkh/chhankitek/calendar/MainActivity;)V
    .locals 0

    .line 544
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Chrome;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-direct {p0}, Landroid/webkit/WebChromeClient;-><init>()V

    return-void
.end method


# virtual methods
.method public onGeolocationPermissionsShowPrompt(Ljava/lang/String;Landroid/webkit/GeolocationPermissions$Callback;)V
    .locals 5

    .line 548
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Chrome;->this$0:Lkh/chhankitek/calendar/MainActivity;

    .line 549
    const-string v1, "android.permission.ACCESS_FINE_LOCATION"

    invoke-static {v0, v1}, Lkh/chhankitek/calendar/MainActivity;->access$300(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;)Z

    move-result v0

    const/4 v2, 0x0

    const-string v3, "android.permission.ACCESS_COARSE_LOCATION"

    const/4 v4, 0x1

    if-nez v0, :cond_1

    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Chrome;->this$0:Lkh/chhankitek/calendar/MainActivity;

    .line 550
    invoke-static {v0, v3}, Lkh/chhankitek/calendar/MainActivity;->access$300(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    move v0, v2

    goto :goto_1

    :cond_1
    :goto_0
    move v0, v4

    .line 551
    :goto_1
    if-nez v0, :cond_2

    .line 552
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Chrome;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0, p2}, Lkh/chhankitek/calendar/MainActivity;->access$1402(Lkh/chhankitek/calendar/MainActivity;Landroid/webkit/GeolocationPermissions$Callback;)Landroid/webkit/GeolocationPermissions$Callback;

    .line 553
    iget-object p2, p0, Lkh/chhankitek/calendar/MainActivity$Chrome;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {p2, p1}, Lkh/chhankitek/calendar/MainActivity;->access$1502(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;)Ljava/lang/String;

    .line 554
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Chrome;->this$0:Lkh/chhankitek/calendar/MainActivity;

    filled-new-array {v1, v3}, [Ljava/lang/String;

    move-result-object p2

    const/16 v0, 0x3ea

    invoke-virtual {p1, p2, v0}, Lkh/chhankitek/calendar/MainActivity;->requestPermissions([Ljava/lang/String;I)V

    .line 559
    return-void

    .line 561
    :cond_2
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$Chrome;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$900(Lkh/chhankitek/calendar/MainActivity;)V

    .line 562
    invoke-interface {p2, p1, v4, v2}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V

    .line 563
    return-void
.end method

.method public onPermissionRequest(Landroid/webkit/PermissionRequest;)V
    .locals 1

    .line 567
    invoke-virtual {p1}, Landroid/webkit/PermissionRequest;->getResources()[Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/webkit/PermissionRequest;->grant([Ljava/lang/String;)V

    .line 568
    return-void
.end method

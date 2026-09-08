.class Lkh/chhankitek/calendar/MainActivity$2;
.super Ljava/lang/Object;
.source "MainActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lkh/chhankitek/calendar/MainActivity;->emitStatus()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lkh/chhankitek/calendar/MainActivity;

.field final synthetic val$background:Ljava/lang/String;

.field final synthetic val$location:Ljava/lang/String;

.field final synthetic val$night:Ljava/lang/String;

.field final synthetic val$notify:Ljava/lang/String;


# direct methods
.method constructor <init>(Lkh/chhankitek/calendar/MainActivity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 237
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity$2;->this$0:Lkh/chhankitek/calendar/MainActivity;

    iput-object p2, p0, Lkh/chhankitek/calendar/MainActivity$2;->val$night:Ljava/lang/String;

    iput-object p3, p0, Lkh/chhankitek/calendar/MainActivity$2;->val$notify:Ljava/lang/String;

    iput-object p4, p0, Lkh/chhankitek/calendar/MainActivity$2;->val$location:Ljava/lang/String;

    iput-object p5, p0, Lkh/chhankitek/calendar/MainActivity$2;->val$background:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .line 239
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$2;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$000(Lkh/chhankitek/calendar/MainActivity;)Landroid/webkit/WebView;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 240
    :cond_0
    iget-object v0, p0, Lkh/chhankitek/calendar/MainActivity$2;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-static {v0}, Lkh/chhankitek/calendar/MainActivity;->access$000(Lkh/chhankitek/calendar/MainActivity;)Landroid/webkit/WebView;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "(function(){var d={night:\'"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lkh/chhankitek/calendar/MainActivity$2;->val$night:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\',notify:\'"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lkh/chhankitek/calendar/MainActivity$2;->val$notify:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\',location:\'"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lkh/chhankitek/calendar/MainActivity$2;->val$location:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\',background:\'"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lkh/chhankitek/calendar/MainActivity$2;->val$background:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\'};try{window.dispatchEvent(new CustomEvent(\'khmer-native-status\',{detail:d}));window.dispatchEvent(new Event(\'khmer-night-mode\'));}catch(e){}})()"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V

    .line 251
    return-void
.end method

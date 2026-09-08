.class final Lkh/chhankitek/calendar/MainActivity$Client;
.super Landroid/webkit/WebViewClient;
.source "MainActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lkh/chhankitek/calendar/MainActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x10
    name = "Client"
.end annotation


# instance fields
.field final synthetic this$0:Lkh/chhankitek/calendar/MainActivity;


# direct methods
.method constructor <init>(Lkh/chhankitek/calendar/MainActivity;)V
    .locals 0

    .line 571
    iput-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Client;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-direct {p0}, Landroid/webkit/WebViewClient;-><init>()V

    return-void
.end method

.method private handleUrl(Ljava/lang/String;)Z
    .locals 3

    .line 584
    const/4 v0, 0x1

    if-nez p1, :cond_0

    return v0

    .line 585
    :cond_0
    const-string v1, "blob:"

    invoke-virtual {p1, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v1

    const/4 v2, 0x0

    if-nez v1, :cond_4

    const-string v1, "data:"

    invoke-virtual {p1, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_1

    goto :goto_1

    .line 586
    :cond_1
    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity$Client;->isAppUrl(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_3

    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity$Client;->isExternalApi(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_2

    goto :goto_0

    .line 587
    :cond_2
    return v0

    .line 586
    :cond_3
    :goto_0
    return v2

    .line 585
    :cond_4
    :goto_1
    return v2
.end method

.method private isAppUrl(Ljava/lang/String;)Z
    .locals 1

    .line 643
    const-string v0, "https://app.khmer.calendar"

    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_1

    const-string v0, "file:///android_asset/www"

    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_0

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    goto :goto_1

    :cond_1
    :goto_0
    const/4 p1, 0x1

    :goto_1
    return p1
.end method

.method private isExternalApi(Ljava/lang/String;)Z
    .locals 1

    .line 647
    const-string v0, "open-meteo.com"

    invoke-virtual {p1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_1

    const-string v0, "wttr.in"

    invoke-virtual {p1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p1

    if-eqz p1, :cond_0

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    goto :goto_1

    :cond_1
    :goto_0
    const/4 p1, 0x1

    :goto_1
    return p1
.end method

.method private mime(Ljava/lang/String;)Ljava/lang/String;
    .locals 1

    .line 651
    invoke-virtual {p1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object p1

    .line 652
    const-string v0, ".js"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string p1, "application/javascript"

    return-object p1

    .line 653
    :cond_0
    const-string v0, ".css"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_1

    const-string p1, "text/css"

    return-object p1

    .line 654
    :cond_1
    const-string v0, ".html"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_d

    const-string v0, ".htm"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_2

    goto :goto_2

    .line 655
    :cond_2
    const-string v0, ".json"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_c

    const-string v0, ".webmanifest"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_3

    goto :goto_1

    .line 656
    :cond_3
    const-string v0, ".png"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_4

    const-string p1, "image/png"

    return-object p1

    .line 657
    :cond_4
    const-string v0, ".jpg"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_b

    const-string v0, ".jpeg"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_5

    goto :goto_0

    .line 658
    :cond_5
    const-string v0, ".svg"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_6

    const-string p1, "image/svg+xml"

    return-object p1

    .line 659
    :cond_6
    const-string v0, ".webp"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_7

    const-string p1, "image/webp"

    return-object p1

    .line 660
    :cond_7
    const-string v0, ".woff2"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_8

    const-string p1, "font/woff2"

    return-object p1

    .line 661
    :cond_8
    const-string v0, ".woff"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_9

    const-string p1, "font/woff"

    return-object p1

    .line 662
    :cond_9
    const-string v0, ".ttf"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_a

    const-string p1, "font/ttf"

    return-object p1

    .line 663
    :cond_a
    const-string p1, "application/octet-stream"

    return-object p1

    .line 657
    :cond_b
    :goto_0
    const-string p1, "image/jpeg"

    return-object p1

    .line 655
    :cond_c
    :goto_1
    const-string p1, "application/json"

    return-object p1

    .line 654
    :cond_d
    :goto_2
    const-string p1, "text/html"

    return-object p1
.end method

.method private serve(Ljava/lang/String;)Landroid/webkit/WebResourceResponse;
    .locals 12

    .line 602
    const-string v0, "*"

    const-string v1, "Access-Control-Allow-Origin"

    const-string v2, "/index.html"

    const/4 v3, 0x0

    if-eqz p1, :cond_a

    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity$Client;->isExternalApi(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_0

    goto/16 :goto_3

    .line 603
    :cond_0
    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity$Client;->isAppUrl(Ljava/lang/String;)Z

    move-result v4

    if-nez v4, :cond_1

    const-string v4, "file:"

    invoke-virtual {p1, v4}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v4

    if-nez v4, :cond_1

    return-object v3

    .line 604
    :cond_1
    nop

    .line 606
    :try_start_0
    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object p1

    .line 607
    invoke-virtual {p1}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object p1

    .line 608
    if-eqz p1, :cond_2

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v4
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-lez v4, :cond_2

    goto :goto_0

    .line 610
    :cond_2
    move-object p1, v2

    :goto_0
    goto :goto_1

    .line 609
    :catchall_0
    move-exception p1

    move-object p1, v2

    .line 611
    :goto_1
    const-string v4, "/android_asset/www"

    invoke-virtual {p1, v4}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v5

    if-eqz v5, :cond_3

    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v4

    invoke-virtual {p1, v4}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p1

    .line 612
    :cond_3
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v4

    const-string v5, "/"

    if-eqz v4, :cond_5

    invoke-virtual {v5, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_4

    goto :goto_2

    :cond_4
    move-object v2, p1

    .line 613
    :cond_5
    :goto_2
    invoke-virtual {v2, v5}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_6

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v2, "index.html"

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    .line 614
    :cond_6
    invoke-virtual {v2, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_7

    const/4 p1, 0x1

    invoke-virtual {v2, p1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v2

    .line 615
    :cond_7
    const/16 p1, 0x3f

    invoke-virtual {v2, p1}, Ljava/lang/String;->indexOf(I)I

    move-result p1

    .line 616
    if-ltz p1, :cond_8

    const/4 v4, 0x0

    invoke-virtual {v2, v4, p1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v2

    .line 618
    :cond_8
    :try_start_1
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Client;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-virtual {p1}, Lkh/chhankitek/calendar/MainActivity;->getAssets()Landroid/content/res/AssetManager;

    move-result-object p1

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "www/"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {p1, v4}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v11

    .line 619
    new-instance v10, Ljava/util/HashMap;

    invoke-direct {v10}, Ljava/util/HashMap;-><init>()V

    .line 620
    invoke-interface {v10, v1, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 621
    const-string p1, "Cache-Control"

    const-string v4, "public, max-age=31536000"

    invoke-interface {v10, p1, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 622
    nop

    .line 623
    new-instance p1, Landroid/webkit/WebResourceResponse;

    invoke-direct {p0, v2}, Lkh/chhankitek/calendar/MainActivity$Client;->mime(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    const-string v7, "utf-8"

    const/16 v8, 0xc8

    const-string v9, "OK"

    move-object v5, p1

    invoke-direct/range {v5 .. v11}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/util/Map;Ljava/io/InputStream;)V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    return-object p1

    .line 626
    :catch_0
    move-exception p1

    .line 627
    const-string p1, "."

    invoke-virtual {v2, p1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p1

    if-eqz p1, :cond_9

    return-object v3

    .line 629
    :cond_9
    :try_start_2
    iget-object p1, p0, Lkh/chhankitek/calendar/MainActivity$Client;->this$0:Lkh/chhankitek/calendar/MainActivity;

    invoke-virtual {p1}, Lkh/chhankitek/calendar/MainActivity;->getAssets()Landroid/content/res/AssetManager;

    move-result-object p1

    const-string v2, "www/index.html"

    invoke-virtual {p1, v2}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v10

    .line 630
    nop

    .line 631
    new-instance v9, Ljava/util/HashMap;

    invoke-direct {v9}, Ljava/util/HashMap;-><init>()V

    .line 632
    invoke-interface {v9, v1, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 633
    new-instance p1, Landroid/webkit/WebResourceResponse;

    const-string v5, "text/html"

    const-string v6, "utf-8"

    const/16 v7, 0xc8

    const-string v8, "OK"

    move-object v4, p1

    invoke-direct/range {v4 .. v10}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/util/Map;Ljava/io/InputStream;)V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_1

    return-object p1

    .line 636
    :catch_1
    move-exception p1

    .line 637
    return-object v3

    .line 602
    :cond_a
    :goto_3
    return-object v3
.end method


# virtual methods
.method public shouldInterceptRequest(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Landroid/webkit/WebResourceResponse;
    .locals 0

    .line 597
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;

    move-result-object p1

    invoke-virtual {p1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity$Client;->serve(Ljava/lang/String;)Landroid/webkit/WebResourceResponse;

    move-result-object p1

    return-object p1
.end method

.method public shouldInterceptRequest(Landroid/webkit/WebView;Ljava/lang/String;)Landroid/webkit/WebResourceResponse;
    .locals 0

    .line 592
    invoke-direct {p0, p2}, Lkh/chhankitek/calendar/MainActivity$Client;->serve(Ljava/lang/String;)Landroid/webkit/WebResourceResponse;

    move-result-object p1

    return-object p1
.end method

.method public shouldOverrideUrlLoading(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Z
    .locals 0

    .line 579
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;

    move-result-object p1

    invoke-virtual {p1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Lkh/chhankitek/calendar/MainActivity$Client;->handleUrl(Ljava/lang/String;)Z

    move-result p1

    return p1
.end method

.method public shouldOverrideUrlLoading(Landroid/webkit/WebView;Ljava/lang/String;)Z
    .locals 0

    .line 574
    invoke-direct {p0, p2}, Lkh/chhankitek/calendar/MainActivity$Client;->handleUrl(Ljava/lang/String;)Z

    move-result p1

    return p1
.end method

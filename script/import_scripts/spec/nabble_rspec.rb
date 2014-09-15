require_relative '../nabble_post_format'

describe NabblePostFormat do
  it "keeps text post untouched" do
    nabblePostFormat = NabblePostFormat.new
    raw = "Hello world"
    expect(nabblePostFormat.process_nabble_post(raw)).to eq("Hello world")
  end

  it "removes email headers" do
    nabblePostFormat = NabblePostFormat.new
    raw = <<EOF
Return-path: <dan.j.allen@gmail.com>
Envelope-to: ml-node+s49171n1h15@n6.nabble.com
Delivery-date: Fri, 01 Mar 2013 03:57:41 -0800
Received: from mail-qe0-f50.google.com ([209.85.128.50])
        by sam.nabble.com with esmtp (Exim 4.72)
        (envelope-from <dan.j.allen@gmail.com>)
        id 1UBOar-0005uH-0c
        for ml-node+s49171n1h15@n6.nabble.com; Fri, 01 Mar 2013 03:57:41 -0800
Received: by mail-qe0-f50.google.com with SMTP id k5so1092279qej.37
        for <ml-node+s49171n1h15@n6.nabble.com>; Fri, 01 Mar 2013 03:57:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:mime-version:from:date:message-id:subject:to
         :content-type;
        bh=5Xy2gL0oWAGEGKopBVx0y6A35Hp7lu2Zk6LlPyTLSto=;
        b=k3hAb86bLMqCIAAbPdehI+bX9N0iwxmwk0Z0Q/g9wCIp+zygq9HlhSl21McC9WZe8X
         jY5OTraDrEvvlROqIU4NceaJbJy9GzTa90roEg5ox/swZi8Eq8Eduwljt4h93jyQPON7
         M+Ixgx3WIIPcZIJ/RcN71aSiZ/GfrXdByKM8tXzwDzD0ajelnVOUP1hTQ3tiN6mBEUrF
         2tDZF+uKuWtgZaeAdEurlAyTGr7euXM9ri4hSV69pRSv42ZcpXyJJNmpFrUZfMtJz0zM
         ftkClr439ngPp8LqafUi0DJ8/0tRnCqxGIAyc2rVXzw9/JJbYD4vUgkFodAEWqpuwj0Q
         mrgQ==
X-Received: by 10.229.173.67 with SMTP id o3mr3474699qcz.113.1362139055596;
 Fri, 01 Mar 2013 03:57:35 -0800 (PST)
MIME-Version: 1.0
Received: by 10.224.31.73 with HTTP; Fri, 1 Mar 2013 03:56:54 -0800 (PST)
From: Dan Allen <dan.j.allen@gmail.com>
Date: Fri, 1 Mar 2013 12:56:54 +0100
Message-ID: <CAKeHnO7478P-bGON+_kamDGAN0ZUdbXuXhpoub+JcyP_3uEzPg@mail.gmail.com>
Subject: [announcement] Asciidoctor 0.1.1 released!
To: Asciidoctor Discussion List <ml-node+s49171n1h15@n6.nabble.com>
Content-Type: multipart/alternative; boundary=00504502962f8b351d04d6dbb681
X-SA-Exim-Connect-IP: 209.85.128.50
X-SA-Exim-Mail-From: dan.j.allen@gmail.com
X-SA-Exim-Scanned: No (on sam.nabble.com); SAEximRunCond expanded to false

--00504502962f8b351d04d6dbb681
Content-Type: text/plain; charset=UTF-8

We\'re thrilled to announce that Asciidoctor 0.1.1 has been released!
http://rubygems.org/gems/asciidoctor

There are several key changes in this release:

--00504502962f8b351d04d6dbb681
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

We&#39;re thrilled to announce that Asciidoctor 0.1.1 has been released!<di=
r
/asciidoctor</a><br><div><br></div><div>There are several key changes in th=
is release:</div>

--00504502962f8b351d04d6dbb681--
EOF
    expected = 'We\'re thrilled to announce that Asciidoctor 0.1.1 has been released!
http://rubygems.org/gems/asciidoctor

There are several key changes in this release:

'
    expect(nabblePostFormat.process_nabble_post(raw)).to eq(expected)
  end


  it "removes Nabble specific quote" do
    nabblePostFormat = NabblePostFormat.new
    raw = 'If I have the time I\'ll write up a section in the file


On Tue, Feb 19, 2013 at 7:13 PM, mojavelinux [via Asciidoctor ::
Discussion] <ml-node+s49171n6h92@n6.nabble.com> wrote:

> I put together a short guide that steps through setting up a live web
> preview of the HTML generated from your AsciiDoc document by Asciidoctor
> whenever the document is saved.
>
> Check it out!
>
>
> https://github.com/asciidoctor/asciidoctor.github.com/blob/master/docs/ed=
iting-with-live-preview.adoc
>
> If you have additional suggestions, feel free to fork and edit the file,
> then submit the changes using a pull request.
>
> -Dan
>
> --
> Dan Allen
> Principal Software Engineer, Red Hat | Author of Seam in Action
> Registered Linux User #231597
>
> http://google.com/profiles/dan.j.allen
> http://mojavelinux.com
> http://mojavelinux.com/seaminaction
>
>
> ------------------------------
>  If you reply to this email, your message will be added to the discussion
> below:
> http://discuss.asciidoctor.org/Editing-with-live-preview-tp6.html
>  To start a new topic under Asciidoctor :: Discussion, email
> ml-node+s49171n1h37@n6.nabble.com
> To unsubscribe from Asciidoctor :: Discussion, click here<http://discuss.=
asciidoctor.org/template/NamlServlet.jtp?macro=3Dunsubscribe_by_code&node=
=3D1&code=3DbGlnaHRndWFyZC5qcEBnbWFpbC5jb218MXw3NzU3OTU3MTg=3D>
> .
> NAML<http://discuss.asciidoctor.org/template/NamlServlet.jtp?macro=3Dmacr=
o_viewer&id=3Dinstant_html%21nabble%3Aemail.naml&base=3Dnabble.naml.namespa=
ces.BasicNamespace-nabble.view.web.template.NabbleNamespace-nabble.view.web=
.template.NodeNamespace&breadcrumbs=3Dnotify_subscribers%21nabble%3Aemail.n=
aml-instant_emails%21nabble%3Aemail.naml-send_instant_email%21nabble%3Aemai=
l.naml>
>



--
Jason Porter
http://en.gravatar.com/lightguardjp
'
    expected = 'If I have the time I\'ll write up a section in the file


On Tue, Feb 19, 2013 at 7:13 PM, mojavelinux [via Asciidoctor ::
Discussion] wrote:

> I put together a short guide that steps through setting up a live web
> preview of the HTML generated from your AsciiDoc document by Asciidoctor
> whenever the document is saved.
>
> Check it out!
>
>
> https://github.com/asciidoctor/asciidoctor.github.com/blob/master/docs/editing-with-live-preview.adoc
>
> If you have additional suggestions, feel free to fork and edit the file,
> then submit the changes using a pull request.
>
> -Dan
>
> --
> Dan Allen
> Principal Software Engineer, Red Hat | Author of Seam in Action
> Registered Linux User #231597
>
> http://google.com/profiles/dan.j.allen
> http://mojavelinux.com
> http://mojavelinux.com/seaminaction
>
>
>



--
Jason Porter
http://en.gravatar.com/lightguardjp
'
    expect(nabblePostFormat.process_nabble_post(raw)).to eq(expected)    
  end

  it 'strange email' do
    nabblePostFormat = NabblePostFormat.new
    raw = 'On Nov 7, 2013 10:19 AM, "LightGuardjp [via Asciidoctor :: Discussion]" <
ml-node+s49171n965h99@n6.nabble.com> wrote:'
    expected='On Nov 7, 2013 10:19 AM, "LightGuardjp [via Asciidoctor :: Discussion]" wrote:'
    expect(nabblePostFormat.process_nabble_post(raw)).to eq(expected)
  end

  it 'hidden email' do
    nabblePostFormat = NabblePostFormat.new
    raw = '> On Wed, Nov 6, 2013 at 6:00 PM, mojavelinux [via Asciidoctor ::
> Discussion] <[hidden email]<http://user/SendEmail.jtp?type=3Dnode&node=3D=
965&i=3D0>
> > wrote:'
    expected='> On Wed, Nov 6, 2013 at 6:00 PM, mojavelinux [via Asciidoctor ::
> Discussion] wrote:'
    expect(nabblePostFormat.process_nabble_post(raw)).to eq(expected)
  end


  it 'double quotes' do
    nabblePostFormat = NabblePostFormat.new
    raw = '>> ------------------------------
>>  If you reply to this email, your message will be added to the
>> discussion below:
>>
>> http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-pr=
ojects-tp961.html
>>  To start a new topic under Asciidoctor :: Discussion, email [hidden
>> email] <http://user/SendEmail.jtp?type=3Dnode&node=3D965&i=3D1>
>> To unsubscribe from Asciidoctor :: Discussion, click here.
>> NAML<http://discuss.asciidoctor.org/template/NamlServlet.jtp?macro=3Dmac=
ro_viewer&id=3Dinstant_html%21nabble%3Aemail.naml&base=3Dnabble.naml.namesp=
aces.BasicNamespace-nabble.view.web.template.NabbleNamespace-nabble.view.we=
b.template.NodeNamespace&breadcrumbs=3Dnotify_subscribers%21nabble%3Aemail.=
naml-instant_emails%21nabble%3Aemail.naml-send_instant_email%21nabble%3Aema=
il.naml>
>>'
    expect(nabblePostFormat.process_nabble_post(raw)).to eq('>>')
  end

  it 'full' do
    nabblePostFormat = NabblePostFormat.new
    raw = <<EOF
Return-path: <lightguard.jp@gmail.com>
Envelope-to: ml-node+s49171n967h83@n6.nabble.com
Delivery-date: Thu, 07 Nov 2013 20:38:07 -0800
Received: from mail-pd0-f172.google.com ([209.85.192.172])
	by joe.nabble.com with esmtp (Exim 4.72)
	(envelope-from <lightguard.jp@gmail.com>)
	id 1Vedpa-0003fU-9i
	for ml-node+s49171n967h83@n6.nabble.com; Thu, 07 Nov 2013 20:38:07 -0800
Received: by mail-pd0-f172.google.com with SMTP id w10so1595120pde.31
        for <ml-node+s49171n967h83@n6.nabble.com>; Thu, 07 Nov 2013 20:37:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=subject:references:from:content-type:in-reply-to:message-id:date:to
         :content-transfer-encoding:mime-version;
        bh=zRJ0wONHoZ6466x/E4cBcS+OC60+twWCyboyS+MGWoI=;
        b=b18lrPtEtLmBch3sXf1zpxdVxsqPt0MZnn9ecXEzZE1uHgEhD9CpJa+Eds0lapDSZo
         oTNV2x2tf603lyvopU1kptlFQ0cvO1lAH89r1j+NjjNfoP/8cCTZ92JEF1h3IXLRlREk
         7TegoTKPXCeigyq1SfqUjm1c3wBV3LQEwVBDznV7LDKC0C1Jv0h3ZdLRbahfxD29e//k
         AgL2ApAFfdLFLBk/01ikuEtKSPsvDbmVidmrkOgu1zFEHf6NPdY3fpFgwuuJq9nyeSKv
         F19N0pJAJXT5anTWkBnM8vPCGYZf+O+a9wOdjjTkcjRrbzgLBNOX9R8rdHmy9EgI9pPe
         a15Q==
X-Received: by 10.68.197.36 with SMTP id ir4mr12805470pbc.96.1383885461423;
        Thu, 07 Nov 2013 20:37:41 -0800 (PST)
Received: from [192.168.1.207] (66-182-70-141.static.sdyl010.digis.net. [66.182.70.141])
        by mx.google.com with ESMTPSA id zq10sm10770492pab.6.2013.11.07.20.37.38
        for <ml-node+s49171n967h83@n6.nabble.com>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Nov 2013 20:37:38 -0800 (PST)
Subject: Re: Making versions more meaningful across projects
References: <CAKeHnO5z0xt=M2C_btg5Cr5chP=Ys4rsG=xH4XbvFbCTwQ0rgQ@mail.gmail.com> <CAF9TksMzzbtG3CmrvsSimEdT4Rz54r0xBBh-w+-CTBTcvoUWjQ@mail.gmail.com> <CAKeHnO4+mpzOM=BktBBWbpV3og=Zp+gr0_oJ7LsdBt6BCD_EhQ@mail.gmail.com>
From: Jason Porter <lightguard.jp@gmail.com>
Content-Type: multipart/alternative;
	boundary=Apple-Mail-FE26BEA7-4AEA-45B2-A4E2-2DECC3BDC595
X-Mailer: iPhone Mail (11A465)
In-Reply-To: <CAKeHnO4+mpzOM=BktBBWbpV3og=Zp+gr0_oJ7LsdBt6BCD_EhQ@mail.gmail.com>
Message-Id: <3C541FAA-B847-4727-B0EA-EF03FCF06804@gmail.com>
Date: Thu, 7 Nov 2013 21:37:33 -0700
To: ""mojavelinux [via Asciidoctor :: Discussion]"" <ml-node+s49171n967h83@n6.nabble.com>
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (1.0)
X-SA-Exim-Connect-IP: 209.85.192.172
X-SA-Exim-Mail-From: lightguard.jp@gmail.com
X-SA-Exim-Scanned: No (on joe.nabble.com); SAEximRunCond expanded to false


--Apple-Mail-FE26BEA7-4AEA-45B2-A4E2-2DECC3BDC595
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Must have read things wrong. Or my over stressed brain read more into it tha=
n was there.=20

Sent from my iPhone

> On Nov 7, 2013, at 16:00, ""mojavelinux [via Asciidoctor :: Discussion]"" <m=
l-node+s49171n967h83@n6.nabble.com> wrote:
>=20
> Jason,
>=20
> I don't expect it to require extra effort. It's just a proposal to select v=
ersion numbers with purpose. The main shift is really at the major and minor=
 level. If we switch to 1.x.x, we give ourselves more room for versions. If w=
e agree to use the minor number to track the core library version (e.g., 1.5=
.x) then things just make a lot more sense.
>=20
> I'm not trying to push projects to go faster or slower, just to align on v=
ersion numbers in a sensible way. Hopefully that clarifies the goal a bit.
>=20
> -Dan
>=20
>> On Nov 7, 2013 10:19 AM, ""LightGuardjp [via Asciidoctor :: Discussion]"" <=
[hidden email]> wrote:
>> Theory sounds good, the actual practice of it (speaking for myself and my=
 time available to put in, I'm not SuperMan like Dan and can pull 20 hour da=
ys) may not be as rosy or as quick paced.
>>=20
>>=20
>> On Wed, Nov 6, 2013 at 6:00 PM, mojavelinux [via Asciidoctor :: Discussio=
n] <[hidden email]> wrote:
>> As I mentioned in the release notes for 0.1.4, we're shifting the version=
 numbering in the next release of Asciidoctor core so we can leverage all th=
e parts (major, minor and micro). That's why the next release will be 1.5.0.=

>>=20
>> To help users better understand which version of a subproject, such as As=
ciidoctorJ or one of the build plugins, goes with Asciidoctor core, I'd like=
 to encourage those projects make the switch as well.
>>=20
>> Here's how I'm thinking we should align.
>>=20
>> . If the major version is different between core and another project, the=
 user should not expect that they work together (though, they may).
>>=20
>> . We recommend that at least the minor version match. Projects should not=
 increment their minor version ahead of core, as this gives the impression t=
here is a newer core available.
>>=20
>> . The user should not infer any relationship between micro versions acros=
s projects. That position is entirely up to the project to increment at will=
. However, the project should ensure to maintain capability with the major +=
 minor version of core when doing so.
>>=20
>> The goal is to release core often enough that a project should never feel=
 stuck on a minor version. If anything, core should keep a pace ahead of the=
 projects so that the projects always have something to move towards.
>>=20
>> These are just suggestions and voluntary. It's up to you guys. I'm propos=
ing this alignment to help users feel confident about which versions of the l=
ibraries to select.
>>=20
>> wdyt?
>>=20
>> -Dan
>>=20
>> --=20
>> Dan Allen | http://google.com/profiles/dan.j.allen
>>=20
>>=20
>> If you reply to this email, your message will be added to the discussion b=
elow:
>> http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-pro=
jects-tp961.html
>> To start a new topic under Asciidoctor :: Discussion, email [hidden email=
]=20
>> To unsubscribe from Asciidoctor :: Discussion, click here.
>> NAML
>=20
>=20
>=20
> --=20
> Jason Porter
> http://en.gravatar.com/lightguardjp
>=20
>=20
> If you reply to this email, your message will be added to the discussion b=
elow:
> http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-proj=
ects-tp961p965.html
> To start a new topic under Asciidoctor :: Discussion, email [hidden email]=
=20
> To unsubscribe from Asciidoctor :: Discussion, click here.
> NAML
>=20
>=20
> If you reply to this email, your message will be added to the discussion b=
elow:
> http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-proj=
ects-tp961p967.html
> To start a new topic under Asciidoctor :: Discussion, email ml-node+s49171=
n1h37@n6.nabble.com=20
> To unsubscribe from Asciidoctor :: Discussion, click here.
> NAML

--Apple-Mail-FE26BEA7-4AEA-45B2-A4E2-2DECC3BDC595
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: 7bit

<html><head><meta http-equiv=""content-type"" content=""text/html; charset=utf-8""></head><body dir=""auto""><div>Must have read things wrong. Or my over stressed brain read more into it than was there.&nbsp;<br><br>Sent from my iPhone</div><div><br>On Nov 7, 2013, at 16:00, ""mojavelinux [via Asciidoctor :: Discussion]"" &lt;<a href=""mailto:ml-node+s49171n967h83@n6.nabble.com"">ml-node+s49171n967h83@n6.nabble.com</a>&gt; wrote:<br><br></div><blockquote type=""cite""><div>

	<p dir=""ltr"">Jason,</p>
<p dir=""ltr"">I don't expect it to require extra effort. It's just a proposal to select version numbers with purpose. The main shift is really at the major and minor level. If we switch to 1.x.x, we give ourselves more room for versions. If we agree to use the minor number to track the core library version (e.g., 1.5.x) then things just make a lot more sense.</p>

<p dir=""ltr"">I'm not trying to push projects to go faster or slower, just to align on version numbers in a sensible way. Hopefully that clarifies the goal a bit.</p>
<p dir=""ltr"">-Dan</p>
<div class=""gmail_quote"">On Nov 7, 2013 10:19 AM, ""LightGuardjp [via Asciidoctor :: Discussion]"" &lt;<a href=""/user/SendEmail.jtp?type=node&amp;node=967&amp;i=0"" target=""_top"" rel=""nofollow"" link=""external"">[hidden email]</a>&gt; wrote:<br type=""attribution"">
<blockquote style=""border-left:2px solid #CCCCCC;padding:0 1em"" class=""gmail_quote"">

	<div dir=""ltr"">Theory sounds good, the actual practice of it (speaking for myself and my time available to put in, I'm not SuperMan like Dan and can pull 20 hour days) may not be as rosy or as quick paced.</div><div class=""gmail_extra"">


<br><br><div class=""gmail_quote"">On Wed, Nov 6, 2013 at 6:00 PM, mojavelinux [via Asciidoctor :: Discussion] <span dir=""ltr"">&lt;<a href=""http://user/SendEmail.jtp?type=node&amp;node=965&amp;i=0"" rel=""nofollow"" link=""external"" target=""_blank"">[hidden email]</a>&gt;</span> wrote:<br>




	<div dir=""ltr""><div><div><div><div>As I mentioned in the release notes for 0.1.4, we're shifting the version numbering in the next release of Asciidoctor core so we can leverage all the parts (major, minor and micro). That's why the next release will be 1.5.0.<br>




<br>To help users better understand which version of a subproject, such as AsciidoctorJ or one of the build plugins, goes with Asciidoctor core, I'd like to encourage those projects make the switch as well.<br><br></div>




Here's how I'm thinking we should align.<br><br>. If the major version is different between core and another project, the user should not expect that they work together (though, they may).<br><br>. We recommend that at least the minor version match. Projects should not increment their minor version ahead of core, as this gives the impression there is a newer core available.<br>




<br>. The user should not infer any relationship between micro versions across projects. That position is entirely up to the project to increment at will. However, the project should ensure to maintain capability with the major + minor version of core when doing so.<br>




<br></div>The goal is to release core often enough that a project should never feel stuck on a minor version. If anything, core should keep a pace ahead of the projects so that the projects always have something to move towards.<br>




<br></div>These are just suggestions and voluntary. It's up to you guys. I'm proposing this alignment to help users feel confident about which versions of the libraries to select.<br><br></div>wdyt?<br><div><br><div>




<div><div><div>-Dan<span><font color=""#888888""><br clear=""all""><div><br>-- <br><div dir=""ltr""><div>Dan Allen |&nbsp;<a href=""http://google.com/profiles/dan.j.allen"" rel=""nofollow"" link=""external"" target=""_blank"">http://google.com/profiles/dan.j.allen</a></div>


</div>
</div></font></span></div></div></div></div></div></div><span><font color=""#888888"">

	
	<br>
	<br>
	<hr noshade="""" size=""1"" color=""#cccccc"">
	<div style=""color:#444;font:12px tahoma,geneva,helvetica,arial,sans-serif"">
		<div style=""font-weight:bold"">If you reply to this email, your message will be added to the discussion below:</div>
		<a href=""http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-projects-tp961.html"" rel=""nofollow"" link=""external"" target=""_blank"">http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-projects-tp961.html</a>
	</div>
	<div style=""color:#666;font:11px tahoma,geneva,helvetica,arial,sans-serif;margin-top:.4em;line-height:1.5em"">
		To start a new topic under Asciidoctor :: Discussion, email <a href=""http://user/SendEmail.jtp?type=node&amp;node=965&amp;i=1"" rel=""nofollow"" link=""external"" target=""_blank"">[hidden email]</a> <br>
		To unsubscribe from Asciidoctor :: Discussion, <a rel=""nofollow"" link=""external"" target=""_top"">click here</a>.<br>


		<a href=""http://discuss.asciidoctor.org/template/NamlServlet.jtp?macro=macro_viewer&amp;id=instant_html%21nabble%3Aemail.naml&amp;base=nabble.naml.namespaces.BasicNamespace-nabble.view.web.template.NabbleNamespace-nabble.view.web.template.NodeNamespace&amp;breadcrumbs=notify_subscribers%21nabble%3Aemail.naml-instant_emails%21nabble%3Aemail.naml-send_instant_email%21nabble%3Aemail.naml"" rel=""nofollow"" style=""font:9px serif"" link=""external"" target=""_blank"">NAML</a>
	</div></font></span></div></div></blockquote></div><br><br clear=""all""><div><br></div>-- <br><div dir=""ltr"">Jason Porter<br><a href=""http://en.gravatar.com/lightguardjp"" rel=""nofollow"" link=""external"" target=""_blank"">http://en.gravatar.com/lightguardjp</a><br>
</div>




	
	<br>
	<br>
	<hr noshade="""" size=""1"" color=""#cccccc"">
	<div style=""color:#444;font:12px tahoma,geneva,helvetica,arial,sans-serif"">
		<div style=""font-weight:bold"">If you reply to this email, your message will be added to the discussion below:</div>
		<a href=""http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-projects-tp961p965.html"" target=""_blank"" rel=""nofollow"" link=""external"">http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-projects-tp961p965.html</a>
	</div>
	<div style=""color:#666;font:11px tahoma,geneva,helvetica,arial,sans-serif;margin-top:.4em;line-height:1.5em"">
		To start a new topic under Asciidoctor :: Discussion, email <a href=""/user/SendEmail.jtp?type=node&amp;node=967&amp;i=1"" target=""_top"" rel=""nofollow"" link=""external"">[hidden email]</a> <br>
		To unsubscribe from Asciidoctor :: Discussion, <a href="""" target=""_blank"" rel=""nofollow"" link=""external"">click here</a>.<br>

		<a href=""http://discuss.asciidoctor.org/template/NamlServlet.jtp?macro=macro_viewer&amp;id=instant_html%21nabble%3Aemail.naml&amp;base=nabble.naml.namespaces.BasicNamespace-nabble.view.web.template.NabbleNamespace-nabble.view.web.template.NodeNamespace&amp;breadcrumbs=notify_subscribers%21nabble%3Aemail.naml-instant_emails%21nabble%3Aemail.naml-send_instant_email%21nabble%3Aemail.naml"" rel=""nofollow"" style=""font:9px serif"" target=""_blank"" link=""external"">NAML</a>
	</div>

	
	<br>
	<br>
	<hr noshade=""noshade"" size=""1"" color=""#cccccc"">
	<div style=""color:#444; font: 12px tahoma,geneva,helvetica,arial,sans-serif;"">
		<div style=""font-weight:bold"">If you reply to this email, your message will be added to the discussion below:</div>
		<a href=""http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-projects-tp961p967.html"">http://discuss.asciidoctor.org/Making-versions-more-meaningful-across-projects-tp961p967.html</a>
	</div>
	<div style=""color:#666; font: 11px tahoma,geneva,helvetica,arial,sans-serif;margin-top:.4em;line-height:1.5em"">
		To start a new topic under Asciidoctor :: Discussion, email <a href=""mailto:ml-node+s49171n1h37@n6.nabble.com"">ml-node+s49171n1h37@n6.nabble.com</a> <br>
		To unsubscribe from Asciidoctor :: Discussion, <a href=""http://discuss.asciidoctor.org/template/NamlServlet.jtp?macro=unsubscribe_by_code&amp;node=1&amp;code=bGlnaHRndWFyZC5qcEBnbWFpbC5jb218MXw3NzU3OTU3MTg="">click here</a>.<br>
		<a href=""http://discuss.asciidoctor.org/template/NamlServlet.jtp?macro=macro_viewer&amp;id=instant_html%21nabble%3Aemail.naml&amp;base=nabble.naml.namespaces.BasicNamespace-nabble.view.web.template.NabbleNamespace-nabble.view.web.template.NodeNamespace&amp;breadcrumbs=notify_subscribers%21nabble%3Aemail.naml-instant_emails%21nabble%3Aemail.naml-send_instant_email%21nabble%3Aemail.naml"" rel=""nofollow"" style=""font:9px serif"">NAML</a>
	</div></div></blockquote></body></html>
--Apple-Mail-FE26BEA7-4AEA-45B2-A4E2-2DECC3BDC595--'
EOF
    expected = <<EOF
Must have read things wrong. Or my over stressed brain read more into it than was there.

Sent from my iPhone

> On Nov 7, 2013, at 16:00, ""mojavelinux [via Asciidoctor :: Discussion]"" <ml-node+s49171n967h83@n6.nabble.com> wrote:
>
> Jason,
>
> I don't expect it to require extra effort. It's just a proposal to select version numbers with purpose. The main shift is really at the major and minor level. If we switch to 1.x.x, we give ourselves more room for versions. If we agree to use the minor number to track the core library version (e.g., 1.5.x) then things just make a lot more sense.
>
> I'm not trying to push projects to go faster or slower, just to align on version numbers in a sensible way. Hopefully that clarifies the goal a bit.
>
> -Dan
>
>> On Nov 7, 2013 10:19 AM, ""LightGuardjp [via Asciidoctor :: Discussion]"" <[hidden email]> wrote:
>> Theory sounds good, the actual practice of it (speaking for myself and my time available to put in, I'm not SuperMan like Dan and can pull 20 hour days) may not be as rosy or as quick paced.
>>
>>
>> On Wed, Nov 6, 2013 at 6:00 PM, mojavelinux [via Asciidoctor :: Discussion] wrote:
>> As I mentioned in the release notes for 0.1.4, we're shifting the version numbering in the next release of Asciidoctor core so we can leverage all the parts (major, minor and micro). That's why the next release will be 1.5.0.
>>
>> To help users better understand which version of a subproject, such as AsciidoctorJ or one of the build plugins, goes with Asciidoctor core, I'd like to encourage those projects make the switch as well.
>>
>> Here's how I'm thinking we should align.
>>
>> . If the major version is different between core and another project, the user should not expect that they work together (though, they may).
>>
>> . We recommend that at least the minor version match. Projects should not increment their minor version ahead of core, as this gives the impression there is a newer core available.
>>
>> . The user should not infer any relationship between micro versions across projects. That position is entirely up to the project to increment at will. However, the project should ensure to maintain capability with the major + minor version of core when doing so.
>>
>> The goal is to release core often enough that a project should never feel stuck on a minor version. If anything, core should keep a pace ahead of the projects so that the projects always have something to move towards.
>>
>> These are just suggestions and voluntary. It's up to you guys. I'm proposing this alignment to help users feel confident about which versions of the libraries to select.
>>
>> wdyt?
>>
>> -Dan
>>
>> --
>> Dan Allen | http://google.com/profiles/dan.j.allen
>>
>>
EOF
    expect(nabblePostFormat.process_nabble_post(raw)).to eq(expected)    
  end
end

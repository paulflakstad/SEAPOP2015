<%-- 
    Document   : SEAPOP master template - based on MOSJ master template
    Created on : Dec 10, 2014, 1:28:30 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute
--%><%@page import="org.opencms.jsp.*,
		org.opencms.file.types.*,
		org.opencms.file.*,
                org.opencms.util.CmsStringUtil,
                org.opencms.util.CmsHtmlExtractor,
                org.opencms.util.CmsRequestUtil,
                org.opencms.security.CmsRoleManager,
                org.opencms.security.CmsRole,
                org.opencms.main.OpenCms,
                org.opencms.xml.content.*,
                org.opencms.db.CmsResourceState,
                org.opencms.flex.CmsFlexController,
		java.util.*,
                java.text.SimpleDateFormat,
                java.text.DateFormat,
                no.npolar.common.menu.*,
                no.npolar.util.CmsAgent,
                no.npolar.util.contentnotation.*"
                session="true" 
                contentType="text/html" 
                pageEncoding="UTF-8"
%><%@taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"
%><%
CmsAgent cms                = new CmsAgent(pageContext, request, response);
CmsObject cmso              = cms.getCmsObject();
String requestFileUri       = cms.getRequestContext().getUri();
String requestFolderUri     = cms.getRequestContext().getFolderUri();
Integer requestFileTypeId   = cmso.readResource(requestFileUri).getTypeId();
boolean loggedInUser        = OpenCms.getRoleManager().hasRole(cms.getCmsObject(), CmsRole.WORKPLACE_USER);

// Redirect HTTPS requests to HTTP for any non-logged in user
if (!loggedInUser && cms.getRequest().isSecure()) {
    String redirAbsPath = "http://" + request.getServerName() + cms.link(requestFileUri);
    String qs = cms.getRequest().getQueryString();
    if (qs != null && !qs.isEmpty()) {
        redirAbsPath += "?" + qs;
    }
    //out.println("<!-- redirect path is '" + redirAbsPath + "' -->");
    CmsRequestUtil.redirectPermanently(cms, redirAbsPath);
}

Locale locale               = cms.getRequestContext().getLocale();
String loc                  = locale.toString();
String description          = CmsStringUtil.escapeHtml(CmsHtmlExtractor.extractText(cms.property("Description", requestFileUri, ""), "utf-8"));
String title                = cms.property("Title", requestFileUri, "");
String titleAddOn           = cms.property("Title.addon", "search", "");
//String feedUri              = cms.property("rss", requestFileUri, "");
boolean portal              = Boolean.valueOf(cms.property("portalpage", requestFileUri, "false")).booleanValue();
String canonical            = null;
String featuredImage        = cmso.readPropertyObject(requestFileUri, "image.thumb", false).getValue(null);
String includeFilePrefix    = "";
String fs                   = null; // font size
HttpSession sess            = request.getSession();
String siteName             = cms.property("sitename", "search", "SEAPOP");
//boolean loggedInUser        = OpenCms.getRoleManager().hasRole(cms.getCmsObject(), CmsRole.WORKPLACE_USER);
//boolean pinnedNav           = false; 
boolean homePage            = false;

// Enable session-stored "hover box" resolver
ContentNotationResolver cnr = new ContentNotationResolver();
try {
    // Load global notations
    cnr.loadGlobals(cms, "/" + cms.getRequestContext().getLocale() + "/_global/tooltips.html");
    cnr.loadGlobals(cms, "/" + cms.getRequestContext().getLocale() + "/_global/references.html");
    sess.setAttribute(ContentNotationResolver.SESS_ATTR_NAME, cnr);
} catch (Exception e) {
    out.println("<!-- Content notation resolver error: " + e.getMessage() + " -->");
}

homePage = requestFileUri.equals("/" + loc + "/") 
            || requestFileUri.equals("/" + loc + "/index.html")
            || requestFileUri.equals("/" + loc + "/index.jsp");




// Handle case: canonicalization
// - Priority 1: a canonical URI is specified in the "canonical" property
// - Priority 2: the current request URI is an index file
CmsProperty propCanonical = cmso.readPropertyObject(requestFileUri, "canonical", false);
// First examine the "canonical" property
if (!propCanonical.isNullProperty()) {
    canonical = propCanonical.getValue();
    if (canonical.startsWith("/") && !cmso.existsResource(canonical))
        canonical = null;
}
// If no "canonical" property was found, and we're displaying an index file,
// set the canonical URL to the folder (remove the "index.html" part).
if (canonical == null && CmsRequestUtil.getRequestLink(requestFileUri).endsWith("/index.html")) {
    canonical = cms.link(requestFolderUri);
    // Keep any parameters
    if (!request.getParameterMap().isEmpty()) {
        // Copy the parameter map. (Since we may need to remove some parameters.)
        Map requestParams = new HashMap(request.getParameterMap());
        // Remove internal OpenCms parameters (they start with a double underscore) 
        // and any other unwanted ones - e.g. font size parameters
        Set keys = requestParams.keySet();
        Iterator iKeys = keys.iterator();
        while (iKeys.hasNext()) {
            String key = (String)iKeys.next();
            if (key.startsWith("__")) // This is an internal OpenCms parameter ...
                iKeys.remove(); // ... so go ahead and remove it.
        }
        if (!requestParams.isEmpty())
            canonical = CmsRequestUtil.appendParameters(canonical, requestParams, true);
    }
}

if (request.getParameter("__locale") != null) {
    locale = new Locale(request.getParameter("__locale"));
    cms.getRequestContext().setLocale(locale);
}
if (request.getParameter("includeFilePrefix") != null) {
    includeFilePrefix = request.getParameter("includeFilePrefix");
}

if (!portal) {
    try {
        if (requestFileTypeId == OpenCms.getResourceManager().getResourceType("np_portalpage").getTypeId())
            portal = true;
    } catch (org.opencms.loader.CmsLoaderException unknownResTypeException) {
        // Portal page module not installed
    }
}

String[] moreMarkupResourceTypeNames = { 
                                            "np_event"
                                            , "gallery"
                                            , "np_form"
                                            , "faq"
                                            //, "person"
                                            //, "np_eventcal"
                                        };
// Add those filetypes that require extra markup from this template 
// (These will be wrapped in <article class="main-content">)
List moreMarkupResourceTypes= new ArrayList();
for (int iResTypeNames = 0; iResTypeNames < moreMarkupResourceTypeNames.length; iResTypeNames++) {
    try {
        moreMarkupResourceTypes.add(OpenCms.getResourceManager().getResourceType(moreMarkupResourceTypeNames[iResTypeNames]).getTypeId());
    } catch (org.opencms.loader.CmsLoaderException unknownResTypeException) {
        // Resource type not installed
    }
}

// Handle case:
// - Title set as request attribute
if (request.getAttribute("title") != null) {
    try {
        String reqAttrTitle = (String)request.getAttribute("title");
        //out.println("<!-- set title to '" + reqAttrTitle + "' (found request attribute) -->");
        if (!reqAttrTitle.isEmpty()) {
            title = reqAttrTitle;
        }
    } catch (Exception e) {
        // The title found as request attribute was not of type String
    }
    
}

// Handle case: 
// - the current request URI points to a folder
// - the folder has no title
// - the folder's index file has a title (this is the displayed file, so show that title)
//if (title.isEmpty() && (requestFileUri.endsWith("/") || requestFileUri.endsWith("/index.html"))) {
if (title != null && title.isEmpty()) {
    if (requestFileUri.endsWith("/")) {
        title = cmso.readPropertyObject(requestFileUri.concat("index.html"), "Title", false).getValue("No title");
    }
}

//boolean isFrontPage = false;
//try { isFrontPage = title.equals(siteName); } 
//catch (Exception e) {}

// Insert the "add-on" to the title. For example: A big event has multiple
// pages, and to make the titles unique, the event name could be used as a title add-on.
// Instead of "Programme - NPI", the title would be "Programme - <event name> - NPI"
if (titleAddOn != null && !titleAddOn.equalsIgnoreCase("none") && !titleAddOn.isEmpty()) {
    title = title.concat(" - ").concat(titleAddOn);
}

if (!homePage) {
    title = title.concat(" - ").concat(siteName);
} else {
    title = siteName;
}

title = CmsHtmlExtractor.extractText(title, "utf-8");

// Done with the title. Now create a version of the title specifically targeted at social media (facebook, twitter etc.)
String socialMediaTitle = title.endsWith((" - ").concat(siteName)) ? title.replace((" - ").concat(siteName), "") : title;
// Featured image set? (Also for social media.)
//featuredImage = cmso.readPropertyObject(requestFileUri, "image.thumb", false).getValue(null);

final String NAV_MAIN_URI       = "/menu.html";
final String LANGUAGE_SWITCH    = "/system/modules/no.npolar.common.lang/elements/sibling-switch.jsp";
final String HOME_URI           = cms.link("/" + loc + "/");
final String SERP_URI           = cms.link("/" + loc + "/" + (loc.equalsIgnoreCase("no") ? "sok" : "search") + ".html");
final String SKIP_TO_CONTENT    = loc.equalsIgnoreCase("no") ? "Hopp til innholdet" : "Skip to content";
final boolean EDITABLE_MENU     = true;

String menuTemplate = null;
HashMap params = null;
//String quickLinksTemplate = null;
//HashMap quickLinksParams = null;

//String menuFile = cms.property("menu-file", "search", "");

cms.editable(false);

%><cms:template element="header"><!DOCTYPE html>
<html lang="<%= locale.getLanguage() %>">
<head>
<title><%= title %></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=0.5,user-scalable=yes" />
<% 
// Print all alternate languages (including current language) for this page
cms.include("/system/modules/no.npolar.common.lang/elements/alternate-languages.jsp"); 
if (canonical != null) 
    out.println("<link rel=\"canonical\" href=\"" + canonical + "\" />");
%>
<meta property="og:title" content="<%= socialMediaTitle %>" />
<meta property="og:site_name" content="<%= siteName %>" />
<%
if (!description.isEmpty()) {
    out.println("<meta name=\"description\" content=\"" + description + "\" />");
    out.println("<meta property=\"og:description\" content=\"" + description + "\" />");
    out.println("<meta name=\"twitter:card\" content=\"summary\" />");
    out.println("<meta name=\"twitter:title\" content=\"" + socialMediaTitle + "\" />");
    out.println("<meta name=\"twitter:description\" content=\"" + CmsStringUtil.trimToSize(description, 180, 10, " ...") + "\" />");
    if (featuredImage != null || cmso.existsResource(featuredImage)) {
        out.println("<meta name=\"twitter:image:src\" content=\"" + OpenCms.getLinkManager().getOnlineLink(cmso, featuredImage.concat("?__scale=w:300,h:300,t:3,q:100")) + "\" />");
        out.println("<meta name=\"og:image\" content=\"" + OpenCms.getLinkManager().getOnlineLink(cmso, featuredImage.concat("?__scale=w:400,h:400,t:3,q:100")) + "\" />");
    }
}
if (canonical != null) {
    out.println("<meta property=\"og:url\" content=\"" + OpenCms.getLinkManager().getOnlineLink(cmso, canonical) + "\" />");
}
%>
<link rel="apple-touch-icon" sizes="57x57" href="/apple-icon-57x57.png">
<link rel="apple-touch-icon" sizes="60x60" href="/apple-icon-60x60.png">
<link rel="apple-touch-icon" sizes="72x72" href="/apple-icon-72x72.png">
<link rel="apple-touch-icon" sizes="76x76" href="/apple-icon-76x76.png">
<link rel="apple-touch-icon" sizes="114x114" href="/apple-icon-114x114.png">
<link rel="apple-touch-icon" sizes="120x120" href="/apple-icon-120x120.png">
<link rel="apple-touch-icon" sizes="144x144" href="/apple-icon-144x144.png">
<link rel="apple-touch-icon" sizes="152x152" href="/apple-icon-152x152.png">
<link rel="apple-touch-icon" sizes="180x180" href="/apple-icon-180x180.png">
<link rel="icon" type="image/png" sizes="192x192"  href="/android-icon-192x192.png">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="96x96" href="/favicon-96x96.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="manifest" href="/manifest.json">
<meta name="msapplication-TileColor" content="#ffffff">
<meta name="msapplication-TileImage" content="/ms-icon-144x144.png">
<meta name="theme-color" content="#ffffff">
<%
out.println(cms.getHeaderElement(CmsAgent.PROPERTY_CSS, requestFileUri));
%>
<!--<link rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=Old+Standard+TT:400,700,400italic|Vollkorn:400,700,400italic,700italic|Arvo:400,700italic,400italic,700" />-->

<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/navigation.css") %>" />
<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/base.css") %>" />
<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/smallscreens.css") %>" media="(min-width:310px)" />
<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/largescreens.css") %>" media="(min-width:801px)" />
<!--<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/nav-off-canvas.css") %>" />-->
<!--<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/navigation.css") %>" />-->
<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/print.css") %>" media="print" />
<!--<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/js/highslide/highslide.css") %>" />-->
<!--<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.common.jquery/resources/qtip2/2.1.1/jquery.qtip.min.css") %>" />-->

<!--[if lte IE 8]>
<script type="text/javascript" src="<%= cms.link("/system/modules/no.npolar.util/resources/js/html5.js") %>"></script>
<script type="text/javascript" src="<%= cms.link("/system/modules/no.npolar.util/resources/js/XXXXXrem.min.js") %>"></script>
<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/non-responsive-dynamic.css") %>" />
<link rel="stylesheet" type="text/css" href="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/ie8.css") %>" />
<![endif]-->

<script type="text/javascript" src="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/js/modernizr.js") %>"></script>
<!--[if lt IE 9]>
     <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<![endif]-->
<!--[if gte IE 9]><!-->
     <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
<!--<![endif]-->
<!--<script type="text/javascript" src="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/js/highslide/highslide-full.js") %>"></script>-->
<script type="text/javascript" src="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/js/commons.js") %>"></script>
<!--<script type="text/javascript" src="<%= cms.link("/system/modules/no.npolar.common.jquery/resources/jquery.hoverintent.min.js") %>"></script>-->
<!--<script type="text/javascript" src="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/js/nav-off-canvas.js") %>"></script>-->
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/webfont/1.4.7/webfont.js"></script>
<%
out.println(cms.getHeaderElement(CmsAgent.PROPERTY_JAVASCRIPT, requestFileUri));
out.println(cms.getHeaderElement(CmsAgent.PROPERTY_HEAD_SNIPPET, requestFileUri));
%>
<style type="text/css">
    html, body { height: 100%; width: 100%; margin: 0; padding: 0; }
    #body { overflow:hidden; }
    .jsready .wcag-off-screen { position:absolute; margin-left:-9999px; }
</style>
</head>
<body id="<%= homePage ? "homepage" : "sitepage" %>">
    <div id="wrapwrap"><div id="wrap">
    <a id="skipnav" tabindex="1" href="#contentstart"><%= SKIP_TO_CONTENT %></a>
    <div id="jsbox"></div>
    <div id ="top">
        <header id="header" class="no">

            <div id="header-mid" class="clearfix">
                <div class="fullwidth-centered">

                    <a id="identity" href="<%= HOME_URI %>" tabindex="2">
                        <img id="identity-image" src="<%= cms.link("/system/modules/no.npolar.site.seapop/resources/style/logo-seapop.svg") %>" alt="" />
                        <span id="identity-text">SEAPOP<span id="identity-tagline">Om sjøfugl – for et rikere hav</span></span>
                    </a>

                    <!-- navigation + search togglers (small screen) -->
                    <a id="toggle-nav" class="nav-toggler" tabindex="6" href="#nav"><span><span></span></span></a>
                    <a id="toggle-search" class="smallscr-only" tabindex="3" href="#search-global"><i class="icon-search"></i></a>
                    <%
                    try { cms.include(LANGUAGE_SWITCH); } catch (Exception e) { out.println("\n<!-- error including language switch: " + e.getMessage() + "\n-->"); }
                    %>
                    <!--
                    <div id="searchbox">
                        <form method="get" action="<%= SERP_URI %>">
                            <label for="query" class="hidden">Søk på nettstedet</label>
                            <input type="search" class="query" name="query" id="query" tabindex="4" placeholder="Søk..." />
                            <button title="Søk" type="submit" class="submit" value="" tabindex="5"><i class="icon-search"></i></button>
                        </form>
                    </div>
                    -->
                    <!-- new version -->
                    <div id="search-global" class="searchbox global-site-search">
                        <form method="get" action="<%= SERP_URI %>">
                            <label for="query" class="hidden"><%= cms.labelUnicode("label.seapop.global.search") %></label>
                            <input type="search" class="query query-input" name="query" id="query" placeholder="<%= cms.labelUnicode("label.seapop.global.search.placeholder") %>" />
                            <button class="search-button" title="<%= cms.labelUnicode("label.seapop.global.search.submit") %>" onclick="submit()"><i class="icon-search"></i></button>
                        </form>
                    </div>
                    <!-- end new version -->
                </div>
            </div>

        </header> <!-- #header -->
    
        <div id="navwrap" class="clearfix">
            <nav id="nav" role="navigation" class="xnav-colorscheme-dark">
                <!--<a href="javascript:void(0);" id="close-nav">x</a>-->
                <a class="nav-toggler" id="hide-nav" href="#nonav">Skjul meny</a>
                <%                
                // Get the path to the menu file and put it in a parameter map
                params = new HashMap();
                params.put("filename", NAV_MAIN_URI);
                // Read the property "template-elements" from the menu file. This is the path to the menu template file.
                try {
                    menuTemplate = cms.getCmsObject().readPropertyObject(NAV_MAIN_URI, "template-elements", false).getValue();
                } catch (Exception e) {
                    out.println("<!-- An error occured while trying to read the template for the menu '" + NAV_MAIN_URI + "': " + e.getMessage() + " -->");
                }
                try {
                    cms.include(menuTemplate, "full", EDITABLE_MENU, params);
                } catch (Exception e) {
                    out.println("<!-- An error occured while trying to include main navigation (using template '" + menuTemplate + "'): " + e.getMessage() + " -->");
                }
                %>
            </nav>
        </div><!-- #navwrap -->
    
        <%
        // Don't print breadcrumb on home page
        if (!homePage) {
        %>
        <!-- Breadcrumb navigation: -->
        <nav id="nav_breadcrumb_wrap">
            <%
            // Include the "breadcrumb" element of the menu template file, pass parameters
            try {
                cms.include(menuTemplate, "breadcrumb", EDITABLE_MENU, params);
            } catch (Exception e) {
                out.println("<!-- An error occured while trying to include the breadcrumb menu (using template '" + menuTemplate + "'): " + e.getMessage() + " -->");
            }
            %>
        </nav>
        <!-- Done with breadcrumb navigation -->
        <%
        }
        %>    
        
    </div><!-- #top -->
    
    <!--<div id="docwrap" class="clearfix">-->
    <!--<div id="mainwrap">-->
        
        <!--<div id="leftside" style="display:none;"></div>-->
        <!--<div id="content" style="width:100%;">-->
            
            
    <a id="contentstart"></a>
    <!--<article class="main-content<%= (portal ? " portal" : "") %>">-->
</cms:template>
            
<cms:template element="contentbody">
	<cms:include element="body" />
</cms:template>
            
<cms:template element="footer">
    <!--</article>--><!-- .main-content -->
        <!--</div>--><!-- #content -->        
    <!--</div>--><!-- #mainwrap -->
    <!--</div>--><!-- #docwrap -->
    
    <footer id="footer">
        <div id="footer-content">
            <% 
            cms.includeAny("/" + loc + "/footer-content.html");
            //cms.getContent("/" + "no" + "/footer.html", "body", loc); // won't work ...
            %>
        </div>
    </footer>
    
    </div></div><!-- wrappers -->
    
<script type="text/javascript">
// Loading fonts like this requires the WebFont script in <head> section
WebFont.load({
    google: {
        families: ['Old Standard TT', 'Open Sans', 'Droid Sans', 'Droid Serif']
    }
});

$(document).ready(function() {
    // Prepare Highslide (if necessary)
    readyHighslide('<%= cms.link("/system/modules/no.npolar.common.highslide/resources/js/highslide/highslide.min.css") %>', 
                    '<%= cms.link("/system/modules/no.npolar.common.highslide/resources/js/highslide/highslide.js") %>');
    
    // Blurry hero image background
    if ($('.article-hero')[0]) {
        makeBlurryHeroBackground('<%= cms.link("/system/modules/no.npolar.util/resources/js/stackblur.min.js") %>');
    }
    
    // qTip tooltips
    makeTooltips('<%= cms.link("/system/modules/no.npolar.common.jquery/resources/qtip2/2.1.1/jquery.qtip.min.css") %>',
                    '<%= cms.link("/system/modules/no.npolar.common.jquery/resources/jquery.qtip.min.js") %>');
                    
    // Track clicks
    $('#identity').click(function() {
        try { ga('send', 'event', 'UI interactions', 'clicked site navigation', 'identity area'); } catch(ignore) {}
    });
    $('#nav_topmenu > li:first-child').click(function() {
        try { ga('send', 'event', 'UI interactions', 'clicked site navigation', 'home link in menu'); } catch(ignore) {}
    });
    $('#toggle-nav').click(function() {
        try { ga('send', 'event', 'UI interactions', 'clicked menu toggler', (smallScreenMenuIsVisible() ? 'opened menu' : 'closed menu')); } catch(ignore) {}
    });
    
    //initUserControls();
    
    // Open all links to the NINA full-screen app in new tabs
    $('a[href^="http://www2.nina.no/Seapop/seapophtml/"]').attr('target', '_blank');
    // Open all PDF links in new tabs
    $('a[href$=".pdf"], a[href*=".pdf?"]').attr('target', '_blank');
    
    if (!Modernizr.svg) {
        // Fallback to .png logo
        $('#identity-image').attr({ src : $('#identity-image').attr('src').replace('.svg', '.png') });
    }
});

// Moved to commons.js:
/*      
var large = 800;
var bigScreen = true;  // Default: Browsers with no support for matchMedia (like IE9 and below) will use this value
try {
    bigScreen = window.matchMedia('(min-width: ' + large + 'px)').matches; // Update value for browsers supporting matchMedia
} catch (err) {
    // Retain default value
}

function initUserControls() {
    //if (smallScreenMenuIsVisible) {
        $('#nav').find('li.has_sub').not('.inpath').addClass('hidden-sub');
        $('#nav').find('li.has_sub.inpath').addClass('visible-sub');
        //$('#nav').find('li.has_sub').append('<a class="visible-sub-toggle" href="javascript:void(0)"></a>');
        $('#nav').find('li.has_sub > a').after('<a class="visible-sub-toggle" href="javascript:void(0)"></a>');
        $('.visible-sub-toggle').click(function(e) {
            $(this).parent('li').toggleClass('visible-sub hidden-sub');
        });

        $('.nav-toggler').click(function(e) {
            e.preventDefault();
            $('html').toggleClass('navigating');
        });

        // ToDo: Fix - #docwrap does not exist anymore
        $('#docwrap').click(function() {
            if (smallScreenMenuIsVisible()) {
                $('html').toggleClass('navigating');
            }
        });
    //}
	
    // toggle a "focus" class on the top-level menus when appropriate
    $('#nav a').focus(function() {
        $(this).parents('li').addClass('infocus');
    });
    $('#nav a').blur(function() {
        $(this).parents('li').removeClass('infocus');
    });
    try {
        // use "hover delay" to add usability bonus
        $('#nav li').hoverDelay({
            delayIn: 250,
            delayOut: 300,
            handlerIn: function($element) {
                $element.addClass('infocus');
            },
            handlerOut: function($element) {
                $element.removeClass('infocus');
            }
        });
    } catch (err) {
        // No hoverDelay function
        $('#nav li').mouseenter(function() {
            $(this).addClass('infocus');
        });
        $('#nav li').mouseleave(function() {
            $(this).removeClass('infocus'); 	
        });
    }
    
    // accessibility bonus: clearer outlines
    $('head').append('<style id="behave" />');
    $('body').bind('mousedown', function(e) {
        $('html').removeClass('tabbing');
        mouseFriendly();
    });
    $('body').bind('keydown', function(e) {
        $('html').addClass('tabbing');
        if (e.keyCode === 9) {
            keyFriendly();
        }
    });
    
    // handle clicks on "show/hide search field"
    $('#toggle-search').click(function(e) {	
        var search = $('#searchbox');
        search.removeAttr('style');
        $('html').toggleClass('search-open');
        search.toggleClass('not-visible');
    });

    $(window).resize(function() {
        layItOut();
    });

    layItOut();
}
function layItOut() {
    var bigScreen = true;
    try {
        bigScreen = window.matchMedia('(min-width: ' + large + 'px)').matches; // Update value for browsers supporting matchMedia
    } catch (err) {
        // Retain default value
    }
    if (bigScreen) {
        // Large viewport

        // Create the large screen submenu: 
        // Clone the current top-level navigation's submenu, add it to the DOM and wrap it in a <nav>
        if ($('#subnavigation').length === 0) { // Don't keep adding the submenu again and again ... Du-uh
            var submenu = $('.inpath.subitems > ul').clone(); // Clone it
            submenu.removeAttr('class').removeAttr('style'); // Strip classes and attributes (which may have been modified by togglers in small screen view)
            submenu.children('ul').removeAttr('class').removeAttr('style'); // Do the same for all deeper levels
            $('#leftside').append('<nav id="subnavigation" role="navigation"><ul>' + submenu.html() + '</ul></nav>');
        }
        $('#searchbox').removeAttr('class');
        $('#searchbox').removeAttr('style');
    }
    else {
        $('#subnavigation').remove(); // Remove the big screen submenu
        $('#searchbox').hide(); // Prevent "search box collapse" animation on page load
        //$('#searchbox').attr('style', 'display:none;'); // Prevent search box collapsing animation on page load
        $('#searchbox').addClass('not-visible');
    }
}
function keyFriendly() {
    try { 
        document.getElementById("behave").innerHTML="a:focus, input:focus, button:focus, select:focus { outline:thin dotted; outline:3px solid #1f98f6; }"; 
    } catch (err) {}
}
function mouseFriendly() {
    try { 
        document.getElementById("behave").innerHTML="a, a:focus, input:focus, select:focus { outline:none !important; }"; 
    } catch (err) {}
}
function smallScreenMenuIsVisible() {
    return $('html').hasClass('navigating');
}
*/
</script>
<% 
// Enable Analytics 
// (... but not if the "visitor" is actually a logged-in user)
if (!loggedInUser) {
%>
<script>
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
ga('create', 'UA-770196-14', 'auto');
ga('send', 'pageview');
</script>
<script type="text/javascript">
/*
Script: Autogaq 2.1.6 (http://redperformance.no/autogaq/)
Last update: 6 May 2015
Description: Finds external links and track clicks as Events that gets sent to Google Analytics
Compatibility: Google Universal Analytics
*/
!function(){function a(a){var c=a.target||a.srcElement,f=!0,i="undefined"!=typeof c.href?c.href:"",j=i.match(document.domain.split(".").reverse()[1]+"."+document.domain.split(".").reverse()[0]);if(!i.match(/^javascript:/i)){var k=[];if(k.value=0,k.non_i=!1,i.match(/^mailto\:/i))k.category="contact",k.action="email",k.label=i.replace(/^mailto\:/i,""),k.loc=i;else if(i.match(d)){var l=/[.]/.exec(i)?/[^.]+$/.exec(i):void 0;k.category="download",k.action=l[0],k.label=i.replace(/ /g,"-"),k.loc=e+i}else i.match(/^https?\:/i)&&!j?(k.category="outbound traffic",k.action="click",k.label=i.replace(/^https?\:\/\//i,""),k.non_i=!0,k.loc=i):i.match(/^tel\:/i)?(k.category="contact",k.action="telephone",k.label=i.replace(/^tel\:/i,""),k.loc=i):f=!1;f&&(a.preventDefault(),g=k.loc,h=a.target.target,ga("send","event",k.category.toLowerCase(),k.action.toLowerCase(),k.label.toLowerCase(),k.value,{nonInteraction:k.non_i}),b())}}function b(){"_blank"==h?window.open(g,"_blank"):window.location.href=g}function c(a,b,c){a.addEventListener?a.addEventListener(b,c,!1):a.attachEvent("on"+b,function(){return c.call(a,window.event)})}var d=/\.(zip|exe|dmg|pdf|doc.*|xls.*|ppt.*|mp3|txt|rar|wma|mov|avi|wmv|flv|wav)$/i,e="",f=document.getElementsByTagName("base");f.length>0&&"undefined"!=typeof f[0].href&&(e=f[0].href);for(var g="",h="",i=document.getElementsByTagName("a"),j=0;j<i.length;j++)c(i[j],"click",a)}();
</script>
<script type="text/javascript">
/*
Script: Still here beacon (Based on http://redperformance.no/google-analytics/time-on-site-manipulasjon/)
Last update: 3 Nov 2015
Description: Sends an event to Google Analytics every N seconds after the page has loaded, to improve time-on-site metrics.
    Works like a beacon, regularly signaling that the visitor is "still here".
    By changing nonInteraction to false, beacon beeps are treated as interactions. The most notable effect 
    of this will be that any visit that produces at least one beacon beep will not be considered a bounce.
Compatibility: Google Universal Analytics
*/
var secondsOnPage = 0; // How many (active) seconds the user has spent on this page
var pageVisible = true; // Flag that indicates whether or not the page is visible, see http://www.samdutton.com/pageVisibility/
var beaconInterval = 10; // Frequency at which to send the beacon signal (in seconds)
function handleVisibilityChange() {
    try {
        if (document['hidden']) {
            pageVisible = false;
        } else {
            pageVisible = true;
        }
    } catch (err) {
        pageVisible = true;
    }
}
// Set initial page visibility flag
handleVisibilityChange();
// Set the visibility change handler
document.addEventListener('visibilitychange', handleVisibilityChange, false);
// Initialize counter and beacon signal
window.setInterval(
    function() {
        try {
            if (pageVisible) {
                if (++secondsOnPage % beaconInterval === 0) {
                    ga('send', 'event', 'seconds on page', 'log', secondsOnPage, {nonInteraction: true});
                }
            }
        } catch (ignore) { }
    }, 1000);
</script>
<% 
}
%>
</body>
</html>
<%
// Clear hoverbox resolver
cnr.clear();
// Clear session variables and hoverbox resolver
sess.removeAttribute("share");
sess.removeAttribute("autoRelatedPages");
sess.removeAttribute(ContentNotationResolver.SESS_ATTR_NAME);
%>
</cms:template>
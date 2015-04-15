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

Locale loc                  = cms.getRequestContext().getLocale();
String locale               = loc.toString();
String description          = CmsStringUtil.escapeHtml(CmsHtmlExtractor.extractText(cms.property("Description", requestFileUri, ""), "utf-8"));
String title                = cms.property("Title", requestFileUri, "");
String titleAddOn           = cms.property("Title.addon", "search", "");
String feedUri              = cms.property("rss", requestFileUri, "");
boolean portal              = Boolean.valueOf(cms.property("portalpage", requestFileUri, "false")).booleanValue();
String canonical            = null;
String featuredImage        = null;
String includeFilePrefix    = "";
String fs                   = null; // font size
HttpSession sess            = request.getSession();
String siteName             = cms.property("sitename", "search", "SEAPOP");
//boolean loggedInUser        = OpenCms.getRoleManager().hasRole(cms.getCmsObject(), CmsRole.WORKPLACE_USER);
boolean pinnedNav           = false; 
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
            if (key.startsWith("__")) // This is an internal OpenCms parameter or a font-size parameter ...
                iKeys.remove(); // ... so go ahead and remove it.
        }
        if (!requestParams.isEmpty())
            canonical = CmsRequestUtil.appendParameters(canonical, requestParams, true);
    }
}

if (request.getParameter("__locale") != null) {
    loc = new Locale(request.getParameter("__locale"));
    cms.getRequestContext().setLocale(loc);
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
// - the current request URI is a resource of type "person" AND
// - the resource has a title on the format "lastname, firstname"
try {
    if (requestFileTypeId == OpenCms.getResourceManager().getResourceType("person").getTypeId()) {
        if (title != null && !title.isEmpty() && title.indexOf(",") > -1) {
            String[] titleParts = title.split(","); // [Flakstad][ Paul-Inge]
            if (titleParts.length == 2) {
                title = titleParts[1].trim() + " " + titleParts[0].trim();
            }
        }
    }
} catch (org.opencms.loader.CmsLoaderException unknownResTypeException) {
    // Resource type "person" not installed
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
featuredImage = cmso.readPropertyObject(requestFileUri, "image.thumb", false).getValue(null);

final String NAV_MAIN_URI       = "/menu.html";
//final String MENU_TOP_URL       = includeFilePrefix + "/header-menu.html";
//final String QUICKLINKS_MENU_URI= "/menu-quicklinks-isblink.html";
//final String LANGUAGE_SWITCH    = "/system/modules/no.npolar.common.lang/elements/sibling-switch.jsp";
final String HOME_URI           = cms.link("/" + locale + "/");
final String SERP_URI		= cms.link("/" + locale + "/" + (locale.equalsIgnoreCase("no") ? "sok" : "search") + ".html");
final boolean EDITABLE_MENU     = true;

String menuTemplate = null;
HashMap params = null;
String quickLinksTemplate = null;
HashMap quickLinksParams = null;

//String menuFile = cms.property("menu-file", "search", "");

cms.editable(false);

%><cms:template element="header"><!DOCTYPE html>
<html lang="<%= loc.getLanguage() %>">
<head>
<title><%= title %></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=0.5,user-scalable=yes" />
<meta property="og:title" content="<%= socialMediaTitle %>" />
<meta property="og:site_name" content="<%= siteName %>" />
<%
if (!description.isEmpty()) {
    out.println("<meta name=\"description\" content=\"" + description + "\" />");
    out.println("<meta property=\"og:description\" content=\"" + description + "\" />");
    out.println("<meta name=\"twitter:card\" content=\"summary\" />");
    out.println("<meta name=\"twitter:site\" content=\"@NorskPolar\" />");
    out.println("<meta name=\"twitter:title\" content=\"" + socialMediaTitle + "\" />");
    out.println("<meta name=\"twitter:description\" content=\"" + CmsStringUtil.trimToSize(description, 180, 10, " ...") + "\" />");
    if (featuredImage != null || cmso.existsResource(featuredImage)) {
        out.println("<meta name=\"twitter:image:src\" content=\"" + OpenCms.getLinkManager().getOnlineLink(cmso, featuredImage.concat("?__scale=w:300,h:300,t:3,q:100")) + "\" />");
        out.println("<meta name=\"og:image\" content=\"" + OpenCms.getLinkManager().getOnlineLink(cmso, featuredImage.concat("?__scale=w:400,h:400,t:3,q:100")) + "\" />");
    }
}
if (canonical != null) {
    out.println("<!-- This page may exist at other URLs, but this is the true URL: -->");
    out.println("<link rel=\"canonical\" href=\"" + canonical + "\" />");
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
out.println(cms.getHeaderElement(CmsAgent.PROPERTY_HEAD_SNIPPET, requestFileUri));
%>
<!--<link rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=Old+Standard+TT:400,700,400italic|Vollkorn:400,700,400italic,700italic|Arvo:400,700italic,400italic,700" />-->

<link rel="stylesheet" type="text/css" href="<%= cms.link("../resources/style/navigation.css") %>" />
<link rel="stylesheet" type="text/css" href="<cms:link>../resources/style/base.css</cms:link>" />
<link rel="stylesheet" type="text/css" href="<cms:link>../resources/style/smallscreens.css</cms:link>" media="(min-width:310px)" />
<link rel="stylesheet" type="text/css" href="<cms:link>../resources/style/largescreens.css</cms:link>" media="(min-width:801px)" />
<!--<link rel="stylesheet" type="text/css" href="<cms:link>../resources/style/nav-off-canvas.css</cms:link>" />-->
<!--<link rel="stylesheet" type="text/css" href="<cms:link>../resources/style/navigation.css</cms:link>" />-->
<link rel="stylesheet" type="text/css" href="<cms:link>../resources/style/print.css</cms:link>" media="print" />
<link rel="stylesheet" type="text/css" href="<cms:link>../resources/js/highslide/highslide.css</cms:link>" />
<link rel="stylesheet" type="text/css" href="<cms:link>/system/modules/no.npolar.common.jquery/resources/qtip2/2.1.1/jquery.qtip.min.css</cms:link>" />

<!--[if lte IE 8]>
<script type="text/javascript" src="<cms:link>/system/modules/no.npolar.util/resources/js/html5.js</cms:link>"></script>
<script type="text/javascript" src="<cms:link>/system/modules/no.npolar.util/resources/js/rem.min.js</cms:link>"></script>
<link rel="stylesheet" type="text/css" href="<cms:link>../resources/style/non-responsive.css</cms:link>" />
<link rel="stylesheet" type="text/css" href="<cms:link>../resources/style/ie8.css</cms:link>" />
<![endif]-->

<script type="text/javascript" src="<cms:link>../resources/js/modernizr.js</cms:link>"></script>
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script type="text/javascript" src="<cms:link>/system/modules/no.npolar.site.seapop/resources/js/highslide/highslide-full.js</cms:link>"></script>
<script type="text/javascript" src="<cms:link>../resources/js/commons.js</cms:link>"></script>
<script type="text/javascript" src="<cms:link>/system/modules/no.npolar.common.jquery/resources/jquery.hoverintent.min.js</cms:link>"></script>
<!--<script type="text/javascript" src="<cms:link>../resources/js/nav-off-canvas.js</cms:link>"></script>-->
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/webfont/1.4.7/webfont.js"></script>

<style type="text/css">
    html, body { height: 100%; width: 100%; margin: 0; padding: 0; }
    #body { overflow:hidden; }
    .jsready .wcag-off-screen { position:absolute; margin-left:-9999px; }
</style>
</head>
<body id="<%= homePage ? "homepage" : "sitepage" %>">
    <%
    // Google Analytics tracking code - output only for users who are not logged in
    if (!loggedInUser) { %>
    <script>
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', 'UA-770196-14', 'auto');
    ga('send', 'pageview');
    </script>
    <%}%>
    <div id="wrapwrap"><div id="wrap">
    <a id="skipnav" tabindex="1" href="#contentstart">Hopp til innholdet</a>
    <div id="jsbox"></div>
    <div id ="top">
        <header id="header" class="no">

            <div id="header-mid" class="clearfix">
                <div class="fullwidth-centered">

                    <a id="identity" href="<%= HOME_URI %>" tabindex="2">
                        <img id="identity-image" src="<%= cms.link("../resources/style/logo-seapop.svg") %>" alt="" />
                        <span id="identity-text">SEAPOP<span id="identity-tagline">Om sjøfugl – for et rikere hav</span></span>
                    </a>

                    <!-- navigation + search togglers (small screen) -->
                    <a id="toggle-nav" class="nav-toggler" tabindex="6" href="#nav"><span><span></span></span></a>
                    <a id="toggle-search" class="smallscr-only" tabindex="3" href="javascript:void(0);"><i class="icon-search"></i></a>

                    <div id="searchbox">
                        <form method="get" action="<%= SERP_URI %>">
                            <label for="query" class="hidden">Søk på nettstedet</label>
                            <input type="search" class="query" name="query" id="query" tabindex="4" placeholder="Søk..." />
                            <button title="Søk" type="submit" class="submit" value="" tabindex="5"><i class="icon-search"></i></button>
                        </form>
                    </div>

                </div>
            </div>

        </header> <!-- #header -->
    
        <div id="navwrap" class="clearfix">
            <!-- Navigation: -->
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
            </nav><!-- #nav -->
            <!-- Done with navigation -->
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
    <!--<article class="main-content">-->
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
            %>
        </div>
    </footer>
    
    </div></div><!-- wrappers -->
    
<script type="text/javascript">
WebFont.load({
    google: {
        families: ['Old Standard TT', 'Open Sans', 'Droid Sans', 'Droid Serif']
    }
});
      
var large = 800;
var bigScreen = true;  // Default: Browsers with no support for matchMedia (like IE9 and below) will use this value
try {
    bigScreen = window.matchMedia('(min-width: ' + large + 'px)').matches; // Update value for browsers supporting matchMedia
} catch (err) {
    // Retain default value
}




$(document).ready(function() {
    initUserControls();
    
    if (bigScreen && Modernizr.cssfilters) {
        // Blurry version of the hero image as background
        $('.article-hero').append( $('.article-hero-content > figure > img').clone() );
    }
    if (!Modernizr.svg) {
        // Fallback to .png logo
        $('#identity-image').attr({ src : $('#identity-image').attr('src').replace('.svg', '.png') });
    }
});

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
        // use "hover intent" to add usability bonus
        $('#nav li').hoverIntent({
            over: mouseinMenuItem
            ,out: mouseoutMenuItem
            ,timeout:400
            ,interval:250
        });
    } catch (err) {
        // No "hover intent"
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

function mouseinMenuItem(menuItem) {
    $(this).addClass('infocus');
}
function mouseoutMenuItem(menuItem) {
    $(this).removeClass('infocus');
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
        //if (emptyOrNonExistingElement('subnavigation')) { // Don't keep adding the submenu again and again ... Du-uh
        if ($('#subnavigation').length == 0) { // Don't keep adding the submenu again and again ... Du-uh
            var submenu = $('.inpath.subitems > ul').clone(); // Clone it
            submenu.removeAttr('class').removeAttr('style'); // Strip classes and attributes (which may have been modified by togglers in small screen view)
            submenu.children('ul').removeAttr('class').removeAttr('style'); // Do the same for all deeper levels
            $('#leftside').append('<nav id="subnavigation" role="navigation"><ul>' + submenu.html() + '</ul></nav>');
        }
        $('#searchbox').removeAttr('class');
        $('#searchbox').removeAttr('style');

        // 3rd and deeper level menus
        /*
        $('#nav ul ul li.has_sub').not('.inpath').mouseenter(function() {
                $(this).addClass('subnav-popup');
        });
        $('#nav ul ul li.has_sub').not('.inpath').mouseleave(function() {
            $(this).removeClass('subnav-popup');
        });
        */
        /*$('#nav ul ul li.has_sub').not('.inpath').children('a').first().focus(function() {
            $(this).parents('li').first().addClass('subnav-popup');
        });
        $('#nav ul ul li.has_sub').not('.inpath').children('a').first().blur(function() {
            $(this).parents('li').first().removeClass('subnav-popup');
        });*/
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

function showSubMenu() {
}


document.getElementsByTagName('a').onfocus = function(e) {
    this.toggleClass('has-focus');
};
</script>
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
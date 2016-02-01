<%-- 
    Document   : frontpage-buttons-and-publications
    Created on : Mar 31, 2015, 4:23:26 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%>
<%@ page import="org.opencms.loader.CmsImageScaler"%>
<%@ page import="no.npolar.util.*"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.io.PrintStream"%>
<%@ page import="org.opencms.file.*, org.opencms.file.types.*, org.opencms.xml.content.*, org.opencms.xml.page.CmsXmlPage"%>
<%@ page import="org.opencms.main.*" %>
<%@ page session="false" import="org.opencms.jsp.*"%>
<%@ page import="java.util.*"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>

<%
// Create a JSP action element, and get the URI of the requesting file
CmsAgent cms = new CmsAgent(pageContext, request, response);
Locale locale = cms.getRequestContext().getLocale();
String loc = locale.toString();

// Annual brochure: URLs to PDF and image files
final String URL_ANNUAL_BROCHURE_PDF = cms.link("/no/filer/pdf/arsbrosjyrer/SEAPOP-arsbrosjyre-2014.pdf");
final String URL_ANNUAL_BROCHURE_IMG = cms.link("/images/news-images/seapop-arsbrosjyre-2014_forside.jpg");
final String URL_ANNUAL_BROCHURE_TITLE = loc.equalsIgnoreCase("no") ? "SEAPOP årsbrosjyre 2014" : "SEAPOP 2014 annual brochure";

// Key document: URLs to PDF and image files
final String URL_KEY_DOC_PDF = cms.link("/no/filer/pdf/SEAPOP-Nokkeldokument-2015-web.pdf");
final String URL_KEY_DOC_IMG = cms.link("/images/news-images/SEAPOP-Nokkeldokument-2015_forside.jpg");
final String URL_KEY_DOC_TITLE = loc.equalsIgnoreCase("no") ? "SEAPOP Nøkkeldokument 2005-2014" : "SEAPOP key document 2005-2014";

// Publications: Folder / title
final String PUBLICATIONS_FOLDER = loc.equalsIgnoreCase("no") ? "/no/publikasjoner/" : "/en/publications/";
final String PUBLICATIONS_TITLE = loc.equalsIgnoreCase("no") ? "Siste publikasjoner" : "Latest publications";
final String PUBLICATIONS_LINK_TEXT = loc.equalsIgnoreCase("no") ? "Flere publikasjoner" : "More publications";



%>
<div class="layout-group single">
    <div class="layout-box">
        <%
        cms.includeAny("/" + loc + "/frontpage-buttons.html");
        %>
    </div>
    <div class="layout-box">
        
	<a href="<%= URL_ANNUAL_BROCHURE_PDF %>" hreflang="no" class="card-link featured-link" target="_blank" 
           onclick="ga('send', 'event', 'Downloads', 'Start download', '<%= URL_ANNUAL_BROCHURE_TITLE %> (<%= locale.getDisplayLanguage() %>)');">
            <div class="card card-h" style="padding:1.2em;">
                <div class="card-image-wrapper">
                    <img src="<%= cms.link(URL_ANNUAL_BROCHURE_IMG) %>" alt="<%= URL_ANNUAL_BROCHURE_TITLE %>" />
                </div>
                <div class="card-text">
                    <h3 class="card-heading"><%= URL_ANNUAL_BROCHURE_TITLE %> (PDF)</h3>
                    <%
                    // Norwegian
                    if (loc.equalsIgnoreCase("no")) {
                        out.println("<p>Sammenfatter viktige resultater og aktiviter fra 2014.</p>");
                    }
                    // English
                    else if (loc.equalsIgnoreCase("en")) {
                        out.println("<p>A summary of important activities and results from 2014.</p>");
                    }
                    %>
                </div>
            </div>
        </a>
		
	<a href="<%= URL_KEY_DOC_PDF %>" hreflang="no" class="card-link featured-link" target="_blank" 
           onclick="ga('send', 'event', 'Downloads', 'Start download', '<%= URL_KEY_DOC_TITLE %> (<%= locale.getDisplayLanguage() %>)');">
            <div class="card card-h" style="padding:1.2em;">
                <div class="card-image-wrapper">
                    <img src="<%= cms.link(URL_KEY_DOC_IMG) %>" alt="<%= URL_KEY_DOC_TITLE %>" />
                </div>
                <div class="card-text">
                    <h3 class="card-heading"><%= URL_KEY_DOC_TITLE %> (PDF)</h3>
                    <%
                    // Norwegian
                    if (loc.equalsIgnoreCase("no")) {
                        out.println("<p>Oppsummerer SEAPOPs resultater og belyser endringer i sjøfuglbestandene.</p>");
                    }
                    // English
                    else if (loc.equalsIgnoreCase("en")) {
                        out.println("<p>A summary of the results of the SEAPOP programme and of the changes in the seabird populations.</p>");
                    }
                    %>
                </div>
            </div>
        </a>
		
    </div>
    <div class="layout-box">
        <h2 class="portal-box-heading"><%= PUBLICATIONS_TITLE %></h2>
        <%
        
        // Define settings for the "latest publications" list
        HashMap params = new HashMap();
        params.put("folder", PUBLICATIONS_FOLDER); // Define which folder to list files from
        params.put("subtree", "true"); // Define if we should list from all sub-folders as well (true)
        params.put("limit", "5"); // Set the max number of entries in the list
        
        // Include the script that prints the latest publications ...
        cms.include("/system/modules/no.npolar.common.publication/elements/publication-list.jsp", "simple", params);
        
        // ... and a link to the publications archive
        out.println("<a class=\"cta more\" href=\"" + cms.link(PUBLICATIONS_FOLDER) + "\">" + PUBLICATIONS_LINK_TEXT + "</a>");
        
        %>
    </div>
</div>
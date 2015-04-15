<%-- 
    Document   : frontpage-publications
    Created on : Mar 7, 2015, 3:14:26 PM
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
final String URL_ANNUAL_BROCHURE_PDF = cms.link("/no/files/publications/2014/SEAPOP_aarsbrosjyre_2013_web.pdf");
final String URL_ANNUAL_BROCHURE_IMG = cms.link("/system/modules/no.npolar.site.seapop/resources/img/seapop-arsbrosjyre-2013.png");
final String URL_ANNUAL_BROCHURE_TITLE = loc.equalsIgnoreCase("no") ? "SEAPOP årsbrosjyre 2013" : "SEAPOP 2013 annual brochure";

// Publications: Folder
final String PUBLICATIONS_FOLDER = loc.equalsIgnoreCase("no") ? "/no/publikasjoner/" : "/en/publications/";
%>
<div class="layout-gruop single">
    <div class="layout-box">
        <a href="<%= URL_ANNUAL_BROCHURE_PDF %>" hreflang="no" class="card-link featured-link" target="_blank" 
           onclick="ga('send', 'event', 'Downloads', 'Start download', 'SEAPOP annual brochure 2013 (<%= locale.getDisplayLanguage() %>)');">
            <div class="card card-h" style="padding:1.2em;">
                <div class="card-image-wrapper">
                    <img src="<cms:link>/images/news-images/seapop-arsbrosjyre-2013.png</cms:link>" alt="SEAPOP årsbrosjyre 2013" />
                </div>
                <div class="card-text">
                    <h3 class="card-heading"><%= URL_ANNUAL_BROCHURE_TITLE %> (PDF)</h3>
                    <%
                    // Norwegian
                    if (loc.equalsIgnoreCase("no")) {
                        out.println("<p>Sammenfatter viktige resultater og aktiviter fra 2013.</p>");
                    }
                    // English
                    else if (loc.equalsIgnoreCase("en")) {
                        out.println("<p>A summary of important activities and results from 2013.</p>");
                    }
                    %>
                </div>
            </div>
        </a>
    </div>
    <div class="layout-box">
        <%
        HashMap params = new HashMap();
        params.put("folder", PUBLICATIONS_FOLDER);
        params.put("subtree", "true");
        params.put("limit", "5");
        cms.include("/system/modules/no.npolar.common.publication/elements/publication-list.jsp", "simple", params);
        out.println("<a class=\"cta more\" href=\"" + cms.link(PUBLICATIONS_FOLDER) + "\">Flere publikasjoner</a>");
        %>
    </div>
</div>
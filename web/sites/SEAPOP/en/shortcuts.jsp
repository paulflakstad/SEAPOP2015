<%-- 
    Document   : shortcuts.jsp
    Created on : Jan 29, 2016, 12:35:28 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="no.npolar.util.*" %>
<%@page import="org.opencms.jsp.*" %>
<%
CmsAgent cms = new CmsAgent(pageContext, request, response);

final String URI_LOCATIONS_FILE = "/en/seatrack/locations/index.html";
final String URI_SPECIES_FILE = "/en/seatrack/species/index.html";
final String PARAGRAPH_HANDLER = "/system/modules/no.npolar.common.pageelements/elements/paragraphhandler-standalone.jsp";
%>
        
<div class="layout-group double">
    <section class="layout-box">
        <h2 class="layout-box_heading">Locations</h2>
        <%
        I_CmsXmlContentContainer fileContainer = cms.contentload("singleFile", URI_LOCATIONS_FILE, false);
        if (fileContainer.hasMoreResources()) {
            request.setAttribute("paragraphContainer", fileContainer);
            if (fileContainer != null) 
                cms.includeAny(PARAGRAPH_HANDLER); 
            else 
                out.println("<!-- fileContainer was NULL -->");
        }
        %>
    </section>
    <section class="layout-box">
        <h2 class="layout-box_heading">Species</h2>
        <%
        fileContainer = cms.contentload("singleFile", URI_SPECIES_FILE, false);
        if (fileContainer.hasMoreResources()) {
            request.setAttribute("paragraphContainer", fileContainer);
            if (fileContainer != null) 
                cms.includeAny(PARAGRAPH_HANDLER); 
            else 
                out.println("<!-- fileContainer was NULL -->");
        }
        %>
    </section>
</div>
<%
request.setAttribute("paragraphContainer", null);
%>
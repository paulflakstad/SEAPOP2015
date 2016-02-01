<%-- 
    Document   : top.jsp
    Created on : Jan 29, 2016, 12:35:28 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="no.npolar.util.*" %>
<%@page import="org.opencms.jsp.*" %>
<%@page import="org.opencms.util.*" %>
<%@page import="org.opencms.file.*" %>
<%@page import="org.opencms.main.*" %>
<%
// Action element and CmsObject
CmsAgent cms = new CmsAgent(pageContext, request, response);
CmsObject cmso = cms.getCmsObject();

final String URI_WIDGET_IMAGE = "/images/figures-and-maps/toppskarv-arealbruk-GPS-sklinna.jpg";
final String URI_SEATRACK_LOGO = "/images/logos/SEATRACK-logo-draft-67.png";
final String URI_LOCATIONS_FILE = "/en/seatrack/locations/index.html";
final String PARAGRAPH_HANDLER = "/system/modules/no.npolar.common.pageelements/elements/paragraphhandler-standalone.jsp";
%>
<!--
        <section class="article-hero">
            <div class="article-hero-content">
                <h1><%= "SEATRACK :)" %></h1>
                <figure>
                    <%= ImageUtil.getImage(cms, URI_WIDGET_IMAGE) %>
                </figure>            
            </div>
        </section>
-->
<div style="width: 700px; max-width: 100%; margin: 0px auto;">
    <%= ImageUtil.getImage(cms, URI_SEATRACK_LOGO, "SEATRACK") %>
</div>
<div class="layout-group triple">
    <div class="layout-box span2">
        <figure>
            <%= ImageUtil.getImage(cms, URI_WIDGET_IMAGE) %>
        </figure> 
    </div>
    <div class="layout-box stretch-y standout">
        <h2 class="">See the data</h2>
        <p>All SEATRACK data presented in an <strong>interactive map application</strong>.</p><p>Create <strong>custom visualizations</strong> for on the particular species or location you're interested in.</p><p><strong>Free.</strong></p>
        <p><a class="cta" href="#">Open the app</a><br><em>or <a href="#">use a species or location shortcut</a></em></p>
    </div>
</div>
        
<div class="layout-group double">
    <div class="layout-box">
        <%
        request.setAttribute("paragraphContainer", cms.contentload("singleFile", URI_LOCATIONS_FILE, false));
        cms.include(PARAGRAPH_HANDLER); 
        %>
    </div>
    <div class="layout-box stretch-y standout">
        <h2 class="">See the data</h2>
        <p>All SEATRACK data presented in an <strong>interactive map application</strong>.</p><p>Create <strong>custom visualizations</strong> for on the particular species or location you're interested in.</p><p><strong>Free.</strong></p>
        <p><a class="cta" href="#">Open the app</a><br><em>or <a href="#">use a species or location shortcut</a></em></p>
    </div>
</div>
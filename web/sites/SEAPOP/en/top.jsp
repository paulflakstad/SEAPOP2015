<%-- 
    Document   : top.jsp
    Created on : Jan 29, 2016, 12:35:28 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%>
<%@page contentType="text/html" pageEncoding="UTF-8" import="no.npolar.util.*" %>
<%
CmsAgent cms = new CmsAgent(pageContext, request, response);

final String URI_WIDGET_IMAGE = "/images/figures-and-maps/rangifer-4156c.png";//"/images/figures-and-maps/toppskarv-arealbruk-GPS-sklinna.jpg";
final String URI_SEATRACK_LOGO = "/images/logos/SEATRACK-logo-draft-67.png";
%>
<div style="width: 700px; max-width: 100%; margin: 0px auto;">
    <%= ImageUtil.getImage(cms, URI_SEATRACK_LOGO, "SEATRACK") %>
</div>
<div class="layout-group triple">
    <div class="layout-box span2 standout">
        <figure style="max-height:600px; overflow:hidden;">
            <%= ImageUtil.getImage(cms, URI_WIDGET_IMAGE) %>
        </figure> 
    </div>
    <div class="layout-box stretch-y standout">
        <h2 class="" style="color:#fff;">View data</h2>
        <p>All data is visualized in an <strong>interactive map application</strong>, where you can create your own <strong>custom views</strong> for specific species or locations.</p>
        <!--<p><strong>Free.</strong></p>-->
        <p><a class="cta cta--button cta--inline-button" href="#">Open the app</a><br><em>or <a href="#locations-and-species">go directly to a species or location</a></em></p>
    </div>
</div>
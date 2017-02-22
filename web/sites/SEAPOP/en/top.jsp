<%-- 
    Document   : top.jsp
    Created on : Jan 29, 2016, 12:35:28 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%>
<%@page contentType="text/html" pageEncoding="UTF-8" import="no.npolar.util.*" %>
<%
CmsAgent cms = new CmsAgent(pageContext, request, response);

final String URI_WIDGET_IMAGE = "/images/figures-and-maps/seatrack-visualization-app.png";//"/images/figures-and-maps/toppskarv-arealbruk-GPS-sklinna.jpg";
final String URI_SEATRACK_LOGO = "/images/logos/SEATRACK-logo-draft-67.png";
%>
<!--<div style="width: 700px; max-width: 100%; margin: 0px auto;">
    <%= ImageUtil.getImage(cms, URI_SEATRACK_LOGO, "SEATRACK") %>
</div>
-->
<div class="layout-group triple" style="margin-top: 2em; margin-bottom: 2em;">
    <div class="standout clearfix" style="padding: 0;">
        <div class="layout-box span2 standout">
            <div id="map--locations" style="width:100%; height:400px; height:37vh; min-height:400px;"></div>
            <!--<figure style="max-height:600px; overflow:hidden;">-->
                <!--<%= ImageUtil.getImage(cms, URI_WIDGET_IMAGE) %>-->
            <!--</figure> -->
        </div>
        <div class="layout-box standout">
            <div style="background: transparent; margin-bottom: 1.2rem;">
                <img src="/images/logos/SEATRACK-light.png" alt="SEATRACK" style="max-width: 100%; max-width: calc(100% - 1rem);" />
                <!--<%= ImageUtil.getImage(cms, URI_SEATRACK_LOGO, "SEATRACK") %>-->
            </div>
            <h2 class="" style="color:#fff;">View data</h2>
            <p>All data is visualized in an <strong>interactive map application</strong>, where you can create your own <strong>custom views</strong> for specific species or locations.</p>
            <!--<p><strong>Free.</strong></p>-->
            <p><a class="cta cta--button cta--inline-button" href="//seatrack.seapop.no/map/" target="_blank">Open the app</a><br><em>or <a href="#locations-and-species">go directly to a species or location</a></em></p>
        </div>
    </div>
</div>
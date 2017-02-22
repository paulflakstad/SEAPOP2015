<%-- 
    Document   : shortcuts.jsp
    Created on : Jan 29, 2016, 12:35:28 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="no.npolar.util.*" %>
<%@page import="no.seapop.data.*"%>
<%@page import="org.opencms.jsp.*" %>
<%@page import="org.opencms.main.OpenCms" %>
<%@page import="org.opencms.file.*" %>
<%@page import="org.opencms.file.types.*" %>
<%@page import="java.util.*" %>
<%
CmsAgent cms = new CmsAgent(pageContext, request, response);
CmsObject cmso = cms.getCmsObject();

final String URI_LOCATIONS_FILE = "/en/seatrack/locations/index.html";
final String URI_SPECIES_FOLDER = "/en/seatrack/species/";
final String URI_SPECIES_FILE = URI_SPECIES_FOLDER + "index.html";
final String PARAGRAPH_HANDLER_STANDALONE = "/system/modules/no.npolar.common.pageelements/elements/paragraphhandler-standalone.jsp";
final String PARAGRAPH_HANDLER = "/system/modules/no.npolar.common.pageelements/elements/paragraphhandler.jsp";
%>

<!--<div class="layout-group double">-->
    <!--<div class="layout-box" id="map--locations" style="width:100%; height:400px; height:50vh; min-height:400px;"></div>-->
<!--</div>-->

<div class="layout-group double" id="locations-and-species">
    <section class="layout-box">
        <h2 class="layout-box_heading">Locations</h2>
        <%
        I_CmsXmlContentContainer fileContainer = cms.contentload("singleFile", URI_LOCATIONS_FILE, false);
        if (fileContainer.hasMoreResources()) {
            request.setAttribute("paragraphContainer", fileContainer);
            if (fileContainer != null) 
                cms.includeAny(PARAGRAPH_HANDLER_STANDALONE); 
            else 
                out.println("<!-- fileContainer was NULL -->");
        }
        %>
    </section>
    <section class="layout-box">
        <h2 class="layout-box_heading">Species</h2>
        <%
        //I_CmsXmlContentContainer allSpecies = cms.contentload("allInFolderPriorityTitleDesc", URI_SPECIES_FOLDER, false);
        
        CmsResourceFilter resTypeFilter = CmsResourceFilter.DEFAULT_FILES.addRequireType(OpenCms.getResourceManager().getResourceType("ivorypage").getTypeId());
        List<CmsResource> speciesResources = cmso.readResources(URI_SPECIES_FOLDER, resTypeFilter, false);
        
        Iterator<CmsResource> iSpeciesResources = speciesResources.iterator();        
        while (iSpeciesResources.hasNext()) {
            CmsResource speciesResource = iSpeciesResources.next();
            if (speciesResource.getName().startsWith("index")) {
                continue;
            }
            out.println("<!-- collected file " + speciesResource.getName() + " -->");
            // Load single species file
            fileContainer = cms.contentload("singleFile", cmso.getSitePath(speciesResource), false);
            if (fileContainer.hasMoreResources()) {
                
                out.println("<div class=\"toggleable collapsed\">");
                
                String targetId = speciesResource.getName().replace(".html", "");
                
                out.println("<a class=\"toggletrigger\" href=\"#" + targetId + "\" aria-controls=\"" + targetId + "\" style=\"font-size:large; padding:0.2em;\">"
                                + "<h3 style=\"display:inline; font-size:1em;\">" + cms.contentshow(fileContainer, "PageTitle") + "</h3>"
                            + "</a>");
                
                out.println("<div class=\"toggletarget\" id=\"" + targetId + "\">");
                out.println("<div style=\"font-weight:bold;\">" + cms.contentshow(fileContainer, "Intro") + "</div>");
                
                request.setAttribute("paragraphContainer", fileContainer);
                request.setAttribute("paragraphHeadingWrapper", "h4");
                request.setAttribute("pageTitle", cms.contentshow(fileContainer, "PageTitle"));
                if (fileContainer != null) 
                    cms.includeAny(PARAGRAPH_HANDLER_STANDALONE); 
                else 
                    out.println("<!-- fileContainer was NULL -->");
                out.println("</div>");
                
                out.println("</div>");
            }
        }
        /*fileContainer = cms.contentload("singleFile", URI_SPECIES_FILE, false);
        if (fileContainer.hasMoreResources()) {
            request.setAttribute("paragraphContainer", fileContainer);
            if (fileContainer != null) 
                cms.includeAny(PARAGRAPH_HANDLER); 
            else 
                out.println("<!-- fileContainer was NULL -->");
        }*/
        %>
    </section>
</div>
<%
request.setAttribute("paragraphContainer", null);
%>
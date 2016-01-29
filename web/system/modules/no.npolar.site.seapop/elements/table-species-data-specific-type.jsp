<%-- 
    Document   : table-species-data-specific-type.jsp
    Created on : Apr 8, 2015
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%><%@page contentType="text/html" pageEncoding="UTF-8" 
%><%@page import="java.util.Locale,
                java.util.Arrays,
                java.util.Collections,
                java.util.Comparator,
                java.util.List,
                java.util.ArrayList,
                java.util.Iterator,
                no.npolar.util.*,
                no.seapop.data.*,
                org.opencms.jsp.*,
                org.opencms.main.OpenCms,
                org.opencms.file.*"
%><%
    
    
    // -------------------------------------------------------------------------
    // Define the order of the locations in the table
    //
    List<String> locationsInOrder = Arrays.asList( new String[] {
        "Spitsbergen",
        "Bjørnøya",
        "Hornøya",
        "Hjelmsøya",
        "Grindøya",
        "Jan Mayen",
        "Anda",
        "Røst",
        "Sør-Helgeland",
        "Sklinna",
        "Runde",
        "Hordaland",
        "Rogaland",
        "Vest-Agder",
        "Ytre Oslofjord"
    });
    // -------------------------------------------------------------------------
    
    
    
    CmsAgent cms = new CmsAgent(pageContext, request, response);
    CmsObject cmso = cms.getCmsObject();
    Locale locale = cms.getRequestContext().getLocale();
    String loc = locale.toString();
    String requestFileUri = cms.getRequestContext().getUri();
    
    final String dataFilesFolder = "/no/artsdata/";
    List<CmsResource> excludedFiles = cmso.readResourcesWithProperty(dataFilesFolder, "timeseries.exclude", "true", CmsResourceFilter.DEFAULT_FILES.addRequireType(OpenCms.getResourceManager().getResourceType("seapop_species_data").getTypeId()));
    SpeciesDataCollection speciesDataEntries = new SpeciesDataCollection(dataFilesFolder, cms, excludedFiles);
	
	Iterator<SpeciesData> iSpeciesDataEntries = null;
	
	String type = cms.getRequest().getParameter("type");
	if (type == null || type.isEmpty()) {
		out.println("Error printing data table: No type set (" + type + ").");
		return;
	}
    
%>
        <div class="paragraph">
            <h2><%= new SpeciesDataLinkType(type).getLabel(cms) %></h2>
            <table class="species-data-link-table">
                <tr>
                    <th rowspan="3"></th>
                    <th colspan="8"><%= cms.labelUnicode("label.seapop-species-data.classification.pelagic") %></th>
                    <th rowspan="2"><%= cms.labelUnicode("label.seapop-species-data.classification.ice-related") %></th>
                    <th colspan="9"><%= cms.labelUnicode("label.seapop-species-data.classification.coastal-bound") %></th>
                    <th rowspan="2" colspan="5"><%= cms.labelUnicode("label.seapop-species-data.total") %></th>
                </tr>
                <tr>
                    <th colspan="6"><%= cms.labelUnicode("label.seapop-species-data.classification.diving") %></th>
                    <th colspan="3"><%= cms.labelUnicode("label.seapop-species-data.classification.surface-bound") %></th>
                    <th colspan="5"><%= cms.labelUnicode("label.seapop-species-data.classification.surface-bound") %></th>
                    <th colspan="4"><%= cms.labelUnicode("label.seapop-species-data.classification.diving") %></th>
                </tr>
                <tr class="th-v">
                    <%
                    iSpeciesDataEntries = speciesDataEntries.get().iterator();
                    while (iSpeciesDataEntries.hasNext()) {
                        out.println("<th scope=\"col\"><span>" + iSpeciesDataEntries.next().getName() + "</span></th>");
                    }
                    %>
                    <th scope="col"><span><%= cms.labelUnicode("label.seapop-species-data.number-of-series.short") %></span></th>
                </tr>

                <% 
                out.println(speciesDataEntries.toHtmlTableRows(cms, type, SpeciesDataLinkType.TYPES_ORDER_DEFAULT, null, locationsInOrder));
                %>
        </div>
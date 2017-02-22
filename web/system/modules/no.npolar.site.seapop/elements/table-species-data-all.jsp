<%-- 
    Document   : table-species-data-all.jsp
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
%><%!
    /**
     * Generates HTML table rows based on the data in the given collection, and 
     * the given "type totals" (aggregated sums per data type).
     * 
     * NOTE: This method substitutes 
     * no.seapop.data.SpeciesDataCollection#toHtmlTableRows(...)
     * 
     * (Controlling the generated HTML from within this JSP is both easier and
     * more natural.)
     * 
     * @param cms
     * @param dataCollection The SpeciesDataCollection to base the output on.
     * @param dataType If provided, the generated table will include only this data type. If null, all data types will be included.
     * @param dataTypeTotals The names of the data types to aggregate data for, and their order.
     * @param excludedDataTypes The names of the data types to exclude from the table.
     * @param locationsInOrder The names of the locations to include, in order. Required.
     * @return Ready-to-use HTML table rows.
     */
    public String toHtmlTableRows(CmsAgent cms, 
                                    SpeciesDataCollection dataCollection,
                                    String dataType, 
                                    List<String> dataTypeTotals, 
                                    List<String> excludedDataTypes, 
                                    List<String> locationsInOrder) {
        if (excludedDataTypes == null) {
            excludedDataTypes = new ArrayList<String>(); // Prevent NPE
        }
        
        List<String> comments = new ArrayList<String>();
        String s = "";
        
        Iterator<String> iLocations = locationsInOrder.iterator();
        while (iLocations.hasNext()) {
            // Get the location
            String location = iLocations.next();
            
            // Construct the array of aggregated sums per data type + 1 for the combined total
            int[] sums = new int[dataTypeTotals.size()+1]; // E.g.: [Population] [Reproduction] [Survival] [Diet] [COMBINED TOTAL (always last)]
            for (int sum : sums) {
                sum = 0;
            }
            
            // Start the row, using the location as the row header
            s += "<tr><th scope=\"row\">" + location + "</th>";
            
            // Now iterate the data entries ...
            Iterator<SpeciesData> iData= dataCollection.get().iterator();
            while (iData.hasNext()) {
                // A data entry
                SpeciesData speciesDataEntry = iData.next();
                // That data entry's location-specific data
                List<SpeciesDataLink> dataForSpeciesOnLocation = speciesDataEntry.getDataLinksByLocation(location);
                
                s += "<td>";
                
                if (dataType == null) 
                    s += "<div>"; // This <div> is a vital wrapper when dataType is null
                
                if (dataForSpeciesOnLocation.size() > 0) {
                    
                    Iterator<SpeciesDataLink> iDataLink = dataForSpeciesOnLocation.iterator();
                    while (iDataLink.hasNext()) {
                        SpeciesDataLink dataLink = iDataLink.next();

                        // We need to allow for "links" without URLs
                        // (Output these as <a> elements without href attribs)
                        boolean dataLinkHasUrl = dataLink.getUrl() != null && !dataLink.getUrl().isEmpty();
                        
                        // We don't want to include data links with negative order 
                        // factor (like the timing data links) in the combined table
                        if (dataType == null && excludedDataTypes.contains(dataLink.getType().getName()))
                            continue;
                        
                        if (dataType == null || dataType.equals(dataLink.getType().getName())) {
                            
                            if (dataType != null)
                                s += "<div class=\"rel-data-type-".concat(dataLink.getType().getIdentifier()).concat("\"") + ">";
                            
                            sums[dataTypeTotals.indexOf(dataLink.getType().getName())]++; // Increment relevant counter
                            sums[dataTypeTotals.size()]++; // Increment combined total (always at the "rightmost" position in the sums array)
                            String linkText = "";
                            if (dataType != null) {
                                linkText = dataLink.getNumYears();
                                
                                String comment = dataLink.getComment();
                                if (comment != null && !comment.isEmpty()) {
                                    int commentIndex = comments.indexOf(comment);
                                    if (commentIndex < 0) {
                                        comments.add(comment);
                                        commentIndex = comments.indexOf(comment);
                                    }
                                    linkText += "<sup>" + (commentIndex+1) + "</sup>"; 
                                }
                            }
                            
                            s += "<a"
                                    + (dataLinkHasUrl ? (" href=\"" + dataLink.getUrl() + "\"") : "")
                                    + " class=\"rel-data-type-" + dataLink.getType().getIdentifier() 
                                        + //(dataType == null ? 
                                            " species-data-link".concat(dataLinkHasUrl ? "" : " species-data-link--disabled")
                                            //: "")
                                        + "\""
                                    + " title=\"" 
                                        + speciesDataEntry.getName() 
                                        + ": " + dataLink.getType().getLabel(cms) 
                                        + ", " + location + (dataLink.getNumYears().isEmpty() ? 
                                            "" : 
                                            " ("+dataLink.getNumYears()+" "+cms.labelUnicode("label.seapop-species-data.year").toLowerCase()+")") 
                                        + "\""
                                    + (dataLinkHasUrl ? " target=\"_blank\"" : "")
                                    + ">" + linkText + "</a>";
                            
                            if (dataType != null)
                                s += "</div>";
                        }
                    }
                    
                } 
                
                if (dataType == null)
                    s += "</div>";
                
                s += "</td>";
            }
            
            if (dataType == null) {
                // No specified data type - print all aggregated sums
                for (int iSums = 0; iSums < sums.length; iSums++) {
                    try { if (excludedDataTypes.contains(dataTypeTotals.get(iSums))) continue; } catch (Exception e) {}
                    String dataTypeIdentifier = "total"; // Default: total - will be used if the next line throws an exception (which it should do at the last iteration)
                    try { dataTypeIdentifier = SpeciesDataLinkType.getIdentifierForName(dataTypeTotals.get(iSums)); } catch (Exception e) {}
                    s += "<td class=\"rel-data-type-" + dataTypeIdentifier + "\"><span>" + sums[iSums] + "</span></td>";
                }
            } 
            
            else {
                // Specified data type - print the single total sum
                s += "<td class=\"rel-data-type-t\"><span>" + sums[dataTypeTotals.indexOf(dataType)] + "</span></td>";
            }
            
            // End the row
            s += "</tr>\n\n";
            
            
        }
        
        s += "</table>\n\n";
        
        if (dataType != null && !comments.isEmpty()) {
            s += "<div class=\"species-data-table-comments\">";
            s += "<ol>";
            Iterator<String> iComments = comments.iterator();
            while (iComments.hasNext()) {
                s += "<li>" + iComments.next() + "</li>";
            }
            s += "</ol>";
            s += "</div>";
        }
        
        return s;
    }
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
    List<String> excludeTypes = Arrays.asList( new String[] { SpeciesDataLinkType.TIMING } );
    SpeciesDataCollection speciesDataCollection = new SpeciesDataCollection(dataFilesFolder, cms, excludedFiles);
    
%>
        
        <div class="paragraph">
            <table class="species-data-link-table species-data-link-table-all-combined">
                <tr>
                    <th rowspan="3"></th>
                    <th colspan="8"><%= cms.labelUnicode("label.seapop-species-data.classification.pelagic") %></th>
                    <th rowspan="2"><%= cms.labelUnicode("label.seapop-species-data.classification.ice-related") %></th>
                    <th colspan="9"><%= cms.labelUnicode("label.seapop-species-data.classification.coastal-bound") %></th>
                    <th rowspan="2" colspan="5"><%= cms.labelUnicode("label.seapop-species-data.number-of-series") %></th>
                </tr>
                <tr>
                    <th colspan="6"><%= cms.labelUnicode("label.seapop-species-data.classification.diving") %></th>
                    <th colspan="3"><%= cms.labelUnicode("label.seapop-species-data.classification.surface-bound") %></th>
                    <th colspan="5"><%= cms.labelUnicode("label.seapop-species-data.classification.surface-bound") %></th>
                    <th colspan="4"><%= cms.labelUnicode("label.seapop-species-data.classification.diving") %></th>                
                </tr>
                <tr class="th-v">
                    <%
                    List<SpeciesData> speciesDataEntries = speciesDataCollection.get();
                    Iterator<SpeciesData> iSpeciesDataEntries = speciesDataEntries.iterator();
                    while (iSpeciesDataEntries.hasNext()) {
                        out.println("<th scope=\"col\"><span>" + iSpeciesDataEntries.next().getName() + "</span></th>");
                    }
                    %>

                    <%
                    List<String> dataTypes = new ArrayList<String>(SpeciesDataLinkType.TYPES_ORDER_DEFAULT);
                    dataTypes.removeAll(excludeTypes);
                    Iterator<String> iDataTypes = dataTypes.iterator();
                    while (iDataTypes.hasNext()) {
                        String dataType = iDataTypes.next();
                        String dataTypeLabel = cms.labelUnicode("label.seapop-species-data.category.".concat(dataType.toLowerCase()));
                        out.println("<th class=\"species-data-head-" + dataType.toLowerCase() + "\"><span>" + dataTypeLabel + "</span></th>");
                    }
                    %>
                    <!--
                    <th><span>Diett</span></th>
                    <th><span>Bestand</span></th>
                    <th><span>Reprod</span></th>
                    <th><span>Overlevelse</span></th>-->
                    <th><span><%= cms.labelUnicode("label.seapop-species-data.total") %></span></th>
                </tr>

                <% 
                // The method handles closing the table tag because there may be 
                // comments that need to be included *after* the table.
                out.println(toHtmlTableRows(cms, speciesDataCollection, null, SpeciesDataLinkType.TYPES_ORDER_DEFAULT, excludeTypes, locationsInOrder));
                
                // The library has this method for generating html, but it is 
                // too cumbersome to make changes => Instead, use an equivalent 
                // method from within this script.
                //out.println(speciesDataCollection.toHtmlTableRows(cms, null, SpeciesDataLinkType.TYPES_ORDER_DEFAULT, excludeTypes, locationsInOrder));
                %>
            <!--</table>-->
        </div>
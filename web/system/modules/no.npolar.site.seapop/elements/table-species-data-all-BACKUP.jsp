<%-- 
    Document   : table-species-data-all.jsp
    Created on : Mar 26, 2015, 2:18:19 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%><%@page import="java.util.Collections"%>
<%@page import="java.util.Comparator"%>
<%@page contentType="text/html" pageEncoding="UTF-8" 
%><%@page import="java.util.Locale,
                java.util.Arrays,
                java.util.List,
                java.util.ArrayList,
                java.util.Iterator,
                no.npolar.util.*,
                org.opencms.jsp.*,
                org.opencms.main.OpenCms,
                org.opencms.file.*"
%><%!
public class SpeciesDataLink {
    private String url = null;
    private String location = null;
    private String type = null; // Diet | Population | Reproduction | Survival
    private String numYears = null;
    private String comment = null;
    
    /**
     * dummy constructor
     */
    public SpeciesDataLink() {
        this(null, null, null, null, null);
    }
    
    public SpeciesDataLink(String location, String type, String url, String numYears, String comment) {
        this.location = location;
        this.url = url;
        this.type = type;
        this.numYears = numYears;
        this.comment = comment;
    }
    
    public String getLocation() { return this.location; }
    public String getUrl() { return this.url; }
    public String getType() { return this.type; }
    public String getTypeIdentifier() { return this.type.toLowerCase().substring(0, 1); }
    
    /*public String getType(Locale locale) {
        return this.type;
    }*/
    public String getTypeLabel(CmsAgent cms) {
        return cms.labelUnicode("label.seapop-species-data.category.".concat(type.toLowerCase()));
    }
    public String getNumYears() { return this.numYears; }
    public String getComment() { return this.comment; }
    //public /*static*/ List<String> getTypes() { return Arrays.asList( new String[] { "Diet", "Population", "Reproduction", "Survival" } ); }
    //public /*static*/ List<String> getTypesNorwegian() { return Arrays.asList( new String[] { "Diett", "Bestand", "Reproduksjon", "Overlevelse" } ); }
}

public class SpeciesData {
    private String name = null;
    private String uri = null;    
    //private String speciesFileUri = null;
    private boolean isPelagic = false;
    private boolean isSurfaceBound = false;
    private boolean isDiving = false;
    private boolean isCoastalBound = false;
    private boolean isIceBound = false;
    
    private List<SpeciesDataLink> dataLinks = null;
    
    
    
    /*public static final Comparator<SpeciesData> GROUP_NUMBER = new Comparator<SpeciesData>() {
        @Override
        public int compare(SpeciesData o1, SpeciesData o2) {
            return Integer.valueOf(o1.getGroupNumber()).compareTo(Integer.valueOf(o2.getGroupNumber()));
            //throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }
    };*/
    
    
    public SpeciesData(String uri, CmsAgent cms) {
        this.uri = uri;
        this.dataLinks = new ArrayList<SpeciesDataLink>();
        try {
            I_CmsXmlContentContainer container = cms.contentload("singleFile", uri, cms.getRequestContext().getLocale(), false);
            while (container.hasMoreResources()) {
                this.name = cms.contentshow(container, "SpeciesName");
                this.isPelagic = Boolean.valueOf(cms.contentshow(container, "Pelagic")).booleanValue();
                this.isCoastalBound = Boolean.valueOf(cms.contentshow(container, "CoastalBound")).booleanValue();
                this.isSurfaceBound = Boolean.valueOf(cms.contentshow(container, "SurfaceBound")).booleanValue();
                this.isDiving = Boolean.valueOf(cms.contentshow(container, "Diving")).booleanValue();
                this.isIceBound = Boolean.valueOf(cms.contentshow(container, "IceBound")).booleanValue();
                
                try {
                    I_CmsXmlContentContainer locationContainer = cms.contentloop(container, "DataLinks");
                    while (locationContainer.hasMoreResources()) {
                        String location = cms.contentshow(locationContainer, "Location");
                        I_CmsXmlContentContainer dataLinksContainer = cms.contentloop(locationContainer, "DataLink");
                        while (dataLinksContainer.hasMoreResources()) {
                            String dataLinkType = cms.contentshow(dataLinksContainer, "Type");
                            String dataLinkURL = cms.contentshow(dataLinksContainer, "URL");
                            String dataLinkNumYears = cms.contentshow(dataLinksContainer, "NumOfYears");
                            String dataLinkComment = cms.contentshow(dataLinksContainer, "Comment");
                            this.addDataLink(location, dataLinkType, dataLinkURL, dataLinkNumYears, CmsAgent.elementExists(dataLinkComment) ? dataLinkComment : null);
                        }
                    }
                } catch (Exception ee) {
                    
                }
            }
        } catch (Exception e) {
            
        }
    }
    public boolean isPelagic() { return isPelagic; }
    public boolean isCoastalBound() { return isCoastalBound; }
    public boolean isSurfaceBound() { return isSurfaceBound; }
    public boolean isDiving() { return isDiving; }
    public boolean isIceBound() { return isIceBound; }
    public String getVfsUri() { return uri; }
    //public String getSpeciesFileVfsUri() { return speciesFileUri; }
    
    public int getGroupNumber() {
        int i = -1;
        if (isPelagic()) {
            if (isDiving()) { 
                i = 0; 
                if (isSurfaceBound()) {
                    i = 1;
                }
            } else if (isSurfaceBound()) { 
                i = 2;
            } 
            
            if (isIceBound()) {
                i = 3;
            }
            if (isCoastalBound()) {
                i = 4;
            }
        } else {
            if (isSurfaceBound()) {
                i = 5; 
                if (isDiving()) {
                    i = 6;
                }
            } else if (isDiving()) {
                i = 7;
            }
        }
        
        return i;
    }
    
    public SpeciesData addDataLink(String location, String type, String url, String numYears, String comment) {
        this.dataLinks.add(new SpeciesDataLink(location, type, url, numYears, comment));
        return this;
    }
    public List<SpeciesDataLink> getDataLinksByLocation(String location) {
        List<SpeciesDataLink> tmp = new ArrayList<SpeciesDataLink>();
        Iterator<SpeciesDataLink> i = this.dataLinks.iterator();
        while (i.hasNext()) {
            SpeciesDataLink sdl = i.next();
            try {
                if (sdl.getLocation().equals(location)) {
                    tmp.add(sdl);
                }
            } catch (NullPointerException npe) {
                // missing location => ignore, and continue (or not)
            }
        }
        return tmp;
    }
    
    public List<String> getLocations() {
        List<String> tmp = new ArrayList<String>();
        Iterator<SpeciesDataLink> i = this.dataLinks.iterator();
        while (i.hasNext()) {
            SpeciesDataLink sdl = i.next();
            String location = sdl.getLocation();
            if (location != null && !tmp.contains(location)) {
                tmp.add(location);
            }
        }
        return tmp;
    }
    
    public List<SpeciesDataLink> getDataLinks() { return this.dataLinks; }
    public String getName() { return this.name; }
}

public class SpeciesDataCollection {
    // All locations
    private List<String> locations = null;
    // All bird species names, as Strings
    private List<String> names = null;
    // All data entries (one per bird species)
    private List<SpeciesData> data = null;
    
    public SpeciesDataCollection() {
        locations = new ArrayList<String>();
        names = new ArrayList<String>();
        data = new ArrayList<SpeciesData>();
    }
    
    public SpeciesDataCollection(String folder, CmsAgent cms) {
        this();
        try {
            CmsObject cmso = cms.getCmsObject();
            CmsResourceFilter dataFilesFilter = CmsResourceFilter.DEFAULT_FILES.addRequireType(OpenCms.getResourceManager().getResourceType("seapop_species_data").getTypeId());

            // Load data files
            List<CmsResource> ocmsDataFiles = cmso.readResources(folder, dataFilesFilter, false);
            Iterator<CmsResource> iOcmsDataFiles = ocmsDataFiles.iterator();
            while (iOcmsDataFiles.hasNext()) {
                SpeciesData speciesDataEntry = new SpeciesData(cmso.getSitePath(iOcmsDataFiles.next()), cms);
                this.add(speciesDataEntry);
                
            }            
        } catch (Exception e) {
            // ???
        }
        
        sortByGroup();
    }
    
    public String toHtmlTableRows(CmsAgent cms, String dataType) {
        List<String> comments = new ArrayList<String>();
        String s = "";
        Iterator<String> iLocations = locations.iterator();
        while (iLocations.hasNext()) {
            String location = iLocations.next();
            s += "<tr><th scope=\"row\">" + location + "</th>";
            Iterator<SpeciesData> iData= data.iterator();
            int[] sums = new int[] { 0, 0, 0, 0, 0 }; // TOTAL THIS ROW: Diet | Population | Reproduction | Survival | Combined
            while (iData.hasNext()) {
                SpeciesData speciesDataEntry = iData.next();
                
                List<SpeciesDataLink> dataForSpeciesOnLocation = speciesDataEntry.getDataLinksByLocation(location);
                s += "<td>";// + (dataType != null ? "" : " class=\"rel-data-type-".concat(getFirstLetter(dataType))).concat("\"") + ">"; 
                if (dataType == null) 
                    s += "<div>";
                if (dataForSpeciesOnLocation.size() > 0) {
                    
                    int counter = 0;
                    Iterator<SpeciesDataLink> iDataLink = dataForSpeciesOnLocation.iterator();
                    while (iDataLink.hasNext()) {
                        counter++;
                        SpeciesDataLink dataLink = iDataLink.next();
                        if (dataType == null || dataType.equals(dataLink.getType())) {
                            if (dataType != null)
                                s += "<div class=\"rel-data-type-".concat(dataLink.getTypeIdentifier()).concat("\"") + ">";
                            
                            sums[getTypes().indexOf(dataLink.getType())]++; // Increment relevant counter
                            sums[4]++; // Increment combined total
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
                            
                            s += "<a href=\"" + dataLink.getUrl() + "\""
                                    + " class=\"rel-data-type-" + dataLink.getTypeIdentifier() + (dataType == null ? " species-data-link" : "") + "\""
                                    + " title=\"" + speciesDataEntry.getName() +": " + dataLink.getTypeLabel(cms) + ", " + location + (dataLink.getNumYears().isEmpty() ? "" : " ("+dataLink.getNumYears()+")") + "\""
                                    + ">" + linkText + "</a>";
                            if (dataType != null)
                            s += "</div>";
                        }
                    }
                    
                } else {
                    s += "";
                }
                if (dataType == null)
                    s += "</div>";
                s += "</td>";
            }
            if (dataType == null) {
                for (int iSums = 0; iSums < sums.length; iSums++) {
                    String dataTypeIdLetter = "t"; // Default: total (t)
                    try { dataTypeIdLetter = getTypes().get(iSums).substring(0, 1).toLowerCase(); } catch (Exception e) {}
                    s += "<td class=\"rel-data-type-" + dataTypeIdLetter + "\"><span>" + sums[iSums] + "</span></td>";
                }
            } else {
                s += "<td class=\"rel-data-type-t\"><span>" + sums[getTypes().indexOf(dataType)] + "</span></td>";
            }
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
    
    /**
     * Adds a species data entry
     */
    public SpeciesDataCollection add(SpeciesData speciesDataEntry) {
        if (speciesDataEntry != null) {
            data.add(speciesDataEntry);
            updateNames(speciesDataEntry);
            updateLocations(speciesDataEntry);
        }
        return this;
    }
    /**
     * Updates list of all species names in this collection
     */
    protected void updateNames(SpeciesData speciesDataEntry) {
        if (!names.contains(speciesDataEntry.getName())) {
            names.add(speciesDataEntry.getName());
        }
    }
    /**
     * Update list of all locations in this collection
     */
    protected void updateLocations(SpeciesData speciesDataEntry) {
        Iterator<String> iEntryLocations = speciesDataEntry.getLocations().iterator();
        while (iEntryLocations.hasNext()) {
            String entryLocation = iEntryLocations.next();
            if (!locations.contains(entryLocation))
                locations.add(entryLocation);
        }
    }
    /**
     * Sorts all entries in this collection by its group number
     */
    public SpeciesDataCollection sortByGroup() {
        Comparator<SpeciesData> GROUP_NUMBER = new Comparator<SpeciesData>() {
            
            public int compare(SpeciesData o1, SpeciesData o2) {
                int diff = Integer.valueOf(o1.getGroupNumber()).compareTo(Integer.valueOf(o2.getGroupNumber()));
                if (diff == 0)
                    return o1.getName().compareTo(o2.getName());
                else
                    return diff;
            }
        };
        Collections.sort(data, GROUP_NUMBER);
        return this;
    }
    
    public List<SpeciesData> get() { return this.data; }
    
    public int size() { return data.size(); }
    
}
/*
public String getFirstLetter(String typeName) {
    if (typeName == null || typeName.trim().isEmpty())
        return "";
    return typeName.substring(0, 1).toLowerCase();
}*/

/**
 * Should be a static method of SpeciesDataLink
 */
public List<String> getTypes() { return Arrays.asList( new String[] { "Population", "Reproduction", "Survival", "Diet" } ); }

%><%
    CmsAgent cms = new CmsAgent(pageContext, request, response);
    CmsObject cmso = cms.getCmsObject();
    Locale locale = cms.getRequestContext().getLocale();
    String loc = locale.toString();
    String requestFileUri = cms.getRequestContext().getUri();
    
    final String dataFilesFolder = "/no/artsdata/";
    SpeciesDataCollection birdData = new SpeciesDataCollection(dataFilesFolder, cms);
    
%>
<!--<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Species data</title>
        
    </head>
    <body>-->
        <%
        /*out.println("<h1>Species data</h1>");
        out.println("<h2>" + data.size() + " data entries</h2>");
        
        Iterator<SpeciesData> iData = data.iterator();
        out.println("<ul>");
        while (iData.hasNext()) {
            SpeciesData sd = iData.next();
            out.println("<li>" 
                            + sd.getName() 
                            + "<br />" + sd.getLocations().toString()
                        + "</li>");
        }
        out.println("</ul>");*/
        %>
        
        
        
        
        
        
        
        <style type="text/css">
            .species-data-link-table {
                /*table-layout:fixed;*/
                max-width:100%;
                width:100%;
                font-size:1em; 
            }
            .species-data-link-table th, 
            .species-data-link-table td {
                text-align:center;
                background-color:#eee;
                padding:0;
                margin:0;
                border:none;
            }
            .species-data-link-table td {
                width:2em;
                max-width:2em;
            }
            .species-data-link-table .th-v th {
                width:2em;
                height:8em;
                vertical-align:top;
            }
            .species-data-link-table .th-v th span { 
                /*float:left;*/
                display:block;
                padding:1em 0;
                width:2em; 
                -ms-filter:"progid:DXImageTransform.Microsoft.BasicImage(rotation=1)"; /* 0=0, 1=90, 2=180, 3=270 */
                -webkit-transform:rotate(90deg);
                -moz-transform:rotate(90deg);
                -o-transform:rotate(90deg);
                -ms-transform:rotate(90deg);
                transform:rotate(90deg);
            }
            .species-data-link-table th[scope='row'] {
                width:8em;
                width:10%;
                text-align:right;
                padding:0 0.5em 0 0;
            }
            .species-data-link-table td div {
                width:100%;
                height:1.8em;
                position:relative;
            }
            td div .species-data-link {
                display:block;
                width:50%;
                height:0.9em;
                position:absolute;
            }
            td div .species-data-link-d,
            th.species-data-head-d,
            .rel-data-type-d,
            .rel-data-type-d a {
                background-color:red !important;
                background-color:#e00 !important;
                color:#fff;
                right:0;
                bottom:0;
            }
            td div .species-data-link-p,
            th.species-data-head-p,
            .rel-data-type-p,
            .rel-data-type-p a {
                background-color:yellow !important;
                background-color:#ff0 !important;
                left:0;
                top:0;
                color:#333;
            }
            td div .species-data-link-r,
            th.species-data-head-r,
            .rel-data-type-r,
            .rel-data-type-r a {
                background-color:lightgreen !important;
                background-color:#92D050 !important;
                right:0;
                top:0;
                color:#333;
            }
            td div .species-data-link-s,
            th.species-data-head-s,
            .rel-data-type-s,
            .rel-data-type-s a {
                background-color:lightblue !important;
                background-color:#9cf !important;
                left:0;
                bottom:0;
                color:#333;
            }
            
        </style>
        
        <div class="paragraph">
            <table class="species-data-link-table">
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
                    Iterator<SpeciesData> iSpeciesDataEntries = birdData.get().iterator();
                    while (iSpeciesDataEntries.hasNext()) {
                        out.println("<th scope=\"col\"><span>" + iSpeciesDataEntries.next().getName() + "</span></th>");
                    }
                    %>

                    <%
                    List<String> dataTypes = getTypes();
                    Iterator<String> iDataTypes = dataTypes.iterator();
                    while (iDataTypes.hasNext()) {
                        String dataType = iDataTypes.next();
                        String dataTypeLabel = cms.labelUnicode("label.seapop-species-data.category.".concat(dataType.toLowerCase()));
                        out.println("<th class=\"species-data-head-" + dataType.substring(0, 1).toLowerCase() + "\"><span>" + dataTypeLabel + "</span></th>");
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
                out.println(birdData.toHtmlTableRows(cms, null));
                %>
            <!--</table>-->
        </div>
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        <div class="paragraph">
            <h2>Bestand</h2>
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
                    iSpeciesDataEntries = birdData.get().iterator();
                    while (iSpeciesDataEntries.hasNext()) {
                        out.println("<th scope=\"col\"><span>" + iSpeciesDataEntries.next().getName() + "</span></th>");
                    }
                    %>
                    <th scope="col"><span><%= cms.labelUnicode("label.seapop-species-data.number-of-series.short") %></span></th>
                </tr>

                <% 
                out.println(birdData.toHtmlTableRows(cms, "Population"));
                %>
        </div>
        <div class="paragraph">
            <h2>Diett</h2>
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
                    iSpeciesDataEntries = birdData.get().iterator();
                    while (iSpeciesDataEntries.hasNext()) {
                        out.println("<th scope=\"col\"><span>" + iSpeciesDataEntries.next().getName() + "</span></th>");
                    }
                    %>
                    <th scope="col"><span><%= cms.labelUnicode("label.seapop-species-data.number-of-series.short") %></span></th>
                </tr>

                <% 
                out.println(birdData.toHtmlTableRows(cms, "Diet"));
                %>
        </div>
        <div class="paragraph">
            <h2>Overlevelse</h2>
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
                    iSpeciesDataEntries = birdData.get().iterator();
                    while (iSpeciesDataEntries.hasNext()) {
                        out.println("<th scope=\"col\"><span>" + iSpeciesDataEntries.next().getName() + "</span></th>");
                    }
                    %>
                    <th scope="col"><span><%= cms.labelUnicode("label.seapop-species-data.number-of-series.short") %></span></th>
                </tr>

                <% 
                out.println(birdData.toHtmlTableRows(cms, "Survival"));
                %>
        </div>
        <div class="paragraph">
            <h2>Reproduksjon</h2>
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
                    iSpeciesDataEntries = birdData.get().iterator();
                    while (iSpeciesDataEntries.hasNext()) {
                        out.println("<th scope=\"col\"><span>" + iSpeciesDataEntries.next().getName() + "</span></th>");
                    }
                    %>
                    <th scope="col"><span><%= cms.labelUnicode("label.seapop-species-data.number-of-series.short") %></span></th>
                </tr>

                <%
                out.println(birdData.toHtmlTableRows(cms, "Reproduction"));
                %>
        </div>
        
        
    <!--</body>
</html>-->

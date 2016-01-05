<%-- 
    Document   : list-species-general-links
    Created on : Jan 4, 2016, 4:14:43 PM
    Author     : Paul-Inge Flakstad, Norwegian Polar Institute <flakstad at npolar.no>
--%><%@page contentType="text/html" pageEncoding="UTF-8" 
%><%@page import="java.util.Locale,
                java.util.Arrays,
                java.util.Collections,
                java.util.Comparator,
                java.util.Map,
                java.util.HashMap,
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
 * Creates a list item that holds a link, if the URI is considered valid.
 */
public String toListItemLink(CmsAgent cms, String uri, String text, String liClass) {
    if (CmsAgent.elementExists(uri)) {
        boolean ninaLink = uri.contains("//www2.nina.no/");
        return "<li" + (liClass != null ? (" " + liClass) : "") + ">"
                + "<a href=\"" + cms.link(uri).replaceAll("\\&", "&amp;") + "\""
                    + (ninaLink ? " target=\"_blank\"" : "")
                + ">" + text + "</a></li>";
    }
    return "";
}

/**
 * Adds a link as a list item to the given list, if the URI is considered valid.
 */
public List addValid(List<String> list, CmsAgent cms, String uri, String text, String liClass) {
    String li = toListItemLink(cms, uri, text, liClass);
    if (li != null && !li.isEmpty()) {
        list.add(li);
    }
    return list;
}
%><%
CmsAgent cms = new CmsAgent(pageContext, request, response);
CmsObject cmso = cms.getCmsObject();
Locale locale = cms.getRequestContext().getLocale();
String loc = locale.toString();
String requestFileUri = cms.getRequestContext().getUri();

final int RESOURCE_TYPE_ID = OpenCms.getResourceManager().getResourceType("seapop_species_data").getTypeId();
final String COLLECTOR = "allInFolderPriorityTitleDesc";
final String FOLDER = "/no/artsdata/";
final String LABEL_PREFIX = "label.seapop-general.";

I_CmsXmlContentContainer filesContainer = cms.contentload(COLLECTOR, FOLDER.concat("|").concat(Integer.toString(RESOURCE_TYPE_ID)), false);

if (!filesContainer.getCollectorResult().isEmpty()) {
    %>
    <div class="paragraph">
    <ul class="blocklist">
    <%
    while (filesContainer.hasMoreResources()) {
        String filePath = cms.contentshow(filesContainer, "%(opencms.filename)");
        I_CmsXmlContentContainer singleFile = cms.contentload("singleFile", filePath, false);

        while (singleFile.hasMoreResources()) {
            String title = cms.contentshow(singleFile, "SpeciesName");

        %>
        <li class="toggleable collapsed">
            <h2 class="toggletrigger"><%= title %></h2>
            <div class="toggletarget">
                <ul>
        <%

            I_CmsXmlContentContainer generalLinks = cms.contentloop(singleFile, "GeneralLinks");
            while (generalLinks.hasMoreResources()) {
                List<String> listItems = new ArrayList<String>();

                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "Description/URL"), cms.labelUnicode(LABEL_PREFIX.concat("description")), null);
                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "WinterDistribution/URL"), cms.labelUnicode(LABEL_PREFIX.concat("winter-distribution")), null);
                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "MoultingDistribution/URL"), cms.labelUnicode(LABEL_PREFIX.concat("moulting-distribution")), null);
                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "NestingDistribution/URL"), cms.labelUnicode(LABEL_PREFIX.concat("nesting-distribution")), null);
                if (!listItems.isEmpty()) {
                    Iterator<String> i = listItems.iterator();
                    while (i.hasNext()) {
                        out.println(i.next());
                    }
                }
                listItems.clear();

                // Done with group, continue to next

                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "PopulationDevelopment/URL"), cms.labelUnicode(LABEL_PREFIX.concat("population-development")), null);
                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "BreedingSuccess/URL"), cms.labelUnicode(LABEL_PREFIX.concat("breeding-success")), null);
                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "Survival/URL"), cms.labelUnicode(LABEL_PREFIX.concat("survival")), null);
                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "Diet/URL"), cms.labelUnicode(LABEL_PREFIX.concat("diet")), null);
                listItems = addValid(listItems, cms, cms.contentshow(generalLinks, "Phenology/URL"), cms.labelUnicode(LABEL_PREFIX.concat("phenology")), null);
                if (!listItems.isEmpty()) {
                    %>
                    <li>
                        <h3><%= cms.labelUnicode(LABEL_PREFIX.concat("time-series-data")) %></h3>
                        <ul>
                            <%
                            Iterator<String> i = listItems.iterator();
                            while (i.hasNext()) {
                                out.println(i.next());
                            }
                            %>
                        </ul>
                    </li>
                    <%
                }
                listItems.clear();
            }
        }
        %>
                </ul>
            </div>
        </li>
        <%
    }
    %>
    </ul>
    </div>
    <%
}
%>
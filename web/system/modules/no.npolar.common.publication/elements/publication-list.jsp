<%-- 
    Document   : publication.jsp
    Created on : 09.apr.2009, 13:22:35
    Author     : Paul-Inge Flakstad
--%>

<%@ page import="no.npolar.util.*" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.opencms.jsp.*, org.opencms.file.*, org.opencms.file.types.*, org.opencms.xml.content.*"%>
<%@ page import="org.opencms.main.*" %>
<%@ page session="true" %>

<%
// Create a JSP action element, and useful URIs
CmsAgent cms = new CmsAgent(pageContext, request, response);
String resourceUri = cms.getRequestContext().getUri();
String folderUri = cms.getRequestContext().getFolderUri();
Locale locale = cms.getRequestContext().getLocale();
String loc = locale.toString();

String folderToList = request.getParameter("folder");
if (folderToList == null) {
    folderToList = cms.property("template-search-folder");
}

if (folderToList == null) {
    throw new NullPointerException("No folder assigned.");
}

boolean listSubTree = false; // Default value
try {
   listSubTree = Boolean.valueOf(request.getParameter("subtree")).booleanValue();
} catch (Exception e) {
   // Maintain default value
}
int limit = -1; // Default value
try {
   limit = Integer.valueOf(request.getParameter("limit")).intValue();
} catch (Exception e) {
   // Maintain default value
}

final int TYPE_ID = OpenCms.getResourceManager().getResourceType("publication").getTypeId();//"318", publication file type ID

if (cms.template("simple")) {
    I_CmsXmlContentContainer structuredContentFile, contentList; // Containers
    String principalAuthor, title, year, url, journal, journalUrl, vol, pages, state, publishDate; // String variables corresponding to XSD elements
    ArrayList coAuthors = new ArrayList();

    //
    // Process structured content file
    //
    String collector = "allIn".concat(listSubTree? "SubTree" : "Folder").concat("PriorityDateDesc");
    structuredContentFile = cms.contentload(collector, //"allInFolderPriorityDateDesc", 
            folderToList.concat("|").concat(Integer.toString(TYPE_ID).concat(limit > -1 ? ("|"+limit) : "")), false);
    
    if (structuredContentFile != null) {
        out.println("<ul class=\"publications\">");

        while (structuredContentFile.hasMoreContent()) {
            title = cms.contentshow(structuredContentFile, "Title");
            year = cms.contentshow(structuredContentFile, "Year");
            principalAuthor = cms.contentshow(structuredContentFile, "PrincipalAuthor");
            
            contentList = cms.contentloop(structuredContentFile, "CoAuthor");
            coAuthors.clear();
            while (contentList.hasMoreContent()) {
                coAuthors.add(cms.contentshow(contentList));
            }
            
            url = cms.contentshow(structuredContentFile, "Url");
            journal = cms.contentshow(structuredContentFile, "Journal");
            journalUrl = cms.contentshow(structuredContentFile, "JournalUrl");
            vol = cms.contentshow(structuredContentFile, "Volume");
            pages = cms.contentshow(structuredContentFile, "Pages");
            state = cms.contentshow(structuredContentFile, "PublishState");
            publishDate = cms.contentshow(structuredContentFile, "Published");


            out.println("<li class=\"publication\">" + 
                        //(cms.elementExists(url) ? "<a href=\"" + url + "\">" : "") +
                        "<a href=\"" + (cms.elementExists(url) ? url : cms.link(cms.contentshow(structuredContentFile, "%(opencms.filename)"))) + "\">" + 
                        title + 
                        (cms.elementExists(url) ? "</a>" : "") +
                        "</li>");
        }
        out.println("</ul>");
    }
}
%>
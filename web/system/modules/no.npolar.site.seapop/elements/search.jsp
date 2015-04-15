<%@ page buffer="none" import="org.opencms.main.*, org.opencms.search.*, org.opencms.file.*, org.opencms.jsp.*, java.util.*, java.util.Locale" %>
<%   
    // Create a JSP action element
    org.opencms.jsp.CmsJspActionElement cms = new CmsJspActionElement(pageContext, request, response);
	String resourceUri = cms.getRequestContext().getUri();
	String folderUri = cms.getRequestContext().getFolderUri();
	String microSiteRoot;
        
        final String NO_INDEX_NAME = "SEAPOP_no";
        final String EN_INDEX_NAME = "SEAPOP_en";
        
	try {
            // e.g.: evaluates to "/cruise" when the url is "http://christer.npolar.no/cruise/en/svalbard/index.html"
            microSiteRoot = folderUri.substring(0, folderUri.indexOf("/", 1)); 
	}
	catch (Exception e) {
            microSiteRoot = cms.getRequestContext().getFolderUri();
	}
	Locale locale = cms.getRequestContext().getLocale();
	String loc = locale.toString();
    
    // Get the search manager
    CmsSearchManager searchManager = OpenCms.getSearchManager(); 
    
    //
    // Set the index
    //
    String indexName = null;
    // Try to retrieve the index name from file property
    indexName = cms.property("search.index", "search");
    // If the index name was not set as a property, set default value
    if (indexName == null) {
        // default index names (these may not exist -> exception will be caught in searchresult.jsp)
        indexName = loc.equalsIgnoreCase("no") ? NO_INDEX_NAME : EN_INDEX_NAME; 
    }
    
    // The target of the search form (the page that the form calls on submit)
    String formTarget = "/" + loc + "/searchresult.html";
    // This file must exist so give the user an error page if it hasn't yet been created
    if (!cms.getCmsObject().existsResource(formTarget))
        throw new NullPointerException("The search form result page '" + formTarget + 
                "' does not exist. It needs to be created in order for search to work.<br/>microSiteRoot='" + microSiteRoot + "'<br />folderUri='" + folderUri + "'.");
%>

<jsp:useBean id="search" scope="request" class="org.opencms.search.CmsSearch">
    <jsp:setProperty name="search" property="*"/>
    <% search.init(cms.getCmsObject()); %>
</jsp:useBean>

<form method="post" action="<%= cms.link(formTarget) %>">
<!--  query and index are obligatory fields, used by the CmsSearch bean -->
<input type="text" class="searchbox" name="query" value="<%=(cms.property("query") != null) ? cms.property("query") : ""%>">
<!--  tester for å sette index her... -->
<input type="hidden" name="index" value="<%= indexName %>">
<input type="submit" class="searchsubmit" value="<%= loc.equalsIgnoreCase("no") ? "S&oslash;k" : "Search" %>">
</form>
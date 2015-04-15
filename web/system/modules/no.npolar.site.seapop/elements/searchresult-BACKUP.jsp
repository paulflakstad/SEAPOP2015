<%@ page buffer="none" import="org.opencms.main.*, org.opencms.search.*, org.opencms.search.fields.*, org.opencms.file.*, org.opencms.jsp.*, java.util.*" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%    
    // Create a JSP action element
    org.opencms.jsp.CmsJspActionElement cms = new CmsJspActionElement(pageContext, request, response);
    
    // Get the search manager
    CmsSearchManager searchManager = OpenCms.getSearchManager(); 
    String resourceUri = cms.getRequestContext().getUri();
    String folderUri = cms.getRequestContext().getFolderUri();
    Locale locale = cms.getRequestContext().getLocale();
    String loc = locale.toString();
%>

<jsp:useBean id="search" scope="request" class="org.opencms.search.CmsSearch">
    <jsp:setProperty name="search" property="matchesPerPage" param="matchesperpage"/>
    <jsp:setProperty name="search" property="displayPages" param="displaypages"/>
    <jsp:setProperty name="search" property="*"/>
    <% 
    		search.init(cms.getCmsObject()); 		
    %>
</jsp:useBean>
<%
//HTML LAYOUT
cms.include("../templates/seapop.jsp", "header");
%>
<h1><%= (loc.equalsIgnoreCase("no") ? "S&oslash;keresultat" : "Search result") %></h1>
<div class="content-body">
<% 
//Enumeration headerNames = request.getHeaderNames();
//while (headerNames.hasMoreElements())
//	out.println(headerNames.nextElement().toString());
%>

<%
	int resultno = 1;
	int pageno = 0;
	if (request.getParameter("searchPage") != null) {		
		pageno = Integer.parseInt(request.getParameter("searchPage")) - 1;
	}
	resultno = (pageno * search.getMatchesPerPage()) + 1;
	
	//String fields = search.getFields();
	String fields = "title content";
   if (fields == null) {
   	fields = request.getParameter("fields");
   }

   List result = null;
   try {
   	result = search.getSearchResult();
   }
   catch (java.lang.NullPointerException npe) {
	out.println("<h3>Script crashed!</h3>A null pointer was encountered while attempting to process the search results. The cause may be an invalid or missing search index.<br>&nbsp;<br> Please notify the system administrator.</h3>");
	StackTraceElement[] npeStack = npe.getStackTrace();
	if (npeStack.length > 0) {
		out.println("<h4>Stack trace:</h4>"); //npe.printStackTrace(response.getWriter());
		out.println("<span style=\"display:block; width:auto; overflow:scroll; font-style:italic; color:red; border:1px dotted #555555; background-color:#DEDEDE; padding:5px;\">");
		out.println("java.lang.NullPointerException:<br>");
            	for (int i = 0; i < npeStack.length; i++) {
                	out.println(npeStack[i].toString());
            	}
        	out.println("</span>");
        }
   }
	// DEBUG:
	/*
	out.println("<h4>Fields: " + fields + "</h4>");
	out.println("<h4>Resultno: " + resultno + "</h4>");
	out.println("<h4>Pageno: " + pageno + "</h4>");
	out.println("<h4>Result (List): " + result + "</h4>");
	*/
	
    if (result == null) {
    %>
    <%
        if (search.getLastException() != null) { 
            out.println("<h3>Error</h3>" + search.getLastException().toString());
        }
    } 
    else {
        ListIterator iterator = result.listIterator();
        %>
        <h3><%= search.getSearchResultCount() %><%= (loc.equalsIgnoreCase("no") ? 
        " resultater for s&oslash;keord " : " results found for query ")%><i><%= search.getQuery()%></i></h3>
        <%
        while (iterator.hasNext()) {
            CmsSearchResult entry = (CmsSearchResult)iterator.next();
            String entryPath = cms.link(cms.getRequestContext().removeSiteRoot(entry.getPath()));
            %>
            <!--<span style="display:block; width:100%; clear:both; font-size:12px; font-weight:bold; padding-bottom:5px; padding-top:10px;">-->
                <h3 class="searchHitTitle" style="padding:1em 0 0.2em 0; margin:0;">
                    <a href="<%= entryPath %>"><%= entry.getField(CmsSearchField.FIELD_TITLE) %></a>&nbsp;(<%= entry.getScore() %>%)
                </h3>
            <!--</span>
            <span style="display:block; width:100%; clear:both; font-size:12px; font-weight:normal; padding-bottom:5px;">-->
                <div class="text">
                    <%= entry.getExcerpt() %>
                </div>
            <!--</span>
            <span style="display:block; width:100%; clear:both; font-size:10px; font-weight:normal; color:green; padding-bottom:15px;">-->
                <div class="search-hit-path" style="font-size:0.7em; color:green;">
                    <%= "http://" + request.getServerName() + entryPath %>
                </div>
            <!--</span>-->
				
            <%
            resultno++;            
        }
    }
%> 
        <div class="pagination" style="margin-top:2em;">
<%
        
	if (search.getPreviousUrl() != null) {
%>
		<input type="button" value="&lt;&lt; <%= (loc.equalsIgnoreCase("no") ? "forrige" : "previous") %>" onclick="location.href='<%= cms.link(search.getPreviousUrl()) %>&fields=<%= fields %>';">
<%
	}
	Map pageLinks = search.getPageLinks();
	Iterator i =  pageLinks.keySet().iterator();
	while (i.hasNext()) {
		int pageNumber = ((Integer)i.next()).intValue();
		String pageLink = cms.link((String)pageLinks.get(new Integer(pageNumber)));       		
		out.print("&nbsp; &nbsp;");
		if (pageNumber != search.getSearchPage()) {
%>
			<a href="<%= pageLink %>&fields=<%= fields %>"><%= pageNumber %></a>
<%
		} else {
%>
			<span class="currentpage"><%= pageNumber %></span>
<%
		}
	}
	if (search.getNextUrl() != null) {
%>
		&nbsp; &nbsp;<input type="button" value="<%= (loc.equalsIgnoreCase("no") ? "neste" : "next") %> &gt;&gt;" onclick="location.href='<%= cms.link(search.getNextUrl()) %>&fields=<%= fields %>';">
<%
	} 
%>  
        </div>
</div>
<cms:include file="../templates/seapop.jsp" element="footer" />
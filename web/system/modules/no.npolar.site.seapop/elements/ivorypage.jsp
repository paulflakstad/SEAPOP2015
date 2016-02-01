<%@ page import="no.npolar.util.*" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.opencms.jsp.*, org.opencms.file.*, org.opencms.file.types.*, org.opencms.xml.content.*"%>
<%@ page import="org.opencms.main.*,
                 org.opencms.util.CmsRequestUtil,
                 org.opencms.loader.CmsImageScaler" %>
<%@ page session="true" %>

<%!
/**
*Generates HTML code for a wrapped image, where the wrappers make up a frame around the image.
*@param imageTag String  The normal <img> tag code.
*@param imageText String  The image description / text.
*@param imageSource String  The image source or reference.
*@param small boolean  True if the HTML should create a splitting div at the end.
*@return String The generated HTML code.
*/
public String getImageFrameHTML(String imageTag, String imageText, String imageSource, String width) {
    String imageFrameHTML = "<span class=\"image\" style=\"width:" + width + "px;\"" + ">" + 
                                imageTag + /*"</span><!-- END image -->\n\t" + */
                                "<span class=\"imageinfo\">\n\t" + 
                                    "<span class=\"imagetext\">" + imageText + "</span><!-- END imagetext -->\n\t\t" + 
                                    "<span class=\"imagesource\">" + imageSource + "</span><!-- END imagesource -->\n\t\t" + 
                                "</span><!-- END imageinfo -->\n\t" + 
                            "</span><!-- END image -->\n";
    return imageFrameHTML;
}

public String getImageContainer(String imageTag, int width, String imageCaption, String imageCredit, String creditLabel) {
    String imageContainer = "<span class=\"illustration\" style=\"width:" + Integer.toString(width) + "px;\">" +
                                imageTag + 
                            (CmsAgent.elementExists(imageCaption) || CmsAgent.elementExists(imageCredit) ?
                                "<span class=\"imagetext highslide-caption\">" : "") + 
                                (CmsAgent.elementExists(imageCaption) ?
                                    imageCaption : "") +
                                (CmsAgent.elementExists(imageCredit) ?
                                    ("<span class=\"imagecredit\">" + 
                                        (CmsAgent.elementExists(creditLabel) ? creditLabel : "") +
                                        imageCredit + 
                                     "</span>") : "") +
                            (CmsAgent.elementExists(imageCaption) || CmsAgent.elementExists(imageCredit) ?
                                "</span>" : "") +
                            "</span>";

    return imageContainer;
}

public String getProfilePath(String name) {
    String path = "/profiles/" + name.toLowerCase().replaceAll(" ", ".").replaceAll("æ", "a").replaceAll("ø", "o").replaceAll("å", "a");
    return path;
}
%>

<%
// Create a JSP action element, and get the URI of the requesting file (the one that includes this menu)
//CmsJspXmlContentBean cms = new CmsJspXmlContentBean(pageContext, request, response);
CmsAgent cms = new CmsAgent(pageContext, request, response);

//org.opencms.file.CmsRequestContext requestContext = cms.getRequestContext();
String requestFileUri = cms.getRequestContext().getUri();
String requestFolderUri = cms.getRequestContext().getFolderUri();
Locale locale = cms.getRequestContext().getLocale();
String loc = locale.toString();
// Template:
String template = cms.getTemplate();
String[] elements = cms.getTemplateIncludeElements();

final String PARAGRAPH_HANDLER = "/system/modules/no.npolar.common.pageelements/elements/paragraphhandler.jsp";

String normalFolder     = "thumbs/";
String largeFolder      = "large/";
String smallFolder      = "small/";

String[] imageFields    = {"Title", "Text", "Source", "URI"};

String galleryPath      = null;
String byline           = null;
String author           = null;

String thumbnailFolder  = null;
String imagePath        = null;
String imageName        = null;
String imageTag         = null;
String imageLink        = null;
String imageText        = null;
String imageTitle       = null;
String imageSource      = null;
String imageSizeValue   = null;
ArrayList images        = new ArrayList(); 
//StringMap imageData     = new StringMap(); // image title, text, source and URI
ArrayList imageHTML     = new ArrayList();

CmsImageProcessor imgPro= new CmsImageProcessor();
imgPro.setType(3);
imgPro.setQuality(99);

int[] imageDimensions   = null;
int imageWidth          = -1;
int imageHeight         = -1;


final int IMG_WIDTH_S   = Integer.parseInt(cms.getCmsObject().readPropertyObject(requestFileUri, "image.size.s", true).getValue("140"));
final int IMG_WIDTH_M   = Integer.parseInt(cms.getCmsObject().readPropertyObject(requestFileUri, "image.size.m", true).getValue("300"));
final int IMG_WIDTH_L   = Integer.parseInt(cms.getCmsObject().readPropertyObject(requestFileUri, "image.size.l", true).getValue("300"));
final int IMG_WIDTH_XL  = Integer.parseInt(cms.getCmsObject().readPropertyObject(requestFileUri, "image.size.xl", true).getValue("630"));


int i                   = 0;
int[] imageSize         = null;

final int MAX_IMAGEWIDTH= 675;  // Maximum allowed image width (large images)
final boolean DEBUG     = false;    // Set to true to print out debugging data

/* MOVE TO workplace.properties */
final String IMAGE      = loc.equalsIgnoreCase("en") ? "Image" : "Bilde";

I_CmsXmlContentContainer container, paragraphs, imageContainer; // Containers
String pageTitle, pageIntro, title, text, topWidget, illustrationFrame; // String variables

// Include-file
String includeFile      = cms.property("template-include-file");
boolean wrapInclude     = cms.property("template-include-file-wrap") != null ? (cms.property("template-include-file-wrap").equalsIgnoreCase("outside") ? false : true) : true;
boolean titleHidden     = Boolean.valueOf(cms.property("Title.hidden")); // Hide title on-screen?


// 
// Include upper part of main template
//
cms.include(template, elements[0], true);
//out.println("<div id=\"content\">");

// 
// Get file creation and last modification info
//
CmsResource reqFile = cms.getCmsObject().readResource(cms.getRequestContext().getUri());
//out.println(org.opencms.util.CmsDateUtil.getDateTimeShort(reqFile.getDateLastModified()));
//out.println(org.opencms.util.CmsDateUtil.getDateShort(cms.getCmsObject().readResource(cms.getRequestContext().getUri()).getDateLastModified()));

Date m = new Date(); // Create dates (representing the moment in time they are created. These objects are changed below.)
Date c = new Date();
long lastMod = (long)cms.getCmsObject().readResource(cms.getRequestContext().getUri()).getDateLastModified(); // Get the float value of the timestamp
long created = (long)cms.getCmsObject().readResource(cms.getRequestContext().getUri()).getDateCreated();
org.opencms.util.CmsUUID creator = reqFile.getUserCreated(); // Get the user who created the file
org.opencms.util.CmsUUID modUser = reqFile.getUserLastModified(); // Get the user who modified the file
String creatorName = cms.getCmsObject().readUser(creator).getFirstname();
creatorName += " ".concat(cms.getCmsObject().readUser(creator).getLastname());
String modifierName = cms.getCmsObject().readUser(modUser).getFirstname(); // Get the user's login name
modifierName += " ".concat(cms.getCmsObject().readUser(modUser).getLastname());
m.setTime(lastMod); // Change the date object so that it represents the time kept in "timestamp"
c.setTime(created);
SimpleDateFormat dFormat = new SimpleDateFormat("dd.MM.yyyy"); // Create the desired output format

/*
try {
    boolean modifiedAfterCreated = !dFormat.format(c).equals(dFormat.format(m));
    byline = "<div class=\"byline\">By " + creatorName + " &ndash; " + dFormat.format(c);
    if (modifiedAfterCreated)
        byline += (", last modified " + dFormat.format(m) + " by " + modifierName);
    byline += ("</div>");
}
catch (Exception e) {
    e.printStackTrace();
    throw new ServletException("An error was encountered while trying to process the date-time. Please check the format and correct the text, or use the calendar function to insert a date directly. If the problem persists, please contact your system administrator.");
}
*/
           
container = cms.contentload("singleFile", "${opencms.uri}", false);
while (container.hasMoreContent()) {
    pageTitle = cms.contentshow(container, "PageTitle");
    pageIntro = cms.contentshow(container, "Intro");
    author = cms.contentshow(container, "ByLine");
    
    topWidget = cms.contentshow(container, "TopWidget");
    
    if (!CmsAgent.elementExists(author))
        author = cms.getCmsObject().readPropertyObject(requestFileUri, "Author", true).getValue();
    
    if (author != null) {
        String[] authorList = author.split(",");
        String profilePath = null;
        // Multiple authors in a comma-separated list
        if (authorList.length > 0) {
            author = "";
            for (int j = 0; j < authorList.length; j++) {
                authorList[j] = authorList[j].trim();
                profilePath = getProfilePath(authorList[j]);
                if (cms.getCmsObject().existsResource(profilePath)) {
                    authorList[j] = "<a href=\"" + profilePath + "\">" + authorList[j] + "</a>";
                }
                author += authorList[j];
                if (j+1 < authorList.length)
                    author += ", ";
            }
        }
        // Single author
        else {
            profilePath = getProfilePath(author);
            author = "<a href=\"" + profilePath + "\">" + author + "</a>";
        }
        // ToDo: REPLACE HARD CODED LABELS WITH WORKPLACE.PROPERTIES VALUES
        byline = "Av" + " " + author + " &ndash; " + "sist endret" + " " + dFormat.format(m);
    }
    //
    // HTML OUTPUT
    //
    out.println("<div class=\"main-content\">");
    out.println(CmsAgent.elementExists(pageTitle) ? ("<h1" + (titleHidden ? " class=\"hidden\"" : "") + ">" + pageTitle + "</h1>") : "");
    out.println("<div class=\"byline\">" + (byline != null ? byline : "") + "</div>");
        
    // Code below based on similar routine in portalpage template
    if (CmsAgent.elementExists(topWidget)) {
        topWidget += (topWidget.contains("?") ? "&" : "?") + "dynamic_container=ivorypage_widget_top";
        String topWidgetPath = topWidget.split("\\?")[0];
        String topWidgetParams = topWidget.split("\\?")[1];
        try {
            cms.includeAny(topWidgetPath, null, CmsRequestUtil.createParameterMap(topWidgetParams));
        } catch (Exception ee) {
            out.println("<!-- Failed to include dynamic content '" + topWidget + "' with includeAny(), error was: " + ee.getMessage() + " -->");
            cms.include(topWidgetPath, null, CmsRequestUtil.createParameterMap(topWidgetParams));
        }
    }
        
    if (CmsAgent.elementExists(pageIntro))
        out.println("<div class=\"ingress\">" + pageIntro + "</div>");
    
    
    //
    // Paragraphs, handled by a separate file
    //
    cms.include(PARAGRAPH_HANDLER);
    
    
    
    // NEW INCLUDE PROCEDURE
    // If the include file should NOT be wrapped inside the "content-body" div
    if (!wrapInclude) 
        out.println("</div><!-- END #main-content -->");  
    
    //
    // Include file from property "template-include-file"
    //
    if (includeFile != null) { // This means that the property template-include-file has a value
        // If the included file is a JSP, include it directly
        if (cms.getCmsObject().readResource(includeFile).getTypeId() == OpenCms.getResourceManager().getResourceType("jsp").getTypeId()) {
            //out.print("Include-file was <em>jsp</em>");
            cms.include(includeFile);
        }
        // If the included file is NOT a JSP, check the included file's "template-elements" property. Then, include that
        // JSP with a parameter "resourceUri" that is the file itself (typically a HTML file). The parameter "resourceUri"
        // will then act in place of the usual CmsJspActionElement.getRequestContext().getUri() - but this solution requires
        // that the "template-elements" JSP actually checks for the parameter. There is no auto-check on the parameter from
        // on behalf of OpenCms.
        else {// (cms.getCmsObject().readResource(includeFile).getTypeId() == OpenCms.getResourceManager().getResourceType("np_form").getTypeId()) {
            //out.print("Include-file was <em>NOT jsp</em> - resolving template-elements property for include-file...<br />");
            String tempElem = cms.getCmsObject().readPropertyObject(includeFile, "template-elements", true).getValue();
            HashMap parameters = new HashMap(); // request.getParameterMap();
            parameters.put("resourceUri", includeFile);
            cms.include(tempElem, "main", parameters);
        }
    }
    
    // If the include should be wrapped inside the "content-body" div
    if (wrapInclude)
        out.println("</div><!-- #main-content (or script div) -->");
     
} // While container.hasMoreContent()

// 
// Include lower part of main template
//
cms.include(template, elements[1], true);
%>

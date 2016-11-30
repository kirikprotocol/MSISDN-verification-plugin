<%@ page import="mobi.eyeline.utils.restclient.web.RestClient" %>
<%@ page import="mobi.eyeline.utils.restclient.web.RestClientException" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page contentType="application/xml; charset=UTF-8" language="java" %>

<%!

  static final String API_ROOT = "http://localhost:11201/wstorage/v2";

  private final Logger log = Logger.getLogger("error-handler");

  private boolean isDeveloperModeEnabled(String wnumber, String serviceId) {
    try {
      final String safeSid = serviceId.replace(".", "_");

      final String value = new RestClient()
          .json(API_ROOT + "/profile/" + wnumber + "/" + "services.dev-mode-" + safeSid)
          .object()
          .getString("value");

      return "true".equals(value);

    } catch (RestClientException.HttpRequestFailedException e) {
      if (e.getCode() == 404)
        return false;

      log.warn("Failed checking devmode: userId = [" + wnumber + "], serviceId = [" + serviceId + "]", e);
      return false;

    } catch (Exception e) {
      log.warn("Failed checking devmode: userId = [" + wnumber + "], serviceId = [" + serviceId + "]", e);
      return false;
    }
  }

  public static String toString(Map<String, String[]> map) {
    final StringBuilder result = new StringBuilder();

    result.append("{");
    for (Iterator<Map.Entry<String, String[]>> iterator = map.entrySet().iterator(); iterator.hasNext(); ) {
      final Map.Entry<String, String[]> entry = iterator.next();
      result
          .append("\"")
          .append(entry.getKey())
          .append("\"=")
          .append(Arrays.toString(entry.getValue()));
      if (iterator.hasNext()) {
        result.append(", ");
      }
    }
    result.append("}");

    return result.toString();
  }



  //
  //  Locales.
  //

  private static final String BUNDLE_BASE = "error_page";


  public static String _(String key, String lang) {
    if (lang == null) {
      lang = "ru";
    }

    final Locale expectedLocale = new Locale(lang);
    ResourceBundle rb =
        ResourceBundle.getBundle("/" + BUNDLE_BASE, expectedLocale);

    if (!rb.getLocale().equals(expectedLocale)) {
      // Falls back to system locale -> replace with default one
      rb = ResourceBundle.getBundle("/" + BUNDLE_BASE, new Locale("en"));
    }

    return new String(
        rb.getString(key).getBytes(StandardCharsets.ISO_8859_1),
        StandardCharsets.UTF_8);
  }

  public static String _(String key, HttpServletRequest req) {
    return _(key, req.getParameter("lang"));
  }
%>

<%

  final String userId = request.getParameter("user_id");

  request.setAttribute("error.message.code", "error.message");

  final String message = request.getParameter("error");
  if (message != null) {
    log.warn(message);

    try {
      final JSONObject obj = new JSONObject(message);

      final String startPage = obj.optString("service_start_page");
      if (startPage != null) {
        request.setAttribute("startPage", startPage);
      }

      final String serviceId = obj.optString("service");

      final boolean devMode = isDeveloperModeEnabled(userId, serviceId);
      if (devMode) {
        request.setAttribute("obj", obj);
      }

      if ("TG_UNSUPPORTED_CLIENT".equals(obj.optString("code"))) {
        request.setAttribute("error.message.code", "error.message.tg_unsupported_client");
      }

    } catch (Exception e) {
      log.warn("Failed parsing error message", e);
    }

  } else {
    log.warn("No error message present." +
        " Request uri = [" + request.getRequestURI() + "]," +
        " parameters = [" + toString(request.getParameterMap()) + "]");
  }
%>

<page version="2.0">

  <div>
    <%= _((String) request.getAttribute("error.message.code"), request) %>

    <% if (request.getAttribute("obj") != null &&
        !"sms".equals(request.getProtocol()) && !"ussd".equals(request.getProtocol())) { %>

      <br/>
      <br/>

      <b>Detailed info</b>
      <br/>

      <% if (((JSONObject) request.getAttribute("obj")).optString("code") != null) { %>
        Code: <%=((JSONObject) request.getAttribute("obj")).optString("code")%>.
        <br/>
      <% } %>

      <% if (((JSONObject) request.getAttribute("obj")).optString("message") != null) { %>
        Description: <%=((JSONObject) request.getAttribute("obj")).optString("message")%>.
        <br/>
      <% } %>

      <% if (((JSONObject) request.getAttribute("obj")).optString("service") != null) { %>
        Service: <%=((JSONObject) request.getAttribute("obj")).optString("service")%>.
        <br/>
      <% } %>

      <% if (((JSONObject) request.getAttribute("obj")).optString("uri") != null) { %>
        Page URI: <%=((JSONObject) request.getAttribute("obj")).optString("uri")%>.
        <br/>
      <% } %>

      <% if (((JSONObject) request.getAttribute("obj")).optString("details") != null &&
          !((JSONObject) request.getAttribute("obj")).optString("details").trim().isEmpty()) { %>
        Details: <%=((JSONObject) request.getAttribute("obj")).optString("details")%>.
      <% } %>

      <br/>
    <% } %>
  </div>

  <% if (request.getAttribute("startPage") != null) { %>
    <navigation>
      <link pageId="<%= request.getAttribute("startPage") %>" accesskey="1"><%= _("start.page", request) %></link>
    </navigation>
  <% } %>
</page>
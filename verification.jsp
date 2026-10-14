<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Locale" %>
<%!
  private String escapeHtml(String value) {
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        .replace("\"", "&quot;").replace("'", "&#39;");
  }

  private boolean validEmail(String email) {
    if (email == null || email.length() > 254 || email.contains("..")) return false;
    return email.matches("^[A-Za-z0-9_%+-]+(?:\\.[A-Za-z0-9_%+-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z]{2,}$");
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  String name = request.getParameter("name");
  String email = request.getParameter("email");
  String summary = request.getParameter("summary");
  name = name == null ? "" : name;
  email = email == null ? "" : email;
  summary = summary == null ? "" : summary.trim();

  String error = "";
  if (name.trim().isEmpty()) {
    error = "Please enter your name.";
  } else if (!name.matches("[A-Za-z]{5,}")) {
    error = "Invalid username.";
  } else if (email.trim().isEmpty()) {
    error = "Please enter your email address.";
  } else if (!validEmail(email)) {
    error = "Please enter a valid email address.";
  } else if (summary.isEmpty()) {
    error = "Please enter your Hibernate summary.";
  }

  int wordCount = 0;
  int matchingKeywords = 0;
  int rating = 0;
  if (error.isEmpty()) {
    wordCount = summary.split("\\s+").length;
    String normalizedSummary = summary.toLowerCase(Locale.ROOT);
    String[] requiredKeywords = {
      "hibernate", "orm", "entity classes", "annotations", "sessionfactory",
      "hql", "crud", "transactions", "database connectivity"
    };
    for (String keyword : requiredKeywords) {
      if (normalizedSummary.contains(keyword)) matchingKeywords++;
    }

    if (matchingKeywords == requiredKeywords.length) {
      rating = 10;
    } else if (wordCount > 70) {
      rating = 8;
    } else if (wordCount > 50) {
      rating = 7;
    } else {
      rating = 5;
    }
  }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Hibernate Knowledge Test | Verification</title>
  <style>
    :root { --ink: #1d2925; --muted: #586761; --paper: #f5f7f2; --green: #176b52; --red: #a52d2d; }
    * { box-sizing: border-box; }
    body { margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 24px; background: var(--paper); color: var(--ink); font: 16px/1.6 "Trebuchet MS", Arial, sans-serif; }
    main { width: min(100%, 620px); padding: clamp(24px, 6vw, 42px); background: white; border-top: 5px solid <%= error.isEmpty() ? "#176b52" : "#a52d2d" %>; }
    h1 { margin-top: 0; font-size: 27px; }
    .error { color: var(--red); font-weight: 700; }
    .success { color: var(--green); font-weight: 700; }
    a { color: var(--green); }
  </style>
</head>
<body>
  <main>
    <% if (!error.isEmpty()) { %>
      <h1>We couldn't verify your test</h1>
      <p class="error"><%= escapeHtml(error) %></p>
      <p>Please correct the details and submit the form again.</p>
      <a href="user%20details.html">Return to your test details</a>
    <% } else { %>
      <h1>Verification successful</h1>
      <p class="success">Your email address is valid. Your summary has been evaluated.</p>
      <p>Your results are ready. Opening them now...</p>
      <div id="verified-result"
           data-name="<%= escapeHtml(name) %>"
           data-email="<%= escapeHtml(email) %>"
           data-word-count="<%= wordCount %>"
           data-matching-keywords="<%= matchingKeywords %>"
           data-keyword-total="9"
           data-rating="<%= rating %>"></div>
      <p><a href="result.html" id="result-link">Continue to your results</a></p>
      <script>
        const resultElement = document.getElementById("verified-result");
        const result = {
          name: resultElement.dataset.name,
          email: resultElement.dataset.email,
          wordCount: Number(resultElement.dataset.wordCount),
          matchingKeywords: Number(resultElement.dataset.matchingKeywords),
          keywordTotal: Number(resultElement.dataset.keywordTotal),
          rating: Number(resultElement.dataset.rating)
        };
        sessionStorage.setItem("hibernateTestResult", JSON.stringify(result));
        sessionStorage.setItem("hibernateTestVerified", "true");
        window.setTimeout(() => { window.location.replace("result.html"); }, 900);
      </script>
    <% } %>
  </main>
</body>
</html>
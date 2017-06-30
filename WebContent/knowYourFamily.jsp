<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
  <%-- Import the java.sql package --%>
  <%@ page import="java.sql.*"%>
  <%@ page import="java.io.*,java.util.*" %>
  <%@ page import="javax.servlet.*,java.text.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%
  String name=null;
  try{
    if(session.getAttribute("username")!=null || !session.getAttribute("username").equals("")) {
      name = (String)session.getAttribute("username");
    }
    else{
    	name = null;
    	response.sendRedirect("/FamilyTree/redirectlogin");
    	return;
    }
  }catch(Exception n){
    name = null;
    response.sendRedirect("/FamilyTree/redirectlogin");
    return;
  }
  %>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Get to know yo fam</title>
</head>
<body>
  <div class="container">
    <h1>Know your fam!</h1>
    
  
  </div>
</body>
</html>
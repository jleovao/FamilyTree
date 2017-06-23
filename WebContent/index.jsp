<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
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
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Home</title>
</head>
<body>
  <div class="container">
  <b>Family Tree Menu</b>
  <ul>
    <li><a href="index.jsp">Home Page</a></li>
     <li><a href="welcome_page.jsp">Welcome Page</a></li>
  </ul>
  
  </div>
</body>
</html>
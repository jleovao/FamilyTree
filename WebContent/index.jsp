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
<style>
	body {
  		text-align: center;
  		background: url("./images/background_textured_blue.jpg");
  		background-size: cover;
  		background-position: center center;
  		background-repeat: no-repeat;
  		background-attachment: fixed;
  		color: white;
    }
    div.nav {
    	text-align: left;
    	float: left;
    	color: white;
    }
  </style>
  <title>Home</title>
</head>
<body link="aqua" vlink="#808080" alink="#FF0000">
  <div class="container">
  <h1>Family Tree Menu</h1>
  <h4 style="text-align:center">Hello, <%=name%>!</h4>
  <div class="nav">
    <ul>
      <li><a href="/FamilyTree/home">Family Tree Settings</a></li>
      <li><a href="/FamilyTree/welcome_page">Login Page</a></li>
      <li><a href="/FamilyTree/tree">View Tree</a></li>
    </ul>
  </div>
  
  
  
  <%-- Import the java.sql package --%>
  <%@ page import="java.sql.*"%>
  <%@ page import="java.util.*"%>
  <%-- -------- Open Connection Code -------- --%>
  <%
            
  Connection conn = null;
  PreparedStatement pstmt = null;
  ResultSet rs = null;
  try 
  {
  // Registering Postgresql JDBC driver with the DriverManager
  Class.forName("org.postgresql.Driver");
  // Open a connection to the database using DriverManager
  conn = DriverManager.getConnection(
      "jdbc:postgresql://localhost/FamilyTree?" +
      "user=postgres&password=7124804");
  %>
  
  <%-- -------- INSERT Code -------- --%>
  <%
  String action = request.getParameter("action");
  
  // Check if an insertion is requested
  if (action != null && action.equals("insert")) {
    // Begin transaction
    conn.setAutoCommit(false);
    pstmt = conn.prepareStatement("INSERT INTO TREES(tree_name,creator) VALUES(?, ?)");
    pstmt.setString(1, request.getParameter("tree_name"));
    pstmt.setString(2, request.getParameter("creator"));
    
    int rowCount = pstmt.executeUpdate();
    
    // Commit transaction
    conn.commit();
    conn.setAutoCommit(true);
  }
  %>
  
  <%-- -------- UPDATE Code -------- --%>
        <%
        // Check if an update is requested
        if (action != null && action.equals("update")) {
        // Begin transaction
        conn.setAutoCommit(false);
        pstmt = conn.prepareStatement("UPDATE trees SET tree_name = ?, creator = ? WHERE tree_id = ?");
        pstmt.setString(1, request.getParameter("tree_name"));
        pstmt.setString(2, request.getParameter("creator"));
        pstmt.setInt(3, Integer.parseInt(request.getParameter("tree_id")));
        int rowCount = pstmt.executeUpdate();
        // Commit transaction
        conn.commit();
        conn.setAutoCommit(true);
        }
        %>
        
        <%-- -------- DELETE Code -------- --%>
        <%
        // Check if a delete is requested
        if (action != null && action.equals("delete")) {
        // Begin transaction
        conn.setAutoCommit(false);
        pstmt = conn.prepareStatement("DELETE FROM trees WHERE tree_id = ?");
        pstmt.setInt(1, Integer.parseInt(request.getParameter("tree_id")));
        int rowCount = pstmt.executeUpdate();
        // Commit transaction
        conn.commit();
        conn.setAutoCommit(true);
        }
        %>
  
  <div class="displayTable">
    <p align="left">For simplicity purposes, only one tree per user.</p>
  <table border="1">
    <tr>
      <th>Tree Name</th>
      <th>Creator</th>
      <th colspan="2">Action</th>
    </tr>
    <tr>
      <form action="./index.jsp" method="POST">
        <input type="hidden" name="action" value="insert"/>
        <th><input value="" name="tree_name"/></th>
        <th><input value="" name="creator"/></th>
	    <th colspan="2"><input type="submit" value="Insert"/></th>
      </form>
    </tr>
    <%
    Statement creator_stmnt = conn.createStatement();
    rs = creator_stmnt.executeQuery("Select * from trees where creator ='" + name + "'");
    while(rs.next()) {
    %>
    <tr>
      <form action="./index.jsp" method="POST">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="tree_id" value="<%=rs.getInt("tree_id")%>"/>
      <td>
        <input value="<%=rs.getString("tree_name")%>" name="tree_name"/>
      </td>
      <td>
        <input value="<%=rs.getString("creator")%>" name="creator"/>
      </td>
      <%--Update Button --%>
      <td><input type="submit" value="Update"></td>
      </form>
      <form action="./index.jsp" method="POST">
        <input type="hidden" name="action" value="delete"/>
        <input type="hidden" value="<%=rs.getInt("tree_id")%>" name="tree_id"/>
        <%-- Delete Button --%>
        <td><input type="submit" value="Delete"/></td>
      </form>
    </tr>
    <%
    } // end while
    %>
    
  </table>
  </div>
  
  <%-- -------- Close Connection Code -------- --%>
  <%
  // Close the ResultSets
  rs.close();
  //Close the Connection
  conn.close();
  } catch (SQLException e) {
	  throw new RuntimeException(e);
  }
  finally {
    if (rs != null) {
      try {
        rs.close();
      } catch (SQLException e) { } // Ignore
      rs = null;
    } 
    if (pstmt != null) {
      try {
        pstmt.close();
      } catch (SQLException e) { } // Ignore
      pstmt = null;
    }
    if (conn != null) {
      try {
        conn.close();
      } catch (SQLException e) { } // Ignore
      conn = null;
    }
  }
  %>
  </div>
</body>
</html>
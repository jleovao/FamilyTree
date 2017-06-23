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
  <h1>Family Tree Menu</h1>
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
  <div class="displayTable">
  <table border="1">
    <tr>
      <th>Tree Name</th>
      <th>Creator</th>
      <th>Action</th>
    </tr>
    <tr>
      <form action="./index.jsp" method="POST">
        <input type="hidden" name="action" value="insert"/>
        <th><input value="" name="tree_name"/></th>
        <th><input value="" name="creator"/></th>
	    <th><input type="submit" value="Insert"/></th>
      </form>
    </tr>
    <%
    Statement creator_stmnt = conn.createStatement();
    rs = creator_stmnt.executeQuery("Select * from trees");
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
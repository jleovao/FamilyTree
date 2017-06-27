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
    pstmt = conn.prepareStatement("INSERT INTO PERSON(first_name,middle_name,last_name,gender,date_of_birth,alive) VALUES(?,?,?,?,?,?)");
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
        pstmt = conn.prepareStatement("DELETE FROM person WHERE person_id = ?");
        pstmt.setInt(1, Integer.parseInt(request.getParameter("person_id")));
        int rowCount = pstmt.executeUpdate();
        // Commit transaction
        conn.commit();
        conn.setAutoCommit(true);
        }
        %>
  
  <div class="displayTable">
  <table border="1">
    <tr>
      <th>First Name</th>
      <th>Middle Name</th>
      <th>Last Name</th>
      <th>Gender</th>
      <th>Date of Birth</th>
      <th>Still Alive?</th>
      <th>Mother</th>
      <th>Father</th>
      <th colspan="2">Action</th>
    </tr>
    <tr>
      <form action="./tree.jsp" method="POST">
        <input type="hidden" name="action" value="insert"/>
        <th><input value="" name="first_name"/></th>
        <th><input value="" name="middle_name"/></th>
        <th><input value="" name="first_name"/></th>
        <th><input value="" name="gender"/></th>
        <th><input value="" name="date_of_birth"/></th>
        <th><input value="" name="alive"/></th>
        <% // Parent Dropdown Menu will be in format first_name,middle_name,last_name 
           // and will pass in the corresponding parent_id upon insert
         %>
        
        <!-- Mother Dropdown Menu -->
        <th><input value="" name="mother_id"/></th>
        <!-- Father Dropdown Menu -->
        <th><input value="" name="father_id"/></th>
	    <th colspan="2"><input type="submit" value="Insert"/></th>
      </form>
    </tr>
    <%
    Statement creator_stmnt = conn.createStatement();
    String selectSQL = "select p.person_id,p.first_name,p.middle_name,p.last_name,p.gender,p.date_of_birth,p.alive," +
    "p2.first_name as m_first,p2.middle_name as m_middle,p2.last_name as m_last," +
    "p3.first_name as f_first,p3.middle_name as f_middle,p3.last_name as f_last " +
	"from trees t, person p, person p2, person p3 " +
	"where t.tree_id = p.tree_id " +
	"and p.mother_id = p2.person_id and p.father_id = p3.person_id " +
	"and t.creator = '" + name + "'";
    rs = creator_stmnt.executeQuery(selectSQL);
    
    while(rs.next()) {
    %>
    <tr>
      <form action="./tree.jsp" method="POST">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="person_id" value="<%=rs.getInt("person_id")%>"/>
      <td>
        <input value="<%=rs.getString("first_name")%>" name="first_name"/>
      </td>
      <td>
        <input value="<%=rs.getString("middle_name")%>" name="middle_name"/>
      </td>
      <td>
        <input value="<%=rs.getString("last_name")%>" name="last_name"/>
      </td>
      <td>
        <input value="<%=rs.getString("gender")%>" name="gender"/>
      </td>
      <td>
        <input value="<%=rs.getDate("date_of_birth")%>" name="date_of_birth"/>
      </td>
      <td>
        <input value="<%=rs.getString("alive")%>" name="alive"/>
      </td>
      <td>
        <%=rs.getString("m_first")%> <%=rs.getString("m_last")%>
      </td>
      <td>
        <%=rs.getString("f_first")%> <%=rs.getString("f_last")%>
      </td>
      
      <%--Update Button --%>
      <td><input type="submit" value="Update"></td>
      </form>
      <form action="./tree.jsp" method="POST">
        <input type="hidden" name="action" value="delete"/>
        <input type="hidden" value="<%=rs.getInt("person_id")%>" name="person_id"/>
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
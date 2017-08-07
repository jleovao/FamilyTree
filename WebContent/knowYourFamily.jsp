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
  div.personData {
  		float:left;
  		clear:left;
  }
</style>
<title>Get to know yo fam</title>
</head>
<body link="aqua" vlink="#808080" alink="#FF0000">
  <%-- -------- Open Connection Code -------- --%>
  <%         
  Connection conn = null;
  PreparedStatement pstmt = null;
  ResultSet rs = null;
  ResultSet rs_id = null;
  ResultSet rs_person = null;
  ResultSet rs_mother = null;
  ResultSet rs_father = null;
  ResultSet rs_sibling = null;
  ResultSet rs_kids = null;
  try 
  {
  // Registering Postgresql JDBC driver with the DriverManager
  Class.forName("org.postgresql.Driver");
  // Open a connection to the database using DriverManager
  conn = DriverManager.getConnection(
      "jdbc:postgresql://localhost/FamilyTree?" +
      "user=postgres&password=7124804");
  
  Statement id_stmnt = conn.createStatement();
  String idSQL = "select t.tree_id from trees t where t.creator = '" + name + "'";
  rs_id= id_stmnt.executeQuery(idSQL);
  // Object references can be null, not primitives. Zero for now.
  int tree_id = 0;
  while(rs_id.next()){
	  tree_id = rs_id.getInt("tree_id");
  }
  %>
  <div class="container">
    <h1>Know your fam!</h1>
    <h4 style="text-align:center">Hello, <%=name%>!</h4>
    <div class="nav">
      <ul>
        <li><a href="/FamilyTree/welcome_page">Login Page</a></li>
        <li><a href="/FamilyTree/home">Create/Edit Tree Name</a></li>
        <li><a href="/FamilyTree/tree">Edit Tree</a></li>
        <li><a href="/FamilyTree/knowYourFamily">Get to know yo fam</a></li>
      </ul>
    </div>
    <div class="selectPerson" align="left">
    <%
    Statement stmnt = conn.createStatement();
	rs = stmnt.executeQuery("select * from person p,trees t " +
			"where p.tree_id = t.tree_id and " +
			" t.tree_id = " + tree_id + 
			" and t.creator = '" + name + "'");
    %>
    <table border="1">
        <tr>
          <th>Select</th>
          <th>Action</th>
        </tr>
        <tr>
          <form action="knowYourFamily.jsp" method="get">
		  <input type="hidden" value="person_selection" name="action">
		  <th>
          <select name="person_id">
          <option value=""></option>
          <%
          while(rs.next()) {
          %>
            <option value="<%=rs.getInt("person_id")%>"><%=rs.getString("first_name")%> <%=rs.getString("middle_name")%> <%=rs.getString("last_name")%></option>
          <%
		  } // end while
          %>
          </select>
          </th>
          <%-- Button --%>
		  <th>
		    <input type="submit" value="Select">
		  </th>
        </tr>
      </table>
    </div>
    
    <%-- -------- ResultSet Code -------- --%>
    <%
    String action = request.getParameter("action");
    if (action != null && action.equals("person_selection")) {
      // Begin transaction
      conn.setAutoCommit(false);
      String personSQL = "select * " +
    		  "from person p1,trees t " +
    		  "where p1.person_id = " + request.getParameter("person_id") + 
    		  " and t.creator='" + name + "';";
      Statement p_stmnt = conn.createStatement();
      rs_person = p_stmnt.executeQuery(personSQL);
      
      String motherSQL = "select p1.* " +
    		  "from person p1, person p2, person p3,trees t " +
    		  "where p3.mother_id = p1.person_id " +
    		  "and  p3.father_id = p2.person_id " +
    		  "and p3.person_id = " + request.getParameter("person_id") +
    		  " and t.creator='" + name + "';";
      Statement m_stmnt = conn.createStatement();
      rs_mother = m_stmnt.executeQuery(motherSQL);
      
      String fatherSQL = "select p2.* " +
    		  "from person p1, person p2, person p3,trees t " +
    		  "where p3.mother_id = p1.person_id " +
    		  "and  p3.father_id = p2.person_id " +
    		  "and p3.person_id = " + request.getParameter("person_id") +
    		  " and t.creator='" + name + "';";
      Statement f_stmnt = conn.createStatement();
      rs_father = f_stmnt.executeQuery(fatherSQL);
      
      String sibSQL = "select p1.* " +
    		  "from person p1, person p2, trees t " +
    		  "where p1.mother_id = p2.mother_id and " +
    		  "p1.father_id = p2.father_id and " +
    		  "p2.person_id = " + request.getParameter("person_id") +
    		  " and t.creator = '" + name + "'" +
    		  "and p1 <> p2;";
 	 Statement s_stmnt = conn.createStatement();
 	 rs_sibling = s_stmnt.executeQuery(sibSQL);
 	 
 	String kidSQL = "select p1.* from Person p1, Person p2, trees t " +
 			"where p2.person_id = " + request.getParameter("person_id") +
 			" and p1.tree_id = p2.tree_id and " +
 			" (p2.person_id = p1.mother_id or p2.person_id = p1.father_id) and " +
 		    "p1.tree_id = t.tree_id and t.creator = '" + name +"'";
	 Statement k_stmnt = conn.createStatement();
	 rs_kids = k_stmnt.executeQuery(kidSQL);
      
      // Commit transaction
      conn.commit();
      conn.setAutoCommit(true);
    %>
      <div class = "personData">
      <!-- Display data of person selected -->
      <b>Person Selected</b>
      <table border="1">
        <tr>
          <th>First Name</th>
          <th>Middle Name</th>
          <th>Last Name</th>
          <th>Gender</th>
          <th>Date of Birth</th>
          <th>Still Alive?</th>
        </tr>
        <%
        while(rs_person.next()) {
        %>
        <tr>
          <td><%=rs_person.getString("first_name") %></td>
          <td><%=rs_person.getString("middle_name") %></td>
          <td><%=rs_person.getString("last_name") %></td>
          <td><%=rs_person.getString("gender") %></td>
          <td><%=rs_person.getDate("date_of_birth") %></td>
          <td><%=rs_person.getString("alive") %></td>
        </tr>
        <%
        } // end rs_person
        %>
      </table>
      
      <br>
      <!-- Display mother data of person selected -->
      <b>Mother</b>
      <table border="1">
        <tr>
          <th>First Name</th>
          <th>Middle Name</th>
          <th>Last Name</th>
          <th>Gender</th>
          <th>Date of Birth</th>
          <th>Still Alive?</th>
        </tr>
        <%
        while(rs_mother.next()) {
        %>
        <tr>
          <td><%=rs_mother.getString("first_name") %></td>
          <td><%=rs_mother.getString("middle_name") %></td>
          <td><%=rs_mother.getString("last_name") %></td>
          <td><%=rs_mother.getString("gender") %></td>
          <td><%=rs_mother.getDate("date_of_birth") %></td>
          <td><%=rs_mother.getString("alive") %></td>
        </tr>
        <%
        } // end rs_mother
        %>
      </table>
    
      <br>
      <!-- Display father data of person selected -->
      <b>Father</b>
      <table border="1">
        <tr>
          <th>First Name</th>
          <th>Middle Name</th>
          <th>Last Name</th>
          <th>Gender</th>
          <th>Date of Birth</th>
          <th>Still Alive?</th>
        </tr>
        <%
        while(rs_father.next()) {
        %>
        <tr>
          <td><%=rs_father.getString("first_name") %></td>
          <td><%=rs_father.getString("middle_name") %></td>
          <td><%=rs_father.getString("last_name") %></td>
          <td><%=rs_father.getString("gender") %></td>
          <td><%=rs_father.getDate("date_of_birth") %></td>
          <td><%=rs_father.getString("alive") %></td>
        </tr>
        <%
        } // end rs_father
        %>
      </table>
      
      <br>
      <!-- Display sibling data of person selected -->
      <b>Person's Siblings</b>
      <table border="1">
        <tr>
          <th>First Name</th>
          <th>Middle Name</th>
          <th>Last Name</th>
          <th>Gender</th>
          <th>Date of Birth</th>
          <th>Still Alive?</th>
        </tr>
        <%
        while(rs_sibling.next()) {
        %>
        <tr>
          <td><%=rs_sibling.getString("first_name") %></td>
          <td><%=rs_sibling.getString("middle_name") %></td>
          <td><%=rs_sibling.getString("last_name") %></td>
          <td><%=rs_sibling.getString("gender") %></td>
          <td><%=rs_sibling.getDate("date_of_birth") %></td>
          <td><%=rs_sibling.getString("alive") %></td>
        </tr>
        <%
        } // end rs_sibling
        %>
      </table>
      
      <br>
      <!-- Display children data of person selected -->
      <b>Person's Children</b>
      <table border="1">
        <tr>
          <th>First Name</th>
          <th>Middle Name</th>
          <th>Last Name</th>
          <th>Gender</th>
          <th>Date of Birth</th>
          <th>Still Alive?</th>
        </tr>
        <%
        while(rs_kids.next()) {
        %>
        <tr>
          <td><%=rs_kids.getString("first_name") %></td>
          <td><%=rs_kids.getString("middle_name") %></td>
          <td><%=rs_kids.getString("last_name") %></td>
          <td><%=rs_kids.getString("gender") %></td>
          <td><%=rs_kids.getDate("date_of_birth") %></td>
          <td><%=rs_kids.getString("alive") %></td>
        </tr>
        <%
        } // end rs_kids
        %>
      </table>
      
      </div>
    
    <%
    } // end if person_selection
    %>
  </div>
  <%-- -------- Close Connection Code -------- --%>
  <%
  // Close the ResultSets
  rs.close();
  rs_id.close();

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
    if (rs_id != null) {
      try {
    	  rs_id.close();
      } catch (SQLException e) { } // Ignore
      rs_id = null;
    } 
    if (rs_person != null) {
        try {
          rs_person.close();
        } catch (SQLException e) { } // Ignore
        rs_person = null;
    }
    if (rs_mother != null) {
        try {
        	rs_mother.close();
        } catch (SQLException e) { } // Ignore
        rs_mother = null;
    }
    if (rs_father != null) {
        try {
        	rs_father.close();
        } catch (SQLException e) { } // Ignore
        rs_father = null;
    }
    if (rs_sibling != null) {
        try {
        	rs_sibling.close();
        } catch (SQLException e) { } // Ignore
        rs_sibling = null;
    }
    if (rs_kids != null) {
        try {
        	rs_kids.close();
        } catch (SQLException e) { } // Ignore
        rs_kids = null;
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
</body>
</html>
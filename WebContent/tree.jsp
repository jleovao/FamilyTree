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
    div.insertTable {
    	clear: both;
    	color: white;
    }
    div.insertTableNoParent {
    	clear: both;
    	color: white;
    }
  </style>
  <title>Home</title>
</head>
<body link="aqua" vlink="#808080" alink="#FF0000">
  <div class="container">
  <h1>Edit Family Tree</h1>
  <h4 style="text-align:center">Hello, <%=name%>!</h4>
  <div class="nav">
    <ul>
      <li><a href="/FamilyTree/welcome_page">Login Page</a></li>
      <li><a href="/FamilyTree/home">Create/Edit Tree Name</a></li>
      <li><a href="/FamilyTree/tree">Edit Tree</a></li>
      <li><a href="/FamilyTree/knowYourFamily">Get to know yo fam</a></li>
    </ul>
  </div>
  <%-- -------- Open Connection Code -------- --%>
  <%         
  Connection conn = null;
  PreparedStatement pstmt = null;
  ResultSet rs = null;
  ResultSet rs_mother = null;
  ResultSet rs_father = null;
  ResultSet rs_id = null;
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
  
  <%-- -------- INSERT Code -------- --%>
  <%
  String action = request.getParameter("action");
  
  // Check if an insertion is requested
  if (action != null && action.equals("insert")) {
    // Begin transaction
    conn.setAutoCommit(false);
    pstmt = conn.prepareStatement("INSERT INTO PERSON(first_name,middle_name,last_name,gender,date_of_birth,alive,mother_id,father_id,tree_id) VALUES(?,?,?,?,?,?,?,?,?)");
    pstmt.setString(1, request.getParameter("first_name"));
    pstmt.setString(2, request.getParameter("middle_name"));
    pstmt.setString(3, request.getParameter("last_name"));
    pstmt.setString(4, request.getParameter("gender"));
    // Convert date_of_birth parameter
    String currDate = request.getParameter("date_of_birth");
    if(currDate == null || currDate.equals("")) {
    	pstmt.setDate(5,null);
    }
    else {
      java.util.Date utilDate = new SimpleDateFormat("yyyy-MM-dd",Locale.ENGLISH).parse(currDate);
      java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
      pstmt.setDate(5,sqlDate);
    }
    pstmt.setString(6, request.getParameter("alive"));
    pstmt.setInt(7, Integer.parseInt(request.getParameter("mother_id")));
    pstmt.setInt(8, Integer.parseInt(request.getParameter("father_id")));
    pstmt.setInt(9, tree_id);
    int rowCount = pstmt.executeUpdate();
    
    // Commit transaction
    conn.commit();
    conn.setAutoCommit(true);
  }
  
  // Check if an insertion without parents is requested
  if (action != null && action.equals("insertWithoutParents")) {
    // Begin transaction
    conn.setAutoCommit(false);
    pstmt = conn.prepareStatement("INSERT INTO PERSON(first_name,middle_name,last_name,gender,date_of_birth,alive,tree_id) VALUES(?,?,?,?,?,?,?)");
    pstmt.setString(1, request.getParameter("first_name"));
    pstmt.setString(2, request.getParameter("middle_name"));
    pstmt.setString(3, request.getParameter("last_name"));
    pstmt.setString(4, request.getParameter("gender"));
    // Convert date_of_birth parameter
    String currDate = request.getParameter("date_of_birth");
    if(currDate == null || currDate.equals("")) {
    	pstmt.setDate(5,null);
    }
    else {
      java.util.Date utilDate = new SimpleDateFormat("yyyy-MM-dd",Locale.ENGLISH).parse(currDate);
      java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
      pstmt.setDate(5,sqlDate);
    }
    pstmt.setString(6, request.getParameter("alive"));
    pstmt.setInt(7, tree_id);
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
        // Case when parent_ids are null
        if(Integer.parseInt(request.getParameter("mother_id")) == 0) {
       	pstmt = conn.prepareStatement("UPDATE PERSON SET first_name = ?, middle_name = ?, last_name = ?," + 
				  " gender = ?, date_of_birth = ?, alive = ?, " +
				  "tree_id = ? where person_id = ?");
       	pstmt.setInt(7, tree_id);
       	pstmt.setInt(8, Integer.parseInt(request.getParameter("person_id")));
       	
        }
        // Case when parent_ids are not null
        else{
       	pstmt = conn.prepareStatement("UPDATE PERSON SET first_name = ?, middle_name = ?, last_name = ?," + 
				  " gender = ?, date_of_birth = ?, alive = ?, mother_id = ?, " +
				  "father_id = ?,tree_id = ? where person_id = ?");
       	
       	// Parameters are shared whether parent_ids are null or not
       	pstmt.setInt(7, Integer.parseInt(request.getParameter("mother_id")));
        pstmt.setInt(8, Integer.parseInt(request.getParameter("father_id")));
        pstmt.setInt(9, tree_id);
        pstmt.setInt(10, Integer.parseInt(request.getParameter("person_id")));
        }
        
        pstmt.setString(1, request.getParameter("first_name"));
        pstmt.setString(2, request.getParameter("middle_name"));
        pstmt.setString(3, request.getParameter("last_name"));
        pstmt.setString(4, request.getParameter("gender"));
        // Convert date_of_birth parameter
        String currDate = request.getParameter("date_of_birth");
        if(currDate == null || currDate.equals("") || currDate.equals("null")) {
        	pstmt.setDate(5,null);
        }
        else {
          java.util.Date utilDate = new SimpleDateFormat("yyyy-MM-dd",Locale.ENGLISH).parse(currDate);
          java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
          pstmt.setDate(5,sqlDate);
        }
        pstmt.setString(6, request.getParameter("alive"));
        
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
        
        <%-- -------- ResultSets -------- --%>
  		<%
  		Statement mother_stmnt = conn.createStatement();
  		String motherSQL = "select p.person_id,p.first_name,p.middle_name,p.last_name " +
  		"from Person p,trees t where (gender = 'Female' or gender = 'Other') " +
  		"and t.creator = '" + name + "' and t.tree_id = p.tree_id";
  		rs_mother = mother_stmnt.executeQuery(motherSQL);
  		
  		Statement father_stmnt = conn.createStatement();
  		String fatherSQL = "select p.person_id,p.first_name,p.middle_name,p.last_name " +
  		  		"from Person p,trees t where (gender = 'Male' or gender = 'Other') " +
  		  		"and t.creator = '" + name + "' and t.tree_id = p.tree_id";
  		rs_father= father_stmnt.executeQuery(fatherSQL);
  		%>
  
  <div class="insertTable">
  <b align="left">Insert Person With Existing Parent</b>
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
        <th><input value="" name="last_name"/></th>
        <th>
          <select name="gender">
            <option value=""></option>
            <option value="Male">Male</option>
            <option value="Female">Female</option>
            <option value="Other">Other</option>
          </select>
        </th>
        <th><input type="date" value="" name="date_of_birth"/></th>
        <th>
		  <select name="alive">
            <option value="Yes">Yes</option>
            <option value="No">No</option>
          </select>
		</th>
        
        <% // Parent Dropdown Menu will be in format first_name,middle_name,last_name 
           // and will pass in the corresponding parent_id upon insert
         %>
        <!-- Mother Drop down Menu -->
        <th>
        <select name="mother_id">
        <option value=""></option>
        <%
        // Lists to hold mother's id, first_name, middle_name, and last_name
        List<Integer> mid = new ArrayList<Integer>();
        List<String> mfn = new ArrayList<String>();
        List<String> mmn = new ArrayList<String>();
        List<String> mln = new ArrayList<String>();
        
        while(rs_mother.next()) {
        int mother_id = rs_mother.getInt("person_id");
        String fn = rs_mother.getString("first_name");
        String mn = rs_mother.getString("middle_name");
        String ln = rs_mother.getString("last_name");
        mid.add(mother_id);
        mfn.add(fn);
        mmn.add(mn);
        mln.add(ln);
        %>
        	<option value=<%=mother_id%>><%=fn%> <%=mn%> <%=ln%></option>
        <%
  		}// end while	
        %>
        </select>
        </th>
        <!-- Father Drop down Menu -->
        <th>
        <select name="father_id">
        <option value=""></option>
        <%
        // Lists to hold father's id, first_name, middle_name, and last_name
        List<Integer> fid = new ArrayList<Integer>();
        List<String> ffn = new ArrayList<String>();
        List<String> fmn = new ArrayList<String>();
        List<String> fln = new ArrayList<String>();
        
        while(rs_father.next()) {
        int father_id = rs_father.getInt("person_id");
        String fn = rs_father.getString("first_name");
        String mn = rs_father.getString("middle_name");
        String ln = rs_father.getString("last_name");
        fid.add(father_id);
        ffn.add(fn);
        fmn.add(mn);
        fln.add(ln);
        %>
        	<option value=<%=father_id%>><%=fn%> <%=mn%> <%=ln%></option>
        <%
  		}// end while	
        %>
        </select>
        </th>
	    <th colspan="2"><input type="submit" value="Insert"/></th>
      </form>
    </tr>
    </table>
  </div>
  <p> </p>
  
  <div class="insertTableNoParent">
  <b align="left">Insert Person Without Existing Parent</b>
    <table border="1">
      <tr>
        <th>First Name</th>
        <th>Middle Name</th>
        <th>Last Name</th>
        <th>Gender</th>
        <th>Date of Birth</th>
        <th>Still Alive?</th>
        <th colspan="2">Action</th>
      </tr>
      <tr>
      <form action="./tree.jsp" method="POST">
        <input type="hidden" name="action" value="insertWithoutParents"/>
        <th><input value="" name="first_name"/></th>
        <th><input value="" name="middle_name"/></th>
        <th><input value="" name="last_name"/></th>
        <th>
          <select name="gender">
            <option value=""></option>
            <option value="Male">Male</option>
            <option value="Female">Female</option>
            <option value="Other">Other</option>
          </select>
        </th>
        <th><input type="date" value="" name="date_of_birth"/></th>
        <th>
		  <select name="alive">
            <option value="Yes">Yes</option>
            <option value="No">No</option>
          </select>
		</th>
	    <th colspan="2"><input type="submit" value="Insert"/></th>
      </form>
    </tr>
    </table>
  </div>
  <p> </p>
 		
  <div class="displayTable">
  <b align="left">List of People in Family Tree</b>
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
    <%
    Statement creator_stmnt = conn.createStatement();
    String selectSQL = "(select p.person_id,p.first_name,p.middle_name,p.last_name,p.gender,p.date_of_birth,p.alive," +
    "p2.person_id as m_id,p2.first_name as m_first,p2.middle_name as m_middle,p2.last_name as m_last," +
    "p3.person_id as f_id,p3.first_name as f_first,p3.middle_name as f_middle,p3.last_name as f_last " +
	"from trees t, person p, person p2, person p3 " +
	"where t.tree_id = p.tree_id " +
	"and p.mother_id = p2.person_id and p.father_id = p3.person_id " +
	"and t.creator = '" + name + "') " +
	"union " +
	"(select x.person_id,x.first_name,x.middle_name,x.last_name,x.gender,x.date_of_birth,x.alive," +
	"null as m_id,null as m_first,null as m_middle,null as m_last, " +
	"null as f_id,null as f_first,null as f_middle,null as f_last " +
	"from trees t, person x " +
	"where t.tree_id = x.tree_id " +
	"and x.mother_id is null and x.father_id is null " +
	"and t.creator = '" + name + "')";
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
        <select name="gender">
          <option value="<%=rs.getString("gender")%>"><%=rs.getString("gender")%></option>
          <%
          if(rs.getString("gender").equals("Male")) {
          %>
            <option value="Female">Female</option>
            <option value="Other">Other</option>
          <%
          } else if(rs.getString("gender").equals("Female")) {
          %>
            <option value="Male">Male</option>
            <option value="Other">Other</option>
          <% 
          } else {
          %>
            <option value="Male">Male</option>
            <option value="Female">Female</option>
          <%
          } // end else
          %>
        </select>
      </td>
      <td>
        <input value="<%=rs.getDate("date_of_birth")%>" name="date_of_birth"/>
      </td>
      <td>
      	<select name="alive">
      	  <option value="<%=rs.getString("alive")%>"><%=rs.getString("alive")%></option>
      	  <%
      	  if(rs.getString("alive").equals("Yes")) {
      	  %>
      	  <option value="No">No</option>
      	  <%
      	  } else {
      	  %>
      	  <option value="Yes">Yes</option>
      	  <%
      	  }
      	  %>
      	</select>
      </td>
      <td>
        <select name="mother_id">
          <%
          // Check if mother is known or not
          if(rs.getInt("m_id") != 0) {
          %>
            <option value=<%=rs.getInt("m_id")%>><%=rs.getString("m_first")%> <%=rs.getString("m_last")%></option>
          <%
          } else {
          %>
            <option value=<%=rs.getInt("m_id")%>></option>
          <%
          } // end else
          %>
          <%
          int m_temp = 0;
          for(int current: mid) {
            if(current != rs.getInt("m_id")) {
              %>
              <option value="<%=current%>"><%=mfn.get(m_temp)%> <%=mln.get(m_temp)%></option>
          <%
              m_temp++;
            }// end if
          }// end for
          %>
		</select>	
      </td>
      <td>
      <select name="father_id">
        <%
        // Check if father is known or not
        if(rs.getInt("f_id") != 0) {
        %>
          <option value=<%=rs.getInt("f_id")%>><%=rs.getString("f_first")%> <%=rs.getString("f_last")%></option>
        <% 
        } else {
        %>
          <option value=<%=rs.getInt("f_id")%>></option>
        <%
        } // End else
        %>
        <%
        int f_temp = 0;
        for(int current: fid) {
          if(current != rs.getInt("f_id")) {
          %>
            <option value="<%=current%>"><%=ffn.get(f_temp)%> <%=fln.get(f_temp)%></option>
          <%
            f_temp++;
          }// end if
        }// end for
        %>
        </select>
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
  rs_mother.close();
  rs_father.close();
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
    if (rs_id != null) {
        try {
        	rs_id.close();
        } catch (SQLException e) { } // Ignore
        rs_id = null;
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
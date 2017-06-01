<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    import="java.sql.*" pageEncoding="ISO-8859-1"%>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <style>
    	body{
    		text-align: center;
    		background: url("./images/background_textured_blue.jpg");
    		background-size: cover;
    		background-position: center center;
    		background-repeat: no-repeat;
    		background-attachment: fixed;
    		color: white;
    	}
    </style>
    <title>Signup Page</title>
  </head>
  <body>
    <h1>Create a New Account</h1>
    <p>It's free and always will be</p>
    <form>
      <input type="hidden" name="action" value="insert">
      <input type="text" name="username" placeholder="username" autofocus><br>
      <input type="password" name="password" placeholder="password"><br>
      <input type="password" name="re-password" placeholder="re-enter password"><br>
      <input type="text" name="first_name" placeholder="First Name"><br>
      <input type="text" name="last_name" placeholder="Last Name"><br>
      <input type="radio" name="gender" value="Male" checked> Male
      <input type="radio" name="gender" value="Female" > Female
      <input type="radio" name="gender" value="Other"> Other<br>
      <input type="text" name="email" placeholder="Email"><br>
      <input type="submit" value="Create Account">
    </form>
    <a href="/FamilyTree/welcome_page"  style="color:#00FF00">Back to Login</a>
    <%
    String action = request.getParameter("action");
    String n = null;
    Connection conn=null;
    PreparedStatement pstmt=null;
    
    try{
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
          "jdbc:postgresql://localhost:5432/FamilyTree?" +
          "user=postgres&password=7124804");
        
        if(action != null && action.equals("insert")){
      	  conn.setAutoCommit(false);
      	  pstmt = conn.prepareStatement("insert into Users(username,user_password,first_name,last_name,gender,email) VALUES(?,?,?,?,?,?)");
      	  try{ 
      	    if(request.getParameter("username").equals("")){
      	      pstmt.setString(1, n);
      	    } else{ 
      	      pstmt.setString(1, request.getParameter("username"));
      	    }
      	    if(request.getParameter("password").equals("") || 
      	    		!request.getParameter("password").equals(request.getParameter("re-password"))){
      	      pstmt.setString(2, n);
      	    } else{
      	    	pstmt.setString(2,request.getParameter("password"));	
      	    }     	    
      	    if(request.getParameter("first_name").equals("")){
      	      pstmt.setString(3, n);
      	    } else{ 
      	      pstmt.setString(3, request.getParameter("first_name"));
      	    }
      	    if(request.getParameter("last_name").equals("")) {
      	      pstmt.setString(4, n);
      	    } else{ 
      	      pstmt.setString(4, request.getParameter("last_name"));
      	    }
      	    if(request.getParameter("gender").equals("")) {
      	      pstmt.setString(5, n);
      	    } else{ 
      	      pstmt.setString(5, request.getParameter("gender"));
      	    }
      	    if(request.getParameter("email").equals("")) {
      	      pstmt.setString(6, n);
      	    } else{ 
      	      pstmt.setString(6, request.getParameter("email"));
      	    }
      	    int rowCount = pstmt.executeUpdate();
      	    conn.commit();
      	    conn.setAutoCommit(true);
      	    response.sendRedirect("/FamilyTree/welcome_page");
      	  }catch(Exception e){
            //throw new RuntimeException(e);
      	    response.sendRedirect("/FamilyTree/signup");
      	  }
        }
        conn.close();
    } catch (SQLException e){
      response.sendRedirect("/CSE135/signup");
    }
    finally{
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
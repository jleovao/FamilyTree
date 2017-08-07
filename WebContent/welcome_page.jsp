<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    import="java.sql.*" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
  <%
  session.removeAttribute("username");
  session.removeAttribute("user_password");
  session.removeAttribute("role");
  %>
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
	    div.login_form {
	        padding: 1em;
	        clear: left;
	        text-align: center;
	    }
    </style>
    <title>Welcome</title>
  </head>
  <body>
    
    <div class="login_form">
    <h1>Welcome to my Family Tree Program</h1>
    <form>
      <input type="hidden" name="action" value="select">
      <input type="text" name="username" placeholder="username">
      <input type="password" name="user_password" placeholder="password">
      <input type="submit" value="Login">
      <a href="/FamilyTree/signup" style="color:#00FF00">New User?</a>
    </form>
    </div> 
    
    <a href="https://www.youtube.com/watch?v=lWKd5xquliU" style="color:aqua">McDonald's Menu</a> <br>
    <video width="320" height="240" controls>
      
      <source src="./images/dbs_97.mp4" type="video/mp4">
      Your browser does not support the video tag.
    </video> 
    <%
    String action = request.getParameter("action");
    String username=null;
    String user_password=null;
    String role=null;
    Connection conn=null;
    Statement stmt=null;
    ResultSet rs=null;

    try{
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
          "jdbc:postgresql://localhost:5432/FamilyTree?" +
          "user=postgres&password=7124804");
        
        if(action!=null && action.equals("select")){
          stmt=conn.createStatement();
          try {
            username=request.getParameter("username");
            user_password=request.getParameter("user_password");
          }catch(Exception e){username=null;}
          rs=stmt.executeQuery("SELECT * FROM users where username='"+username+"' and user_password='"+user_password+"';");
          if(rs.next()) {
            role=rs.getString(3);
            session.setAttribute("username", username);
            session.setAttribute("user_password", user_password);
            session.setAttribute("role",role);
            response.sendRedirect("/FamilyTree/home");
          }
          else{
            if(username!=null && !username.equals("")){
              out.println("<br>***Incorrect username and/or password!");
            }
            else{
              out.println("<br>***Provide a username and password");
            }
          }
        }
        conn.close();
    }catch(SQLException e){
      throw new RuntimeException(e);
    }
    finally{
      if (stmt != null) {
        try {
          stmt.close();
        } catch (SQLException e) { } // Ignore
      stmt = null;
      }
      if (conn != null) {
        try {
          conn.close();
        } catch (SQLException e) { } // Ignore
        conn = null;
      }
    }   
    %>
    
    <br>
    
  </body>
</html>
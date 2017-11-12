/* ---------- Start of Data Insertion ---------- */

/* Copy and paste these statements into
 * Postgresql query tool and run to create tables 
 * and insert sample data. */
drop table if exists Users,Person,Trees;

create table Users(
    user_id serial primary key,
    username text unique not null,
    user_password text not null,
    first_name text not null,
    last_name text not null,
    gender text not null,
    email text not null
);

create table Trees(
    tree_id serial primary key,
    tree_name text unique not null,
    creator text references users(username)
);

create table Person(
    person_id serial primary key,
    first_name text not null,
    middle_name text,
    last_name text not null,
    gender text not null,
    date_of_birth,
    alive text not null,
    mother_id integer references Person(person_id),
    father_id integer references Person(person_id),
    tree_id integer references Trees(tree_id)
);

/* Insert Statements */
insert into Users(username,user_password,first_name,last_name,gender,email)
values('jleovao','charlie323','Joseph','Leovao','Male','jleovao93@gmail.com');

insert into Trees(tree_name,creator) values ('L7_Enterprise','jleovao');

/* Insert new person without parent IDs, then updating parent ids */
/* Skewed Data for privacy */
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,tree_id) 
values ('fn1',null,'Siona','Female','1941-09-22','Yes',1);
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,tree_id) 
values ('fn2',null,'Siona','Male','1931-02-20','No',1);
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,tree_id) 
values ('fn3','a','L','Female','1974-09-06','Yes',1);
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,tree_id) 
values ('fn4','f','L','Male','1970-01-01','Yes',1);
update Person set mother_id = 1,father_id=2 where person_id = 3;

/* Insert new person with parent IDs */
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,mother_id,father_id,tree_id) 
values ('j1','T B','L','Male','1994-02-20','Yes',1,2,1);
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,mother_id,father_id,tree_id) 
values ('j2','B','L','Female','1995-04-15','Yes',1,2,1);
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,mother_id,father_id,tree_id) 
values ('j3','K','L','Male','2003-07-22','Yes',1,2,1);
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,mother_id,father_id,tree_id) 
values ('j4','F','L','Female','2005-05-05','Yes',1,2,1);
insert into Person(first_name,middle_name,last_name,gender,date_of_birth,alive,mother_id,father_id,tree_id) 
values ('j5','N','L','Female','2005-05-05','Yes',1,2,1);

/* Update parent ids */
update Person set mother_id = 3,father_id=4 where person_id = 5;
update Person set mother_id = 3,father_id=4 where person_id = 6;
update Person set mother_id = 3,father_id=4 where person_id = 7;
update Person set mother_id = 3,father_id=4 where person_id = 8;
update Person set mother_id = 3,father_id=4 where person_id = 9;

/* ---------- End of Data Insertion ---------- */



/* ---------- Data Queries ---------- */

/* Get Mother */
select p1.* 
from person p1, person p2, person p3
where p3.mother_id = p1.person_id
 and  p3.father_id = p2.person_id
 and p3.first_name = 'Joseph' and p3.last_name = 'Leovao';

/* Get Father */
select p2.* 
from person p1, person p2, person p3
where p3.mother_id = p1.person_id
 and  p3.father_id = p2.person_id
 and p3.first_name = 'Joseph' and p3.last_name = 'Leovao';

/* Siblings */
select p1.*
from person p1, person p2
where p1.mother_id = p2.mother_id and 
      p1.father_id = p2.father_id and 
      p2.first_name = 'Joseph' and p2.last_name = 'Leovao'
      and p1 <> p2;

/* Get Kids */
select p1.first_name, p1.last_name from Person p1, Person p2, trees t
where p2.first_name = 'Eddard' and p2.last_name = 'Stark' and
	  p1.tree_id = p2.tree_id and
      (p2.person_id = p1.mother_id or p2.person_id = p1.father_id) and
      p1.tree_id = t.tree_id and t.creator = 'LordSnow';

/* Display person table info */
select p.first_name,p.middle_name,p.last_name,p.gender,p.date_of_birth,p.alive,
       p2.first_name as m_first,p2.middle_name as m_middle,p2.last_name as m_last,
       p3.first_name as f_first,p3.middle_name as f_middle,p3.last_name as f_last
from trees t, person p, person p2, person p3
where t.tree_id = p.tree_id
and p.mother_id = p2.person_id and p.father_id = p3.person_id
and t.creator = 'jleovao';

/* Display Possible Mothers */
select p.person_id,p.first_name,p.middle_name,p.last_name
from Person p,trees t where (gender = 'Female' or gender = 'Other')
and t.creator = 'jleovao' and t.tree_id = p.tree_id

/* Display Potential Fathers */
select p.person_id,p.first_name,p.middle_name,p.last_name
from Person p,trees t where (gender = 'Male' or gender = 'Other')
and t.creator = 'jleovao' and t.tree_id = p.tree_id

/* Display Contents of Tree including Parent First/Middle/Last Name */
/* Includes people who do not have null parent ids */
/* Might want to include case where father or mother id is null */
(select p.person_id,p.first_name,p.middle_name,p.last_name,p.gender,p.date_of_birth,p.alive,
    p2.first_name as m_first,p2.middle_name as m_middle,p2.last_name as m_last,
    p3.first_name as f_first,p3.middle_name as f_middle,p3.last_name as f_last
  from trees t, person p, person p2, person p3
  where t.tree_id = p.tree_id
  and p.mother_id = p2.person_id and p.father_id = p3.person_id
  and t.creator = 'jleovao')
union
(select x.person_id,x.first_name,x.middle_name,x.last_name,x.gender,x.date_of_birth,x.alive,
    null as m_first,null as m_middle,null as m_last,
    null as f_first,null as f_middle,null as f_last
  from trees t, person x
  where t.tree_id = x.tree_id
  and x.mother_id is null and x.father_id is null
  and t.creator = 'jleovao')












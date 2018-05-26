1.查询课时为64或48的课程名称和学时；

select Cname,Chour
FROM Courses
WHERE Chour=48 OR Chour=64;


2.	查询没有参加考试的学生学号。

SELECT Student.Sno
FROM Student LEFT OUTER JOIN STC ON (Student.Sno=STC.Sno)
WHERE Score IS NULL

3.向students中插入学号为“200616121”且姓名为你自己本人姓名的记录，其他属性自己设定并输入。（此题必做）

INSERT
INTO Student
VALUES ('200616121','朱彦东','zyd@163.com','2006','男');


1.向STC表中插入（200616121，B001,101，65）和（200616121，B003,103，67）两条选课记录。

INSERT
INTO STC 
VALUES ('200616121','B001','101',65);
INSERT
INTO STC
VALUES {'200616121','B003','103',67};




2.新建表STC_B001，表结构与STC相同（包括sno,tno,cno,score），向该表中插入选修了B001号课程的选课记录。

CREATE TABLE STC_B001(
Sno char(10),
Cno char(8),
Tno char(8),
Score smallint
)
INSERT
INTO STC_B001(sno,cno,tno,score)
SELECT sno,cno,tno,score
FROM STC
WHERE Cno='B001';



3.	将所有工资小于2500元的教师普涨200元。

UPDATE Teachers
SET Salary=Salary+200
WHERE Salary<2500;


4.	将所有女生的选课成绩置空。
UPDATE STC
SET Score=null
where Sno IN(
	SELECT Sno
	FROM Students
	WHERE Ssex='女'
)


5.	删除没有被学生选修的课程信息。

DELETE 
FROM Courses 
WHERE Cno IN(
		SELECT Courses.Cno
		FROM Courses LEFT OUTER JOIN STC ON (Courses.Cno=STC.Cno)
		WHERE Sno IS NULL
)


6.	定义视图v1：给出选课成绩合格的学生学号，所选课程号和该课程的成绩。

CREATE VIEW v1
AS
SELECT Sno,Cno,Score
FROM STC
WHERE Score>=60;


7.	定义视图v2：给出学生学号、所选课程数目和每人的各科平均成绩。

CREATE VIEW v2
AS
SELECT Sno,COUNT(*) 所选课程数目,AVG(Score) 各科平均成绩
FROM STC
GROUP BY Sno



8.	定义视图v3：给出学生学号、姓名、课程名及成绩，必要时进行视图列的改名。

CREATE VIEW v3
AS
SELECT Student.Sno,Sname,Cname,Score
FROM Student,STC,Courses 
WHERE Student.Sno=STC.Sno AND Courses.Cno=STC.Cno


9.	利用视图查询v1：查询所有选修 “C程序设计”课程及格的学生姓名。

SELECT Sname
From v1,Courses,Student
WHERE v1.Sno=Student.Sno AND v1.Cno=Courses.Cno
		AND Cname='C程序设计' AND Score>=60;
		
		
		
10.	定义视图v4，条件与第1题创建视图v1相同，只是增加“WITH CHECK OPTION”子句，然后执行：
（提示：执行前后分别查看操作的视图和相应基本表中的记录）

CREATE VIEW v4
AS
SELECT Sno,Cno,Score
FROM STC
WHERE Score>=60
WITH CHECK OPTION;

(1)	先用视图V4插入（200515123，B003，59）记录，观察执行结果。.
(2)	再用视图V1插入（200515123，B003，59）记录，观察执行结果。
结论:当在创建视图的命令最后加上一句WITH CHECK OPTION之后，所有对这个视图输入的数据都会进行判断，若不满足创建视图时定义的要求则无法输入数据。若创建视图的命令最后没有加上WITH CHECK OPTION，则即使输入的数据不满足创建视图时定义的要求，也能进行输入只是输入之后会直接写入到数据库的对应位置，也就是若输入的数据不满足视图条件，则在刷新之后视图中将不可见。


11.	利用派生表查询并显示每位学生的学号、姓名和平均成绩。

SELECT Student.Sno,Student.Sname,AVERAGE.平均成绩
FROM Student,(
			SELECT Sno,AVG(Score) 平均成绩
			FROM STC
			GROUP BY Sno
) AVERAGE
WHERE Student.Sno=AVERAGE.Sno









*12.定义视图v5，包括每个学生的学号、姓名和已经修得的总学分。
提示：每16个学时为一个学分，即每门课程的学分=学时/16

CREATE VIEW v5
AS
SELECT Student.Sno,Student.Sname,C1.Credit
FROM Student,(
				SELECT Student.Sno,SUM(Chour)/16 Credit
				FROM Student,Courses,STC
				WHERE Student.Sno=STC.Sno AND Courses.Cno=STC.Cno
				GROUP BY Student.Sno
) C1

WHERE Students.Sno=C1.Sno










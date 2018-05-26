CREATE DATABASE S_T202 ON(
	name='S_T202',
	filename='G:\zth5.21\mdf'
)

CREATE TABLE Students(
	Sno char(10) PRIMARY KEY,
	Sname char(8),
	Email char(30),
	Grade smallint
)

1·····

INSERT
INTO Students
VALUES(200515124,'张小天','666@qq.com',2005)

INSERT
INTO Students
VALUES(200515123,'张大天','777@qq.com',2004)

2stc表和course表以CNO建立参照完整性

CREATE TABLE Courses(
	Cno char(8) PRIMARY KEY,
	Cname char(10),
	Chour tinyint
)

CREATE TABLE Teachers(
	Tno char(8) PRIMARY KEY,
	Tname char(8) NOT NULL,
	Email char(30),
	Salary real CHECK(Salary>=1500)
)

CREATE TABLE STC(
	Sno char(10) REFERENCES Students(Sno),
	Cno char(8) REFERENCES Courses(Cno),
	Tno char(8),
	Score smallint,
	PRIMARY KEY(Sno,Cno)
)

插入记录

INSERT
INTO STC
VALUES('200515123','B003','103','60')

INSERT
INTO STC
VALUES('200515123','B011','102','60')

从students表中删除200515121学生的记录

alter table STC
add constraint YD_Sno
foreign key(Sno) references Student(Sno)

select *
from STC
where Sno='200515121' 

select *
from Student
where Sno='200515121' 

DELETE
FROM Students
WHERE Sno='200515121'

设置stc表和students表的参照关系为级联删除；
ALTER TABLE STC
ADD FOREIGN KEY (Sno) REFERENCES Students(Sno)
ON DELETE CASCADE

delete 
from Student
where Sno='200515121'


5.在students表上建立自定义约束U1，其中U1规定GRADE在2004~2007之间。然后插入一条sno为“201115001”，sname为“刘洋”，grade为“2011”的学生信息，观察执行结果并分析原因。

ALTER TABLE Students
	ADD CONSTRAINT U1 CHECK(Grade>=2004 AND Grade<=2007)
	
INSERT
INTO Students(Sno,Sname,Grade)
VALUES('201115001','刘洋','2011')

6.在teacher表上建立触发器T1，当插入或修改表中的数据时，保证所操作的记录Salary>=3000，若不符合要求拒绝插入，并给出相关提示信息；

CREATE TRIGGER T1
ON Teachers
FOR INSERT,UPDATE
AS
if (SELECT Salary FROM inserted) <3000
	BEGIN
		print 'Salary信息不满足条件'
		ROLLBACK
	END
	

7.演示违反T1触发器约束的插入操作：教师标号“008”、教师姓名“张帆”、工资2500；
INSERT
INTO Teachers
VALUES('008','张帆','ldw@tfhbt.edu.cn','2500')


8.演示违反T1触发器约束的更新操作：将教师编号为“104”教师的工资改为2900；

UPDATE Teachers
SET Salary=3200
WHERE Tno=104

9.在teacher表上建立触发器T2，禁止删除编号为103的教师，并给出提示信息；
CREATE TRIGGER T2
ON Teachers
FOR DELETE
AS
if (SELECT Tno FROM deleted)=103
	BEGIN
		ROLLBACK
	END

10.删除编号为103的教师，观察执行结果并解释原因；
DELETE
FROM Teachers
WHERE Tno=103
11.将教师编号为101的姓名改为王华；
UPDATE Teachers
SET Tname='王华'
WHERE Tno=101
12.在teacher表上建立触发器T3，实现更新中教师姓名不可重名，并给出相应提示信息。
CREATE TRIGGER T3
ON Teachers
FOR UPDATE
AS
if (SELECT Tname FROM inserted) IN (SELECT Tname FROM Teachers)
	BEGIN
		print '教师姓名发生重复'
		ROLLBACK
	END
	
	
13.演示违反T3触发器约束的更新操作；将教师编号为101的姓名改为王军。观察执行结果并解释原因。

UPDATE Teachers
SET Tname='王军'
WHERE Tno=101


14.在Courses表上建立一个触发器T4实现课程号的级联修改，即在Courses表中修改一个课程号时，如果stc表中有该课程的选课记录，将stc表中的该课程号也一并修改。

CREATE TRIGGER T4
ON Courses
FOR UPDATE
AS
	BEGIN
		UPDATE STC
		SET Cno=(SELECT Cno FROM inserted)
		WHERE Cno=(SELECT Cno FROM deleted)
	END

ALTER TABLE Teachers
ADD s_num int


15.在teachers表，添加一列s_num（int型），用于记录选修每位老师所任课程的学生总数。建立一个触发器T5，实现在stc表中每增加、删除一条选课记录，相应的teachers表的s_num数据自动修改。

ALTER TABLE Teacher ADD s_num int 


CREATE TRIGGER T5
ON STC
FOR INSERT,DELETE
AS
if (SELECT Sno FROM inserted) IS NOT NULL
	BEGIN
		UPDATE Teacher
		SET s_num=s_num+1
		WHERE Tno=(SELECT Tno FROM inserted)
	END
ELSE
	BEGIN
		UPDATE Teacher
		SET s_num=s_num-1
		WHERE Tno=(SELECT Tno FROM inserted)
	END

ALTER TABLE Students
ADD sum_C int


create trigger T5
on stc
for insert,update,delete
as
if UPDATE(cno)
begin
update teacher
set s_num=(select count(*) from STC group by cno)
end

*16.创建一个学生不及格课程统计表（Fail），包括学号、姓名、课程名、成绩(Sno，Sname、Cname、Score)四个属性；将Students表增加已获得的总学分属性（sum_C），int型。

CREATE TABLE Fail(
	Sno char(10),
	Sname char(8),
	Cname char(10),
	Score smallint
)

CREATE TRIGGER T6
ON STC
FOR INSERT,UPDATE
AS
if (SELECT Score FROM inserted)<60
	BEGIN
		INSERT
		INTO Fail
		VALUES((SELECT Sno FROM inserted),(SELECT Sname FROM Students WHERE Sno=(SELECT Sno FROM inserted)),
			   (SELECT Cname FROM Courses WHERE Cno=(SELECT Cno FROM inserted)),(SELECT Score FROM inserted))
	END
ELSE
	BEGIN
		UPDATE Students
		SET sum_C=(SELECT SUM(Chour)/16
				   FROM STC,Courses
				   WHERE STC.Cno=Courses.Cno AND Score>=60 AND Sno=(SELECT Sno FROM inserted)
				   GROUP BY Sno
		)
		WHERE Sno=(SELECT Sno FROM inserted)
	END
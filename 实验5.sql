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

1����������

INSERT
INTO Students
VALUES(200515124,'��С��','666@qq.com',2005)

INSERT
INTO Students
VALUES(200515123,'�Ŵ���','777@qq.com',2004)

2stc���course����CNO��������������

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

�����¼

INSERT
INTO STC
VALUES('200515123','B003','103','60')

INSERT
INTO STC
VALUES('200515123','B011','102','60')

��students����ɾ��200515121ѧ���ļ�¼

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

����stc���students��Ĳ��չ�ϵΪ����ɾ����
ALTER TABLE STC
ADD FOREIGN KEY (Sno) REFERENCES Students(Sno)
ON DELETE CASCADE

delete 
from Student
where Sno='200515121'


5.��students���Ͻ����Զ���Լ��U1������U1�涨GRADE��2004~2007֮�䡣Ȼ�����һ��snoΪ��201115001����snameΪ�����󡱣�gradeΪ��2011����ѧ����Ϣ���۲�ִ�н��������ԭ��

ALTER TABLE Students
	ADD CONSTRAINT U1 CHECK(Grade>=2004 AND Grade<=2007)
	
INSERT
INTO Students(Sno,Sname,Grade)
VALUES('201115001','����','2011')

6.��teacher���Ͻ���������T1����������޸ı��е�����ʱ����֤�������ļ�¼Salary>=3000����������Ҫ��ܾ����룬�����������ʾ��Ϣ��

CREATE TRIGGER T1
ON Teachers
FOR INSERT,UPDATE
AS
if (SELECT Salary FROM inserted) <3000
	BEGIN
		print 'Salary��Ϣ����������'
		ROLLBACK
	END
	

7.��ʾΥ��T1������Լ���Ĳ����������ʦ��š�008������ʦ�������ŷ���������2500��
INSERT
INTO Teachers
VALUES('008','�ŷ�','ldw@tfhbt.edu.cn','2500')


8.��ʾΥ��T1������Լ���ĸ��²���������ʦ���Ϊ��104����ʦ�Ĺ��ʸ�Ϊ2900��

UPDATE Teachers
SET Salary=3200
WHERE Tno=104

9.��teacher���Ͻ���������T2����ֹɾ�����Ϊ103�Ľ�ʦ����������ʾ��Ϣ��
CREATE TRIGGER T2
ON Teachers
FOR DELETE
AS
if (SELECT Tno FROM deleted)=103
	BEGIN
		ROLLBACK
	END

10.ɾ�����Ϊ103�Ľ�ʦ���۲�ִ�н��������ԭ��
DELETE
FROM Teachers
WHERE Tno=103
11.����ʦ���Ϊ101��������Ϊ������
UPDATE Teachers
SET Tname='����'
WHERE Tno=101
12.��teacher���Ͻ���������T3��ʵ�ָ����н�ʦ����������������������Ӧ��ʾ��Ϣ��
CREATE TRIGGER T3
ON Teachers
FOR UPDATE
AS
if (SELECT Tname FROM inserted) IN (SELECT Tname FROM Teachers)
	BEGIN
		print '��ʦ���������ظ�'
		ROLLBACK
	END
	
	
13.��ʾΥ��T3������Լ���ĸ��²���������ʦ���Ϊ101��������Ϊ�������۲�ִ�н��������ԭ��

UPDATE Teachers
SET Tname='����'
WHERE Tno=101


14.��Courses���Ͻ���һ��������T4ʵ�ֿγ̺ŵļ����޸ģ�����Courses�����޸�һ���γ̺�ʱ�����stc�����иÿγ̵�ѡ�μ�¼����stc���еĸÿγ̺�Ҳһ���޸ġ�

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


15.��teachers�����һ��s_num��int�ͣ������ڼ�¼ѡ��ÿλ��ʦ���ογ̵�ѧ������������һ��������T5��ʵ����stc����ÿ���ӡ�ɾ��һ��ѡ�μ�¼����Ӧ��teachers���s_num�����Զ��޸ġ�

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

*16.����һ��ѧ��������γ�ͳ�Ʊ�Fail��������ѧ�š��������γ������ɼ�(Sno��Sname��Cname��Score)�ĸ����ԣ���Students�������ѻ�õ���ѧ�����ԣ�sum_C����int�͡�

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
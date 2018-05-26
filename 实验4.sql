1.检查SQL Server服务器登录模式是否为混合验证模式，若不是，设置SQL Server验证模式为混合安全认证模式。
说明：设置方法不限，不用抓图

2.在SQL Server中，利用“对象资源管理器”创建一个名为“U1”的登录账号，登录密码为111，并允许其登录S-T数据库，数据库用户名也为U1。


3.在SQL Server中，利用代码创建一个名为“U2”的登录账号，登录密码为111，并允许其登录S-T数据库，映射到S-T数据库的数据库用户名为lucky。

CREATE LOGIN u2 WITH PASSWORD='111'
USE s_t205
CREATE USER lucky FOR LOGIN u2



4.用“U1”账号登录后，执行对students表的查询操作，根据执行结果分析产生该结果的原因（建议：再启动一个SQL Server 2008窗口）。
select *
from student
U1账号没有权限访问Students表。




5.将students表的select和insert操作权限赋予数据库用户U1，并允许U1向其它用户授权。
grant select,insert
on Sutdento
to U1
with grant option




6.以“U1”用户名登录，执行对students和teacher表的查询操作，对该运行结果进行分析。

因为u1账号被授权可以对Students表执行select操作和insert操作，因此在登录u1之后才可以对Students表执行查询操作；但u1账号并没有被赋予查询Teachers表的权限，因此在登录u1之后无法对Teachers表进行查询。

7.执行下列代码后（如下图所示），分析登录账号U2能否对s_t数据库的student表进行select和update操作，为什么？并用相应的语句验证。

能对Students表进行select操作，因为对u2账号授权了两次，但是只收回的一次，因此依旧可以执行select操作；不能对Students表进行update操作，因为deny命令会将同一权限一次性屏蔽。

GRANT SELECT,INSERT,UPDATE
ON Student
TO public
GRANT SELECT,INSERT,UPDATE
ON Student
TO lucky
REVOKE SELECT
ON Student
TO lucky
DENY UPDATE
ON Student
TO lucky

select *
from Student

update Student
set Grade=Grade+1


8.启用sa账号，并以sa登录数据库，在s_t数据库的stc表上创建显示查询选修B001课程的视图st_view。将该视图上的select和列score上的update权限授予U1；
9.以U1登录，对学号为“200415123”成绩提高10分，并查看修改后的结果。

11.创建角色r1，并向r1角色授予teacher表的所有权限

12.将U1添加到r1角色中，在U1的登录窗口查询teacher表；然后将该用户从r1角色中移除，再在U1的登录窗口中查询teacher表；观察并分析结果。


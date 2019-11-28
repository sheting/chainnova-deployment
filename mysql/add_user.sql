
use mysql;

#cabinet：用户名  %：从任何主机都可登录 password：密码
create USER 'cabinet'@'%' IDENTIFIED BY 'password';

#删除用户
#delete from user where user='bdh-v1';
#重新加载授权表
#flush privileges;

#all：database的所有权限  chainnova：database名 cabinet：用户名
grant all on `chainnova`.* to 'cabinet'@'%';
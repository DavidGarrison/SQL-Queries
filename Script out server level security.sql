SELECT @@SERVERNAME
 
--create windows logins
select 'CREATE LOGIN ['+ name +'] FROM WINDOWS WITH DEFAULT_DATABASE=['+default_database_name+'], DEFAULT_LANGUAGE=['+default_language_name+']'
from sys.server_principals
where type in ('U','G')
 
 
--script out SQL logins
--http://support.microsoft.com/kb/918992
 
 
--Server level roles
SELECT DISTINCT
 QUOTENAME(r.name) as server_role_name, r.type_desc, QUOTENAME(m.name) as principal_name, m.type_desc 
, TSQL = 'EXEC master..sp_addsrvrolemember @loginame = N''' + m.name + ''', @rolename = N''' + r.name + ''''
FROM sys.server_role_members AS rm
inner join sys.server_principals r on rm.role_principal_id = r.principal_id
inner join sys.server_principals m on rm.member_principal_id = m.principal_id
where r.is_disabled = 0 and m.is_disabled = 0
and m.name not in ('dbo', 'sa', 'public')
and m.name <> 'NT AUTHORITY\SYSTEM'
 
 
--Server Level Security
SELECT rm.state_desc, rm.permission_name, principal_name = QUOTENAME(u.name),  u.type_desc
,  TSQL = rm.state_desc + N' ' + rm.permission_name + N' TO ' + cast(QUOTENAME(u.name COLLATE DATABASE_DEFAULT) as nvarchar(256))
FROM sys.server_permissions rm
inner join sys.server_principals u 
on rm.grantee_principal_id = u.principal_id
where u.name not like '##%'
and u.name not in ('dbo', 'sa', 'public')
order by rm.permission_name, u.name
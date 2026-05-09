-- создание ролей и пользователей

CREATE ROLE vitalya_admin_role;
CREATE ROLE marssel_admin_role;
CREATE ROLE yrhik_analyst_role;

CREATE USER vitalya_admin_user WITH PASSWORD '60036003';
CREATE USER marssel_admin_user WITH PASSWORD '1212';
CREATE USER yrhik_analyst_user WITH PASSWORD '1234';

GRANT vitalya_admin_role TO vitalya_admin_user;
GRANT marssel_admin_role TO marssel_admin_user;
GRANT yrhik_analyst_role TO yrhik_analyst_user;


-- права администратора 
GRANT CONNECT ON DATABASE "CodeWars" TO vitalya_admin_user;
GRANT CREATE ON DATABASE "CodeWars" TO vitalya_admin_user;
GRANT TEMPORARY ON DATABASE "CodeWars" TO vitalya_admin_user;

GRANT ALL PRIVILEGES ON DATABASE "CodeWars" TO marssel_admin_user;

SELECT datname FROM pg_database 
WHERE datistemplate = false 
ORDER BY datname;

SELECT 
    datname AS база_данных,
    rolname AS роль,
    has_database_privilege(rolname, datname, 'CONNECT') AS может_подключиться,
    has_database_privilege(rolname, datname, 'CREATE') AS может_создавать_схемы,
    has_database_privilege(rolname, datname, 'TEMPORARY') AS может_временные_таблицы
FROM pg_database, pg_roles 
WHERE datname ILIKE 'CodeWars' 
AND rolname = 'vitalya_admin_role';

-- SELECT - читать данные
-- INSERT - добавлять новые записи
-- UPDATE - изменять существующие записи
-- DELETE - удалять записи
-- TRUNCATE - полностью очищать таблицу
-- REFERENCES - создавать внешние ключи
-- TRIGGER - создавать триггеры

-- права на работу с бд
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER 
ON ALL TABLES IN SCHEMA public 
TO vitalya_admin_role;

GRANT SELECT, INSERT, UPDATE 
ON ALL TABLES IN SCHEMA public 
TO marssel_admin_role;

GRANT SELECT 
ON ALL TABLES IN SCHEMA public 
TO yrhik_analyst_role;

-- права на последовательность 

-- USAGE - использовать последовательность
-- SELECT - получать текущее значение

GRANT USAGE, SELECT, UPDATE 
ON ALL SEQUENCES IN SCHEMA public 
TO vitalya_admin_role;

GRANT USAGE, SELECT 
ON ALL SEQUENCES IN SCHEMA public 
TO marssel_admin_role;



-- права на функции и процедуры 
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO vitalya_admin_role;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO vitalya_admin_role;

GRANT EXECUTE ON PROCEDURE change_appeal_status TO marssel_admin_role;

GRANT EXECUTE ON PROCEDURE show_uk_articles TO yrhik_analyst_role;



-- тестирование 

SET ROLE vitalya_admin_role;
SET ROLE marssel_admin_role;
SET ROLE yrhik_analyst_role;

SELECT current_user;

SELECT * FROM citizen LIMIT 1;

INSERT INTO citizen (passport_details, contact_phone, residential_address)
VALUES ('TEST-001', '+7-999-999-99-99', 'Тестовый адрес')
RETURNING id;

UPDATE citizen SET contact_phone = '+7-999-888-88-88' 
WHERE passport_details = 'TEST-001';

DELETE FROM citizen WHERE passport_details = 'TEST-001';



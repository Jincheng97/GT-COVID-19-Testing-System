/*
CS4400: Introduction to Database Systems
Fall 2020
Phase III Template

Team ##
Ziyu Liang (zliang87)
Yingjia Tao (ytao92)
Yixu Yang (yyang847)
Jincheng Zhu (jzhu411)

Directions:
Please follow all instructions from the Phase III assignment PDF.
This file must run without error for credit.
*/


-- ID: 2a
-- Author: lvossler3
-- Name: register_student
DROP PROCEDURE IF EXISTS register_student;
DELIMITER //
CREATE PROCEDURE register_student(
		IN i_username VARCHAR(40),
        IN i_email VARCHAR(40),
        IN i_fname VARCHAR(40),
        IN i_lname VARCHAR(40),
        IN i_location VARCHAR(40),
        IN i_housing_type VARCHAR(20),
        IN i_password VARCHAR(40)
)
BEGIN
-- Type solution below

	INSERT INTO user (username, user_password, email, fname, lname) VALUES (i_username, md5(i_password), i_email, i_fname, i_lname);
	INSERT INTO student (student_username, location, housing_type) VALUES (i_username, i_location, i_housing_type);
-- End of solution
END //
DELIMITER ;

-- ID: 2b
-- Author: lvossler3
-- Name: register_employee
DROP PROCEDURE IF EXISTS register_employee;
DELIMITER //
CREATE PROCEDURE register_employee(
		IN i_username VARCHAR(40),
        IN i_email VARCHAR(40),
        IN i_fname VARCHAR(40),
        IN i_lname VARCHAR(40),
        IN i_phone VARCHAR(10),
        IN i_labtech BOOLEAN,
        IN i_sitetester BOOLEAN,
        IN i_password VARCHAR(40)
)
BEGIN
-- Type solution below

	INSERT INTO user (username, user_password, email, fname, lname) VALUES (i_username, MD5(i_password), i_email, i_fname, i_lname);
	INSERT INTO employee (emp_username, phone_num) VALUES (i_username, i_phone);
	IF i_labtech is TRUE THEN 
		INSERT INTO labtech (labtech_username) VALUES (i_username);
	END IF;
	IF i_sitetester is TRUE THEN 
		INSERT INTO sitetester (sitetester_username) VALUES (i_username);
	END IF;

-- End of solution
END //
DELIMITER ;

-- CALL register_student('lvossler3', 'laurenvossler@gatech.edu', 'Lauren', 'Vossler', 'East', 'Off-campus Apartment',  'iLoVE4400$');
-- CALL register_employee('sstentz3', 'sstentz3@gatech.edu', 'Samuel', 'Stentz', '9703312824', True, True, 'l@urEni$myLIFE2');

-- ID: 4a
-- Author: Aviva Smith
-- Name: student_view_results
DROP PROCEDURE IF EXISTS `student_view_results`;
DELIMITER //
CREATE PROCEDURE `student_view_results`(
    IN i_student_username VARCHAR(50),
	IN i_test_status VARCHAR(50),
	IN i_start_date DATE,
    IN i_end_date DATE
)
BEGIN
	DROP TABLE IF EXISTS student_view_results_result;
    CREATE TABLE student_view_results_result(
        test_id VARCHAR(7),
        timeslot_date date,
        date_processed date,
        pool_status VARCHAR(40),
        test_status VARCHAR(40)
    );
    INSERT INTO student_view_results_result

    -- Type solution below

		SELECT t.test_id, t.appt_date, p.process_date, p.pool_status , t.test_status
        FROM Appointment a
            LEFT JOIN Test t
                ON t.appt_date = a.appt_date
                AND t.appt_time = a.appt_time
                AND t.appt_site = a.site_name
            LEFT JOIN Pool p
                ON t.pool_id = p.pool_id
        WHERE i_student_username = a.username
            AND (i_test_status = t.test_status OR i_test_status IS NULL)
            AND (i_start_date <= t.appt_date OR i_start_date IS NULL)
            AND (i_end_date >= t.appt_date OR i_end_date IS NULL);

    -- End of solution
END //
DELIMITER ;

-- CALL student_view_results('aallman302', 'negative', '2020-09-01', '2020-09-10');

-- ID: 5a
-- Author: asmith457
-- Name: explore_results
DROP PROCEDURE IF EXISTS explore_results;
DELIMITER $$
CREATE PROCEDURE explore_results (
    IN i_test_id VARCHAR(7))
BEGIN
    DROP TABLE IF EXISTS explore_results_result;
    CREATE TABLE explore_results_result(
        test_id VARCHAR(7),
        test_date date,
        timeslot time,
        testing_location VARCHAR(40),
        date_processed date,
        pooled_result VARCHAR(40),
        individual_result VARCHAR(40),
        processed_by VARCHAR(80)
    );
    INSERT INTO explore_results_result

    -- Type solution below
		select test_id, appt_date, appt_time, appt_site, process_date, pool_status, test_status, CONCAT(fname, ' ', lname) AS fullname from
		pool natural join test join user on username=processed_by
        where (test_id=i_test_id or i_test_id='All');

    -- End of solution
END$$
DELIMITER ;

-- CALL explore_results('100017');


-- ID: 6a
-- Author: asmith457
-- Name: aggregate_results
DROP PROCEDURE IF EXISTS aggregate_results;
DELIMITER $$
CREATE PROCEDURE aggregate_results(
    IN i_location VARCHAR(50),
    IN i_housing VARCHAR(50),
    IN i_testing_site VARCHAR(50),
    IN i_start_date DATE,
    IN i_end_date DATE)
BEGIN
    DROP TABLE IF EXISTS aggregate_results_result;
    CREATE TABLE aggregate_results_result(
        test_status VARCHAR(40),
        num_of_test INT,
        percentage DECIMAL(6,2)
    );

    INSERT INTO aggregate_results_result

    -- Type solution below
            select test_status, 
     count(test_status), 100 * count(test_status) / 
     (select count(*) from (TEST join APPOINTMENT on 
             (TEST.appt_site = APPOINTMENT.site_name and 
           TEST.appt_date = APPOINTMENT.appt_date and
           TEST.appt_time = APPOINTMENT.appt_time)) join STUDENT on 
            APPOINTMENT.username = STUDENT.student_username
         where ( ((i_location is null) or (location = i_location)) and
        ((i_housing is null) or (housing_type = i_housing)) and 
        ((i_testing_site is null) or (appt_site = i_testing_site)) and 
        ((i_start_date is null) or (TEST.appt_date >= i_start_date)) and 
        ((i_end_date is null) or (TEST.appt_date <= i_end_date)) ))
    from (TEST join APPOINTMENT on 
           (TEST.appt_site = APPOINTMENT.site_name and 
            TEST.appt_date = APPOINTMENT.appt_date and
            TEST.appt_time = APPOINTMENT.appt_time)) join STUDENT on 
                APPOINTMENT.username = STUDENT.student_username
    where ( ((i_location is null) or (location = i_location)) and
            ((i_housing is null) or (housing_type = i_housing)) and 
            ((i_testing_site is null) or (appt_site = i_testing_site)) and 
            ((i_start_date is null) or (TEST.appt_date >= i_start_date)) and 
            ((i_end_date is null) or (TEST.appt_date <= i_end_date)) )
    group by test_status; 
    
		-- SELECT t.test_status, COUNT(*) as count_group, 100 * COUNT(*) / (SELECT COUNT(*) AS total FROM test) FROM
--         (SELECT * FROM
--         test t LEFT JOIN appointment a ON (t.appt_site = a.site_name AND t.appt_date = a.appt_date AND t.appt_time = a.appt_time)
--         LEFT JOIN student s ON a.username = s.student_username
--         WHERE (s.location = i_location OR i_location IS NULL) 
-- 			AND (s.housing_type = i_housing OR i_housing IS NULL) 
--             AND (t.appt_site = i_testing_site OR i_testing_site IS NULL) 
--             AND (t.appt_date >= i_start_date OR i_start_date IS NULL) 
--             AND (t.appt_date <= i_end_date OR i_end_date IS NULL))
--         GROUP BY t.test_status; 

    -- End of solution
END$$
DELIMITER ;
-- CALL aggregate_results('East', NULL, NULL, NULL, NULL);


-- ID: 7a
-- Author: lvossler3
-- Name: test_sign_up_filter
DROP PROCEDURE IF EXISTS test_sign_up_filter;
DELIMITER //
CREATE PROCEDURE test_sign_up_filter(
    IN i_username VARCHAR(40),
    IN i_testing_site VARCHAR(40),
    IN i_start_date date,
    IN i_end_date date,
    IN i_start_time time,
    IN i_end_time time)
BEGIN
    DROP TABLE IF EXISTS test_sign_up_filter_result;
    CREATE TABLE test_sign_up_filter_result(
        appt_date date,
        appt_time time,
        street VARCHAR (40),
        city VARCHAR(40),
        state VARCHAR(2),
        zip VARCHAR(5),
        site_name VARCHAR(40));
    INSERT INTO test_sign_up_filter_result

    -- Type solution below
SELECT DISTINCT appt_date, appt_time, street, city, state, zip, a.site_name 
        FROM appointment a 
        LEFT JOIN site s 
        ON a.site_name = s.site_name
  WHERE (username IS NULL) 
        AND (a.appt_date >= i_start_date OR i_start_date IS NULL)
  AND (a.appt_date <= i_end_date OR i_end_date IS NULL)
  AND (a.appt_time >= i_start_time OR i_start_time IS NULL)
  AND (a.appt_time <= i_end_time OR i_end_time IS NULL)
  AND (a.site_name = i_testing_site OR i_testing_site IS NULL)
        AND s.location in (select location from student where student_username = i_username);


        -- End of solution

    END //
    DELIMITER ;
-- CALL test_sign_up_filter('gburdell1', 'North Avenue (Centenial Room)', NULL, '2020-10-06', NULL, NULL);

-- ID: 7b
-- Author: lvossler3
-- Name: test_sign_up
DROP PROCEDURE IF EXISTS test_sign_up;
DELIMITER //
CREATE PROCEDURE test_sign_up(
		IN i_username VARCHAR(40),
        IN i_site_name VARCHAR(40),
        IN i_appt_date date,
        IN i_appt_time time,
        IN i_test_id VARCHAR(7)
)
BEGIN
-- Type solution below
	if ((select count(username) from APPOINTMENT where
    APPOINTMENT.username = i_username and APPOINTMENT.site_name = i_site_name 
    and APPOINTMENT.appt_date = i_appt_date and APPOINTMENT.appt_time = i_appt_time) = 0)
    and ('pending' not in (select test_status from TEST, APPOINTMENT where TEST.appt_site = APPOINTMENT.site_name and TEST.appt_date = APPOINTMENT.appt_date and TEST.appt_time = APPOINTMENT.appt_time and APPOINTMENT.username = i_username))
    
    then update APPOINTMENT set username = i_username 
    where APPOINTMENT.username is null and APPOINTMENT.site_name = i_site_name 
    and APPOINTMENT.appt_date = i_appt_date and APPOINTMENT.appt_time = i_appt_time; 

    insert into TEST (test_id, test_status, pool_id, appt_site, appt_date, appt_time) 
    values (i_test_id, 'pending', NULL, i_site_name, i_appt_date, i_appt_time); end if;
-- End of solution
END //
DELIMITER ;

-- CALL test_sign_up('pbuffay56','BobbyDoddStadium','2020-09-16','12:00:00','12345');

-- Number: 8a
-- Author: lvossler3
-- Name: tests_processed
DROP PROCEDURE IF EXISTS tests_processed;
DELIMITER //
CREATE PROCEDURE tests_processed(
    IN i_start_date date,
    IN i_end_date date,
    IN i_test_status VARCHAR(10),
    IN i_lab_tech_username VARCHAR(40))
BEGIN
    DROP TABLE IF EXISTS tests_processed_result;
    CREATE TABLE tests_processed_result(
        test_id VARCHAR(7),
        pool_id VARCHAR(10),
        test_date date,
        process_date date,
        test_status VARCHAR(10) );
    INSERT INTO tests_processed_result
    -- Type solution below

--         SELECT t.test_id, t.pool_id, t.appt_date, p.process_date, t.test_status FROM
--         test t JOIN pool p on t.pool_id = p.pool_id
--         WHERE (t.appt_date >= i_start_date OR i_start_date IS NULL)
--         AND (t.appt_date <= i_end_date OR i_end_date IS NULL)
--         AND (p.pool_status = i_test_status OR i_test_status IS NULL)
--         AND (p.processed_by = i_lab_tech_username OR i_lab_tech_username IS NULL);
        select test_id, t.pool_id, appt_date, process_date, test_status
        from test t natural join pool p
        where (i_start_date <= appt_date OR i_start_date IS NULL)
            and (i_end_date >= appt_date OR i_end_date is null)
            and (i_test_status = test_status or i_test_status is null)
            and (i_lab_tech_username = processed_by or i_lab_tech_username is null);
    -- End of solution
    END //
    DELIMITER ;

-- CALL tests_processed(NULL, '2020-09-07', 'positive', 'ygao10');

-- ID: 9a
-- Author: ahatcher8@
-- Name: view_pools
DROP PROCEDURE IF EXISTS view_pools;
DELIMITER //
CREATE PROCEDURE view_pools(
    IN i_begin_process_date DATE,
    IN i_end_process_date DATE,
    IN i_pool_status VARCHAR(20),
    IN i_processed_by VARCHAR(40)
)
BEGIN
    DROP TABLE IF EXISTS view_pools_result;
    CREATE TABLE view_pools_result(
        pool_id VARCHAR(10),
        test_ids VARCHAR(100),
        date_processed DATE,
        processed_by VARCHAR(40),
        pool_status VARCHAR(20));

    INSERT INTO view_pools_result
-- Type solution below

SELECT a.pool_id, b.test_ids, a.process_date AS date_processed, a.processed_by, a.pool_status
FROM pool a
LEFT JOIN 
(SELECT pool_id, GROUP_CONCAT(test_id) AS test_ids FROM test GROUP BY pool_id) b
ON a.pool_id = b.pool_id
WHERE pool_status = CASE WHEN i_pool_status IS NULL THEN pool_status ELSE i_pool_status END
AND
 ( (i_processed_by IS NOT NULL AND processed_by = i_processed_by AND pool_status != 'pending') OR (i_processed_by IS NULL) )
AND
 (
(i_begin_process_date IS NOT NULL AND i_end_process_date IS NOT NULL AND process_date >= i_begin_process_date AND process_date <= i_end_process_date AND pool_status != 'pending') 
OR 
(i_begin_process_date IS NULL AND i_end_process_date IS NOT NULL AND process_date <= i_end_process_date AND pool_status != 'pending')
OR
(i_begin_process_date IS NOT NULL AND i_end_process_date IS NULL AND (process_date >= i_begin_process_date OR process_date IS NULL))
OR
(i_begin_process_date IS NULL AND i_end_process_date IS NULL)
 );


-- End of solution
END //
DELIMITER ;

-- CALL view_pools('1900-10-10', '2020-12-12', NULL, NULL);

-- ID: 10a
-- Author: ahatcher8@
-- Name: create_pool
DROP PROCEDURE IF EXISTS create_pool;
DELIMITER //
CREATE PROCEDURE create_pool(
	IN i_pool_id VARCHAR(10),
    IN i_test_id VARCHAR(7)
)
BEGIN
-- Type solution below

    
	if (not exists (select * from POOL where pool_id = i_pool_id) )
    and (select count(*) from TEST where TEST.test_id = i_test_id and TEST.pool_id is NULL) = 1
	then insert into POOL (pool_id, pool_status, process_date, processed_by) values (i_pool_id, 'pending', NULL, NULL);
    update TEST set pool_id = i_pool_id where TEST.test_id = i_test_id and TEST.pool_id is NULL; 
    end if;

-- End of solution
END //
DELIMITER ;

-- CALL create_pool('99','100034');


-- ID: 10b
-- Author: ahatcher8@
-- Name: assign_test_to_pool
DROP PROCEDURE IF EXISTS assign_test_to_pool;
DELIMITER //
CREATE PROCEDURE assign_test_to_pool(
    IN i_pool_id VARCHAR(10),
    IN i_test_id VARCHAR(7)
)
BEGIN
-- Type solution below

	if ((select count(pool_id) from POOL where pool_id = i_pool_id) = 1
    and (select count(test_id) from TEST where test_id = i_test_id) = 1
    and (select count(pool_id) from TEST where pool_id = i_pool_id) < 7)
    
	then update TEST set TEST.pool_id = i_pool_id 
    where TEST.pool_id is NULL and TEST.test_id = i_test_id; 
    end if;

-- End of solution
END //
DELIMITER ;

-- CALL assign_test_to_pool('99','100089');

-- ID: 11a
-- Author: ahatcher8@
-- Name: process_pool
DROP PROCEDURE IF EXISTS process_pool;
DELIMITER //
CREATE PROCEDURE process_pool(
    IN i_pool_id VARCHAR(10),
    IN i_pool_status VARCHAR(20),
    IN i_process_date DATE,
    IN i_processed_by VARCHAR(40)
)
BEGIN
-- Type solution below

    SELECT pool_status
    INTO @curr_status
    FROM POOL
    WHERE pool_id = i_pool_id;

    IF
        ((@curr_status = 'pending') AND (i_pool_status = 'positive' OR i_pool_status = 'negative'))
    THEN
        UPDATE POOL
        SET pool_status = i_pool_status, process_date = i_process_date, processed_by = i_processed_by
        WHERE pool_id = i_pool_id;
    END IF;


-- End of solution
END //
DELIMITER ;

-- ID: 11b
-- Author: ahatcher8@
-- Name: process_test
DROP PROCEDURE IF EXISTS process_test;
DELIMITER //
CREATE PROCEDURE process_test(
    IN i_test_id VARCHAR(7),
    IN i_test_status VARCHAR(20)
)
BEGIN
-- Type solution below
 IF EXISTS (SELECT * FROM test WHERE test_id = i_test_id) THEN    
    SELECT DISTINCT pool_status
    FROM pool natural join test
    WHERE test_id = i_test_id
    INTO @parent_pool_status;
    SELECT DISTINCT test_status
    FROM test WHERE test_id = i_test_id
    INTO @test_status;
 IF @test_status = 'pending' AND @parent_pool_status = 'positive'
    THEN
  UPDATE test SET test_status = i_test_status WHERE test_id = i_test_id;
    END IF;
    IF @test_status = 'pending' AND @parent_pool_status = 'negative'
    THEN
  UPDATE test SET test_status = 'negative' WHERE test_id = i_test_id;
    END IF;
    END IF;
-- End of solution
END //
DELIMITER ;


-- CALL process_pool('9', 'positive', '2020-12-14', 'jhilborn98');
-- CALL process_test('100042', 'positive');

-- ID: 12a
-- Author: dvaidyanathan6
-- Name: create_appointment

DROP PROCEDURE IF EXISTS create_appointment;
DELIMITER //
CREATE PROCEDURE create_appointment(
	IN i_site_name VARCHAR(40),
    IN i_date DATE,
    IN i_time TIME
)
BEGIN
-- Type solution below

 IF (NOT EXISTS (SELECT * FROM appointment WHERE (site_name = i_site_name AND appt_date = i_date AND appt_time = i_time))) 
    THEN 
    SELECT COUNT(*) FROM appointment WHERE site_name = i_site_name AND appt_date = i_date INTO @actual_appt_num;
 SELECT COUNT(*) *10 FROM working_at WHERE site = i_site_name INTO @appt_num_limit; 
    IF @actual_appt_num < @appt_num_limit
 THEN 
    INSERT INTO appointment (username, site_name, appt_date, appt_time) VALUES (NULL, i_site_name, i_date, i_time);
    END IF;
    END IF;

-- End of solution
END //
DELIMITER ;

-- CALL create_appointment("Bobby Dodd Stadium", '2020-11-14', '12:00:00');

-- ID: 13a
-- Author: dvaidyanathan6@
-- Name: view_appointments
DROP PROCEDURE IF EXISTS view_appointments;
DELIMITER //
CREATE PROCEDURE view_appointments(
    IN i_site_name VARCHAR(40),
    IN i_begin_appt_date DATE,
    IN i_end_appt_date DATE,
    IN i_begin_appt_time TIME,
    IN i_end_appt_time TIME,
    IN i_is_available INT  -- 0 for "booked only", 1 for "available only", NULL for "all"
)
BEGIN
    DROP TABLE IF EXISTS view_appointments_result;
    CREATE TABLE view_appointments_result(

        appt_date DATE,
        appt_time TIME,
        site_name VARCHAR(40),
        location VARCHAR(40),
        username VARCHAR(40));

    INSERT INTO view_appointments_result
               
 SELECT a.appt_date, a.appt_time, a.site_name, s.location, a.username 
   FROM (appointment a NATURAL JOIN site s)
   LEFT OUTER JOIN test t ON (  a.site_name = t.appt_site AND 
                                         a.appt_date = t.appt_date AND 
                                         a.appt_time = t.appt_time)
   WHERE ((a.site_name = i_site_name OR i_site_name IS NULL)
   AND (a.appt_date >= i_begin_appt_date OR i_begin_appt_date IS NULL) 
   AND (a.appt_date <= i_end_appt_date OR i_end_appt_date IS NULL)
   AND (a.appt_time >= i_begin_appt_time OR i_begin_appt_time IS NULL)
   AND (a.appt_time <= i_end_appt_time OR i_end_appt_time IS NULL)
            AND (((i_is_available = 0) AND (a.username is not NULL)) OR 
                 ((i_is_available = 1) AND (a.username is NULL)) OR
                 (i_is_available IS NULL))
   );

-- End of solution
END //
DELIMITER ;
-- CALL view_appointments('Bobby Dodd Stadium', NULL, NULL, NULL, NULL, NULL);

-- CALL view_appointments(NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL view_appointments('Bobby Dodd Stadium', '2020-07-12', '2020-9-12', '07:00:00', '12:00:00', 0);

-- ID: 14a
-- Author: kachtani3@
-- Name: view_testers
DROP PROCEDURE IF EXISTS view_testers;
DELIMITER //
CREATE PROCEDURE view_testers()
BEGIN
    DROP TABLE IF EXISTS view_testers_result;
    CREATE TABLE view_testers_result(

        username VARCHAR(40),
        name VARCHAR(80),
        phone_number VARCHAR(10),
        assigned_sites VARCHAR(255));

    INSERT INTO view_testers_result
    -- Type solution below
    
    select sitetester_username as username, 
           CONCAT( fname, " ", lname ) AS name, 
           phone_num as phone_number, 
           GROUP_CONCAT(site SEPARATOR ',') AS assigned_sites
    from ((sitetester join employee on sitetester_username = employee.emp_username) 
           join user on employee.emp_username = user.username) 
           left outer join working_at on working_at.username = sitetester_username
 group by sitetester_username;
    
    -- End of solution
END //
DELIMITER ;
-- call view_testers();

-- ID: 15a
-- Author: kachtani3@
-- Name: create_testing_site
DROP PROCEDURE IF EXISTS create_testing_site;
DELIMITER //
CREATE PROCEDURE create_testing_site(
 IN i_site_name VARCHAR(40),
    IN i_street varchar(40),
    IN i_city varchar(40),
    IN i_state char(2),
    IN i_zip char(5),
    IN i_location varchar(40),
    IN i_first_tester_username varchar(40)
)
BEGIN
-- Type solution below
	insert into SITE (site_name, street, city, state, zip, location) 
    values (i_site_name, i_street, i_city, i_state, i_zip, i_location);
    insert into WORKING_AT (username, site) values (i_first_tester_username, i_site_name);

-- End of solution
END //
DELIMITER ;

-- ID: 16a
-- Author: kachtani3@
-- Name: pool_metadata
DROP PROCEDURE IF EXISTS pool_metadata;
DELIMITER //
CREATE PROCEDURE pool_metadata(
    IN i_pool_id VARCHAR(10))
BEGIN
    DROP TABLE IF EXISTS pool_metadata_result;
    CREATE TABLE pool_metadata_result(
        pool_id VARCHAR(10),
        date_processed DATE,
        pooled_result VARCHAR(20),
        processed_by VARCHAR(100));

    INSERT INTO pool_metadata_result
-- Type solution below
    
	SELECT pool_id, process_date, pool_status, CONCAT(fname, ' ', lname) as name
    from pool join user on processed_by = username
    where (pool_id=i_pool_id);
-- End of solution
END //
DELIMITER ;

-- ID: 16b
-- Author: kachtani3@
-- Name: tests_in_pool
DROP PROCEDURE IF EXISTS tests_in_pool;
DELIMITER //
CREATE PROCEDURE tests_in_pool(
    IN i_pool_id VARCHAR(10))
BEGIN
    DROP TABLE IF EXISTS tests_in_pool_result;
    CREATE TABLE tests_in_pool_result(
        test_id varchar(7),
        date_tested DATE,
        testing_site VARCHAR(40),
        test_result VARCHAR(20));

    INSERT INTO tests_in_pool_result
-- Type solution below

    SELECT test_id, appt_date, appt_site, test_status FROM test 
    WHERE pool_id = i_pool_id;
-- End of solution
END //
DELIMITER ;

-- ID: 17a
-- Author: kachtani3@
-- Name: tester_assigned_sites
DROP PROCEDURE IF EXISTS tester_assigned_sites;
DELIMITER //
CREATE PROCEDURE tester_assigned_sites(
    IN i_tester_username VARCHAR(40))
BEGIN
    DROP TABLE IF EXISTS tester_assigned_sites_result;
    CREATE TABLE tester_assigned_sites_result(
        site_name VARCHAR(40));

    INSERT INTO tester_assigned_sites_result
    -- Type solution below
    select site as site_name 
    from WORKING_AT
    where username = i_tester_username;
    -- End of solution
    
END //
DELIMITER ;
-- call tester_assigned_sites('akarev16');


-- ID: 17b
-- Author: kachtani3@
-- Name: assign_tester
DROP PROCEDURE IF EXISTS assign_tester;
DELIMITER //
CREATE PROCEDURE assign_tester(
 IN i_tester_username VARCHAR(40),
    IN i_site_name VARCHAR(40)
)
BEGIN
-- Type solution below
INSERT INTO WORKING_AT VALUES
(i_tester_username, i_site_name);
-- End of solution
END //
DELIMITER ;
-- call assign_tester('akarev16', 'Bobby Dodd Stadium');


-- ID: 17c
-- Author: kachtani3@
-- Name: unassign_tester
DROP PROCEDURE IF EXISTS unassign_tester;
DELIMITER //
CREATE PROCEDURE unassign_tester(
 IN i_tester_username VARCHAR(40),
    IN i_site_name VARCHAR(40)
)
BEGIN
-- Type solution below

IF ((select count(*) from working_at where site = i_site_name) >= 2) THEN 
   DELETE FROM WORKING_AT WHERE username = i_tester_username and site = i_site_name;
END IF;

-- End of solution
END //
DELIMITER ;
-- call unassign_tester('akarev16', 'Bobby Dodd Stadium');


-- ID: 18a
-- Author: lvossler3
-- Name: daily_results
DROP PROCEDURE IF EXISTS daily_results;
DELIMITER //
CREATE PROCEDURE daily_results()
BEGIN
	DROP TABLE IF EXISTS daily_results_result;
    CREATE TABLE daily_results_result(
		process_date date,
        num_tests int,
        pos_tests int,
        pos_percent DECIMAL(6,2));
	INSERT INTO daily_results_result
    -- Type solution below

    select process_date, 
           count(test_id) as num_tests, 
           sum(case when test_status = 'positive' then 1 else 0 end) as pos_tests, 
           100 * sum(case when test_status = 'positive' then 1 else 0 end) / count(test_id) as pos_percent
    from TEST left outer join POOL on TEST.pool_id = POOL.pool_id
    where process_date is not null and test_status != 'pending'
    group by process_date;


    -- End of solution
    END //
    DELIMITER ;
-- call daily_results();














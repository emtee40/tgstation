/*
It is recommended you do not perfom any of these queries while your server is live as they will lock the tables during execution.

Backup your database before starting; Breaking errors may occur when old data is not be compatible with new column formats.
i.e. A field that is null or empty due to rows existing before the column was added, data corruption or incorrect inputs will prevent altering the column to be NOT NULL.
In this event, you can populate the fields with placeholder data using a query such as:
UPDATE `[database]`.`[table]` SET `[column]` = IF(`[column]` IS NULL OR `[column]` = '','[placeholder]',`[column]`)
I have accounted for some fields where this is likely to occur, but cannot cover every possibility, so be careful.

Take note some columns have been renamed, removed or changed type. Any services relying on these columns will have to be updated per changes.

----------------------------------------------------*/

START TRANSACTION;
ALTER TABLE `feedback`.`ban`
 DROP COLUMN `rounds`
, CHANGE COLUMN `bantype` `bantype` ENUM('PERMABAN', 'TEMPBAN', 'JOB_PERMABAN', 'JOB_TEMPBAN', 'ADMIN_PERMABAN', 'ADMIN_TEMPBAN') NOT NULL
, CHANGE COLUMN `reason` `reason` VARCHAR(2048) NOT NULL
, CHANGE COLUMN `who` `who` VARCHAR(2048) NOT NULL
, CHANGE COLUMN `adminwho` `adminwho` VARCHAR(2048) NOT NULL
, CHANGE COLUMN `unbanned` `unbanned` TINYINT UNSIGNED NULL DEFAULT NULL
, ADD COLUMN `server_ip` INT UNSIGNED NOT NULL AFTER `serverip`
, ADD COLUMN `server_port` SMALLINT UNSIGNED NOT NULL AFTER `server_ip`
, ADD COLUMN `ipTEMP` INT UNSIGNED NOT NULL AFTER `ip`
, ADD COLUMN `a_ipTEMP` INT UNSIGNED NOT NULL AFTER `a_ip`
, ADD COLUMN `unbanned_ipTEMP` INT UNSIGNED NULL DEFAULT NULL AFTER `unbanned_ip`;
SET SQL_SAFE_UPDATES = 0;
UPDATE `feedback`.`ban`
 SET `server_ip` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`serverip`, ':', 1)), ''), INET_ATON('0.0.0.0'))
, `server_port` = IF(`serverip` LIKE '%:_%', CAST(SUBSTRING_INDEX(`serverip`, ':', -1) AS UNSIGNED), '0')
, `ipTEMP` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`ip`, ':', 1)), ''), INET_ATON('0.0.0.0'))
, `a_ipTEMP` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`a_ip`, ':', 1)), ''), INET_ATON('0.0.0.0'))
, `unbanned_ipTEMP` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`unbanned_ip`, ':', 1)), ''), INET_ATON('0.0.0.0'));
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `feedback`.`ban`
 DROP COLUMN `unbanned_ip`
, DROP COLUMN `a_ip`
, DROP COLUMN `ip`
, DROP COLUMN `serverip`
, CHANGE COLUMN `ipTEMP` `ip` INT(10) UNSIGNED NOT NULL
, CHANGE COLUMN `a_ipTEMP` `a_ip` INT(10) UNSIGNED NOT NULL
, CHANGE COLUMN `unbanned_ipTEMP` `unbanned_ip` INT(10) UNSIGNED NULL DEFAULT NULL;
COMMIT;

START TRANSACTION;
ALTER TABLE `feedback`.`connection_log`
 ADD COLUMN `server_ip` INT UNSIGNED NOT NULL AFTER `serverip`
, ADD COLUMN `server_port` SMALLINT UNSIGNED NOT NULL AFTER `server_ip`
, ADD COLUMN `ipTEMP` INT UNSIGNED NOT NULL AFTER `ip`;
SET SQL_SAFE_UPDATES = 0;
UPDATE `feedback`.`ban`
 SET `server_ip` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`serverip`, ':', 1)), ''), INET_ATON('0.0.0.0'))
, `server_port` = IF(`serverip` LIKE '%:_%', CAST(SUBSTRING_INDEX(`serverip`, ':', -1) AS UNSIGNED), '0')
, `ipTEMP` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`ip`, ':', 1)), ''), INET_ATON('0.0.0.0'));
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `feedback`.`connection_log`
 DROP COLUMN `ip`
, DROP COLUMN `serverip`
, CHANGE COLUMN `ipTEMP` `ip` INT(10) UNSIGNED NOT NULL;
COMMIT;

START TRANSACTION;
ALTER TABLE `feedback`.`death`
 CHANGE COLUMN `pod` `pod` VARCHAR(50) NOT NULL
, CHANGE COLUMN `coord` `coord` VARCHAR(32) NOT NULL
, CHANGE COLUMN `mapname` `mapname` VARCHAR(32) NOT NULL
, CHANGE COLUMN `job` `job` VARCHAR(32) NOT NULL
, CHANGE COLUMN `special` `special` VARCHAR(32) NULL DEFAULT NULL
, CHANGE COLUMN `name` `name` VARCHAR(32) NOT NULL
, CHANGE COLUMN `byondkey` `byondkey` VARCHAR(32) NOT NULL
, CHANGE COLUMN `laname` `laname` VARCHAR(32) NULL DEFAULT NULL
, CHANGE COLUMN `lakey` `lakey` VARCHAR(32) NULL DEFAULT NULL
, CHANGE COLUMN `gender` `gender` ENUM('neuter', 'male', 'female', 'plural') NOT NULL
, CHANGE COLUMN `bruteloss` `bruteloss` SMALLINT UNSIGNED NOT NULL
, CHANGE COLUMN `brainloss` `brainloss` SMALLINT UNSIGNED NOT NULL
, CHANGE COLUMN `fireloss` `fireloss` SMALLINT UNSIGNED NOT NULL
, CHANGE COLUMN `oxyloss` `oxyloss` SMALLINT UNSIGNED NOT NULL
, ADD COLUMN `server_ip` INT UNSIGNED NOT NULL AFTER `server`
, ADD COLUMN `server_port` SMALLINT UNSIGNED NOT NULL AFTER `server_ip`;
SET SQL_SAFE_UPDATES = 0;
UPDATE `feedback`.`ban`
 SET `server_ip` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`server`, ':', 1)), ''), INET_ATON('0.0.0.0'))
, `server_port` = IF(`server` LIKE '%:_%', CAST(SUBSTRING_INDEX(`server`, ':', -1) AS UNSIGNED), '0');
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `feedback`.`death`
 DROP COLUMN `server`;
COMMIT;

ALTER TABLE `feedback`.`library`
 CHANGE COLUMN `category` `category` ENUM('Any', 'Fiction', 'Non-Fiction', 'Adult', 'Reference', 'Religion') NOT NULL
, CHANGE COLUMN `ckey` `ckey` VARCHAR(32) NOT NULL DEFAULT 'LEGACY'
, CHANGE COLUMN `datetime` `datetime` DATETIME NOT NULL
, CHANGE COLUMN `deleted` `deleted` TINYINT(1) UNSIGNED NULL DEFAULT NULL;

ALTER TABLE `feedback`.`messages`
 CHANGE COLUMN `type` `type` ENUM('memo', 'message', 'message sent', 'note', 'watchlist entry') NOT NULL
, CHANGE COLUMN `text` `text` VARCHAR(2048) NOT NULL
, CHANGE COLUMN `secret` `secret` TINYINT(1) UNSIGNED NOT NULL;

START TRANSACTION;
ALTER TABLE `feedback`.`player`
 ADD COLUMN `ipTEMP` INT UNSIGNED NOT NULL AFTER `ip`;
SET SQL_SAFE_UPDATES = 0;
UPDATE `feedback`.`player`
 SET `ip` = IF(`ip` IS NULL OR `ip` = '','0',`ip`);
UPDATE `feedback`.`player`
 SET `ipTEMP` = INET_ATON(`ip`);
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `feedback`.`player`
 DROP COLUMN `ip`
, CHANGE COLUMN `ipTEMP` `ip` INT(10) UNSIGNED NOT NULL;
COMMIT;

ALTER TABLE `feedback`.`poll_question`
 CHANGE COLUMN `polltype` `polltype` ENUM('OPTION', 'TEXT', 'NUMVAL', 'MULTICHOICE', 'IRV') NOT NULL
, CHANGE COLUMN `adminonly` `adminonly` TINYINT(1) UNSIGNED NOT NULL
, CHANGE COLUMN `createdby_ckey` `createdby_ckey` VARCHAR(32) NULL DEFAULT NULL
, CHANGE COLUMN `createdby_ip` `createdby_ip` VARCHAR(32) NULL DEFAULT NULL
, CHANGE COLUMN `for_trialmin` `for_trialmin` VARCHAR(32) NULL DEFAULT NULL
, CHANGE COLUMN `dontshow` `dontshow` TINYINT(1) UNSIGNED NOT NULL;

START TRANSACTION;
ALTER TABLE `feedback`.`poll_textreply`
 CHANGE COLUMN `replytext` `replytext` VARCHAR(2048) NOT NULL
, ADD COLUMN `ipTEMP` INT UNSIGNED NOT NULL AFTER `ip`;
SET SQL_SAFE_UPDATES = 0;
UPDATE `feedback`.`ban`
 SET `ipTEMP` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`ip`, ':', 1)), ''), INET_ATON('0.0.0.0'));
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `feedback`.`poll_textreply`
 DROP COLUMN `ip`
, CHANGE COLUMN `ipTEMP` `ip` INT(10) UNSIGNED NOT NULL;
COMMIT;

START TRANSACTION;
ALTER TABLE `feedback`.`poll_vote`
 CHANGE COLUMN `ckey` `ckey` VARCHAR(32) NOT NULL
, ADD COLUMN `ipTEMP` INT UNSIGNED NOT NULL AFTER `ip`;
SET SQL_SAFE_UPDATES = 0;
UPDATE `feedback`.`ban`
 SET `ipTEMP` = COALESCE(NULLIF(INET_ATON(SUBSTRING_INDEX(`ip`, ':', 1)), ''), INET_ATON('0.0.0.0'));
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `feedback`.`poll_vote`
 DROP COLUMN `ip`
, CHANGE COLUMN `ipTEMP` `ip` INT(10) UNSIGNED NOT NULL;
COMMIT;

/*----------------------------------------------------

These queries are to be run after the above.
These indexes are designed with only the codebase queries in mind.
You may find it helpful to modify or create your own indexes if you utilise additional queries for other services.

----------------------------------------------------*/

ALTER TABLE `feedback`.`ban`
 ADD INDEX `idx_ban_checkban` (`ckey` ASC, `bantype` ASC, `expiration_time` ASC, `unbanned` ASC, `job` ASC)
, ADD INDEX `idx_ban_isbanned` (`ckey` ASC, `ip` ASC, `computerid` ASC, `bantype` ASC, `expiration_time` ASC, `unbanned` ASC)
, ADD INDEX `idx_ban_count` (`id` ASC, `a_ckey` ASC, `bantype` ASC, `expiration_time` ASC, `unbanned` ASC);

ALTER TABLE `feedback`.`ipintel`
 ADD INDEX `idx_ipintel` (`ip` ASC, `intel` ASC, `date` ASC);

ALTER TABLE `feedback`.`library`
 ADD INDEX `idx_lib_id_del` (`id` ASC, `deleted` ASC)
, ADD INDEX `idx_lib_del_title` (`deleted` ASC, `title` ASC)
, ADD INDEX `idx_lib_search` (`deleted` ASC, `author` ASC, `title` ASC, `category` ASC);

ALTER TABLE `feedback`.`messages`
 ADD INDEX `idx_msg_ckey_time` (`targetckey` ASC, `timestamp` ASC)
, ADD INDEX `idx_msg_type_ckeys_time` (`type` ASC, `targetckey` ASC, `adminckey` ASC, `timestamp` ASC)
, ADD INDEX `idx_msg_type_ckey_time_odr` (`type` ASC, `targetckey` ASC, `timestamp` ASC);

ALTER TABLE `feedback`.`player`
 ADD INDEX `idx_player_cid_ckey` (`computerid` ASC, `ckey` ASC)
, ADD INDEX `idx_player_ip_ckey` (`ip` ASC, `ckey` ASC);

ALTER TABLE `feedback`.`poll_option`
 ADD INDEX `idx_pop_pollid` (`pollid` ASC);

ALTER TABLE `feedback`.`poll_question`
 ADD INDEX `idx_pquest_question_time_ckey` (`question` ASC, `starttime` ASC, `endtime` ASC, `createdby_ckey` ASC, `createdby_ip` ASC)
, ADD INDEX `idx_pquest_time_admin` (`starttime` ASC, `endtime` ASC, `adminonly` ASC)
, ADD INDEX `idx_pquest_id_time_type_admin` (`id` ASC, `starttime` ASC, `endtime` ASC, `polltype` ASC, `adminonly` ASC);

ALTER TABLE `feedback`.`poll_vote`
 ADD INDEX `idx_pvote_pollid_ckey` (`pollid` ASC, `ckey` ASC)
, ADD INDEX `idx_pvote_optionid_ckey` (`optionid` ASC, `ckey` ASC);

ALTER TABLE `feedback`.`poll_textreply`
 ADD INDEX `idx_ptext_pollid_ckey` (`pollid` ASC, `ckey` ASC);
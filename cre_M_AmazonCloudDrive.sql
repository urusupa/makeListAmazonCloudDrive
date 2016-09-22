
DROP TABLE IF EXISTS `M_AmazonCloudDrive`;

CREATE TABLE `M_AmazonCloudDrive` (
  `FILEID` varchar(22) NOT NULL,
  `PATH` varchar(256) NOT NULL,
  `FILENAME` varchar(256) NOT NULL,
  `extension` varchar(4) NOT NULL DEFAULT '000',
  `size` int(15) NOT NULL DEFAULT '0',
  `isShared` int(1) NOT NULL,
  `modifiedDate` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  `createdDate` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  `USE_KBN` int(1) NOT NULL DEFAULT '0',
  `KSN_USER` varchar(32) NOT NULL,
  `RCD_KSN_TIME` varchar(17) NOT NULL,
  `RCD_TRK_TIME` varchar(17) NOT NULL,
  KEY `PATH` (`PATH`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
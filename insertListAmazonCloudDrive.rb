#! ruby -Ku
# encoding: utf-8

###############################################################################
# insertListAmazonCloudDrive.rb
# in:
# out:
# 
###############################################################################


require 'rubygems'
require 'mechanize'
require 'nkf'
require 'fileutils'
require 'date'
require 'common'


###############################################################################
# 関数
###############################################################################



def insertListAmazonCloudDrive()

	csv_path = DATADIR + 'acdcli_tree.csv'
	APPEND_LOGFILE('Readファイル:' + csv_path)
	APPEND_LOGFILE('Read:' + File.read(csv_path).count("\n").to_s + '件')

	connection = Mysql.init()
	connection.options(Mysql::OPT_LOCAL_INFILE, true)
	connection.real_connect(DBHOST, DBUSER, DBPASS , DBSCHEMA)
	connection.charset = "utf8"
	
	result = connection.query("TRUNCATE TABLE M_AmazonCloudDrive;")

	result = connection.query("LOAD DATA LOCAL INFILE '" + csv_path + "' INTO TABLE M_AmazonCloudDrive FIELDS TERMINATED BY '|';")
	result = connection.query("SELECT Count(*) FROM M_AmazonCloudDrive;")
	APPEND_LOGFILE('テーブル件数(M_AmazonCloudDrive):' + result.fetch_row().join.to_s + '件')

	result = connection.query("ALTER TABLE M_AmazonCloudDrive DROP INDEX PATH;")
	result = connection.query("ALTER TABLE M_AmazonCloudDrive ADD INDEX PATH(PATH);")

	#fileidの取得が解決するまでコメントアウト
	#result = connection.query("ALTER TABLE M_AmazonCloudDrive DROP PRIMARY KEY;")
	#result = connection.query("ALTER TABLE M_AmazonCloudDrive ADD PRIMARY KEY (FILEID);")

	connection.close

rescue => ex
	p ex
	APPEND_LOGFILE(ex)
end

insertListAmazonCloudDrive()


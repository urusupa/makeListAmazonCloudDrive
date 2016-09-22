#! ruby -Ku
# encoding: utf-8

###############################################################################
# makeListAmazonCloudDrive.rb
# in:
# out:
# 
###############################################################################


require 'rubygems'
require 'mechanize'
require 'nkf'
require 'fileutils'
require 'date'
require 'json'
require 'rake'
require 'common'


###############################################################################
# 関数
###############################################################################



def makeListAmazonCloudDrive
	@cntLine_r = 0
	@cntLine_w = 0
	
	readfile = TMPDIR + "acdcli_tree.txt"
	writefile = DATADIR + "acdcli_tree.csv"
	APPEND_LOGFILE('Readファイル:' + readfile)
	APPEND_LOGFILE('Writeファイル:' + writefile)
	
	#csv作成
	@filehdl_w = File.open(writefile,"w+")
		
	#acdcli_tree読み込み
	filehdl_r = File.open(readfile)
	filehdl_r.each_line do |line|
		editLine(line)
	end
	
	#csvクローズ
	@filehdl_w.close

rescue => ex
	@filehdl_w.close
	filehdl_r.close
	p ex
ensure
	APPEND_LOGFILE('Read:' + @cntLine_r.to_s + '件')
	APPEND_LOGFILE('Write:' + @cntLine_w.to_s + '件')
end


def editLine(line)
#ファイルIDから最終更新時刻とか取得したい
	delimiter = "|"
	line = line.chomp
	line = line.gsub(/\s{4}/, '□')

	directory = checkDirectory(line)
	filename = line.gsub(/□/, '')

	@cntLine_r += 1
	return if line[line.length-1] == "/" #ディレクトリのみの行は出力しない

=begin
	#行ごとにメタデータの取得をしようと思ったけど、遅すぎる(6時間で8000件ぐらい)
	#対応待ち、https://github.com/yadayada/acd_cli#node-cache-features
	wDirectory = "'" + directory + "'"
	wFilename = "'" + filename + "'"
	metadata = `acdcli metadata #{wDirectory}#{wFilename}`
	metadata = JSON.parse(metadata)
	
	wRec = metadata["id"] + delimiter
	wRec.concat(directory).concat(delimiter)
	wRec.concat(filename).concat(delimiter)
	wRec.concat(metadata["contentProperties"]["extension"]).concat(delimiter)
	wRec.concat(metadata["contentProperties"]["size"].to_s).concat(delimiter)
	wRec.concat(metadata["isShared"] == true ? "1" : "0" ).concat(delimiter)
	wRec.concat(toDatetime(metadata["modifiedDate"])).concat(delimiter)
	wRec.concat(toDatetime(metadata["createdDate"])).concat(delimiter)
	wRec.concat("0").concat(delimiter)
	wRec.concat(DBUSER).concat(delimiter)
	wRec.concat(metadata["modifiedDate"][0..3])
	    .concat(metadata["modifiedDate"][5..6])
	    .concat(metadata["modifiedDate"][8..9])
	    .concat(metadata["modifiedDate"][11..12])
	    .concat(metadata["modifiedDate"][14..15])
	    .concat(metadata["modifiedDate"][17..18])
	    .concat(metadata["modifiedDate"][20..22]).concat(delimiter)
	wRec.concat(TIMESTMP)
=end

	wRec = '0000000000000000000000' .concat(delimiter)
	wRec.concat(directory).concat(delimiter)
	wRec.concat(filename).concat(delimiter)
	wRec.concat(filename.pathmap("%{.,}x")).concat(delimiter)
	wRec.concat('1').concat(delimiter)
	wRec.concat('0').concat(delimiter)
	wRec.concat('1000-01-01 00:00:00.000').concat(delimiter)
	wRec.concat('1000-01-01 00:00:00.000').concat(delimiter)
	wRec.concat("0").concat(delimiter)
	wRec.concat(DBUSER).concat(delimiter)
	wRec.concat(TIMESTMP).concat(delimiter)
	wRec.concat(TIMESTMP)

	@filehdl_w.puts wRec
	@cntLine_w += 1
	
rescue => ex
	p ex
#	APPEND_LOGFILE(ex.class)
end

def toDatetime(metadata_date)
	metadata_date = metadata_date.gsub('T',' ')
	metadata_date = metadata_date.gsub('Z','')

	return metadata_date

rescue => ex
	p ex
end

###############################################################################
# checkDirectory
# in:txtの1行
# out:フォルダの行の場合パスを返す
#     フォルダではない場合そのままlineを返す
###############################################################################
def checkDirectory(line)
	indent = "□"
	@filepath = Array.new if @filepath.nil?
	@indent_num = line.count(indent)
	@indent_num_pre = 0 if @indent_num_pre.nil?
	
	@filepath.push(line) if @indent_num == 0

	
	if @indent_num == @indent_num_pre then
		s = " 同じ"
		line = line.gsub(/□/,'')
		if line[line.length-1] == "/" then
			@filepath.pop
			@filepath.push(line)
			retFilepath =  @filepath.join
		else
			retFilepath =  @filepath.join
		end
		
	elsif @indent_num > @indent_num_pre then
		s = " 深い"
		line = line.gsub(/□/,'')
		if line[line.length-1] == "/" then
			@filepath.push(line)
			retFilepath =  @filepath.join
		else
			retFilepath =  @filepath.join
		end
	elsif @indent_num < @indent_num_pre then
		s = " 浅い"
		line = line.gsub(/□/,'')
		
		if line[line.length-1] == "/" then
			up_num = @indent_num_pre - @indent_num 
			up_num.times{ |e|
				@filepath.pop
			}
			if @preRec[@preRec.length-1] == "/" then #直前が空フォルダのパターン
				@filepath.pop
			end
			@filepath.push(line)
			retFilepath =  @filepath.join
		else
			@filepath.pop
			retFilepath =  @filepath.join
		end
	end

#		puts "前:" + @indent_num_pre.to_s + s + " 今:" + @indent_num.to_s + "|" + @filepath.join
	
	@indent_num_pre = @indent_num
	@preRec = line
	
	return retFilepath
	
rescue => ex
	p ex
end


makeListAmazonCloudDrive()


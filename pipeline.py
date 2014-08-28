import os
from ruffus import *
from ruffus.combinatorics import *
from utils import *

TOKEN = ''
SECRET = ''
CMD_TEMPLATE = 'coffee grabber/grabber.coffee --token={token} --secret={secret} --user={user}'

###
# grab likes for every brother in list
###
@originate(['molefrog.json', 'epshenichnyy.json', 'tikhon_daz.json', '_fly_with_me_.json', 'victor_suzdalev.json'])
def fetch_likes_from_instagram_for_brothers(output_file):
	cmd = CMD_TEMPLATE.format(
		token = TOKEN,
		secret = SECRET,
		user = output_file.split('.')[0]
	)
	
	os.system(cmd)


###
# convert each json with likes to simple tab delimeted file
###
@transform(fetch_likes_from_instagram_for_brothers, suffix(".json"), ".likes")
def convert_to_like_table(input_file, output_file):
	convertJsonToLikesTable(input_file, output_file)


###
# calculate mutual likes for brothers
###
@product(convert_to_like_table,
		formatter("(.likes)$"),
		convert_to_like_table,
		formatter("(.likes)$"),
		"{path[0][0]}/{basename[0][0]}*likes*{basename[1][0]}.stat",
		"{path[0][0]}",
		["{basename[0][0]}", "{basename[1][0]}"])
def calc_mututal_likes(input_file, output_parameter, shared_path, basenames):
	print input_file[0], input_file[1]
	calculateMutualLikes(input_file[0], input_file[1], output_parameter)


###
# make pretty html report for all this stuff
###
@merge(calc_mututal_likes, "statistics.html")
def present(input_file_names, output_file_name):
	calcStatistics(input_file_names, output_file_name)


pipeline_run()
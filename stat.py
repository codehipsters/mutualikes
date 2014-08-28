import json
from pprint import pprint
from string import Template


def generate_sample():
	users = ['molefrog', 'epshenichnyy', 'tikhon_daz', '_fly_with_me_', 'victor_suzdalev']
	peoples_count = len(users)
	data = [[0 for i in xrange(peoples_count)] for j in xrange(peoples_count)]
	generate_template(data, users)
	# names = "mo"


def calculateLikesFrom(likesDict, username):
	for user, likeCount in likesDict.iteritems():
		if user == username:
			return likeCount
	return 0

with open('codehipsters.json') as data_file:    
    data = json.load(data_file)

i = 0
for user in data:
	username = user['username']
	pprint(username)

	userLikes = {}
	
	photos = user['photos']
	for photo in photos:
		likes = photo['likes']
		for like in likes:
			like_by = str(like['username'])
			if like_by in userLikes:
				userLikes[like_by] += 1
			else:
				userLikes[like_by] = 1

	oo = open(username + '.stat', "w")
	for user, likeCount in userLikes.iteritems():
		oo.write(str(user) + ',' + str(likeCount) + '\n')

	# pprint(calculateLikesFrom(userLikes, 'epshenichnyy'))
			# likes[user_who_likes_this] = likes['s'] = 1 if 's' not in a else a['s'] + 1

# generate_sample()

	with open(username + '.json', 'w') as outfile:
  		json.dump(data[i], outfile)
  	i += 1
# pprint(data[0])
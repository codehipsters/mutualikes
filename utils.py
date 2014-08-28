import json
from pprint import pprint
from string import Template
from presentation import generate_template


def calculateLikesFrom(likesDict, username):
	for user, likeCount in likesDict.iteritems():
		if user == username:
			return likeCount
	return 0


def extractFirstName(s):
	res = s.split('*')[0].split('/')[-1]
	return str(res)


def extractSecondName(s):
	res = s.split('*')[2].split('.')[0]
	return str(res)

###############################################################

def convertJsonToLikesTable(jsonPath, likesTablePath):
	with open(jsonPath) as data_file:    
		data = json.load(data_file)

	username = data['username']
	print "Convert json data for " + username + "..."

	userLikes = {}
	
	photos = data['photos']
	for photo in photos:
		likes = photo['likes']
		for like in likes:
			like_by = str(like['username'])
			if like_by in userLikes:
				userLikes[like_by] += 1
			else:
				userLikes[like_by] = 1

	oo = open(likesTablePath, "w")
	for user, likeCount in userLikes.iteritems():
		oo.write(str(user) + ',' + str(likeCount) + '\n')
	oo.close()


def calculateMutualLikes(whoLikes, whomLikes, output):
	whoLikesFile = open(whoLikes)
	whomLikesFile = open(whomLikes)
	outputFile = open(output, "w")

	likes_dict = {}
	for line in whomLikesFile:
		(user, like_count) = line.split(",")
		likes_dict[user] = int(like_count)

	username = whoLikesFile.name.split('.')[0]

	likes = calculateLikesFrom(likes_dict, username)
	outputFile.write(str(likes))

	whoLikesFile.close()
	whomLikesFile.close()
	outputFile.close()



def calcStatistics(likesCountFiles, output):
	usersSet = set()
	
	for f in likesCountFiles:
		usersSet.add(extractFirstName(f))
	
	usersList = list(usersSet)
	peoples_count = len(usersList)
	
	userMapping = {}
	for i in xrange(peoples_count):
		userMapping[usersList[i]] = i

	data = [[0 for i in xrange(peoples_count)] for j in xrange(peoples_count)]
	
	for f in likesCountFiles:
		ii = open(f)
		likes = int(ii.read())
		ii.close()

		whoLikes = extractFirstName(f)
		whomLikes = extractSecondName(f)

		data[userMapping[whoLikes]][userMapping[whomLikes]] = likes
	
	generate_template(data, usersList, output)
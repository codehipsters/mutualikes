Instagram   = require "instagram-node-lib"
_           = require "lodash"
async       = require "async"
fs          = require "fs"
multimeter  = require 'multimeter'

##
# Инста-Токены
##
Instagram.set "client_id",      "1024df6a0d6c44ac98a41c9eca344547"
Instagram.set "client_secret",  "3b7623de07b745f2b9673bab15d3e312"

###
# Братюня, который писал instagram-node-lib, не соблюдал
# соглашение об аргументах асинхронных функций
###
instaRequest = (methodname, options, done) ->
  options = _.extend options,
    complete: -> done null, arguments...
    error: -> done arguments...

  m = methodname.split '.'
  Instagram[m[0]][m[1]](options)

###
# Получает все лайки последних фотографий списка пользователей
###
usersPhotos = (users, cb) ->
  async.mapSeries users, (user, done) ->
    instaRequest 'users.search', { q: user, count: 1 }, (err, users_info) ->
      user_info = users_info[0]
      user_id   = user_info.id

      console.log "Получаем список фоток братюни @#{user_info.username}"

      instaRequest 'users.recent', { user_id }, (err, photos) ->
        done null, _.extend(user_info, { photos })
  , cb

users = [
  'molefrog'
  'epshenichnyy'
  'tikhon_daz'
  '_fly_with_me_'
  'victor_suzdalev'
]

usersPhotos users, (err, users) ->
  total = _.foldl users, ((s, u) -> s + u.photos.length), 0
  idx   = 0

  multi = multimeter(process)
  multi.drop { width: 30 }, (bar) ->

    async.eachSeries users, (user, done) ->
      async.eachSeries user.photos, (photo, done_photo) ->
        media_id = photo.id

        instaRequest 'media.likes', { media_id }, (err, likes) ->
          bar.ratio ++idx, total, "#{likes.length}♡ #{photo.link}"
          photo.likes = likes
          done_photo null
      , (err) ->
        done null
    , (err) ->
      multi.destroy()
      fs.writeFileSync "codehipsters.json", JSON.stringify(users, null, 2)





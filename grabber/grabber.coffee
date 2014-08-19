Instagram   = require "instagram-node-lib"
_           = require "lodash"
async       = require "async"
fs          = require "fs"
multimeter  = require 'multimeter'
yargs       = require 'yargs'

awesomeHeader = """
♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡
♡ Получение списка всех постов со всем лайками из Instagram           ♡
♡ Сделали ребзя из Code Hipsters                                      ♡
♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡
"""

console.log awesomeHeader

argv = yargs
  .usage("Использование: $0")
  # Token
  .demand('t').alias('t', 'token')
  .describe('t', 'Токен приложения Instagram API')
  # Secret
  .demand('s').alias('s', 'secret')
  .describe('s', 'Секретный ключ')
  # User
  .demand('u').alias('u', 'user')
  .describe('u', 'Имя пользователя')
  .argv

###
# Инста-Токены
###
Instagram.set "client_id",     argv.token
Instagram.set "client_secret", argv.secret

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
userPhotos = (user, done) ->
  instaRequest 'users.search', { q: user, count: 1 }, (err, users_info) ->
    user_info = users_info[0]
    user_id   = user_info.id

    console.log "Получаем список фоток братюни @#{user_info.username}"

    instaRequest 'users.recent', { user_id }, (err, photos) ->
      done null, _.extend(user_info, { photos })

userPhotos argv.user, (err, user) ->
  total = user.photos.length
  idx   = 0

  multi = multimeter(process)
  multi.drop { width: 30 }, (bar) ->
    async.eachSeries user.photos, (photo, done) ->
      media_id = photo.id

      instaRequest 'media.likes', { media_id }, (err, likes) ->
        bar.ratio ++idx, total, "#{likes.length}♡ #{photo.link}"
        photo.likes = likes
        done null
    , (err) ->
      multi.destroy()

      outFilename = "#{user.username}.json"
      fs.writeFile outFilename, JSON.stringify(user, null, 2), (err) ->
        console.log "\nГотово, братишка! Записал все дерьмо в #{outFilename}"






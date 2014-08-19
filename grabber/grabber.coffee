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
# Получает фоточки с паджинацией
###
userCatchPhotos = (user, done) ->
  user.photos = []

  lastMaxId = null
  processed = 0
  total     = user.counts.media

  async.doWhilst (done_portion) ->
    options =
      user_id: user.id
      count: 30
    options.max_id = lastMaxId if lastMaxId

    instaRequest 'users.recent', options, (err, photos, pagination) ->
      lastMaxId = pagination.next_max_id

      async.eachSeries photos, (photo, done_photo) ->
        media_id = photo.id

        instaRequest 'media.likes', { media_id }, (err, likes) ->
          console.log "(#{++processed}/#{total}) #{likes.length}♡ #{photo.link} #{photo.caption?.text}"
          user.photos.push _.extend(photo, { likes })
          done_photo null

      , (err, photos) ->
        done_portion null
  , ->
    processed < total
  , ->
    done null, user


###
# Получает все лайки последних фотографий списка пользователей
###
userPhotos = (username, done) ->
  instaRequest 'users.search', { q: username, count: 1 }, (err, users_info) ->
    user_info = users_info[0]
    user_id   = user_info.id

    instaRequest 'users.info', { user_id }, (err, user) ->
      console.log "Братюня @#{user.username} (id: #{user_id}) сделал #{user.counts.media} постов."
      console.log "Красавчик! Ну что, подожди тогда, сейчас все сделаю."

      userCatchPhotos user, done

###
# Rock the joint!
###
userPhotos argv.user, (err, user) ->
  outFilename = "#{user.username}.json"
  fs.writeFile outFilename, JSON.stringify(user, null, 2), (err) ->
    console.log "\nГотово, братишка! Записал все дерьмо в #{outFilename}"





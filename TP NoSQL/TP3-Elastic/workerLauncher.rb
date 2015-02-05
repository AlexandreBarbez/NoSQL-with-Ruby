require 'redis'
require './Worker'

Redis
redis = Redis.new

worker = Worker.new()
worker.ajouterJob('recupGoogle', 'https://www.google.fr')
worker.ajouterJob('recupFacebook', 'https://www.facebook.com')


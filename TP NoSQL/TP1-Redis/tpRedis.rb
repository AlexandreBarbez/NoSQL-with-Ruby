require 'redis'
require 'json'
require 'net/http'


redis = Redis.new

class Job
	attr_reader :nom,:action, :url
	def initialize(actionJob, urlJob)
		@action = actionJob
		@url = urlJob
	end
	def convertToJson
		leJobJson = {'action'=>action, 'url'=>url}.to_json
	end
end

class Worker
	attr_reader :nom

	def initialize(nomWorker, redisBase)
		@nom = nomWorker
		@base = redisBase
	end
	def travailler()
		base = Redis.new
		my_hash = JSON.parse(base.rpop("travail"))
		puts "j'execute l'action " + my_hash["action"] + " sur la page " + my_hash["url"]

		if my_hash["action"] == "extract"
			puts Net::HTTP.get(URI.parse(my_hash["url"]))
		end
	end
end


travail = Job.new("extract","http://google.com")
puts redis.lpush("travail", travail.convertToJson)

josé = Worker.new("josé",redis)
puts josé.travailler




=begin
DONE = on veut creer une job maker, qui va envoyer une url et l'acton a faire dessus
on bveut creer ensuite un worker qui va executer une action donnée sur une page donnée en regardant dans la base
leJob = {'action'=>actionJob, 'url'=>urlJob}.to_json
=end

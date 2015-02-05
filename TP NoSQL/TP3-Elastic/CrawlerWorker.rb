require 'redis'
require 'json'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require './Worker'

class CrawlerWorker < Worker
	def lancerCrawler()
		treatedjob = 0
		while true do
			recupNombreJobenAttente()
			recupNombreDeJobTraités(treatedjob)
			redis = Redis.new
			currentJob = redis.rpop("jobsList")
			if !currentJob.nil?
				treatedjob = treatedjob + 1
				parsedJob = JSON.parse(currentJob)
				currentJobName = parsedJob["jobName"]
				currentjobAction = parsedJob["action"]
				puts "#{currentJobName} en cour d'execution"


				self.recupTitre(currentjobAction)
			end
			sleep 5		
		end
	end

	def recupTitre(url)
		result = Net::HTTP.get_response(URI.parse(url)).body
		puts result
		doc = Nokogiri::HTML(result)
		page = {title:" ", description:" ", keywords:[]}
		doc.xpath('//title').each do |title|
			page[:title] = title.content.split(" ")[0]
			puts "le titre de la page est : #{title.content.split(" ")[0]}"
		end

		doc.xpath("//meta[@name='description']/@content").each do |description|
			if description != ""
				page[:description] = description.content.gsub("'", %q(\\'))
			else
				page[:description] = "Pas de description"
			end
		end
		doc.xpath("//meta[@name='keywords']/@content").each do |keywords|
			if keywords != ""
				keywords = keywords.content.split(",").to_a
				page[:keywords] = keywords
			else
				page[:keywords] = "Pas de mots clé"
			end
		end
		page = page.to_json
		puts page

		`curl -XPOST localhost:9200/web/pages/ -d'#{page}'`
	end

	def recupNombreJobenAttente()
		redis = Redis.new
		waitingJobs = redis.lrange "jobsList", 0, -1
		puts "il y a #{waitingJobs.length} job(s) en attente."
	end

	def recupNombreDeJobTraités(treatedjob)
		puts "#{treatedjob} job(s) traités."
	end
end

# curl -XGET 'http://localhost:9h?q=title:bienvenue' pour tester l'appli
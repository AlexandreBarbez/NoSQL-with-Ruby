require 'redis'
require 'json'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require './Worker'
require 'Mongoid'
require 'Mongo'

class Page
	include Mongoid::Document

	field :title, type: String, Default: ''
	field :url, type: String
	field :keywords, type: Array
	field :description, type: String
end

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
		page = Page.new
		doc.xpath('//title').each do |title|
			page.title = title.content.split(" ")[0]
			puts "The title of this Website is : #{title.content.split(" ")[0]}"
		end

		doc.xpath("//meta[@name='description']/@content").each do |description|
			if !description.nil?
				page.description = description.content
			end
		end
		doc.xpath("//meta[@name='keywords']/@content").each do |keywords|
			if !keywords.nil?
				keywords = keywords.content.split(",").to_a
				page.keywords = keywords
			end
		end
		page.save
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
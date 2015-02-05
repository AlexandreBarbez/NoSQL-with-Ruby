require 'redis'
require 'json'


class Worker
	def stockerJob(serializedJob)
		redis = Redis.new
		redis.lpush("jobsList", serializedJob)
	end

	def formaterJobEnJSON()
		return {'jobName' => @name, 'action' => @action}.to_json
	end

	def ajouterJob(name,action)
		@name = name
		@action = action
		serializedJob = self.formaterJobEnJSON()
		self.stockerJob(serializedJob)
	end
end
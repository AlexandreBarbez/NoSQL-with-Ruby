

c = Mongo::Connection.new
Mongoid.database = c['web']

class Page
	include Mongoid::Document

	field :title, type: String, Default: ''
	field :url, type: String
	field :keywords, type: Array
	field :description, type: String
end
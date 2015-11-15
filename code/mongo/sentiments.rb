require 'json'
require 'mongo'
require 'set'

pos_file = 'positive_words.txt'
neg_file = 'negative_words.txt'
out_file = 'categorization.json'

client = Mongo::Client.new ['127.0.0.1:27017'], :database => 'cs336'

pos_table = Set.new
File.open(pos_file, 'r') do |file|
	pos_table.merge file.each_line
end

neg_table = Set.new
File.open(neg_file, 'r') do |file|
	neg_table.merge file.each_line
end

responses = client[:unlabel_review].find.map do |review|
	sent_count = 0
	split_words = client[:unlabel_review_after_splitting].find(id: review['id']).first
	split_words['review'].each do |word|
		sent_count += word['count'] if pos_table.member? word['word']
		sent_count -= word['count'] if neg_table.member? word['word']
	end
	{
		id: review['id'],
		review: review['review'],
		category: sent_count >= 0 ? 'positive' : 'negative'
	}
end

File.open(out_file, 'w') do |file|
	file.write responses.map(&:to_json).join("\n")
end

require 'set'
require 'rest_client'
require 'json'

class NovelsController < ApplicationController
  def search
   #initialize
    ranked = {}
    found = Set.new
    query_columns = ['title','author','description']
    
    @keywords = params[:q].strip.split(" ")
    @keywords.each do |word|
        concept_url = 'http://conceptnet5.media.mit.edu/data/5.2/assoc/list/en/'+word+'?limit=50&filter=/c/en'
        response = RestClient.get concept_url
        body = JSON.parse response.body
        @terms = body["similar"]
        #do for each similar term found in conceptnet
        @terms.each do |term, score|
            #check match in query columns
            query_columns.each do |query|
                condition = query+" ~* ?"
                word = term.strip.split("/")[3].gsub("_"," ")
                results = Novel.find(:all, :conditions => [condition,".[^a-z]"+word+"[^a-z]."])
                found.merge(results)
                results.each do |novel|
                    if ranked.has_key?(novel.id)
                        ranked[novel.id] += score
                    else
                        ranked[novel.id] = score
                    end
                end
            end
        end
    end
    #create a output array
    @output = []
    sorted = ranked.sort_by {|k,v| -v}
    sorted.each do |id, score|
        line = found.detect {|f| f["id"] == id}
        @output.push([line,score])
    end
  end
  
end

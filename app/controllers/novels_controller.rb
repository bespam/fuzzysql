require 'set'
class NovelsController < ApplicationController
  def search
   #initialize
    ranked = {}
    found = Set.new
    query_columns = ['title','author','description']
    
    @keywords = params[:q].strip.split(" ")
    @keywords.each do |word|
        #check match in query columns
        query_columns.each do |query|
            condition = "lower("+query+") like ? or lower("+query+") like ? or lower("+query+") like ? "
            results = Novel.find(:all, :conditions => [condition,"% "+word.downcase+" %",word.downcase+" %","% "+word.downcase])
            found.merge(results)
            results.each do |novel|
                if ranked.has_key?(novel.id)
                    ranked[novel.id] += 1
                else
                    ranked[novel.id] = 1
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

require 'set'
require 'rest_client'
require 'json'

class NovelsController < ApplicationController
  def search
   #initialize
    ranked = {}
    found = Set.new
    query_columns = ['title','author','description']
    
    if params[:q] != nil
        @search_string = params[:q]
        keywords = @search_string.strip.gsub(","," ").split(" ")
        keywords.each do |word|
            concept_url = 'http://conceptnet5.media.mit.edu/data/5.2/assoc/list/en/'+word+'?limit=100&filter=/c/en'
            response = RestClient.get concept_url
            body = JSON.parse response.body
            terms = body["similar"]
            #terms = [["a/a/a/"+word,1]]
            #do for each similar term found in conceptnet
            terms.each do |term, score|
                word = term.strip.split("/")[3].gsub("_"," ")
                #check match in query columns
                query_columns = ['author','title','description']
                # three types of regular expressions
                regex1 = "'.[^a-z]"+word+"[^a-z].'"
                condition1 = query_columns.join(" ~* "+regex1+" or ")+" ~* "+regex1
                regex2 = "'^"+word+"[^a-z].'"
                condition2 = query_columns.join(" ~* "+regex2+" or ")+" ~* "+regex2
                regex3 = "'.[^a-z]"+word+"$'"
                condition3 = query_columns.join(" ~* "+regex3+" or ")+" ~* "+regex3            
                condition = condition1 + " or " + condition2 + " or " + condition3 
                results = Novel.find(:all, :conditions => condition)
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
        #create a output array
        @output = []
        sorted = ranked.sort_by {|k,v| -v}
        sorted.each do |id, score|
            line = found.detect {|f| f["id"] == id}
            @output.push([line,score])
        end
    end
  end
  
end

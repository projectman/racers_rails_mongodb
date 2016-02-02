class Racer

  include ActiveModel::Model
  
  attr_accessor :number, :first_name, :last_name, :gender, :group, :secs, :id
  
  # initialize from both a Mongo and Web hash
  def initialize(params={})
    #switch between both internal and external views of id and population
    @id=params[:_id].nil? ? params[:id] : params[:_id].to_s
    @number=params[:number].to_i
    @first_name=params[:first_name]
    @last_name=params[:last_name]
    @gender=params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i
  end

  # locate a specific document. Use initialize(hash) on the result to 
  # get in class instance form
  def self.find id

    doc = collection.find(:_id=>BSON::ObjectId(id)).first  

    return doc.nil? ? nil : Racer.new(doc)
  end

  # convenience method for access to client in console
  def self.mongo_client
   Mongoid::Clients.default
  end

  # convenience method for access to zips collection
  def self.collection
   self.mongo_client['racers']
  end

  def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil) # why nil ??? 
    
    Rails.logger.debug {"getting all racers, prototype=#{prototype}, sort=#{sort}, skip=#{skip}, limit=#{limit}"}

    result=collection.find(prototype)
          .sort(sort)
          .skip(skip)

    result=result.limit(limit) if !limit.nil?

    return result
  end
  
  def save
  	# insert the current state of the Racer instance into the database
  	# obtain inserted doc _id from the result and addign the to_s value of )id
    # to instanse attribute @id
  	res = self.class.collection
              .insert_one(_id:@id, number:@number, first_name:@first_name, 
              	last_name:@last_name, gender:@gender, group:@group, secs:@secs)
    @id = res.inserted_id.to_s
    puts @id
    return @id

  end

end
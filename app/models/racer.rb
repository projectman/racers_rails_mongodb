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
  
  # tell Rails whether this instance is persisted
  def persisted?
    !@id.nil?
  end
    def created_at
    nil
  end
  def updated_at
    nil
  end
  
  # This method uses the all() method as its implementation
  # and returns instantiated Racer classes within a will_paginate
  def self.paginate(params)

    page=(params[:page] ||= 1).to_i
    limit=(params[:per_page] ||= 30).to_i
    skip=(page-1)*limit
    sort=params[:sort] ||= {:number => 1}

    #get the associated page of Zips -- eagerly convert doc to Zip
    racers=[]
    all({}, sort, skip, limit).each do |doc|
      racers << Racer.new(doc)
    end

    #get a count of all documents in the collection
    total=all({}, sort, 0, 1).count
    

    WillPaginate::Collection.create(page, limit, total) do |pager|
      pager.replace(racers)
    end    
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
    return @id

  end
  
  # update the values for this instance
  def update(params)
  	 
    racer_col = self.class.collection.find({:_id => BSON::ObjectId(@id.to_s)}).first
    @number=params[:number].to_i 
    @first_name=params[:first_name] 
    @last_name=params[:last_name] 
    @group = params[:group] 
    @gender = params[:gender] 
    @secs = params[:secs].to_i 
    

    params={
    	:number =>@number, :first_name =>@first_name, :last_name =>@last_name, 
    	:gender =>@gender, :group=>@group, :secs=>@secs
    }
    
    result = self.class.collection.update_one({:_id => BSON::ObjectId(@id.to_s)}, '$set' => params)
  
  end
  
  # remove the document associated with this instance form the DB
  def destroy

    self.class.collection
              .find(number: @number)
              .delete_one   
  
  end  


end
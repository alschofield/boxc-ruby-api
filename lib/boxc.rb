require 'httparty'
require 'querystring'

class Boxc
  # base url for all http requests
  @@base_uri = 'https://api.boxc.com/v1'

  # Initializer shortcut for testing
  # I thought it was useful if you
  # already have the access token
  # 
  # @params token {string|number} (optional)
   
  def initialize(token=nil)
    @token = nil
  end

  # Sets access token as class variable
  # essential for all requests
   
  def setAccessToken(token)
    @token = token
    return 'Active Token: '+@token
  end

  # Get authorization URL
  # @link https://api.boxc.com/v1/docs/oauth2#get
  # 
  # @param {String} applicationID
  # @param {String}  returnURI
  # 
  # @returns {String}

  def getAuthorizationUrl(applicationID, returnURI)
    query_string=QueryString.stringify({application_id: applicationID, return_uri: returnURI})
    return @@base_uri+'/oauth/authorize?'+query_string
  end

  # Trying to create access token from nonce
  # @link https://api.boxc.com/v1/docs/oauth2#post
  # 
  # @param {String} applicationID
  # @param {String} applicationSecret
  # @param {String} nonce
  # 
  # @returns {'access_token': {String}}
  # 
  # nonce comes from the system with authorization redirect
   
  def createAccessToken(applicationID, applicationSecret, nonce)
    body={
      "application_id": applicationID,
      "application_secret": applicationSecret,
      "nonce": nonce
    }
    return HTTParty.post(@@base_uri+'/oauth/access_token', :body => body.to_json)
  end

  # Retrieves a list of entry points
  # @link https://api.boxc.com/v1/docs/entry-points#search
  # 
  # @returns {[{address: string, country: string, city: string, id: string}, ... , ...]}
  # 
  # also Retrieves an entry point
  # @link https://api.boxc.com/v1/docs/entry-points#get
  # 
  # @param {String} id
  # 
  # @returns {address: string, country: string, city: string, id: string}
   
  def getEntryPoints(id=false)
    if !id
      return HTTParty.get(@@base_uri+'/entry-points')
    elsif id
      return HTTParty.get(@@base_uri+'/entry-points/'+id)
    end  
  end

  # Estimate
  # @link https://api.boxc.com/v1/docs/estimate#get
  # 
  # @param {{country: string, entry_point: string, height: number, length: number, postal_code: string, weight: number, width: number}} args
  # country        The destined country in ISO 3166-1 alpha-2 format. Only US is accepted. Not required.
  # entry_point    The code for the drop off location. See Entry Points for a list of codes. Not required.
  # height        The height of the shipment in CM. Default is 1.
  # length        The length of the shipment in CM. Default is 15.
  # postal_code    The destined Postal Code or ZIP Code. Required for a more accurate estimate.
  # weight        The weight of the shipment in KG. Maximum: 11.363. Required
  # width        The width of the shipment in CM. Default is 10.
  # 
  # @returns {currency: string, entry_point: string, oversize_fee: string, services: [{service: string, total_cost: string, transit_min: number, transit_max: number}], etc.}
   
  def estimate(args)
    query_string=QueryString.stringify(args)
    return HTTParty.get(
      @@base_uri+'/estimate?'+query_string,
      :headers => {'Authorization' => 'Bearer '+@token}
    )
  end

  # Retrieves a paginated list of invoices
  # @link https://api.boxc.com/v1/docs/invoices#search
  # 
  # @param {Object} args
  # date_end        The inclusive date to end the search in YYYY-MM-DD format. Default is "now".
  # date_start    The inclusive date to begin the search in YYYY-MM-DD format. Default is 1 year ago.
  # limit        The number of results to return. Max: 50. Default: 50.
  # order        The order of the results. Can be "asc" for ascending, or "desc" for descending. Default: desc.
  # page            The page number of the results. Default: 1.
  # 
  # @returns {<Object>}
   
  def getInvoices(args)
    query_string=QueryString.stringify(args)
    return HTTParty.get(@@base_uri+'/invoices?'+query_string, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Retrieves an invoice
  # @link https://api.boxc.com/v1/docs/invoices#get
  # 
  # @param {String} id
  # 
  # @returns {<Object>}

  def getInvoice(id)
    return HTTParty.get(@@base_uri+'/invoice/'+id.to_s, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Retrieves a label
  # @link https://api.boxc.com/v1/docs/labels#get
  # 
  # @param {String|Number} id
  # 
  # @returns {<Object>}
  
  def getLabel(id)
    return HTTParty.get(@@base_uri+'/labels/'+id.to_s, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Create Label
  # @link https://api.boxc.com/v1/docs/labels#create
  # 
  # @param label 
  # 
  # @returns {<Object>}
  
  def createLabel(label)
    return HTTParty.post(@@base_uri+'/labels', :body => {'label': label}.to_json, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Update label
  # @link https://api.boxc.com/v1/docs/labels#update
  # 
  # @param {String} id
  # @param {Object} label
  # 
  # @returns {<Object>}
  
  def updateLabel(id, label)
    return HTTParty.put(@@base_uri+'/labels/'+id.to_s, :body => label.to_json, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Cancels a label
  # @link https://api.boxc.com/v1/docs/labels#cancel
  # 
  # @param {String} id
  # 
  # @returns {<Object>}

  def cancelLabel(id)
    return HTTParty.put(@@base_uri+'/labels/'+id.to_s+'/cancel', :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Create manifest
  # @link https://api.boxc.com/v1/docs/manifests#post
  # 
  # @param {Object} manifest
  # 
  # @returns {<Object>}

  def createManifest(manifest)
    return HTTParty.post(@@base_uri+'/manifests', :body => manifest.to_json, :headers => {'Authorization' => 'Bearer '+@token})
  end

  #  Retrieve manifest
  # @link https://api.boxc.com/v1/docs/manifests#get
  # 
  # @param {string} id
  # 
  # @returns {<Object>}

  def getManifest(id)
    return HTTParty.get(@@base_uri+'/manifests/'+id.to_s, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Get overpacks
  # @link https://api.boxc.com/v1/docs/overpacks#search
  # 
  # @param {Object} args
  # 
  # @returns {<Object>}

  def getOverpacks(args=nil)
    if args == nil
      return HTTParty.get(@@base_uri+'/overpacks', :headers => {'Authorization' => 'Bearer '+@token})
    else
      query_string=QueryString.stringify(args)
      return HTTParty.get(@@base_uri+'/overpacks?'+query_string, :headers => {'Authorization' => 'Bearer '+@token})
    end
  end

  # Retrieves an overpack
  # @link https://api.boxc.com/v1/docs/overpacks#get
  # 
  # @param {String} id
  # 
  # @returns {<Object>}

  def getOverpack(id)
    return HTTParty.get(@@base_uri+'/overpacks/'+id.to_s, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Creates an overpack
  # @link https://api.boxc.com/v1/docs/overpacks#create
  # 
  # @param {Object} overpack
  # 
  # @returns {<Object>}

  def createOverpack(overpack)
    return HTTParty.post(@@base_uri+'/overpacks', :body => overpack.to_json, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Updates an overpack
  # @link https://api.boxc.com/v1/docs/overpacks#update
  # 
  # @param {String} id
  # @param {Object} overpack
  # 
  # @returns {<Object>}

  def updateOverpack(id, overpack)
    return HTTParty.put(@@base_uri+'/overpacks/'+id.to_s, :body => overpack.to_json, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Deletes an overpack
  # @link https://api.boxc.com/v1/docs/overpacks#delete
  # 
  # @param {String} id
  # 
  # @returns {<Object>}

  def deleteOverpack(id)
    return HTTParty.delete(@@base_uri+'/overpacks/'+id.to_s, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Retrieves a paginated list of shipments
  # @link https://api.boxc.com/v1/docs/shipments#search
  # 
  # @param {Object} args
  # 
  # @returns {<Object>}

  def getShipments(args=nil)
    if args == nil
      return HTTParty.get(@@base_uri+'/shipments', :headers => {'Authorization' => 'Bearer '+@token})
    else
      query_string=QueryString.stringify(args)
      return HTTParty.get(@@base_uri+'/shipments?'+query_string, :headers => {'Authorization' => 'Bearer '+@token})
    end
  end

  # Retrieves a shipment
  # @link https://api.boxc.com/v1/docs/shipments#get
  # 
  # @param {String} id
  # 
  # @returns {Promise.<Object>}

  def getShipment(id)
    return HTTParty.get(@@base_uri+'/shipments/'+id.to_s, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Creates a shipment
  # @link https://api.boxc.com/v1/docs/shipments#create
  # 
  # @param {Object} shipment
  # 
  # @returns {<Object>}

  def createShipment(shipment)
    return HTTParty.post(@@base_uri+'/shipments', :body => shipment.to_json, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Updates a shipment
  # @link https://api.boxc.com/v1/docs/shipments#update
  # 
  # @param {String} id
  # @param {Object} shipment
  # 
  # @returns {<Boolean>}

  def updateShipment(id, shipment)
    return HTTParty.put(@@base_uri+'/shipments/'+id.to_s, :body => shipment.to_json, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Deletes a shipment
  # @link https://api.boxc.com/v1/docs/shipments#update
  # 
  # @param {String} id
  # 
  # @returns {<Boolean>}

  def deleteShipment(id)
    return HTTParty.delete(@@base_uri+'/shipments/'+id.to_s, :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Retrieves this user
  # @link https://api.boxc.com/v1/docs/users#get
  # 
  # @returns {<Object>}

  def getUser()
    puts HTTParty.get(@@base_uri+'/users/me', :headers => {'Authorization' => 'Bearer '+@token})
  end

  # Updates this user
  # @link https://api.boxc.com/v1/docs/users#update
  # 
  # @param {Object} user
  # 
  # @returns {<Object>}

  def updateUser(user)
    return HTTParty.put(@@base_uri+'/users/me', :body => user.to_json, :headers => {'Authorization' => 'Bearer '+@token})
  end


  
end
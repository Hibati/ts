def create_channel(thingspeak,userkey,line) 
    location  = get_location()
    
    line  = line.split(" ")
    localmac = get_local_mac()
    name= line[0]
    mac = line[1]
    t = translate_device_name(name)
    if(t['code']==-1)
	return -1
    end
    uri = URI(thingspeak)
    res = Net::HTTP.post_form(uri, 'api_key' => userkey, 'name' => t['name'],
    'description' => name, 'field1' =>name,'field2' =>'field2','field3' =>'field3' ,'field8' => "SN", 'public_flag' =>'true' ,'metadata' => mac ,
    'longitude' => location['lon'] , 'latitude' => location['lat']  , 'tags'  => localmac + "," + location['query'])
    str  = JSON.parse( res.body)
    #puts str['id'] # id
    #puts str['api_keys'][0]['api_key'] # api_key
    channel = Hash.new
    channel['api_key'] = str['api_keys'][0]['api_key']
    channel['id'] = str['id'] 
    channel['name'] = name
    channel['mac'] = mac
    
    
    return channel 
end



def get_location()
    
      
        uri = URI("http://ip-api.com/json/")
        res = Net::HTTP.get_response(uri)
        str = JSON.parse( res.body)
        location = Hash.new
        location['lon']  = str['lon']
        location['lat'] =str['lat']
        location['query']  = str['query']
        return location
end


def get_local_mac
    
    system "cat /sys/class/net/eth0/address > eth0.txt" 
    File.open("eth0.txt", "r") do |f|
        f.each_line do |line|
             return line
        end
    end
    
end


def translate_device_name(name)
    
    t = Hash.new
    name = name.downcase
   
    if name.include? "switch" or name.include? "relay"
        t['name'] = "Switch Actuator"
        t['code'] = 1
        return t
    elsif name.include? "pm"
        t['name'] = "PM Sensor"
        t['code'] = 2
        return t
    elsif name.include? "temp"
        t['name'] = "Temperature Sensor"
        t['code'] = 3
       return t
    elsif name.include? "hum"
        t['name'] = "Temperature Sensor"
        t['code'] = 4
        return t
    elsif name.include? "ir"
        t['name'] = "IR Sensor"
        t['code'] = 5
        return t
    elsif name.include? "reed"
        t['name'] = "Switch Sensor"
        t['code'] = 6
        return t
    elsif name.include? "voc"
        t['name'] = "VOC Sensor"
        t['code'] = 7
        return t
    elsif name.include? "lum"
        t['name'] = "Luminosity Sensor"
        t['code'] = 8
        return t     
    else
	t['name'] = name
      	t['code'] = -1
        return t   
        end
    
end


def update_channel(thingspeak,ch,userkey)
    
    location  = get_location()
    localmac = get_local_mac()   
    uri = URI(thingspeak+"/channels/#{ch}.json" ) 
    http = Net::HTTP.new(uri.host) 
    #http.use_ssl = true 
    req = Net::HTTP::Put.new(uri.path)
    
    req.set_form_data({'api_key'=> userkey ,:tags => localmac + "," + location['query']+","+"BLE"}) 
    http.request(req)  
    
end




def delete_all_channel(thingspeak,userkey)
    
    uri = URI(thingspeak + '/channels.json')
    params = { 'api_key' => userkey}
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)
    #puts res.body
    
    
    str = JSON.parse( res.body)

  
    
    str.each do |s|
        
        id =s['id']
        url = thingspeak + '/channels/'+ id.to_s 
        uri = URI(url) 
        http = Net::HTTP.new(uri.host) 
        #http.use_ssl = true 
        req = Net::HTTP::Delete.new(uri.path) 
        req.set_form_data({'api_key'=> userkey}) 
        res = http.request(req) 
        puts "deleted #{res}" 

    end
   

    
    
end